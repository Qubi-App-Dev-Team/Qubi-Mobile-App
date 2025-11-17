# helpers.py

import json
from typing import Any, Dict, List, Tuple, Optional

import firebase_admin
from firebase_admin import credentials, firestore

# ---- Firestore setup ----

SERVICE_ACCOUNT_PATH = "service_account.json"
CHAPTERS_COLLECTION = "chapters"


def get_db():
    """Return a Firestore client, initializing Firebase app if needed."""
    if not firebase_admin._apps:
        cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
        firebase_admin.initialize_app(cred)
    return firestore.client()


# ---- Database operations ----

def get_chapter_list() -> List[Dict[str, Any]]:
    """
    Return a lightweight list of all chapters:
    [
      { "id": <doc_id>, "title": ..., "number": ..., "diff": ..., "status": ..., "version": ... },
      ...
    ]
    """
    db = get_db()
    collection_ref = db.collection(CHAPTERS_COLLECTION)
    docs = collection_ref.stream()

    chapters = []
    for doc in docs:
        data = doc.to_dict() or {}
        chapters.append(
            {
                "id": doc.id,
                "title": data.get("title", f"Untitled ({doc.id})"),
                "number": data.get("number"),
                "diff": data.get("diff", ""),
                "status": data.get("status", "active"),
                "version": data.get("version", 0),
            }
        )

    # Sort by chapter number if present, else by title
    def sort_key(ch):
        num = ch.get("number")
        return (0, num) if isinstance(num, (int, float)) else (1, ch.get("title", ""))

    chapters.sort(key=sort_key)
    return chapters


def load_chapter(chapter_id: str) -> Optional[Dict[str, Any]]:
    """Load a full chapter document by its Firestore document ID."""
    db = get_db()
    doc_ref = db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc = doc_ref.get()
    if not doc.exists:
        return None
    data = doc.to_dict() or {}
    return ensure_chapter_structure(data)


def save_chapter_to_firestore(chapter_id: Optional[str],
                              chapter_data: Dict[str, Any]) -> str:
    """
    Save a chapter to Firestore.

    Logic:
    - If chapter_id is provided (editor opened from Firestore):
        - Overwrite that document, using its current version as the base and incrementing by 1.
    - If chapter_id is None (e.g. JSON draft or new chapter):
        - If chapter_data contains 'chapter_id':
            - Look up that document:
                - If it exists AND status != 'archived':
                    - Overwrite it and increment its version.
                - If it is archived OR does not exist:
                    - Create a new document.
        - If chapter_data does NOT contain 'chapter_id':
            - Create a new document.
    In all cases:
    - 'chapter_id' is NEVER written into the Firestore document itself.
    Returns the document ID that was written.
    """
    db = get_db()
    collection_ref = db.collection(CHAPTERS_COLLECTION)

    # Work on a copy when writing to Firestore so we don't leak 'chapter_id'
    write_data = dict(chapter_data)
    # Drop metadata fields that must not go into the document
    write_data.pop("chapter_id", None)

    write_data = ensure_chapter_structure(write_data)

    def _write_to_doc(doc_id: str, base_version: int, status: Optional[str] = None) -> str:
        # Increment version based on the stored version, not whatever was in chapter_data
        write_data["version"] = int(base_version) + 1
        if status:
            write_data["status"] = status
        elif not write_data.get("status"):
            write_data["status"] = "active"

        collection_ref.document(doc_id).set(write_data)

        # Also reflect the new version/status back into the in-memory chapter_data
        chapter_data["version"] = write_data["version"]
        chapter_data["status"] = write_data["status"]

        return doc_id

    # --- Case 1: We already know the Firestore document ID (normal Edit flow) ---
    if chapter_id:
        doc_ref = collection_ref.document(chapter_id)
        doc = doc_ref.get()
        if doc.exists:
            existing = doc.to_dict() or {}
            base_version = int(existing.get("version", 0))
            status = existing.get("status", "active")
        else:
            # If somehow the doc doesn't exist, treat as new with the given ID
            base_version = int(write_data.get("version", 0))
            status = write_data.get("status", "active")

        return _write_to_doc(chapter_id, base_version, status=status)

    # --- Case 2: No chapter_id (JSON draft or brand-new chapter) ---
    # Try to reuse chapter_id embedded in JSON, if any
    embedded_id = (chapter_data.get("chapter_id") or "").strip() or None

    if not embedded_id:
        # No embedded id: always create a brand-new document
        base_version = int(write_data.get("version", 0))
        new_doc_ref = collection_ref.document()
        return _write_to_doc(new_doc_ref.id, base_version, status="active")

    # We have an embedded id from JSON. Check Firestore.
    doc_ref = collection_ref.document(embedded_id)
    doc = doc_ref.get()

    if doc.exists:
        existing = doc.to_dict() or {}
        status = existing.get("status", "active")
        base_version = int(existing.get("version", 0))

        if status == "archived":
            # Existing doc is archived -> create a completely new document
            base_version_new = int(write_data.get("version", 0))
            new_doc_ref = collection_ref.document()
            return _write_to_doc(new_doc_ref.id, base_version_new, status="active")
        else:
            # Active doc with same embedded id -> update it
            return _write_to_doc(embedded_id, base_version, status=status)
    else:
        # No doc with that id -> create a new one
        base_version = int(write_data.get("version", 0))
        new_doc_ref = collection_ref.document()
        return _write_to_doc(new_doc_ref.id, base_version, status="active")


def soft_delete_chapter(chapter_id: str) -> None:
    """
    Soft delete (archive) a chapter by setting status = 'archived'.
    Does not physically remove the document.
    """
    db = get_db()
    doc_ref = db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc_ref.update({"status": "archived"})


# ---- JSON draft helpers ----

def export_chapter_to_bytes(
    chapter_data: Dict[str, Any],
    default_name: str = "chapter_draft.json",
    chapter_id: Optional[str] = None,
) -> Tuple[str, bytes]:
    """
    Serialize a single chapter to JSON bytes for download.
    If chapter_id is provided, include it in the JSON under the key 'chapter_id'
    so that later imports can reuse the same Firestore document (when appropriate).

    Returns (filename, bytes).
    """
    # Don't mutate the original object in session_state
    export_obj = dict(chapter_data)

    if chapter_id:
        export_obj["chapter_id"] = chapter_id

    safe_title = export_obj.get("title", "chapter_draft").replace(" ", "_")
    filename = f"{safe_title}.json" if safe_title else default_name
    json_str = json.dumps(export_obj, indent=4, ensure_ascii=False)
    return filename, json_str.encode("utf-8")


def import_chapter_from_json(file_obj) -> Dict[str, Any]:
    """
    Given a file-like object (e.g. from Streamlit file_uploader),
    parse JSON and return a chapter dict with correct structure.

    NOTE: This does minimal validation and then normalizes with ensure_chapter_structure.
    """
    raw = file_obj.read()
    if isinstance(raw, bytes):
        raw = raw.decode("utf-8")
    data = json.loads(raw)
    return ensure_chapter_structure(data)


# ---- Structure normalization helpers ----

def ensure_chapter_structure(chapter: Dict[str, Any]) -> Dict[str, Any]:
    """Ensure required keys and list structures exist with sensible defaults."""
    chapter.setdefault("title", "")
    chapter.setdefault("diff", "")
    chapter.setdefault("number", 0)
    chapter.setdefault("sections", [])
    chapter.setdefault("status", "active")  # active | archived
    chapter.setdefault("version", 0)        # chapter-level version, not shown in UI

    if not isinstance(chapter["sections"], list):
        chapter["sections"] = []

    for section in chapter["sections"]:
        section.setdefault("title", "")
        section.setdefault("description", "")
        # section-level version is intentionally not used
        section.setdefault("pages", [])
        if not isinstance(section["pages"], list):
            section["pages"] = []
        for page in section["pages"]:
            page.setdefault("components", [])
            if not isinstance(page["components"], list):
                page["components"] = []

    return chapter


def new_empty_section() -> Dict[str, Any]:
    return {
        "title": "",
        "description": "",
        "pages": [],
    }


def new_empty_page() -> Dict[str, Any]:
    return {
        "components": []
    }


def new_simple_component(comp_type: str = "Header") -> Dict[str, Any]:
    """
    For simple text/URL-based components: Header, Paragraph, Image.
    Structure: {"type": "<Type>", "content": "<string or URL>"}
    """
    return {
        "type": comp_type,
        "content": ""
    }


def new_prompt_component() -> Dict[str, Any]:
    """
    Provide a minimal default prompt structure:
    type: "Prompt"
    content: ordered list of inner components.
    """
    inner_items = [
        {"type": "Header", "content": "New prompt"},
        {"type": "Paragraph", "content": "Describe your prompt here."},
        {
            "type": "Options",
            "options": ["Option 1", "Option 2"],
            "answer": 0,
            "explanation": "Explanation for the correct answer."
        },
    ]
    return build_prompt_component(inner_items)


# ---- Section & page operations ----

def add_section(chapter: Dict[str, Any]) -> int:
    chapter = ensure_chapter_structure(chapter)
    chapter["sections"].append(new_empty_section())
    return len(chapter["sections"]) - 1


def delete_section(chapter: Dict[str, Any], section_index: int) -> None:
    chapter = ensure_chapter_structure(chapter)
    if 0 <= section_index < len(chapter["sections"]):
        del chapter["sections"][section_index]


def add_page(chapter: Dict[str, Any], section_index: int) -> int:
    chapter = ensure_chapter_structure(chapter)
    if 0 <= section_index < len(chapter["sections"]):
        chapter["sections"][section_index]["pages"].append(new_empty_page())
        return len(chapter["sections"][section_index]["pages"]) - 1
    return -1


def delete_page(chapter: Dict[str, Any], section_index: int, page_index: int) -> None:
    chapter = ensure_chapter_structure(chapter)
    if 0 <= section_index < len(chapter["sections"]):
        pages = chapter["sections"][section_index]["pages"]
        if 0 <= page_index < len(pages):
            del pages[page_index]


def delete_component(chapter: Dict[str, Any], section_index: int,
                     page_index: int, component_index: int) -> None:
    chapter = ensure_chapter_structure(chapter)
    if 0 <= section_index < len(chapter["sections"]):
        pages = chapter["sections"][section_index]["pages"]
        if 0 <= page_index < len(pages):
            comps = pages[page_index]["components"]
            if 0 <= component_index < len(comps):
                del comps[component_index]


# ---- Prompt component helpers ----

def _normalize_type(t: str) -> str:
    return (t or "").strip().lower()


def is_prompt_component(component: Dict[str, Any]) -> bool:
    t = _normalize_type(component.get("type", ""))
    return t == "prompt"


def parse_prompt_component(component: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Parse a Prompt component into an ordered list of inner items for the UI.

    Stored structure:
    {
      "type": "Prompt",
      "content": [
        { "Header": "..." },
        { "Paragraph": "..." },
        { "Image": "https://..." },
        {
          "Options": [...],
          "Answer": <int>,
          "Explanation": "..."
        }
      ]
    }

    UI structure for inner items:
    [
      { "type": "Header", "content": "..." },
      { "type": "Paragraph", "content": "..." },
      { "type": "Image", "content": "..." },
      { "type": "Options", "options": [...], "answer": int, "explanation": "..." },
      ...
    ]
    """
    content = component.get("content", []) or []
    items: List[Dict[str, Any]] = []

    for block in content:
        if not isinstance(block, dict):
            continue
        if "Header" in block:
            items.append({"type": "Header", "content": block.get("Header", "")})
        elif "Paragraph" in block:
            items.append({"type": "Paragraph", "content": block.get("Paragraph", "")})
        elif "Image" in block:
            items.append({"type": "Image", "content": block.get("Image", "")})
        elif "Options" in block:
            items.append(
                {
                    "type": "Options",
                    "options": block.get("Options", []) or [],
                    "answer": block.get("Answer"),
                    "explanation": block.get("Explanation", ""),
                }
            )

    # If there were no recognized blocks, start with one empty header
    if not items:
        items.append({"type": "Header", "content": ""})

    return items


def build_prompt_component(items: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Build a prompt component dict from an ordered list of inner items.

    items is in the UI structure described in parse_prompt_component.

    Output structure:
    {
      "type": "Prompt",
      "content": [
        { "Header": "..." },
        { "Paragraph": "..." },
        { "Image": "https://..." },
        {
          "Options": [...],
          "Answer": <int>,
          "Explanation": "..."
        }
      ]
    }
    """
    content: List[Dict[str, Any]] = []

    for item in items:
        itype = item.get("type")
        if itype in ("Header", "Paragraph", "Image"):
            val = (item.get("content") or "").strip()
            if val:
                content.append({itype: val})
        elif itype == "Options":
            options = item.get("options", []) or []
            answer = item.get("answer")
            explanation = item.get("explanation", "") or ""

            # Only include options block if there's at least one non-empty option or explanation
            has_non_empty_option = any((opt or "").strip() for opt in options)
            if has_non_empty_option or explanation.strip():
                # Ensure answer is a valid index if possible
                if not options:
                    answer_idx = 0
                else:
                    if answer is None or answer < 0 or answer >= len(options):
                        answer_idx = 0
                    else:
                        answer_idx = int(answer)

                content.append(
                    {
                        "Options": options,
                        "Answer": answer_idx,
                        "Explanation": explanation,
                    }
                )

    return {
        "type": "Prompt",
        "content": content,
    }
