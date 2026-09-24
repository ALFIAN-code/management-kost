---
name: thesis-writing-en
description: "English bachelor's/master's thesis and graduation thesis writing, review, polishing, and DOCX finalization. Use for generating a thesis from a university Word template, writing a code-backed software/system thesis, optimizing an existing draft, checking citation order, and fixing TOC/keywords/references/styles. Triggers: write thesis, thesis writing, graduation thesis, bachelor thesis, master thesis, optimize thesis draft."
---

# Thesis Writing EN

Treat an English thesis as a verifiable engineering deliverable: establish template and evidence baselines, write or revise the paper, then validate the final DOCX with scripts.

## Core Rules

1. **Template first**: The university `.docx` template and user-provided formatting requirements are the authority. Do not guess fonts, margins, heading levels, captions, references, or TOC depth.
2. **Evidence first**: For software/system theses, architecture, modules, interfaces, data flow, model capability, and evaluation results must come from code, configuration, logs, tests, literature, or user-provided materials.
3. **Zero hallucinated references**: Never invent titles, authors, years, venues, DOIs, or URLs from memory. Use verifiable search results and record the source trail.
4. **Review before rewriting**: For existing drafts, produce a structured review first. Rewrite or overwrite only when the user explicitly requests it.
5. **Source-first editing**: If the DOCX is generated from Markdown, scripts, or structured sources, edit the source and generation script before regenerating DOCX.
6. **Hard validation over visual checks**: Citation order, keyword count, TOC depth, reference numbering, citation superscripts, and file locks must be checked with scripts, OOXML, or another repeatable method.
7. **Evidence bounds conclusions**: If samples are small, environments are narrow, deployment is unverified, or metrics are missing, write limited conclusions such as “under the test conditions” or “prototype validation.”

## Operating Modes

First determine the task mode and ask only for information that cannot be extracted from files.

### From-Scratch Writing

Use when the user has a topic, codebase, template, or direction but no full draft.

```text
Phase -1 Template baseline -> format-baseline.md
Phase 0  Code understanding -> system-understanding.md
Phase 1  Literature evidence -> references/literature-db.md
Phase 2  Thesis outline -> thesis-blueprint.md
Phase 3  Chapter drafting -> outlines/ + chapters/
Phase 4  Full review -> reviews/
Phase 5  DOCX delivery -> thesis-final.docx
```

### Existing Draft Optimization

Use when the user provides a `.docx`, `.md`, or text draft.

```text
Phase -1 Template baseline -> format-baseline.md
Phase 0  Code understanding -> system-understanding.md
Phase 3.5 Draft review/edit -> reviews/optimization-report.md + revised source
Phase 4  Full review -> reviews/
Phase 5  DOCX delivery -> thesis-final.docx
```

Never skip Phase -1 when a template exists. Never skip Phase 0 for a code-backed thesis.

## Startup Checklist

Extract from files first; ask the user only when missing:

| Item | Need | Notes |
|---|---:|---|
| Thesis title or topic | Required | Sets scope and search keywords |
| University `.docx` template | Strongly recommended | Formatting authority |
| Code directory | Required for code-backed theses | Optional for theory-only theses |
| Degree level | Recommended | Bachelor's/master's affects depth and length |
| Existing draft | Optional | Switches to draft optimization mode |
| Example paper | Optional | Use only for format and chapter-style inference; do not copy content |

After template parsing, confirm missing cover metadata, citation style, minimum reference count, word count target, and whether to keep or adjust template chapters.

## Phase -1: Template Baseline

Convert the university template into `format-baseline.md`. Record at least:

- Page and sections: paper size, margins, gutter, headers/footers, page numbering.
- Structure: cover, declaration, abstracts, TOC, body, references, acknowledgments, appendices, foreign-language material.
- Style mapping: level-1/2/3 headings, body text, captions, references, TOC styles.
- Figures, tables, equations: numbering rules, caption placement, in-text reference requirements.
- Citation requirements: APA, IEEE, GB/T 7714, or university-specific style.
- Constraints: word count, abstract length, keyword count, reference count, foreign-reference ratio.

Prefer the parser for the first pass:

```bash
python scripts/parse_docx_template.py template.docx --out format-baseline.md
```

After the script runs, manually verify semantic style mappings. Load `references/docx-spec.md` only when DOCX/OOXML details are needed.

## Phase 0: Code Understanding

Build the evidence base for technical writing.

1. Scan project structure, entry points, dependencies, configs, migrations, tests, and deployment files.
2. Trace core user/business flows from input to output.
3. Extract module responsibilities, interfaces, data models, algorithms, external services, error handling, and test evidence.
4. Attach `file:line` or other verifiable evidence to key technical points.
5. Output `system-understanding.md`.

`system-understanding.md` must include:

```markdown
# System Understanding

## Project Overview
## Tech Stack
## Core Flows
## Module Inventory
| Module | Responsibility | I/O | Key Files | Thesis-Worthy Points |
## Data Models and APIs
## Test and Validation Evidence
## Capabilities Not to Claim
```

If the user says the thesis misrepresents the project, reread code and configuration immediately. Distinguish current configuration, implemented capability, optional integration capability, and future work.

## Phase 1: Literature Evidence

Build real references for the introduction, related work, design rationale, and evaluation method.

- Use currently available live search tools to verify metadata.
- Record query, source page, URL/DOI, and access date.
- Prefer recent papers, foundational works, standards, official docs, and comparable systems.
- Do not cite a source unless its metadata can be verified.

Literature entry format:

```markdown
## [N] Title
- Authors:
- Source:
- Year:
- DOI/URL:
- Search Method:
- Key Points:
- Supports This Thesis:
- Suggested Citation Location:
```

Sequential numeric citations must follow first appearance:

- The first new source cited in the body is `[1]`; later new sources are `[2]`, `[3]`, and so on.
- Repeated citations reuse the original number.
- Do not pre-number by topic, chapter, source type, or reference-list order.
- Multiple citations at the same location must be in ascending order, such as `[2][3][7]`.
- The reference list must match in-text numbering. If the template uses automatic numbering, reference paragraphs must not contain manual `[1]` prefixes.

Before generating DOCX, validate Markdown source citation order:

```bash
python scripts/validate_citation_order.py chapters --references chapters/references.md --order chapter-1 chapter-2 chapter-3 chapter-4 chapter-5
```

## Phase 2: Thesis Outline

Define the whole-paper argument before drafting. Output `thesis-blueprint.md`:

```markdown
# Thesis Blueprint

## Chapter Structure and Semantic Roles
| Chapter | Template Title | Semantic Role | Word Budget | Core Task |

## Core Claims
| Claim | Supporting Chapters | Evidence Type | Risk |

## Glossary
| Term | Abbreviation | First Use | Canonical Form |

## Figure/Table Plan
| Number | Type | Content | Data/Source |

## Writing Order
## Voice, Tense, and Citation Conventions
```

Software/system theses usually follow introduction, related work/background, requirements, system design, implementation, testing/evaluation, and conclusion, but the template is final.

## Phase 3: Chapter Drafting

For each chapter:

1. Write a chapter outline with thesis, sections, evidence, figures/tables, and word budget.
2. Draft only content supported by the blueprint, code, literature, or tests.
3. Reverse-outline paragraphs to check whether each paragraph supports the chapter thesis.
4. Build a claim-evidence table for key claims.
5. Revise by removing unsupported paragraphs, weakening unsupported claims, and unifying terminology.

Writing rules:

- One message per paragraph; the first sentence states the point.
- Background/theory chapters explain concepts, principles, and selection rationale, not implementation details.
- Design chapters explain why decisions were made, not only what modules exist.
- Implementation chapters explain mechanisms, data flow, and error handling; do not paste long code or overload prose with paths.
- Testing chapters include environment, cases, inputs, expected results, actual results, and analysis. Small-sample tests support only prototype-level conclusions.
- Abstracts follow “background/problem -> method -> implementation/evaluation -> conclusion.” Keep keyword lines only as required by the template.
- Conclusions must return to requirements, design, implementation, tests, and limitations. Avoid unsupported claims such as “fully satisfies,” “significantly improves,” or “highly available.”

## Phase 3.5: Draft Review and Editing

When a draft exists, convert it to reviewable text before rewriting:

```bash
python scripts/extract_docx_draft.py draft.docx --out draft-extracted.md
python scripts/scan_thesis_quality.py draft-extracted.md --out reviews/quality-scan.md
```

Review dimensions:

| Dimension | Required checks |
|---|---|
| Format compliance | pages, headings, body text, figures/tables, references, headers/footers |
| Structure | whether the paper closes the loop from problem to design, implementation, testing, conclusion |
| Technical consistency | whether claims match code and avoid overstating missing features |
| Software engineering evidence | requirements, architecture, APIs, database, tests, deployment evidence |
| Citation integrity | real, sequential, consistently formatted, mutually matched references |
| Expression quality | academic tone, no filler, no term drift, no generic AI-like prose |

Output `reviews/optimization-report.md` with high/medium/low priority issues, locations, evidence, and recommendations. Scan output is a review surface, not an automatic error list.

If the user asks to edit the draft directly:

1. Confirm whether DOCX is generated from Markdown/scripts and edit reproducible sources first.
2. Revise by chapter responsibility: abstract, introduction, background, requirements, design, implementation, testing, conclusion.
3. Check every sentence about current configuration against code/configuration, especially cloud APIs, local models, offline capability, backend services, databases, authentication, and test data.
4. Regenerate DOCX.
5. Run delivery validation.

If the target DOCX is open in Word/WPS, has a lock file, or `lsof` shows a write handle, do not overwrite it. Write a suffixed file and tell the user.

## Phase 4: Full Review

Before DOCX generation, score each dimension from 1 to 5. Any score below 3 requires revision:

| Dimension | Checks |
|---|---|
| Contribution completeness | problem, method, system, validation, conclusion form a closed loop |
| Writing clarity | chapter thesis, paragraph message chain, terminology, transitions |
| Technical rigor | architecture, modules, APIs, algorithms, tests match code |
| Evidence sufficiency | claims, data, references, figures/tables are traceable |
| Format compliance | template styles, numbering, citations, pages, word count |

Replace vague patterns such as “in recent years,” “plays an important role,” “significant,” “robust,” and “achieved good results” with concrete problems, data, results, or limitations.

## Phase 5: DOCX Delivery

Generate from the template and use existing template styles. Load `references/docx-spec.md` when OOXML details are needed.

Before delivery, verify:

- File state: target DOCX is not open in Word/WPS; if locked, a suffixed output is created.
- Citation order: first-seen new references are `[1]`, `[2]`, `[3]`; repeated citations reuse their number.
- Citation style: numeric body citations are superscript when required; multiple citations are ascending.
- References: in-text numbering matches the reference list; automatic numbering has no manual prefixes.
- Keywords: keyword lines match the template.
- TOC depth: TOC field and heading outline levels match the template after field update.
- Chapter roles: background does not contain implementation detail, design does not paste code, implementation does not become a path list, testing does not overgeneralize.
- Factual boundaries: cloud APIs, local models, offline capability, test samples, and deployment conditions match evidence.

Suggested DOCX validation:

```bash
python scripts/validate_thesis_docx.py thesis-final.docx --refs-auto-numbered --toc-must-contain 'Heading 1,1,Heading 2,2' --toc-must-not-contain 'Heading 3' --no-outline-style 'Heading 3'
```

## Red Lines

Stop and fix evidence or ask the user when any signal appears:

| Signal | Action |
|---|---|
| Formatting before parsing the template | Run Phase -1 |
| References recalled from memory | Search and record sources |
| Technical point has no code evidence | Return to Phase 0 |
| Performance metric lacks test data | Delete, downgrade, or add tests |
| Thesis describes a missing feature | Revise the thesis or ask whether to implement it |
| First body citation is not `[1]` or first-seen sequence skips numbers | Reorder citations and references in the source |
| Duplicate keyword lines appear without template basis | Keep only the required keyword lines |
| TOC update shows unwanted heading levels | Fix TOC field and heading outline levels |
| Current configuration depends on a cloud API but thesis claims offline operation | Write cloud API as current configuration; offline support only as optional integration or future work |
