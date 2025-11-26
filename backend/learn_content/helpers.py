import json 
import copy
import mimetypes
import os
import uuid
from typing import Any, Dict, List, Optional, Tuple

from dotenv import load_dotenv

import firebase_admin
from firebase_admin import credentials, firestore

from supabase import create_client, Client
from urllib.parse import urlparse

SERVICE_ACCOUNT_PATH = "service_account.json"
CHAPTERS_COLLECTION = "chapters"

# In the future, add other interactive types here (e.g., "Quiz", "Slider", etc.)
INTERACTIVE_PROMPT_ITEM_TYPES = {"Options"}  # currently only Options blocks are interactive

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
SUPABASE_BUCKET = "qubi_images"

supabase: Optional[Client] = None
if SUPABASE_URL and SUPABASE_KEY:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

_db = firestore.client()


def sanitize_chapter_for_storage(chapter: Dict[str, Any]) -> Dict[str, Any]:
    """Remove UI-only fields (uid, chapter_id) from a chapter before saving/exporting."""
    clean = copy.deepcopy(chapter)

    def _strip(obj: Any) -> None:
        if isinstance(obj, dict):
            obj.pop("uid", None)
            obj.pop("chapter_id", None)
            for v in obj.values():
                _strip(v)
        elif isinstance(obj, list):
            for v in obj:
                _strip(v)

    _strip(clean)
    return clean


def get_chapter_list() -> List[Dict[str, Any]]:
    """Return all chapters from Firestore with 'id' field and sorted by 'number'."""
    chapters: List[Dict[str, Any]] = []

    docs = _db.collection(CHAPTERS_COLLECTION).stream()
    for doc in docs:
        data = doc.to_dict() or {}
        data["id"] = doc.id
        chapters.append(data)

    chapters.sort(key=lambda c: c.get("number", 0))
    return chapters


def load_chapter(chapter_id: str) -> Optional[Dict[str, Any]]:
    """Load a chapter by Firestore document id."""
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc = doc_ref.get()
    if not doc.exists:
        return None
    data = doc.to_dict() or {}
    return ensure_chapter_structure(data)


def ensure_chapter_structure(chapter: Dict[str, Any]) -> Dict[str, Any]:
    """Ensure a chapter dict has required keys and normalized lists."""
    chapter = chapter or {}

    chapter.setdefault("title", "")
    chapter.setdefault("diff", "")
    chapter.setdefault("number", 0)
    chapter.setdefault("sections", [])
    chapter.setdefault("status", "active")
    chapter.setdefault("version", 0)

    if not isinstance(chapter["sections"], list):
        chapter["sections"] = []

    for sec in chapter["sections"]:
        sec.setdefault("title", "")
        sec.setdefault("description", "")
        sec.setdefault("version", 0)
        sec.setdefault("pages", [])
        if not isinstance(sec["pages"], list):
            sec["pages"] = []

        for page in sec["pages"]:
            page.setdefault("components", [])
            if not isinstance(page["components"], list):
                page["components"] = []

    return chapter


def add_section(chapter: Dict[str, Any]) -> int:
    """Append a new section to a chapter and return its index."""
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]
    new_section = {
        "title": f"Section {len(sections) + 1}",
        "description": "",
        "version": 0,
        "pages": [],
    }
    sections.append(new_section)
    return len(sections) - 1


def delete_section(chapter: Dict[str, Any], section_index: int) -> None:
    """Delete a section by index and clean up images."""
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]

    if 0 <= section_index < len(sections):
        section = sections[section_index]
        for page in section.get("pages", []):
            for comp in page.get("components", []):
                _cleanup_component_images(comp)
        del sections[section_index]


def add_page(chapter: Dict[str, Any], section_index: int) -> int:
    """Append a new page to a section and return its index."""
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]

    if not (0 <= section_index < len(sections)):
        return -1

    section = sections[section_index]
    pages = section.get("pages", [])
    new_page = {"components": []}
    pages.append(new_page)
    section["pages"] = pages
    return len(pages) - 1


def delete_page(chapter: Dict[str, Any], section_index: int, page_index: int) -> None:
    """Delete a page by index within a section and clean up images."""
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]

    if not (0 <= section_index < len(sections)):
        return

    section = sections[section_index]
    pages = section.get("pages", [])
    if not (0 <= page_index < len(pages)):
        return

    page = pages[page_index]
    for comp in page.get("components", []):
        _cleanup_component_images(comp)

    del pages[page_index]
    section["pages"] = pages


def new_simple_component(component_type: str) -> Dict[str, Any]:
    """Create a new simple component (Header/Paragraph/Image/Video)."""
    return {
        "type": component_type,
        "content": "",
    }


def new_prompt_component() -> Dict[str, Any]:
    """Create a new empty Prompt component."""
    return {
        "type": "Prompt",
        "content": [],
    }


def is_prompt_component(comp: Dict[str, Any]) -> bool:
    """Return True if this component is a Prompt (case-insensitive)."""
    ctype = comp.get("type", "")
    return isinstance(ctype, str) and ctype.lower() == "prompt"


def parse_prompt_component(comp: Dict[str, Any]) -> List[Dict[str, Any]]:
    """Parse a Prompt component into a list of normalized inner items."""
    if not is_prompt_component(comp):
        return []

    result: List[Dict[str, Any]] = []
    content_list = comp.get("content", [])
    if not isinstance(content_list, list):
        return result

    for entry in content_list:
        if not isinstance(entry, dict):
            continue

        if "Header" in entry:
            result.append({
                "type": "Header",
                "content": entry.get("Header", "")
            })
        elif "Paragraph" in entry:
            result.append({
                "type": "Paragraph",
                "content": entry.get("Paragraph", "")
            })
        elif "Image" in entry:
            result.append({
                "type": "Image",
                "content": entry.get("Image", "")
            })
        elif "Video" in entry:
            result.append({
                "type": "Video",
                "content": entry.get("Video", "")
            })
        elif ("options" in entry) or ("Options" in entry):
            options = entry.get("options") or entry.get("Options") or []
            answer = entry.get("answer")
            explanation = entry.get("explanation", "") or ""
            result.append(
                {
                    "type": "Options",
                    "options": options,
                    "answer": answer,
                    "explanation": explanation,
                    # NOTE: id (if present) stays on the raw entry; we
                    # don't need it in the normalized view, so we ignore it here
                }
            )

    return result


def build_prompt_component(items: List[Dict[str, Any]]) -> Dict[str, Any]:
    """Build a Prompt component from normalized inner items."""
    content: List[Dict[str, Any]] = []

    for item in items:
        itype = item.get("type")

        if itype == "Header":
            content.append({"Header": item.get("content", "")})

        elif itype == "Paragraph":
            content.append({"Paragraph": item.get("content", "")})

        elif itype == "Image":
            content.append({"Image": item.get("content", "")})

        elif itype == "Video":
            content.append({"Video": item.get("content", "")})

        elif itype == "Options":
            options = item.get("options", []) or []
            answer = item.get("answer")
            explanation = item.get("explanation", "") or ""
            opt_dict = {
                "options": options,
                "answer": answer,
                "explanation": explanation,
            }
            # NOTE: We intentionally do NOT assign or modify 'id' here;
            # IDs are handled only on publish/save, not during editing.
            content.append(opt_dict)

    return {
        "type": "Prompt",
        "content": content,
    }


def delete_component(
    chapter: Dict[str, Any],
    section_index: int,
    page_index: int,
    component_index: int,
) -> None:
    """Delete a single component from a page and clean up images."""
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]

    if not (0 <= section_index < len(sections)):
        return
    section = sections[section_index]

    pages = section.get("pages", [])
    if not (0 <= page_index < len(pages)):
        return
    page = pages[page_index]

    components = page.get("components", [])
    if not (0 <= component_index < len(components)):
        return

    comp = components[component_index]
    _cleanup_component_images(comp)

    del components[component_index]
    page["components"] = components


def _cleanup_component_images(comp: Dict[str, Any]) -> None:
    """Delete Supabase images referenced by a component (Image or Prompt)."""
    if not comp:
        return

    ctype = comp.get("type", "")
    if isinstance(ctype, str):
        ctype_lower = ctype.lower()
    else:
        ctype_lower = ""

    if ctype_lower == "image":
        delete_image_from_supabase_by_url(comp.get("content"))

    elif ctype_lower == "prompt":
        items = parse_prompt_component(comp)
        for item in items:
            if item.get("type") == "Image":
                delete_image_from_supabase_by_url(item.get("content"))


def import_chapter_from_json(uploaded_file) -> Dict[str, Any]:
    """Import and normalize a chapter from a JSON file-like object."""
    data = json.load(uploaded_file)
    return ensure_chapter_structure(data)


def export_chapter_to_bytes(chapter: Dict[str, Any], chapter_id: Optional[str] = None) -> Tuple[str, bytes]:
    """Export a chapter and optional chapter_id to a JSON bytes payload."""
    clean = sanitize_chapter_for_storage(chapter)

    if chapter_id:
        clean["chapter_id"] = chapter_id

    number = clean.get("number")
    if isinstance(number, (int, float)):
        filename = f"chapter_{int(number)}.json"
    else:
        filename = "chapter.json"

    json_bytes = json.dumps(clean, indent=4, ensure_ascii=False).encode("utf-8")
    return filename, json_bytes

def _generate_interactive_id() -> str:
    """Generate a unique ID for interactive blocks."""
    return uuid.uuid4().hex

def _ensure_interactive_ids(chapter: Dict[str, Any]) -> None:
    """
    Ensure every interactive block has an 'id' field.

    """
    sections = chapter.get("sections", [])
    for section in sections:
        pages = section.get("pages", [])
        for page in pages:
            components = page.get("components", [])
            for comp in components:
                if not is_prompt_component(comp):
                    continue

                content_list = comp.get("content", [])
                if not isinstance(content_list, list):
                    continue

                for entry in content_list:
                    if not isinstance(entry, dict):
                        continue

                    # Options blocks can be keyed by "options" or "Options"
                    if ("options" in entry) or ("Options" in entry):
                        # In the future, if prompt items carry a 'type' field,
                        # we can also check that against INTERACTIVE_PROMPT_ITEM_TYPES.
                        if "id" not in entry:
                            entry["id"] = _generate_interactive_id()


def save_chapter_to_firestore(chapter_id: Optional[str], chapter: Dict[str, Any]) -> str:
    """Save a chapter to Firestore, incrementing version, and return the document id."""
    chapter = ensure_chapter_structure(chapter)

    # Only handle interactive IDs when "publishing" the chapter.
    # Treat 'active' and 'published' statuses as published; skip e.g. 'draft'.
    status = chapter.get("status")
    if isinstance(status, str) and status.lower() == 'active':
        _ensure_interactive_ids(chapter)

    current_version = int(chapter.get("version", 0))
    chapter["version"] = current_version + 1

    clean_data = sanitize_chapter_for_storage(chapter)
    chapters_coll = _db.collection(CHAPTERS_COLLECTION)

    if chapter_id:
        doc_ref = chapters_coll.document(chapter_id)
        doc = doc_ref.get()
        if doc.exists:
            existing = doc.to_dict() or {}
            if existing.get("status") == "archived":
                new_ref = chapters_coll.document()
                new_ref.set(clean_data)
                return new_ref.id
            else:
                doc_ref.set(clean_data, merge=False)
                return chapter_id
        else:
            new_ref = chapters_coll.document()
            new_ref.set(clean_data)
            return new_ref.id
    else:
        new_ref = chapters_coll.document()
        new_ref.set(clean_data)
        return new_ref.id


def soft_delete_chapter(chapter_id: str) -> None:
    """Soft-delete a chapter (mark status='archived')."""
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc_ref.set({"status": "archived"}, merge=True)


def unarchive_chapter(chapter_id: str) -> None:
    """Unarchive a chapter (mark status='active')."""
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc_ref.set({"status": "active"}, merge=True)


def upload_image_to_supabase(uploaded_file, existing_url: Optional[str] = None) -> str:
    """Upload an image to Supabase and optionally delete a previous one."""
    if supabase is None:
        raise RuntimeError("Supabase is not configured. Check SUPABASE_URL and SUPABASE_KEY.")

    file_bytes = uploaded_file.read()
    filename = uploaded_file.name

    mimetype, _ = mimetypes.guess_type(filename)
    if mimetype is None:
        mimetype = "application/octet-stream"

    file_path = filename

    supabase.storage.from_(SUPABASE_BUCKET).upload(
        file_path,
        file_bytes,
        {"content-type": mimetype, "x-upsert": "true"},
    )

    expires_in = 60 * 60 * 24 * 365 * 50
    signed_resp = supabase.storage.from_(SUPABASE_BUCKET).create_signed_url(
        file_path,
        expires_in,
    )

    signed_url = signed_resp['signedURL']
    if existing_url and file_path not in existing_url:
        try:
            delete_image_from_supabase_by_url(existing_url)
        except Exception:
            pass

    return signed_url


def delete_image_from_supabase_by_url(url: Optional[str]) -> None:
    """Delete an image from Supabase using its signed URL."""
    if supabase is None or not url:
        return

    parsed = urlparse(url)
    path = parsed.path

    prefix = "/storage/v1/object/sign/"
    if not path.startswith(prefix):
        return

    bucket_and_path = path[len(prefix):]
    parts = bucket_and_path.split("/", 1)
    if len(parts) != 2:
        return

    bucket_name, file_path = parts[0], parts[1]
    if bucket_name != SUPABASE_BUCKET:
        return

    supabase.storage.from_(SUPABASE_BUCKET).remove([file_path])