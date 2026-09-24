# DOCX Generation Reference

Common thesis Word document generation reference. **Note**: If the user provides a `.docx` template, Phase -1 should extract the actual styles from it. This file is only a fallback reference when no template is available.

## Contents

- [Template Style Extraction Guide](#template-style-extraction-guide)
- [Default Page Setup](#default-page-setup-no-template)
- [Default Font Stack](#default-font-stack-no-template)
- [Default Paragraph Format](#default-paragraph-format)
- [Citation Formats](#citation-formats)
- [Figure and Table Insertion](#figure-and-table-insertion)
- [TOC Generation](#toc-generation)
- [Headers and Page Numbers](#headers-and-page-numbers)

## Template Style Extraction Guide

When a template is provided, extract the following from the template rather than using this file's defaults:

### Extraction Steps

```python
from docx import Document

doc = Document(template_path)

# 1. Page setup
for sec in doc.sections:
    print(f"Page: {sec.page_width} x {sec.page_height}")
    print(f"Margins: top={sec.top_margin}, bottom={sec.bottom_margin}, left={sec.left_margin}, right={sec.right_margin}")

# 2. Style extraction
for i, p in enumerate(doc.paragraphs):
    text = p.text.strip()
    if not text:
        continue
    style_name = p.style.name
    font_info = ""
    if p.runs:
        r = p.runs[0]
        font_info = f"font={r.font.name}, size={r.font.size}, bold={r.font.bold}"
    print(f"style=[{style_name}] {font_info} | {text[:120]}")

# 3. Chapter structure extraction
# Identify the TOC area by TOC styles or a "Contents" / "Table of Contents" heading.
# Parse each TOC paragraph level and extract chapter titles and numbering.

# 4. Special section detection
# Search the TOC for keywords such as Appendix, Declaration, Acknowledgments, References.
```

### Example Extraction Output

```text
## Extracted Style Names (reuse directly in Phase 5)
- Level-1 heading -> actual template style for level-1 headings
- Level-2 heading -> actual template style for level-2 headings
- Level-3 heading -> actual template style for level-3 headings
- Body text -> actual template body style
- Figure caption -> actual template figure-caption style, if present
- TOC level 1 -> actual template TOC-level-1 style
```

## Default Page Setup (No Template)

```python
from docx.shared import Cm

page_width = Cm(21.0)
page_height = Cm(29.7)
top_margin = Cm(3.0)
bottom_margin = Cm(2.5)
left_margin = Cm(3.0)
right_margin = Cm(2.5)
gutter = Cm(0.5)
```

## Default Font Stack (No Template)

| Element | Font | Size | Bold | Alignment |
|---|---|---:|---:|---|
| Title page - university name | Times New Roman | 42pt | No | Center |
| Title page - thesis type | Times New Roman | 36pt | No | Center |
| Title page - thesis title | Times New Roman | 22pt | No | Center |
| Title page - student info | Times New Roman | 16pt | No | Center |
| Abstract heading | Times New Roman | 18pt | No | Center |
| Abstract body | Times New Roman | 12pt | No | Justify |
| Keywords label | Times New Roman | 12pt | Yes | Left |
| TOC heading | Times New Roman | 18pt | No | Center |
| Level-1 heading | Times New Roman | 18pt | No | Center |
| Level-2 heading | Times New Roman | 15pt | No | Left |
| Level-3 heading | Times New Roman | 14pt | No | Left |
| Body text | Times New Roman | 12pt | No | Justify |
| Figure/table caption | Times New Roman | 10pt | No | Center |
| Reference entry | Times New Roman | 10pt | No | Left |
| Header/page number | Times New Roman | 9pt | No | Center |

For bilingual theses, Chinese elements often require East Asian fonts such as SimSun or SimHei. Prefer the template's run XML over defaults.

## Default Paragraph Format

```python
from docx.enum.text import WD_ALIGN_PARAGRAPH
from docx.shared import Cm, Pt

paragraph.alignment = WD_ALIGN_PARAGRAPH.JUSTIFY
paragraph.paragraph_format.first_line_indent = Cm(1.27)
paragraph.paragraph_format.line_spacing = 1.5
paragraph.paragraph_format.space_before = Pt(0)
paragraph.paragraph_format.space_after = Pt(0)

heading.alignment = WD_ALIGN_PARAGRAPH.CENTER
heading.paragraph_format.first_line_indent = Cm(0)
heading.paragraph_format.space_before = Pt(12)
heading.paragraph_format.space_after = Pt(12)
```

## Citation Formats

### APA 7th Edition

```text
Author, A. A., & Author, B. B. (Year). Title of article. Title of Periodical, Volume(Issue), Pages. https://doi.org/xxxx
```

### IEEE

```text
[N] A. A. Author and B. B. Author, "Title of article," Title of Periodical, vol. xx, no. xx, pp. xxx-xxx, Year.
```

### GB/T 7714

```text
[N] Authors. Title[J]. Journal Name, Year, Volume(Issue): Pages.
[N] Authors. Title[C]// Conference Name. Location: Publisher, Year: Pages.
[N] Author. Title[D]. Location: Institution, Year.
```

## Figure and Table Insertion

```python
from docx.shared import Cm

max_image_width = Cm(14.0)
max_image_height = Cm(10.0)

# If no template rule is available:
# Figures: Fig. X-Y
# Tables: Table X-Y
# X is the chapter number; Y is the sequence within the chapter.
```

## TOC Generation

Use Word field codes for an auto-generated TOC. `outline` must come from the template or user requirement. If only levels 1-2 are required, use `1-2`; do not generate levels 1-3 and manually delete visible TOC text.

```python
from docx.oxml.ns import qn
from lxml import etree

def add_toc(doc, outline="1-3"):
    paragraph = doc.add_paragraph()
    run = paragraph.add_run()
    fldChar_begin = etree.SubElement(run._r, qn("w:fldChar"))
    fldChar_begin.set(qn("w:fldCharType"), "begin")
    instrText = etree.SubElement(run._r, qn("w:instrText"))
    instrText.text = f'TOC \\o "{outline}" \\h \\z \\u'
    instrText.set(qn("xml:space"), "preserve")
    fldChar_end = etree.SubElement(run._r, qn("w:fldChar"))
    fldChar_end.set(qn("w:fldCharType"), "end")
```

If the template excludes a heading level from the TOC, also inspect whether the excluded heading style has `w:outlineLvl`. Word/WPS may re-include headings after field update if the outline level remains, so fix both the TOC field and heading style outline settings.

## Headers and Page Numbers

- Page numbers commonly start from the first body chapter.
- Title page, abstract, and TOC may be unnumbered or use Roman numerals.
- Header text and starting section must follow the template.
- Use template extraction results when available.
