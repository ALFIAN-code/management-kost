# Skill Blockers — Aturan Hybrid untuk AI Penulis

> Hasil evaluasi 6 skill (lihat `Docs/03_logs/DECISIONS.md` ADR-002). File ini SOP blocker yang wajib dipatuhi AI. Skill fisik ter-vendor di `PA/docs/skills/` — provenance/lisensi di `../skills/SOURCES.md`.
>
> **Aturan baca:** setiap seksi di bawah mencantumkan **path lokal persis** (relatif dari `PA/docs/02_reference/`). AI **wajib Read file yang dirujuk sebelum eksekusi mode terkait** — jangan hanya baca SOP ini.

## 1. Primary: 1-pluto1/thesis-writing-en (Code-Backed Thesis)

**File lokal (wajib dibaca):**
- `../skills/thesis-writing-en/SKILL.md` — workflow utama (generate dari template, code-backed claims, review, citation check, docx finalize)
- `../skills/thesis-writing-en/references/docx-spec.md` — spesifikasi detail docx (wajib sebelum generate)
- `../skills/thesis-writing-en/scripts/validate_citation_order.py` — cek sitasi `[1]` urut
- `../skills/thesis-writing-en/scripts/validate_thesis_docx.py` — cek docx final (refs auto-numbered, TOC, outline style)
- `../skills/thesis-writing-en/scripts/extract_docx_draft.py` — extract docx → markdown untuk review
- `../skills/thesis-writing-en/scripts/parse_docx_template.py` — parse template kampus → baseline
- Upstream: `https://github.com/1-pluto1/thesis-writing-skills` (`skills/thesis-writing-en/`), Apache-2.0

**Aturan:**
- **Source-first editing:** markdown adalah sumber. DOCX di-generate dari markdown via script, jangan edit docx langsung lalu lupa update markdown.
- **Citation order:** sitasi pertama di body harus `[1]`, urut. Jalankan `validate_citation_order.py` sebelum docx:
  `python ../skills/thesis-writing-en/scripts/validate_citation_order.py ../../modules --references ../DAFTAR_PUSTAKA.md --order bab1 bab2 bab3 bab4 bab5`
- **DOCX validation:** `validate_thesis_docx.py` — cek refs auto-numbered, TOC level (Heading 3 tidak bocor), no-outline-style.
- **Anti-overclaim:** klaim kemampuan/hasil/deployment harus trace ke kode/config/test/log atau bukti user. Tanpa bukti → flag, jangan tulis sebagai fakta.
- **No fabricated refs:** metadata literatur hanya dari hasil search verifikabel (S2/Crossref), bukan dari memori.

## 2. Rigor: Imbad0202/academic-research-skills (Subset — BUKAN full suite)

> Full repo 10-stage (~$4-6, hooks, cross-model) TIDAK di-vendor. Hanya 2 sub-skill di bawah yang dipakai.

**File lokal — Deep-research lite (untuk BAB1-2, wajib dibaca sebelum literature review):**
- `../skills/deep-research-lite/SKILL.md` — upstream `deep-research/SKILL.md` (13-agent pipeline, 8 modes; yang dipakai: `lit-review`, `systematic-review`, `socratic`, `fact-check`)
- `../skills/deep-research-lite/references/semantic_scholar_api_protocol.md` — protokol S2 API (search bulk, filter, verifikasi)
- `../skills/deep-research-lite/references/openalex_api_protocol.md` — protokol OpenAlex (multi-source discovery)
- `../skills/deep-research-lite/references/crossref_api_protocol.md` — verifikasi DOI/metadata
- `../skills/deep-research-lite/references/systematic_review_protocol.md` — PRISMA-style screening
- `../skills/deep-research-lite/references/source_quality_hierarchy.md` — hierarki kualitas sumber
- `../skills/deep-research-lite/references/mode_selection_guide.md` — pilih mode (full/quick/lit-review/socratic)
- Upstream: `https://github.com/Imbad0202/academic-research-skills` (`deep-research/`), CC BY-NC 4.0 (non-komersial saja)

**File lokal — Integrity gate Stage 2.5/4.5 (wajib dibaca sebelum generate docx):**
- `../skills/integrity-gate/SKILL.md` — upstream `academic-pipeline/SKILL.md` (orchestrator; yang dipakai hanya gate 2.5/4.5, bukan full 10 stage)
- `../skills/integrity-gate/references/integrity_review_protocol.md` — protokol gate 2.5/4.5
- `../skills/integrity-gate/references/claim_verification_protocol.md` — verifikasi klaim vs sumber
- `../skills/integrity-gate/references/ai_research_failure_modes.md` — 7 failure modes (frame-lock, halusinasi sitasi, dst.)
- `../skills/integrity-gate/references/claim_audit_calibration_protocol.md` — audit claim + kalibrasi
- `../skills/integrity-gate/references/plagiarism_detection_protocol.md` — cek plagiarisme/parafrase
- Upstream: `https://github.com/Imbad0202/academic-research-skills` (`academic-pipeline/`), CC BY-NC 4.0

**Aturan:**
- **Deep-research lite untuk BAB1-2:** baca `mode_selection_guide.md` → pilih `lit-review` → search multi-source (S2 bulk + OpenAlex + SINTA) mengikuti `semantic_scholar_api_protocol.md` → screening via `systematic_review_protocol.md` → nilai bobot via `source_quality_hierarchy.md` → isi `../TABEL_JURNAL.md` (stop jika 3 search berturut-turut tidak ada temuan baru).
- **Integrity gate Stage 2.5/4.5 (wajib sebelum docx):** jalankan checklist 7 mode dari `integrity_review_protocol.md` + `claim_verification_protocol.md`:
  1. citation existence (semua `[n]` ada di `../DAFTAR_PUSTAKA.md` + DOI resolve via `crossref_api_protocol.md`)
  2. claim-source alignment (klaim BAB2 didukung abstrak jurnal)
  3. code-claim alignment (klaim BAB3 ada file-nya di `Project/`)
  4. figure fidelity (setiap Gambar dirujuk + caption benar)
  5. reporting conformance (sistematika 5 BAB sesuai `../PANDUAN_PENULISAN.md`)
  6. no hallucinated stats (angka harus ada sumber; cek `ai_research_failure_modes.md`)
  7. language (Indonesia formal)
- Gate bersifat **blocking**: jika HIGH-WARN (claim-not-supported, fabricated-ref, anchorless) → tolak generate docx, perbaiki dulu.

## 3. Engine: ComposioHQ/docx

**File lokal (wajib dibaca sesuai tugas):**
- `../skills/docx-engine/SKILL.md` — decision tree: read vs create vs edit vs redlining (upstream `document-skills/docx/SKILL.md`)
- `../skills/docx-engine/docx-js.md` — WAJIB baca utuh sebelum create docx baru (~500 baris)
- `../skills/docx-engine/ooxml.md` — WAJIB baca utuh sebelum edit/redlining docx (~600 baris, Document library + tracked-change patterns)
- Upstream: `https://github.com/ComposioHQ/awesome-claude-skills` (`document-skills/docx/`), Proprietary (baca LICENSE.txt upstream sebelum redistribusi)

**Aturan:**
- **Create:** `python-docx` / `docx-js` dari markdown. Style dari `../TEMPLATE_BASELINE.md`. Baca `docx-js.md` utuh dulu.
- **Redlining revisi dosen:** tracked changes (`w:ins`/`w:del`) via `ooxml` — baca `ooxml.md` utuh dulu, batch 3-10 perubahan per script, verifikasi via `pandoc --track-changes=all`.
- **Verifikasi visual:** `soffice --convert-to pdf` + `pdftoppm` jika perlu cek layout.

## 4. Arsitektur: AlessandroCaforio (Project Brain — pola, bukan konten)

**File lokal (pola yang diadopsi; konten ekonomi/TWFE/LaTeX upstream TIDAK dipakai mentah):**
- `../skills/project-brain/CLAUDE-REFERENCE.md` — pola project brain 600 baris (upstream `CLAUDE.md`): sumber data, pipeline, code decisions, findings, DO/DON'T, session log
- `../skills/project-brain/README-UPSTREAM.md` — arsitektur 3 lapis (brain + rules + skills/agents)
- `../skills/project-brain/rules/verification-protocol.md`, `quality-gates.md`, `notation-registry.md`, `latex-conventions.md`, `literature-citations.md`, `forward-references.md`, `python-conventions.md`, `causal-inference.md` — 8 rules upstream sebagai referensi pola (yang diadopsi: verification-protocol, quality-gates advisory, literature-citations; sisanya diganti aturan PA di `01_guides/`)
- `../skills/project-brain/skills-pattern/write-section-SKILL.md`, `proofread-SKILL.md`, `verify-claims-SKILL.md` — pola 3 skill (upstream `.claude/skills/.../SKILL.md`; `verify-claims` butuh ChromaDB RAG — tanpa itu pakai checklist manual seksi 2)
- Upstream: `https://github.com/AlessandroCaforio/Academic-Writing`, MIT

**Aturan:**
- `PA/docs/00_overview/STATE.md` = project brain (selalu update tiap sesi, tiru pola session log upstream).
- Rules always-on: sitasi numeric, source-first, no-overclaim (file ini + `01_guides/PANDUAN_PENULISAN.md`).
- DO/DON'T list: DO trace ke kode; DON'T sarankan microservice tanpa ADR.

## 5. Writing: David-Saeteros/academic-writing (Secondary)

**File lokal (wajib dibaca sesuai mode):**
- `../skills/academic-writing/SKILL.md` — deteksi mode otomatis: Draft / Edit / Structure / Citation / Reviewer-response / Thesis-review
- `../skills/academic-writing/references/section-guides.md` — panduan drafting per section (intro, methods, results, dst.)
- `../skills/academic-writing/references/apa7-extended.md` — katalog APA 7 (dipakai hanya jika pembimbing minta konversi dari numeric; default PA ini numeric)
- Upstream: `https://github.com/David-Saeteros/claude-skills` (`skills/academic-writing/`), CC BY 4.0

**Aturan:**
- Mode: Draft (dengan `[CITATION NEEDED]` + self-audit), Edit (flag precision/rigor, tanya sebelum rewrite substantif), Structure (map argumen, diagnose gap).
- Selalu tangkap: causal language tanpa data, "signifikan" non-statistik, singkatan undefined.

## 6. Index: O0000-code/awesome-academic-skills (tidak di-vendor)

- Upstream: `https://github.com/O0000-code/awesome-academic-skills`, CC0 — katalog 222 skill per lifecycle. Dirujuk hanya saat butuh skill tambahan (misal figure generation, translation). Tidak ada file lokal.

## Trigger untuk AI (dengan file yang wajib dibaca)

| Perintah user | Baca dulu | Lalu |
|---|---|---|
| "Tulis BABx" | `../skills/thesis-writing-en/SKILL.md` + `../skills/academic-writing/references/section-guides.md` + `../TABEL_JURNAL.md` | Draft + source-first + self-audit |
| "Cari jurnal X" | `../skills/deep-research-lite/references/mode_selection_guide.md` + `semantic_scholar_api_protocol.md` | Search → screening → `TABEL_JURNAL.md` |
| "Cek sitasi" | `../skills/thesis-writing-en/scripts/validate_citation_order.py` + `../skills/deep-research-lite/references/crossref_api_protocol.md` | Verify DOI → perbaiki urutan |
| "Generate docx" | `../skills/integrity-gate/references/integrity_review_protocol.md` + `../skills/thesis-writing-en/references/docx-spec.md` + (`../skills/docx-engine/docx-js.md` jika docx baru) | Gate dulu → generate → `validate_thesis_docx.py` |
| "Revisi dosen" | `../skills/docx-engine/ooxml.md` + `../skills/academic-writing/SKILL.md` (mode Edit/Thesis-review) | Redlining + update `03_logs/PROGRESS_LOG.md` |
