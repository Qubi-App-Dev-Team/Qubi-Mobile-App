# Need to include warnings for deleting images or replacing image components
# Need to modify titles of editing pages
# Need to double check chapter renumbering logic
import streamlit as st
from typing import Any, Dict, List, Optional

from firebase_logic import (
    get_chapter_list,
    load_chapter,
    save_chapter_to_firestore,
    soft_delete_chapter,
    unarchive_chapter,
    swap_chapter_numbers,
)

from chapter_processing import (
    ensure_chapter_structure,
    add_section,
    delete_section,
    add_page,
    delete_page,
    new_simple_component,
    new_prompt_component,
    parse_prompt_component,
    build_prompt_component,
    delete_component,
    import_chapter_from_json,
    export_chapter_to_bytes,
)

from storage_utils import upload_image_to_supabase, delete_image_from_supabase_by_url


def init_session() -> None:
    """
    Inputs: None.
    Output: Initializes Streamlit session_state keys if missing.
    Note: Ensures consistent state for mode, chapter, selection, and publish mode.
    """
    if "mode" not in st.session_state:
        st.session_state.mode = "home"
    if "chapter" not in st.session_state:
        st.session_state.chapter = None
    if "chapter_id" not in st.session_state:
        st.session_state.chapter_id = None
    if "selected_section" not in st.session_state:
        st.session_state.selected_section = 0
    if "selected_page" not in st.session_state:
        st.session_state.selected_page = 0
    if "uid_counter" not in st.session_state:
        st.session_state.uid_counter = 0
    if "publish_mode" not in st.session_state:
        st.session_state.publish_mode = "Create new version"


def new_uid() -> str:
    """
    Inputs: None.
    Output: Sequential string UID for uniquely identifying components.
    Note: Backed by a simple integer counter in session_state.
    """
    st.session_state.uid_counter += 1
    return str(st.session_state.uid_counter)


def ensure_component_uids(chapter: Dict[str, Any]) -> None:
    """
    Inputs: Chapter dict.
    Output: Mutates chapter to ensure each top-level component has a 'uid'.
    Note: Used to provide stable Streamlit widget keys across re-renders.
    """
    if not chapter:
        return
    chapter = ensure_chapter_structure(chapter)
    for sec in chapter["sections"]:
        for page in sec.get("pages", []):
            for comp in page.get("components", []):
                if "uid" not in comp:
                    comp["uid"] = new_uid()


def main() -> None:
    """
    Inputs: None.
    Output: Runs the Streamlit app by selecting home or editor view.
    Note: Entry point guarded at bottom with if __name__ == "__main__".
    """
    init_session()
    st.set_page_config(page_title="Qubi Learn Content Manager", layout="wide")

    if st.session_state.mode == "home":
        show_home_view()
    else:
        show_editor_view()


def show_home_view() -> None:
    """
    Inputs: None (uses global session_state and Firestore data).
    Output: Renders chapter list with version dropdowns and reordering controls.
    Note: Groups docs by chapter number and uses 'latest' to pick default version.
    """
    st.title("Qubi Learn Content Manager")

    chapters = get_chapter_list()
    st.subheader("Chapters in Firestore")

    if not chapters:
        st.info("No chapters found.")
    else:
        grouped: Dict[int, List[Dict[str, Any]]] = {}
        for ch in chapters:
            num = int(ch.get("number", 0))
            grouped.setdefault(num, []).append(ch)

        sorted_numbers = sorted(grouped.keys())

        for idx, chapter_number in enumerate(sorted_numbers):
            versions = grouped[chapter_number]
            versions_sorted = sorted(
                versions,
                key=lambda c: int(c.get("version", 0)),
                reverse=True,
            )

            default_idx = 0
            for i, v in enumerate(versions_sorted):
                if v.get("latest", False):
                    default_idx = i
                    break

            cols = st.columns([4, 3, 2, 1, 1, 1])
            with cols[0]:
                version_options = list(range(len(versions_sorted)))

                def _version_label(i: int) -> str:
                    """
                    Inputs: Index into versions_sorted.
                    Output: Human-readable label for version selectbox.
                    Note: Shows version number, status, and latest tag if applicable.
                    """
                    vdoc = versions_sorted[i]
                    vnum = vdoc.get("version", 0)
                    status = vdoc.get("status", "active")
                    latest_flag = " (latest)" if vdoc.get("latest", False) else ""
                    return f"v{vnum} [{status}]{latest_flag}"

                selected_idx = st.selectbox(
                    f"Chapter {chapter_number} versions",
                    options=version_options,
                    format_func=_version_label,
                    index=default_idx,
                    key=f"chapter-{chapter_number}-version-select",
                )

            selected_doc = versions_sorted[selected_idx]
            title = selected_doc.get("title", "")
            diff = selected_doc.get("diff", "")
            status = selected_doc.get("status", "active")
            version = selected_doc.get("version", 0)

            with cols[1]:
                st.markdown(f"**{chapter_number}: {title}**")
                st.caption(
                    f"Difficulty: {diff} | Version: {version} | Status: {status}"
                )

            with cols[2]:
                if st.button("Edit this version", key=f"edit-{selected_doc['id']}"):
                    chapter = load_chapter(selected_doc["id"])
                    if chapter is not None:
                        st.session_state.chapter = chapter
                        st.session_state.chapter_id = selected_doc["id"]
                        ensure_component_uids(st.session_state.chapter)
                        st.session_state.selected_section = 0
                        st.session_state.selected_page = 0
                        st.session_state.mode = "edit"
                        st.session_state.publish_mode = "Update existing version"
                        st.rerun()

            with cols[3]:
                if status == "archived":
                    if st.button("Unarchive", key=f"unarchive-{selected_doc['id']}"):
                        unarchive_chapter(selected_doc["id"])
                        st.success("Version unarchived.")
                        st.rerun()
                else:
                    if st.button("Archive", key=f"archive-{selected_doc['id']}"):
                        soft_delete_chapter(selected_doc["id"])
                        st.success("Version archived.")
                        st.rerun()

            with cols[4]:
                if st.button("↑", key=f"chapter-up-{chapter_number}") and idx > 0:
                    prev_number = sorted_numbers[idx - 1]
                    swap_chapter_numbers(chapter_number, prev_number)
                    st.rerun()

            with cols[5]:
                if st.button("↓", key=f"chapter-down-{chapter_number}") and idx < len(sorted_numbers) - 1:
                    next_number = sorted_numbers[idx + 1]
                    swap_chapter_numbers(chapter_number, next_number)
                    st.rerun()

    st.markdown("---")

    col1, col2 = st.columns(2)

    with col1:
        if st.button("Add New Chapter"):
            chapters = get_chapter_list()
            if chapters:
                max_number = max(int(c.get("number", 0)) for c in chapters)
                new_number = max_number + 1
            else:
                new_number = 1

            chapter = ensure_chapter_structure(
                {
                    "title": "",
                    "diff": "",
                    "number": new_number,
                    "sections": [],
                    "status": "active",
                    "version": 0,
                    "latest": False,
                }
            )
            st.session_state.chapter = chapter
            st.session_state.chapter_id = None
            ensure_component_uids(st.session_state.chapter)
            st.session_state.selected_section = 0
            st.session_state.selected_page = 0
            st.session_state.mode = "edit"
            st.session_state.publish_mode = "Create new version"
            st.rerun()

    with col2:
        st.subheader("Open JSON Draft")
        uploaded = st.file_uploader(
            "Upload chapter draft JSON",
            type=["json"],
            key="draft_upload",
        )
        if uploaded is not None:
            chapter = import_chapter_from_json(uploaded)
            chapter_id = chapter.get("chapter_id")
            st.session_state.chapter = chapter
            st.session_state.chapter_id = chapter_id
            ensure_component_uids(st.session_state.chapter)
            st.session_state.selected_section = 0
            st.session_state.selected_page = 0
            st.session_state.mode = "edit"
            st.session_state.publish_mode = (
                "Update existing version" if chapter_id else "Create new version"
            )
            st.rerun()


def show_editor_view() -> None:
    """
    Inputs: None (relies on session_state.chapter and chapter_id).
    Output: Renders and manages the chapter editor view.
    Note: Handles sections, pages, components, and publish actions.
    """
    chapter = st.session_state.chapter
    chapter_id = st.session_state.chapter_id

    if chapter is None:
        st.session_state.mode = "home"
        st.session_state.chapter = None
        st.session_state.chapter_id = None
        st.rerun()

    chapter = ensure_chapter_structure(chapter)

    top_cols = st.columns([1, 4])
    with top_cols[0]:
        if st.button("← Back to Chapters"):
            st.session_state.mode = "home"
            st.session_state.chapter = None
            st.session_state.chapter_id = None
            st.rerun()
    with top_cols[1]:
        st.subheader("Editing Chapter")

    chapter_number = int(chapter.get("number", 0))
    version_num = int(chapter.get("version", 0))
    latest_flag = chapter.get("latest", False)

    chapter["title"] = st.text_input("Title", value=chapter.get("title", ""))
    chapter["diff"] = st.text_input("Difficulty", value=chapter.get("diff", ""))
    st.markdown(f"**Chapter number:** {chapter_number}")
    st.markdown(f"**Version:** {version_num} {'(latest)' if latest_flag else ''}")

    st.markdown("---")

    sections = chapter["sections"]

    sec_cols = st.columns([3, 1])
    with sec_cols[0]:
        if sections:
            sec_labels = [f"{i + 1}. {s.get('title') or 'Untitled Section'}" for i, s in enumerate(sections)]
            st.session_state.selected_section = st.radio(
                "Sections",
                options=list(range(len(sections))),
                format_func=lambda i: sec_labels[i],
                index=min(st.session_state.selected_section, len(sections) - 1),
                key="section_radio",
            )
        else:
            st.info("No sections yet. Add one below.")
    with sec_cols[1]:
        if st.button("Add Section"):
            idx = add_section(chapter)
            st.session_state.selected_section = idx
            ensure_component_uids(chapter)
            st.session_state.chapter = chapter
            st.rerun()

    if sections:
        cur_sec_idx = st.session_state.selected_section
        cur_sec_idx = min(cur_sec_idx, len(sections) - 1)
        st.session_state.selected_section = cur_sec_idx
        section = sections[cur_sec_idx]

        st.markdown("### Selected Section")

        section["title"] = st.text_input(
            "Section Title",
            value=section.get("title", ""),
            key=f"sec-title-{cur_sec_idx}",
        )
        section["description"] = st.text_area(
            "Section Description",
            value=section.get("description", ""),
            key=f"sec-desc-{cur_sec_idx}",
        )

        sec_btn_cols = st.columns(2)
        with sec_btn_cols[0]:
            if st.button("Add Page", key=f"add-page-{cur_sec_idx}"):
                add_page(chapter, cur_sec_idx)
                ensure_component_uids(chapter)
                st.session_state.selected_page = len(section.get("pages", [])) - 1
                st.session_state.chapter = chapter
                st.rerun()
        with sec_btn_cols[1]:
            if st.button("Delete Section", key=f"del-sec-{cur_sec_idx}"):
                delete_section(chapter, cur_sec_idx)
                st.session_state.selected_section = 0
                st.session_state.selected_page = 0
                st.session_state.chapter = chapter
                st.rerun()

        pages = section.get("pages", [])
        st.markdown("---")
        st.markdown("### Pages")

        if pages:
            page_labels = [f"Page {i + 1}" for i in range(len(pages))]
            st.session_state.selected_page = st.radio(
                "Select Page",
                options=list(range(len(pages))),
                format_func=lambda i: page_labels[i],
                index=min(st.session_state.selected_page, len(pages) - 1),
                key="page_radio",
                horizontal=True,
            )

            cur_page_idx = st.session_state.selected_page
            cur_page_idx = min(cur_page_idx, len(pages) - 1)
            st.session_state.selected_page = cur_page_idx

            page_btn_cols = st.columns(2)
            with page_btn_cols[0]:
                if st.button("Add Page After", key=f"add-page-after-{cur_sec_idx}-{cur_page_idx}"):
                    new_page = {"components": []}
                    pages.insert(cur_page_idx + 1, new_page)
                    section["pages"] = pages
                    st.session_state.selected_page = cur_page_idx + 1
                    st.session_state.chapter = chapter
                    st.rerun()
            with page_btn_cols[1]:
                if st.button("Delete Page", key=f"del-page-{cur_sec_idx}-{cur_page_idx}"):
                    delete_page(chapter, cur_sec_idx, cur_page_idx)
                    st.session_state.selected_page = 0
                    st.session_state.chapter = chapter
                    st.rerun()

            st.markdown("---")
            st.markdown("### Components on Page")

            render_page_components(chapter, chapter_id, cur_sec_idx, cur_page_idx)

        else:
            st.info("No pages in this section yet.")
    else:
        st.info("No sections defined.")

    st.markdown("---")

    col_left, col_right = st.columns(2)

    with col_left:
        st.session_state.publish_mode = st.radio(
            "Publish mode",
            options=["Update existing version", "Create new version"],
            index=0 if chapter_id else 1,
            key="publish_mode_radio",
        )

        if st.button("Publish to Firestore"):
            create_new_version = (st.session_state.publish_mode == "Create new version")
            doc_id = save_chapter_to_firestore(
                chapter_id,
                chapter,
                create_new_version=create_new_version,
            )
            saved_chapter = load_chapter(doc_id)

            if saved_chapter is not None:
                ensure_component_uids(saved_chapter)
                st.session_state.chapter_id = doc_id
                st.session_state.chapter = saved_chapter
                st.success(f"Published chapter version (id: {doc_id}).")
                st.rerun()
            else:
                st.error("Failed to reload chapter after saving.")

    with col_right:
        filename, json_bytes = export_chapter_to_bytes(chapter, chapter_id)
        st.download_button(
            "Download Draft JSON",
            data=json_bytes,
            file_name=filename,
            mime="application/json",
        )

    st.session_state.chapter = chapter


def render_page_components(
    chapter: Dict[str, Any],
    chapter_id: Optional[str],
    section_index: int,
    page_index: int,
) -> None:
    """
    Inputs: Chapter dict, optional chapter_id, and section/page indexes.
    Output: Renders and mutates components for the selected page.
    Note: Handles image replacement with optional Supabase deletion warnings.
    """
    sections = chapter["sections"]
    section = sections[section_index]
    page = section["pages"][page_index]
    components: List[Dict[str, Any]] = page.get("components", [])

    for idx, comp in enumerate(components):
        if "uid" not in comp:
            comp["uid"] = new_uid()

        uid = comp["uid"]
        ctype = comp.get("type", "")
        ctype_lower = ctype.lower()

        st.markdown("---")
        box = st.container()
        with box:
            header_cols = st.columns([3, 1, 1, 1])
            with header_cols[0]:
                st.markdown(f"**Component {idx + 1} – {ctype}**")
            with header_cols[1]:
                if st.button("↑", key=f"comp-up-{uid}") and idx > 0:
                    components[idx - 1], components[idx] = components[idx], components[idx - 1]
                    page["components"] = components
                    st.session_state.chapter = chapter
                    st.rerun()
            with header_cols[2]:
                if st.button("↓", key=f"comp-down-{uid}") and idx < len(components) - 1:
                    components[idx + 1], components[idx] = components[idx], components[idx + 1]
                    page["components"] = components
                    st.session_state.chapter = chapter
                    st.rerun()
            with header_cols[3]:
                if st.button("Delete", key=f"comp-del-{uid}"):
                    delete_component(chapter, section_index, page_index, idx)
                    st.session_state.chapter = chapter
                    st.rerun()

            if ctype_lower == "header":
                comp["content"] = st.text_input(
                    "Header text",
                    value=comp.get("content", ""),
                    key=f"comp-header-{uid}",
                )

            elif ctype_lower == "paragraph":
                comp["content"] = st.text_area(
                    "Paragraph text",
                    value=comp.get("content", ""),
                    key=f"comp-paragraph-{uid}",
                )

            elif ctype_lower == "image":
                url = comp.get("content", "")
                if url:
                    st.image(url, width=250)
                img_file = st.file_uploader(
                    "Upload image",
                    type=["png", "jpg", "jpeg"],
                    key=f"comp-image-upload-{uid}",
                )
                if img_file is not None:
                    st.info(
                        "If you delete the previous image, it will be permanently "
                        "removed from storage. If that image is used in other "
                        "versions, those versions will lose it as well."
                    )
                    delete_prev = st.checkbox(
                        "Delete previous image from Supabase (if any).",
                        value=False,
                        key=f"comp-image-delete-prev-{uid}",
                    )
                    if st.button("Save image", key=f"comp-image-save-{uid}"):
                        try:
                            new_url = upload_image_to_supabase(img_file)
                            if delete_prev and url:
                                delete_image_from_supabase_by_url(url)
                            comp["content"] = new_url
                            st.session_state.chapter = chapter
                            st.rerun()
                        except Exception as e:
                            st.error(f"Image upload failed: {e}")

            elif ctype_lower == "video":
                url = comp.get("content", "")
                if url:
                    st.video(url)
                comp["content"] = st.text_input(
                    "Video URL",
                    value=url,
                    key=f"comp-video-{uid}",
                )

            elif ctype_lower == "prompt":
                render_prompt_component(chapter, section_index, page_index, idx, comp)

    st.markdown("#### Add Component")

    add_type = st.selectbox(
        "New component type",
        options=["Header", "Paragraph", "Image", "Video", "Prompt"],
        key=f"add-comp-type-{section_index}-{page_index}",
    )
    if st.button("Add Component", key=f"add-comp-{section_index}-{page_index}"):
        if add_type == "Prompt":
            new_comp = new_prompt_component()
        else:
            new_comp = new_simple_component(add_type)
        new_comp["uid"] = new_uid()
        components.append(new_comp)
        page["components"] = components
        st.session_state.chapter = chapter
        st.rerun()


def render_prompt_component(
    chapter: Dict[str, Any],
    section_index: int,
    page_index: int,
    component_index: int,
    comp: Dict[str, Any],
) -> None:
    """
    Inputs: Chapter dict, indexes, and Prompt component dict.
    Output: Renders and mutates nested prompt items for that component.
    Note: Includes optional deletion warnings when replacing images inside prompts.
    """
    uid = comp["uid"]
    items = parse_prompt_component(comp)

    st.markdown("**Prompt Items**")

    for idx, item in enumerate(items):
        itype = item.get("type")
        inner_cols = st.columns([3, 1, 1, 1])
        with inner_cols[0]:
            st.markdown(f"_Item {idx + 1}_ – {itype}")
        with inner_cols[1]:
            if st.button("↑", key=f"prompt-item-up-{uid}-{idx}") and idx > 0:
                items[idx - 1], items[idx] = items[idx], items[idx - 1]
                comp_new = build_prompt_component(items)
                _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
                st.rerun()
        with inner_cols[2]:
            if st.button("↓", key=f"prompt-item-down-{uid}-{idx}") and idx < len(items) - 1:
                items[idx + 1], items[idx] = items[idx], items[idx + 1]
                comp_new = build_prompt_component(items)
                _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
                st.rerun()
        with inner_cols[3]:
            if st.button("Delete", key=f"prompt-item-del-{uid}-{idx}"):
                items.pop(idx)
                comp_new = build_prompt_component(items)
                _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
                st.rerun()

        if itype == "Header":
            item["content"] = st.text_input(
                "Header text",
                value=item.get("content", ""),
                key=f"prompt-header-{uid}-{idx}",
            )

        elif itype == "Paragraph":
            item["content"] = st.text_area(
                "Paragraph text",
                value=item.get("content", ""),
                key=f"prompt-paragraph-{uid}-{idx}",
            )

        elif itype == "Image":
            url = item.get("content", "")
            if url:
                st.image(url, width=250)
            img_file = st.file_uploader(
                "Upload image",
                type=["png", "jpg", "jpeg"],
                key=f"prompt-image-upload-{uid}-{idx}",
            )
            if img_file is not None:
                st.info(
                    "If you delete the previous image, it will be permanently "
                    "removed from storage. If that image is used in other "
                    "versions, those versions will lose it as well."
                )
                delete_prev = st.checkbox(
                    "Delete previous image from Supabase (if any).",
                    value=False,
                    key=f"prompt-image-delete-prev-{uid}-{idx}",
                )
                if st.button("Save prompt image", key=f"prompt-image-save-{uid}-{idx}"):
                    try:
                        new_url = upload_image_to_supabase(img_file)
                        if delete_prev and url:
                            delete_image_from_supabase_by_url(url)
                        item["content"] = new_url
                        comp_new = build_prompt_component(items)
                        _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
                        st.rerun()
                    except Exception as e:
                        st.error(f"Image upload failed: {e}")

        elif itype == "Video":
            url = item.get("content", "")
            if url:
                st.video(url)
            item["content"] = st.text_input(
                "Video URL",
                value=url,
                key=f"prompt-video-{uid}-{idx}",
            )

        elif itype == "Options":
            options = item.get("options", []) or []
            options_text = "\n".join(options)
            options_text = st.text_area(
                "Options (one per line)",
                value=options_text,
                key=f"prompt-options-text-{uid}-{idx}",
            )
            options = [line.strip() for line in options_text.splitlines() if line.strip()]
            if options:
                max_index = len(options) - 1
                answer = item.get("answer", 0)
                if answer is None or not (0 <= answer <= max_index):
                    answer = 0
                answer = st.number_input(
                    "Correct answer index (0-based)",
                    min_value=0,
                    max_value=max_index,
                    value=answer,
                    step=1,
                    key=f"prompt-options-answer-{uid}-{idx}",
                )
            else:
                answer = None
                st.info("Add options to select a correct answer index.")
            explanation = st.text_area(
                "Explanation",
                value=item.get("explanation", ""),
                key=f"prompt-options-expl-{uid}-{idx}",
            )
            item["options"] = options
            item["answer"] = answer
            item["explanation"] = explanation

    st.markdown("**Add Prompt Item**")

    add_type = st.selectbox(
        "New prompt item type",
        options=["Header", "Paragraph", "Image", "Video", "Options"],
        key=f"prompt-add-type-{uid}",
    )
    if st.button("Add Prompt Item", key=f"prompt-add-{uid}"):
        if add_type == "Header":
            items.append({"type": "Header", "content": ""})
        elif add_type == "Paragraph":
            items.append({"type": "Paragraph", "content": ""})
        elif add_type == "Image":
            items.append({"type": "Image", "content": ""})
        elif add_type == "Video":
            items.append({"type": "Video", "content": ""})
        elif add_type == "Options":
            items.append({"type": "Options", "options": [], "answer": 0, "explanation": ""})
        comp_new = build_prompt_component(items)
        _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
        st.rerun()

    comp_new = build_prompt_component(items)
    _update_prompt_component(chapter, section_index, page_index, component_index, comp_new)
    st.session_state.chapter = chapter


def _update_prompt_component(
    chapter: Dict[str, Any],
    section_index: int,
    page_index: int,
    component_index: int,
    new_comp: Dict[str, Any],
) -> None:
    """
    Inputs: Chapter dict, location indexes, and new Prompt component dict.
    Output: Mutates chapter to replace the target Prompt component.
    Note: Preserves the component's existing UID value.
    """
    sections = chapter["sections"]
    section = sections[section_index]
    page = section["pages"][page_index]
    components = page["components"]
    uid = components[component_index].get("uid")
    new_comp["uid"] = uid
    components[component_index] = new_comp
    page["components"] = components
    section["pages"] = section["pages"]
    chapter["sections"] = sections
    st.session_state.chapter = chapter


if __name__ == "__main__":
    main()