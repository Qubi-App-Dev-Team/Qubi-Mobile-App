import json
import copy
from typing import Any, Dict, List, Optional, Tuple

from storage_utils import delete_image_from_supabase_by_url


def sanitize_chapter_for_storage(chapter: Dict[str, Any]) -> Dict[str, Any]:
    """
    Inputs: Full chapter dict (may contain UI-only fields).
    Output: New chapter dict with UI-only fields removed.
    Note: Strips 'uid' and 'chapter_id' recursively.
    """
    clean = copy.deepcopy(chapter)

    def _strip(obj: Any) -> None:
        """
        Inputs: Any nested object within chapter.
        Output: Mutates obj in-place by removing UI keys.
        Note: Internal helper for sanitize_chapter_for_storage.
        """
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


def ensure_chapter_structure(chapter: Dict[str, Any]) -> Dict[str, Any]:
    """
    Inputs: Possibly partial chapter dict.
    Output: Chapter dict with required keys and normalized lists.
    Note: Sets defaults for title, diff, number, sections, status, version, latest.
    """
    chapter = chapter or {}

    chapter.setdefault("title", "")
    chapter.setdefault("diff", "")
    chapter.setdefault("number", 0)
    chapter.setdefault("sections", [])
    chapter.setdefault("status", "active")
    chapter.setdefault("version", 0)
    chapter.setdefault("latest", False)

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
    """
    Inputs: Chapter dict to append a section into.
    Output: Index of the newly added section.
    Note: Section gets a default title and empty pages list.
    """
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


def _cleanup_component_images(comp: Dict[str, Any]) -> None:
    """
    Inputs: Component dict that may reference images.
    Output: None (may delete Supabase images referenced by this component).
    Note: Handles both Image components and Prompt components with inner images.
    """
    if not comp:
        return

    ctype = comp.get("type", "")
    ctype_lower = ctype.lower() if isinstance(ctype, str) else ""

    if ctype_lower == "image":
        delete_image_from_supabase_by_url(comp.get("content"))

    elif ctype_lower == "prompt":
        items = parse_prompt_component(comp)
        for item in items:
            if item.get("type") == "Image":
                delete_image_from_supabase_by_url(item.get("content"))


def delete_section(chapter: Dict[str, Any], section_index: int) -> None:
    """
    Inputs: Chapter dict and index of section to delete.
    Output: None (mutates chapter in-place).
    Note: Cleans up any Supabase images referenced in the deleted section.
    """
    chapter = ensure_chapter_structure(chapter)
    sections = chapter["sections"]

    if 0 <= section_index < len(sections):
        section = sections[section_index]
        for page in section.get("pages", []):
            for comp in page.get("components", []):
                _cleanup_component_images(comp)
        del sections[section_index]


def add_page(chapter: Dict[str, Any], section_index: int) -> int:
    """
    Inputs: Chapter dict and section index.
    Output: Index of newly added page, or -1 on invalid section index.
    Note: Page is created with an empty components list.
    """
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
    """
    Inputs: Chapter dict, section index, and page index to delete.
    Output: None (mutates chapter in-place).
    Note: Cleans up any Supabase images referenced in the deleted page.
    """
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
    """
    Inputs: Component type string ('Header', 'Paragraph', 'Image', 'Video').
    Output: New component dict with default content field.
    Note: Used for top-level non-prompt components.
    """
    return {
        "type": component_type,
        "content": "",
    }


def new_prompt_component() -> Dict[str, Any]:
    """
    Inputs: None.
    Output: New empty Prompt component dict.
    Note: Content list will hold nested items (Headers, Paragraphs, etc).
    """
    return {
        "type": "Prompt",
        "content": [],
    }


def is_prompt_component(comp: Dict[str, Any]) -> bool:
    """
    Inputs: Component dict.
    Output: True if this is a Prompt component, else False.
    Note: Comparison is case-insensitive on the 'type' field.
    """
    ctype = comp.get("type", "")
    return isinstance(ctype, str) and ctype.lower() == "prompt"


def parse_prompt_component(comp: Dict[str, Any]) -> List[Dict[str, Any]]:
    """
    Inputs: Prompt component dict.
    Output: List of normalized inner items with explicit 'type' fields.
    Note: Supports Header, Paragraph, Image, Video, and Options items.
    """
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
            result.append({"type": "Header", "content": entry.get("Header", "")})
        elif "Paragraph" in entry:
            result.append({"type": "Paragraph", "content": entry.get("Paragraph", "")})
        elif "Image" in entry:
            result.append({"type": "Image", "content": entry.get("Image", "")})
        elif "Video" in entry:
            result.append({"type": "Video", "content": entry.get("Video", "")})
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
                }
            )

    return result


def build_prompt_component(items: List[Dict[str, Any]]) -> Dict[str, Any]:
    """
    Inputs: List of normalized prompt items with 'type' keys.
    Output: Prompt component dict with legacy content encoding.
    Note: Does not set or modify any 'id' fields on inner items.
    """
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
    """
    Inputs: Chapter dict and indexes of section/page/component to delete.
    Output: None (mutates chapter in-place).
    Note: Cleans up any Supabase images referenced by the deleted component.
    """
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


def import_chapter_from_json(uploaded_file) -> Dict[str, Any]:
    """
    Inputs: File-like object for uploaded JSON.
    Output: Normalized chapter dict.
    Note: Expects JSON to contain a chapter structure (optionally with chapter_id).
    """
    data = json.load(uploaded_file)
    return ensure_chapter_structure(data)


def export_chapter_to_bytes(
    chapter: Dict[str, Any],
    chapter_id: Optional[str] = None,
) -> Tuple[str, bytes]:
    """
    Inputs: Chapter dict and optional Firestore chapter_id.
    Output: Filename and UTF-8 JSON bytes for download.
    Note: Includes chapter_id in JSON payload if provided.
    """
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