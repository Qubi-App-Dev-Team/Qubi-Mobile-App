# app.py

import streamlit as st

from helpers import (
    get_chapter_list,
    load_chapter,
    save_chapter_to_firestore,
    export_chapter_to_bytes,
    import_chapter_from_json,
    ensure_chapter_structure,
    add_section,
    delete_section,
    add_page,
    delete_page,
    delete_component,
    new_simple_component,
    new_prompt_component,
    is_prompt_component,
    parse_prompt_component,
    build_prompt_component,
    soft_delete_chapter,
)

st.set_page_config(page_title="Qubi Learn Content Editor", layout="wide")

# ---- Session state initialization ----
# Ensures information is stored across all pages and reruns

if "view" not in st.session_state:
    st.session_state["view"] = "chapters"  # "chapters" or "editor"

if "chapter_id" not in st.session_state:
    st.session_state["chapter_id"] = None  # None = new/draft-only chapter

if "chapter_data" not in st.session_state:
    st.session_state["chapter_data"] = None

if "section_index" not in st.session_state:
    st.session_state["section_index"] = 0

if "page_index" not in st.session_state:
    st.session_state["page_index"] = 0


# ---- View: chapters list ----

def show_chapters_view():
    st.title("Qubi Learn Content Editor")

    # Load chapters from Firestore
    try:
        chapters = get_chapter_list()
    except Exception as e:
        st.error(f"Error loading chapters from Firestore: {e}")
        return

    # Filter: show/hide archived chapters
    show_archived = st.checkbox("Show archived chapters", value=False)

    if not show_archived:
        display_chapters = [ch for ch in chapters if ch.get("status", "active") != "archived"]
    else:
        display_chapters = chapters

    st.write(f"Total chapters (including archived): **{len(chapters)}**")
    st.write(f"Visible chapters: **{len(display_chapters)}**")

    # Button to create new chapter
    if st.button("➕ Create new chapter"):
        # Find a suggested next chapter number
        existing_numbers = [
            ch["number"] for ch in chapters
            if isinstance(ch.get("number"), (int, float))
        ]
        next_number = (max(existing_numbers) + 1) if existing_numbers else 1

        # Create an empty chapter in memory
        new_chapter = ensure_chapter_structure({
            "title": "",
            "diff": "",
            "number": next_number,
            "sections": [],
            "status": "active",
            "version": 0,  # will be incremented on first publish
        })

        st.session_state["chapter_id"] = None  # new chapter, not in Firestore yet
        st.session_state["chapter_data"] = new_chapter
        st.session_state["section_index"] = 0
        st.session_state["page_index"] = 0
        st.session_state["view"] = "editor"
        st.rerun()

    st.markdown("---")

    if not display_chapters:
        st.info("No chapters match the current filter.")
    else:
        for ch in display_chapters:
            col1, col2, col3, col4, col5 = st.columns([3, 1.5, 2, 1, 1])
            with col1:
                title = ch.get("title", "")
                number = ch.get("number", "?")
                st.markdown(f"**Chapter {number}: {title}**")
            with col2:
                st.caption(f"ID: `{ch['id']}`")
            with col3:
                diff = ch.get("diff")
                if diff:
                    st.write(f"Diff: {diff}")
            with col4:
                status = ch.get("status", "active")
                if status == "archived":
                    st.markdown("🗂️ *Archived*")
                else:
                    st.markdown("✅ *Active*")
            with col5:
                # Edit button
                if st.button("Edit", key=f"edit_{ch['id']}"):
                    chapter_data = load_chapter(ch["id"])
                    if chapter_data is None:
                        st.error("Chapter not found or failed to load.")
                    else:
                        st.session_state["chapter_id"] = ch["id"]
                        st.session_state["chapter_data"] = chapter_data
                        st.session_state["section_index"] = 0
                        st.session_state["page_index"] = 0
                        st.session_state["view"] = "editor"
                        st.rerun()

                # Soft delete / archive button (only for active chapters)
                if ch.get("status", "active") != "archived":
                    if st.button("Archive", key=f"archive_{ch['id']}"):
                        try:
                            soft_delete_chapter(ch["id"])
                            st.success(f"Chapter {ch.get('number', '?')} archived.")
                            st.rerun()
                        except Exception as e:
                            st.error(f"Failed to archive chapter: {e}")

    st.caption(
        "Note: Chapters are *soft deleted* by archiving. They remain in Firestore "
        "but are hidden from learners and the default view here."
    )

    st.markdown("---")

    # Open a local JSON draft (chapter-level) below the chapter list
    st.markdown("### Open local JSON draft")
    uploaded = st.file_uploader("Upload chapter JSON draft", type=["json"])
    if uploaded is not None:
        try:
            imported_chapter = import_chapter_from_json(uploaded)
            st.session_state["chapter_data"] = imported_chapter
            # Use the embedded chapter_id if present; save_chapter_to_firestore
            # will decide whether to reuse or create new.
            embedded_chapter_id = imported_chapter.get("chapter_id")
            st.session_state["chapter_id"] = embedded_chapter_id or None
            st.session_state["section_index"] = 0
            st.session_state["page_index"] = 0
            st.session_state["view"] = "editor"
            st.success("Draft loaded successfully into editor view.")
            st.rerun()
        except Exception as e:
            st.error(f"Failed to load JSON draft: {e}")


# ---- View: chapter editor ----

def show_editor_view():
    chapter_id = st.session_state.get("chapter_id")
    chapter = ensure_chapter_structure(st.session_state.get("chapter_data") or {})

    st.session_state["chapter_data"] = chapter

    st.title("Editing Chapter")

    if chapter_id:
        st.markdown(f"**Document ID:** `{chapter_id}`")
    else:
        st.markdown("**New / Draft-only chapter (not yet saved to Firestore)**")

    # Back button
    if st.button("← Back to chapters list"):
        st.session_state["view"] = "chapters"
        st.session_state["chapter_id"] = None
        st.session_state["chapter_data"] = None
        st.session_state["section_index"] = 0
        st.session_state["page_index"] = 0
        st.rerun()

    st.markdown("---")

    # ---- Chapter metadata ----
    col1, col2 = st.columns([2, 1])
    with col1:
        title = st.text_input("Chapter title", value=chapter.get("title", ""))
        chapter["title"] = title
    with col2:
        number = st.number_input(
            "Chapter number",
            value=int(chapter.get("number", 0)),
            step=1,
        )
        chapter["number"] = int(number)

    diff = st.text_area("Difficulty / diff", value=chapter.get("diff", ""))
    chapter["diff"] = diff

    st.markdown("---")

    # ---- Sections ----
    st.subheader("Sections")

    sections = chapter.get("sections", [])
    col_left, col_right = st.columns([1, 3])

    # Left panel: section selection & management
    with col_left:
        if sections:
            section_labels = [
                f"{i + 1}: {sec.get('title', 'Untitled section')}"
                for i, sec in enumerate(sections)
            ]
            current_section_index = st.session_state.get("section_index", 0)
            if current_section_index >= len(sections):
                current_section_index = 0

            selected_label = st.selectbox(
                "Select section",
                options=section_labels,
                index=current_section_index,
                key="section_select",
            )
            selected_index = section_labels.index(selected_label)
            st.session_state["section_index"] = selected_index
        else:
            st.info("No sections yet. Add one to get started.")
            st.session_state["section_index"] = 0

        # Add / delete sections
        if st.button("➕ Add new section"):
            new_index = add_section(chapter)
            st.session_state["section_index"] = new_index
            st.session_state["page_index"] = 0
            st.session_state["chapter_data"] = chapter
            st.rerun()

        if sections:
            if st.button("🗑️ Delete current section"):
                idx = st.session_state.get("section_index", 0)
                delete_section(chapter, idx)
                st.session_state["section_index"] = 0
                st.session_state["page_index"] = 0
                st.session_state["chapter_data"] = chapter
                st.rerun()

    # Right panel: section details, pages, components
    with col_right:
        sections = chapter.get("sections", [])
        if not sections:
            st.info("No sections yet. Create one on the left.")
        else:
            sec_idx = st.session_state.get("section_index", 0)
            if sec_idx >= len(sections):
                sec_idx = 0
                st.session_state["section_index"] = 0

            section = sections[sec_idx]

            # Section metadata
            st.markdown(f"### Section {sec_idx + 1}")
            s_col1 = st.columns(1)[0]
            with s_col1:
                section_title = st.text_input(
                    "Section title",
                    value=section.get("title", ""),
                    key=f"section_title_{sec_idx}",
                )
                section["title"] = section_title

            section_desc = st.text_area(
                "Section description",
                value=section.get("description", ""),
                key=f"section_desc_{sec_idx}",
            )
            section["description"] = section_desc

            st.markdown("---")

            # ---- Pages ----
            st.markdown("#### Pages")

            pages = section.get("pages", [])
            page_labels = [f"Page {i + 1}" for i in range(len(pages))]

            if pages:
                current_page_index = st.session_state.get("page_index", 0)
                if current_page_index >= len(pages):
                    current_page_index = 0

                selected_page_label = st.radio(
                    "Select page",
                    options=page_labels,
                    index=current_page_index,
                    key="page_select",
                    horizontal=True,
                )
                selected_page_index = page_labels.index(selected_page_label)
                st.session_state["page_index"] = selected_page_index
            else:
                st.info("No pages yet in this section.")

            p_col1, p_col2 = st.columns(2)
            with p_col1:
                if st.button("➕ Add new page", key=f"add_page_{sec_idx}"):
                    new_p_idx = add_page(chapter, sec_idx)
                    st.session_state["page_index"] = new_p_idx if new_p_idx >= 0 else 0
                    st.session_state["chapter_data"] = chapter
                    st.rerun()
            with p_col2:
                if pages:
                    if st.button("🗑️ Delete current page", key=f"del_page_{sec_idx}"):
                        p_idx = st.session_state.get("page_index", 0)
                        delete_page(chapter, sec_idx, p_idx)
                        st.session_state["page_index"] = 0
                        st.session_state["chapter_data"] = chapter
                        st.rerun()

            st.markdown("---")

            # ---- Components editor for selected page ----
            if pages:
                p_idx = st.session_state.get("page_index", 0)
                if p_idx >= len(pages):
                    p_idx = 0
                    st.session_state["page_index"] = 0

                page = pages[p_idx]
                components = page.get("components", [])

                st.markdown(f"#### Components for Page {p_idx + 1}")

                # Add new components
                c_add_col1, c_add_col2, c_add_col3, c_add_col4 = st.columns(4)
                with c_add_col1:
                    if st.button("➕ Add Header", key=f"add_header_{sec_idx}_{p_idx}"):
                        components.append(new_simple_component("Header"))
                        page["components"] = components
                        st.session_state["chapter_data"] = chapter
                        st.rerun()
                with c_add_col2:
                    if st.button("➕ Add Paragraph", key=f"add_par_{sec_idx}_{p_idx}"):
                        components.append(new_simple_component("Paragraph"))
                        page["components"] = components
                        st.session_state["chapter_data"] = chapter
                        st.rerun()
                with c_add_col3:
                    if st.button("➕ Add Image", key=f"add_img_{sec_idx}_{p_idx}"):
                        components.append(new_simple_component("Image"))
                        page["components"] = components
                        st.session_state["chapter_data"] = chapter
                        st.rerun()
                with c_add_col4:
                    if st.button("➕ Add Prompt", key=f"add_prompt_{sec_idx}_{p_idx}"):
                        components.append(new_prompt_component())
                        page["components"] = components
                        st.session_state["chapter_data"] = chapter
                        st.rerun()

                st.markdown("---")

                # Existing components
                if not components:
                    st.info("No components on this page yet.")
                else:
                    comp_type_choices = ["Header", "Paragraph", "Image", "Prompt"]

                    for idx, comp in enumerate(components):
                        with st.expander(f"Component {idx + 1}", expanded=True):
                            # Determine initial type
                            if is_prompt_component(comp):
                                current_type = "Prompt"
                            else:
                                t = comp.get("type", "Header")
                                if t not in comp_type_choices:
                                    t = "Header"
                                current_type = t

                            # Type selection
                            type_choice = st.selectbox(
                                "Component type",
                                options=comp_type_choices,
                                index=comp_type_choices.index(current_type),
                                key=f"comp_type_{sec_idx}_{p_idx}_{idx}",
                            )

                            # If switched to Prompt
                            if type_choice == "Prompt":
                                if not is_prompt_component(comp):
                                    comp = new_prompt_component()

                            # If switched away from Prompt to a simple type
                            elif type_choice in ["Header", "Paragraph", "Image"]:
                                if is_prompt_component(comp):
                                    comp = new_simple_component(type_choice)
                                else:
                                    comp["type"] = type_choice

                            # Render UI depending on type
                            if type_choice in ["Header", "Paragraph", "Image"]:
                                # Simple components: {"type": "...", "content": "..."}
                                content_str = comp.get("content", "")

                                if type_choice == "Header":
                                    content_str = st.text_input(
                                        "Header text",
                                        value=content_str,
                                        key=f"comp_header_{sec_idx}_{p_idx}_{idx}",
                                    )
                                elif type_choice == "Paragraph":
                                    content_str = st.text_area(
                                        "Paragraph text",
                                        value=content_str,
                                        key=f"comp_par_{sec_idx}_{p_idx}_{idx}",
                                    )
                                else:  # Image
                                    content_str = st.text_input(
                                        "Image URL",
                                        value=content_str,
                                        key=f"comp_img_{sec_idx}_{p_idx}_{idx}",
                                    )

                                comp["content"] = content_str

                            elif type_choice == "Prompt":
                                # Prompt component: treat content as an ordered list of inner components
                                st.markdown(
                                    "This prompt is a container for inner components, "
                                    "rendered in order (Headers, Paragraphs, Images, and Options)."
                                )

                                items = parse_prompt_component(comp)

                                st.write("Inner components (inside this prompt, in order):")

                                # Add inner components row
                                inner_add_c1, inner_add_c2, inner_add_c3, inner_add_c4 = st.columns(4)
                                if inner_add_c1.button(
                                    "➕ Add inner Header",
                                    key=f"add_inner_header_{sec_idx}_{p_idx}_{idx}",
                                ):
                                    items.append({"type": "Header", "content": ""})
                                    comp = build_prompt_component(items)
                                    components[idx] = comp
                                    page["components"] = components
                                    st.session_state["chapter_data"] = chapter
                                    st.rerun()

                                if inner_add_c2.button(
                                    "➕ Add inner Paragraph",
                                    key=f"add_inner_par_{sec_idx}_{p_idx}_{idx}",
                                ):
                                    items.append({"type": "Paragraph", "content": ""})
                                    comp = build_prompt_component(items)
                                    components[idx] = comp
                                    page["components"] = components
                                    st.session_state["chapter_data"] = chapter
                                    st.rerun()

                                if inner_add_c3.button(
                                    "➕ Add inner Image",
                                    key=f"add_inner_img_{sec_idx}_{p_idx}_{idx}",
                                ):
                                    items.append({"type": "Image", "content": ""})
                                    comp = build_prompt_component(items)
                                    components[idx] = comp
                                    page["components"] = components
                                    st.session_state["chapter_data"] = chapter
                                    st.rerun()

                                if inner_add_c4.button(
                                    "➕ Add Options block",
                                    key=f"add_inner_opt_block_{sec_idx}_{p_idx}_{idx}",
                                ):
                                    items.append(
                                        {
                                            "type": "Options",
                                            "options": ["", ""],
                                            "answer": 0,
                                            "explanation": "",
                                        }
                                    )
                                    comp = build_prompt_component(items)
                                    components[idx] = comp
                                    page["components"] = components
                                    st.session_state["chapter_data"] = chapter
                                    st.rerun()

                                # Edit each inner item
                                inner_type_choices = ["Header", "Paragraph", "Image", "Options"]

                                for ii, item in enumerate(items):
                                    with st.expander(
                                        f"Inner component {ii + 1}: {item.get('type')}",
                                        expanded=True,
                                    ):
                                        itype = item.get("type", "Header")
                                        if itype not in inner_type_choices:
                                            itype = "Header"

                                        i_type_choice = st.selectbox(
                                            "Inner type",
                                            options=inner_type_choices,
                                            index=inner_type_choices.index(itype),
                                            key=f"inner_type_{sec_idx}_{p_idx}_{idx}_{ii}",
                                        )

                                        # If type changed, reset structure appropriately
                                        if i_type_choice != itype:
                                            if i_type_choice in ("Header", "Paragraph", "Image"):
                                                item = {
                                                    "type": i_type_choice,
                                                    "content": "",
                                                }
                                            else:  # Options
                                                item = {
                                                    "type": "Options",
                                                    "options": ["", ""],
                                                    "answer": 0,
                                                    "explanation": "",
                                                }
                                            items[ii] = item
                                            comp = build_prompt_component(items)
                                            components[idx] = comp
                                            page["components"] = components
                                            st.session_state["chapter_data"] = chapter
                                            st.rerun()

                                        # Render inner item UI
                                        itype = item.get("type", "Header")

                                        if itype in ("Header", "Paragraph", "Image"):
                                            inner_content = item.get("content", "")

                                            if itype == "Header":
                                                inner_content = st.text_input(
                                                    "Header text (inside prompt)",
                                                    value=inner_content,
                                                    key=f"inner_header_{sec_idx}_{p_idx}_{idx}_{ii}",
                                                )
                                            elif itype == "Paragraph":
                                                inner_content = st.text_area(
                                                    "Paragraph text (inside prompt)",
                                                    value=inner_content,
                                                    key=f"inner_par_{sec_idx}_{p_idx}_{idx}_{ii}",
                                                )
                                            else:  # Image
                                                inner_content = st.text_input(
                                                    "Image URL (inside prompt)",
                                                    value=inner_content,
                                                    key=f"inner_img_{sec_idx}_{p_idx}_{idx}_{ii}",
                                                )

                                            item["content"] = inner_content

                                        elif itype == "Options":
                                            st.write("Options for this prompt:")

                                            options = item.get("options", []) or []
                                            new_options = []
                                            for oi, opt in enumerate(options):
                                                opt_val = st.text_input(
                                                    f"Option {oi + 1}",
                                                    value=opt,
                                                    key=f"inner_opt_{sec_idx}_{p_idx}_{idx}_{ii}_{oi}",
                                                )
                                                new_options.append(opt_val)

                                            # Button to add another option
                                            if st.button(
                                                "Add option",
                                                key=f"add_inner_opt_{sec_idx}_{p_idx}_{idx}_{ii}",
                                            ):
                                                new_options.append("")
                                                item["options"] = new_options
                                                comp = build_prompt_component(items)
                                                components[idx] = comp
                                                page["components"] = components
                                                st.session_state["chapter_data"] = chapter
                                                st.rerun()

                                            item["options"] = new_options

                                            # Answer index only if there are options
                                            if new_options:
                                                raw_answer = item.get("answer")
                                                if (
                                                    raw_answer is None
                                                    or raw_answer < 0
                                                    or raw_answer >= len(new_options)
                                                ):
                                                    raw_answer = 0
                                                answer_index = st.number_input(
                                                    "Correct answer index (0-based)",
                                                    value=int(raw_answer),
                                                    min_value=0,
                                                    max_value=len(new_options) - 1,
                                                    key=f"inner_ans_{sec_idx}_{p_idx}_{idx}_{ii}",
                                                )
                                            else:
                                                answer_index = None

                                            item["answer"] = answer_index

                                            explanation = st.text_area(
                                                "Explanation",
                                                value=item.get("explanation", ""),
                                                key=f"inner_expl_{sec_idx}_{p_idx}_{idx}_{ii}",
                                            )
                                            item["explanation"] = explanation

                                        # Reorder & delete controls for inner items
                                        move_cols = st.columns(3)
                                        if move_cols[0].button(
                                            "↑ Move up",
                                            key=f"inner_move_up_{sec_idx}_{p_idx}_{idx}_{ii}",
                                        ):
                                            if ii > 0:
                                                items[ii - 1], items[ii] = items[ii], items[ii - 1]
                                                comp = build_prompt_component(items)
                                                components[idx] = comp
                                                page["components"] = components
                                                st.session_state["chapter_data"] = chapter
                                                st.rerun()

                                        if move_cols[1].button(
                                            "↓ Move down",
                                            key=f"inner_move_down_{sec_idx}_{p_idx}_{idx}_{ii}",
                                        ):
                                            if ii < len(items) - 1:
                                                items[ii + 1], items[ii] = items[ii], items[ii + 1]
                                                comp = build_prompt_component(items)
                                                components[idx] = comp
                                                page["components"] = components
                                                st.session_state["chapter_data"] = chapter
                                                st.rerun()

                                        if move_cols[2].button(
                                            "🗑️ Delete inner component",
                                            key=f"inner_delete_{sec_idx}_{p_idx}_{idx}_{ii}",
                                        ):
                                            del items[ii]
                                            comp = build_prompt_component(items)
                                            components[idx] = comp
                                            page["components"] = components
                                            st.session_state["chapter_data"] = chapter
                                            st.rerun()

                                # After editing all items, rebuild the prompt component
                                comp = build_prompt_component(items)

                            # Save component back
                            components[idx] = comp

                            # Delete component
                            if st.button(
                                "🗑️ Delete this component",
                                key=f"del_comp_{sec_idx}_{p_idx}_{idx}",
                            ):
                                delete_component(chapter, sec_idx, p_idx, idx)
                                st.session_state["chapter_data"] = chapter
                                st.rerun()

                # Save updated page/section
                page["components"] = components
                pages[p_idx] = page
                section["pages"] = pages
                sections[sec_idx] = section
                chapter["sections"] = sections

    st.session_state["chapter_data"] = chapter

    st.markdown("---")

    # ---- Bottom actions: Save draft & Publish ----
    col_a, col_b = st.columns(2)
    with col_a:
        filename, json_bytes = export_chapter_to_bytes(chapter, chapter_id=chapter_id)
        st.download_button(
            "💾 Save draft (download JSON)",
            data=json_bytes,
            file_name=filename,
            mime="application/json",
        )

    with col_b:
        if st.button("🚀 Publish this chapter to Firestore"):
            try:
                # save_chapter_to_firestore increments version automatically
                new_id = save_chapter_to_firestore(chapter_id, chapter)
                st.session_state["chapter_id"] = new_id
                st.session_state["chapter_data"] = chapter
                st.success("Chapter published (Firestore document created/overwritten).")
            except Exception as e:
                st.error(f"Failed to publish chapter: {e}")


# ---- Main ----

def main():
    view = st.session_state.get("view", "chapters")
    if view == "chapters":
        show_chapters_view()
    else:
        show_editor_view()


if __name__ == "__main__":
    main()
