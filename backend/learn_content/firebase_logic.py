from typing import Any, Dict, List, Optional

from dotenv import load_dotenv
import firebase_admin
from firebase_admin import credentials, firestore
from google.cloud.firestore_v1 import FieldFilter

from chapter_processing import (
    ensure_chapter_structure,
    sanitize_chapter_for_storage,
)

SERVICE_ACCOUNT_PATH = "service_account.json"
CHAPTERS_COLLECTION = "chapters"

load_dotenv()

if not firebase_admin._apps:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)

_db = firestore.client()


def _generate_interactive_id() -> str:
    """
    Inputs: None.
    Output: Random hex string for interactive block IDs.
    Note: Used only when assigning IDs to Options entries.
    """
    import uuid
    return uuid.uuid4().hex


def _ensure_interactive_ids(chapter: Dict[str, Any]) -> None:
    """
    Inputs: Chapter dict.
    Output: Mutated chapter with 'id' fields on interactive prompt entries.
    Note: Applies only to Options-type entries in Prompt components for active chapters.
    """
    sections = chapter.get("sections", [])
    for section in sections:
        pages = section.get("pages", [])
        for page in pages:
            components = page.get("components", [])
            for comp in components:
                ctype = comp.get("type", "")
                if not isinstance(ctype, str) or ctype.lower() != "prompt":
                    continue

                content_list = comp.get("content", [])
                if not isinstance(content_list, list):
                    continue

                for entry in content_list:
                    if not isinstance(entry, dict):
                        continue
                    if ("options" in entry) or ("Options" in entry):
                        if "id" not in entry:
                            entry["id"] = _generate_interactive_id()


def _set_latest_for_chapter_number(chapter_number: int, latest_doc_id: str) -> None:
    """
    Inputs: Chapter number and Firestore doc id to mark as latest.
    Output: None.
    Note: Sets latest=True only on the chosen doc and False on others for that number.
    """
    chapters_coll = _db.collection(CHAPTERS_COLLECTION)
    docs = chapters_coll.where(
        filter=FieldFilter("number", "==", chapter_number)
    ).stream()
    batch = _db.batch()
    for d in docs:
        is_latest = (d.id == latest_doc_id)
        batch.update(d.reference, {"latest": is_latest})
    batch.commit()


def get_chapter_list() -> List[Dict[str, Any]]:
    """
    Inputs: None.
    Output: List of all chapter-version docs (each with 'id' field).
    Note: Sorted by chapter number ascending.
    """
    chapters: List[Dict[str, Any]] = []

    docs = _db.collection(CHAPTERS_COLLECTION).stream()
    for doc in docs:
        data = doc.to_dict() or {}
        data["id"] = doc.id
        chapters.append(data)

    chapters.sort(key=lambda c: c.get("number", 0))
    return chapters


def load_chapter(chapter_id: str) -> Optional[Dict[str, Any]]:
    """
    Inputs: Firestore document id for a chapter version.
    Output: Normalized chapter dict or None if doc does not exist.
    Note: Used by the editor when loading a specific version by id.
    """
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc = doc_ref.get()
    if not doc.exists:
        return None
    data = doc.to_dict() or {}
    return ensure_chapter_structure(data)


def save_chapter_to_firestore(
    chapter_id: Optional[str],
    chapter: Dict[str, Any],
    create_new_version: bool = False,
) -> str:
    """
    Inputs: Optional doc id, chapter dict, and flag for new version creation.
    Output: Firestore document id of the saved chapter version.
    Note: New versions become latest; updates preserve existing latest flag.
    """
    chapter = ensure_chapter_structure(chapter)

    status = chapter.get("status")
    if isinstance(status, str) and status.lower() == "active":
        _ensure_interactive_ids(chapter)

    chapters_coll = _db.collection(CHAPTERS_COLLECTION)
    chapter_number = int(chapter.get("number", 0))

    existing_doc = None
    existing_data: Dict[str, Any] = {}

    if chapter_id:
        existing_doc = chapters_coll.document(chapter_id).get()
        if existing_doc.exists:
            existing_data = existing_doc.to_dict() or {}

    # Create new version or first version for this chapter number.
    if create_new_version or not chapter_id or not (existing_doc and existing_doc.exists):
        max_version = 0
        docs = chapters_coll.where(
            filter=FieldFilter("number", "==", chapter_number)
        ).stream()
        for d in docs:
            data = d.to_dict() or {}
            v = int(data.get("version", 0))
            if v > max_version:
                max_version = v
        new_version = max_version + 1 if max_version > 0 else 1

        chapter["version"] = new_version
        if "status" not in chapter or not isinstance(chapter["status"], str):
            chapter["status"] = "active"
        chapter["latest"] = True

        clean_data = sanitize_chapter_for_storage(chapter)
        new_ref = chapters_coll.document()
        new_ref.set(clean_data)

        _set_latest_for_chapter_number(chapter_number, new_ref.id)
        return new_ref.id

    # Overwrite existing version only, preserving its latest/non-latest status.
    stored_version = int(existing_data.get("version", chapter.get("version", 1)))
    chapter["version"] = stored_version
    chapter["latest"] = existing_data.get("latest", chapter.get("latest", False))

    clean_data = sanitize_chapter_for_storage(chapter)
    doc_ref = chapters_coll.document(chapter_id)
    doc_ref.set(clean_data, merge=False)

    return chapter_id


def soft_delete_chapter(chapter_id: str) -> None:
    """
    Inputs: Firestore document id.
    Output: None.
    Note: Marks a specific chapter-version as archived (status='archived').
    """
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc_ref.set({"status": "archived"}, merge=True)


def unarchive_chapter(chapter_id: str) -> None:
    """
    Inputs: Firestore document id.
    Output: None.
    Note: Marks a specific chapter-version as active (status='active').
    """
    doc_ref = _db.collection(CHAPTERS_COLLECTION).document(chapter_id)
    doc_ref.set({"status": "active"}, merge=True)


def swap_chapter_numbers(number_a: int, number_b: int) -> None:
    """
    Inputs: Two chapter numbers to swap.
    Output: None.
    Note: Updates 'number' for all versions in each chapter group.
    """
    if number_a == number_b:
        return

    chapters_coll = _db.collection(CHAPTERS_COLLECTION)
    docs_a = list(
        chapters_coll.where(filter=FieldFilter("number", "==", number_a)).stream()
    )
    docs_b = list(
        chapters_coll.where(filter=FieldFilter("number", "==", number_b)).stream()
    )

    if not docs_a and not docs_b:
        return

    batch = _db.batch()
    temp_number = -999_999_999

    for d in docs_a:
        batch.update(d.reference, {"number": temp_number})

    for d in docs_b:
        batch.update(d.reference, {"number": number_a})

    for d in docs_a:
        batch.update(d.reference, {"number": number_b})

    batch.commit()