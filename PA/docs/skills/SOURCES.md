# Skills — Sumber & Lisensi

> Vendored skill files untuk penulisan PA. Diunduh 2025-09-20 dari upstream. Cek update berkala; file ini jejak provenance (jangan edit skill tanpa catat di sini + DECISIONS).

| Folder lokal | Upstream | Lisensi | Cakupan (sesuai ADR-002) |
|---|---|---|---|
| `skills/thesis-writing-en/` (SKILL.md + `references/docx-spec.md` + `scripts/*.py`) | [1-pluto1/thesis-writing-skills](https://github.com/1-pluto1/thesis-writing-skills) (`skills/thesis-writing-en/`) | Apache-2.0 | **PRIMARY full** — code-backed thesis, citation order, docx validation |
| `skills/docx-engine/` (SKILL.md + `docx-js.md` + `ooxml.md`) | [ComposioHQ/awesome-claude-skills](https://github.com/ComposioHQ/awesome-claude-skills) (`document-skills/docx/`) | Proprietary (LICENSE.txt upstream) | **Engine full** — create/edit/redlining docx |
| `skills/academic-writing/` (SKILL.md + `references/section-guides.md`, `apa7-extended.md`) | [David-Saeteros/claude-skills](https://github.com/David-Saeteros/claude-skills) (`skills/academic-writing/`) | CC BY 4.0 | **Secondary full** — draft/edit/structure/citation modes |
| `skills/deep-research-lite/` (SKILL.md + 6 protocol refs) | [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (`deep-research/`) | CC BY-NC 4.0 | **Subset**: lit-review + S2/OpenAlex/Crossref protocols. Full 13-agent pipeline TIDAK di-vendor (overkill, lihat ADR-002) |
| `skills/integrity-gate/` (SKILL.md + 5 protocol refs) | [Imbad0202/academic-research-skills](https://github.com/Imbad0202/academic-research-skills) (`academic-pipeline/`) | CC BY-NC 4.0 | **Subset**: integrity/claim-verification/failure-modes/audit/plagiarism. Full 10-stage orchestrator TIDAK dijalankan |
| `skills/project-brain/` (CLAUDE-REFERENCE.md + README-UPSTREAM.md + `rules/*.md` + `skills-pattern/*`) | [AlessandroCaforio/Academic-Writing](https://github.com/AlessandroCaforio/Academic-Writing) | MIT | **Adaptasi pola**: project brain + 8 rules + 3 skill patterns (write-section, proofread, verify-claims). Konten ekonomi/LaTeX/TWFE TIDAK dipakai mentah |
| (tidak di-vendor) | [O0000-code/awesome-academic-skills](https://github.com/O0000-code/awesome-academic-skills) | CC0 (index) | **Index saja** — katalog 222 skill, dirujuk saat butuh skill tambahan |

## Catatan Non-Komersial

- `Imbad0202` berlisensi **CC BY-NC 4.0** — folder `deep-research-lite/` & `integrity-gate/` hanya untuk akademik non-komersial (PA). Jangan pakai untuk proyek komersial.
- `docx-engine` proprietary — baca `LICENSE.txt` upstream sebelum redistribusi.
- `verify-claims` pattern butuh ChromaDB RAG (opsional) — tanpa itu, pakai checklist manual di `02_reference/SKILL_BLOCKERS.md`.
