import mimetypes
import os
import uuid
from typing import Optional, List

from dotenv import load_dotenv
from supabase import create_client, Client
from urllib.parse import urlparse

load_dotenv()

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")
SUPABASE_BUCKET = "qubi_images"

supabase: Optional[Client] = None
if SUPABASE_URL and SUPABASE_KEY:
    supabase = create_client(SUPABASE_URL, SUPABASE_KEY)


def upload_image_to_supabase(uploaded_file) -> str:
    """
    Inputs: File-like object (Streamlit uploaded_file) for an image.
    Output: Signed URL string for the uploaded image.
    Note: Uses a UUID-based filename to avoid collisions.
    """
    if supabase is None:
        raise RuntimeError("Supabase is not configured. Check SUPABASE_URL and SUPABASE_KEY.")

    file_bytes = uploaded_file.read()
    filename = uploaded_file.name

    mimetype, _ = mimetypes.guess_type(filename)
    if mimetype is None:
        mimetype = "application/octet-stream"

    unique_prefix = uuid.uuid4().hex
    file_path = f"{unique_prefix}_{filename}"

    supabase.storage.from_(SUPABASE_BUCKET).upload(
        file_path,
        file_bytes,
        {"content-type": mimetype, "x-upsert": "true"},
    )

    expires_in = 60 * 60 * 24 * 365 * 50  # ~50 years
    signed_resp = supabase.storage.from_(SUPABASE_BUCKET).create_signed_url(
        file_path,
        expires_in,
    )

    signed_url = signed_resp["signedURL"]
    return signed_url


def delete_image_from_supabase_by_url(url: Optional[str]) -> None:
    """
    Inputs: Signed URL or storage URL for an image.
    Output: None (image object is removed from Supabase, if resolvable).
    Note: Currently expects Supabase signed URLs under /storage/v1/object/sign/.
    """
    if supabase is None or not url:
        return

    parsed = urlparse(url)
    path = parsed.path

    prefix = "/storage/v1/object/sign/"
    if not path.startswith(prefix):
        return

    bucket_and_path = path[len(prefix) :]
    parts: List[str] = bucket_and_path.split("/", 1)
    if len(parts) != 2:
        return

    bucket_name, file_path = parts[0], parts[1]
    if bucket_name != SUPABASE_BUCKET:
        return

    supabase.storage.from_(SUPABASE_BUCKET).remove([file_path])