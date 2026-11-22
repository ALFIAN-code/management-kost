# PA State — Status Naskah Terkini

> 1 halaman. Update tiap sesi bimbingan/revisi.

**Terakhir diupdate:** 2026-11-22
**Fase:** **Revisi Penguji Selesai pada `PA/latex/` (BAB 1–3, 10 Modul + AI, 28 Diagram Terverifikasi)**

**Progress:** 90% PA naskah (revisi penguji untuk BAB 1–3, ERD sistem lama 34 tabel, Flowchart Evaluasi, 28 gambar PNG, dan 28 entri BibTeX selesai dan terverifikasi di `PA/latex/`).

## Judul PA

**Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum**

## Pilar Arsitektur Terpadu (ADR-007, ADR-011)

1. **Generalisasi Domain Kost Multi-Gedung**: Solusi umum pengelolaan kost komersial multi-gedung tanpa keterikatan kaku pada satu nama properti.
2. **Modular Monolith NestJS**: 9 modul mandiri, penegakan batas modul bawaan framework, komunikasi event-driven, dan nol FK fisik lintas modul.
3. **Skema Basis Data 21 Tabel Domain (ADR-014 / PA-DEC-004)**: Mengadopsi skema 21 tabel domain utama (24 entitas fisik) dari `erd_sistem_dinamis.html` / `erd_sistem_dinamis.png`, mencakup 9 modul dengan penegakan nol FK fisik lintas modul via soft-reference.
4. **Antarmuka Web-First (Flutter Web)**: Prioritas implementasi dan evaluasi fungsional pada Web, dengan arsitektur Clean Architecture yang siap ekspansi ke Mobile.
5. **Standar Kontrak REST API & DTO**: Response envelope seragam, validasi ketat `class-validator`, dan dokumentasi otomatis OpenAPI Swagger.
6. **Identity & Access Management (Keycloak SSO OIDC)**: Integrasi Keycloak untuk menangani email validation, forgot password, dan session out-of-the-box; backend NestJS verifikasi stateless JWT via JWKS.
7. **Dashboard Analitik & Integrasi MCP AI**: Agregasi baca metrik operasional serta modul server MCP read-only untuk kueri cepat asisten AI/LLM bagi pemilik dan pengelola.

## Apa yang Sudah Selesai

- ✅ **ADR-007 & ADR-011 Ditetapkan**: Keputusan rewrite 13 tabel bulanan, transisi ke NestJS, platform web-first, dan generalisasi domain kost dicatat di `Docs/03_logs/DECISIONS.md`.
- ✅ **BAB 1 Naskah Diperbarui**: Ditulis ulang dengan gaya bahasa natural Indonesia, bebas dari istilah kaku dan dependensi wisma tunggal.
- ✅ **BAB 3 Rekonstruksi Desain Sistem Selesai**: Naskah ditulis ulang berfokus murni pada perancangan sistem sesuai struktur proposal PENS (Arsitektur Terpadu 4 lapis, 9 Modul 3-Tier, Flutter Web Clean Architecture, 9 Alur Proses Bisnis, Use Case, DFD Level 0 & 1, Activity Diagram, ERD 13 Tabel & Kamus Data, serta Mockup Antarmuka). Detail teknis non-desain (endpoint mentah, docker-compose, JSON schema) telah dipangkas dan diarsipkan ke `DRAFT_v1_2026-10-21.md`.
- ✅ **Diagram BAB 3 terintegrasi**: 15 diagram aktif (HTML & Mermaid PNG) tertanam secara otomatis via `figures_to_images.py`, dengan 6 placeholder untuk diagram visual yang belum dibuat.
- ✅ **Cakupan fitur & Skema 18–19 Tabel (ADR-014)**: F02, F11, dan F13 diakomodasi melalui perluasan skema tabel domain, dengan Diagram Klasifikasi Modul disahkan sebagai Gambar 3.19.
- ✅ **Pipeline docx**: `PA/docs/modules/build-docx.sh` merender seluruh diagram (Mermaid dan HTML) menjadi PNG lalu menyisipkannya ke naskah sebelum konversi. `template_pens.docx` belum ada, sehingga style bawaan Pandoc masih dipakai.
- ✅ **Sinkronisasi Total dengan PDF Master (`Naskah Proyek Akhir 1.0.pdf`) (2026-11-22)**: `bab1/README.md`, `bab2/README.md`, `bab3/README.md`, `referensi/DAFTAR_PUSTAKA_LENGKAP.md`, `figures_to_images.py`, dan `full_draft.md` telah selaras dengan PDF Master beserta 27 gambar `.png` ter-embed otomatis.
- ✅ **Restrukturisasi BAB 1–2 & Setup LaTeX `PA/latex/` (`buku-pa-pens-latex`) (2026-11-22)**: Struktur `bab1` & `bab2` disesuaikan dengan template PENS (urutan sitasi pertama BAB 1 dimulai dari `[1]`, blocker sitasi terdahulu selesai). `PA/latex/` menjadi **Source of Truth** baru naskah PA dengan `variables.tex`, `packages.tex`, 28 entri di `refs/references.bib`, 27 diagram `.png` di `assets/diagrams/`, konversi lengkap `chapters/bab1.tex`–`bab3.tex`, dan kerangka bersih `bab4.tex`–`bab5.tex`.

## Roadmap Perancangan & Implementasi Baru

1. ✅ **Step 1 (Selesai):** Kaji kebutuhan & daftar fitur resmi (F01–F17).
2. ✅ **Step 2 (Selesai):** Pendefinisian alur proses bisnis lengkap (BPMN).
3. ✅ **Step 3 (Selesai):** Pemodelan data (ERD Dinamis) & aliran data (DFD L0 & L1).
4. ✅ **Step Konseptual Arsitektur (Selesai):** Desain Modular Monolith, Keycloak SSO, Outbound Adapters (disetujui untuk bekal sidang proposal).
5. ✅ **Step Sinkronisasi & Restrukturisasi Naskah (Selesai):** Sinkronisasi terhadap `PA/master/Naskah Proyek Akhir 1.0.pdf`, restrukturisasi BAB 1–2, dan konversi penuh ke `PA/latex/`.
6. 🟡 **Next Task Utama:** Kompilasi PDF di `PA/latex/` (`make proposal-v2` / `make progres-v2` / `make buku`) via MacTeX lokal (`brew install --cask mactex-no-gui`) atau Overleaf, serta melengkapi `pages/` prelim dan BAB 4–5 saat masuk fase Buku PA.
7. ⚪ **Step Lanjutan (Pasca Proposal):** Spesifikasi Kontrak API REST, Event Bus, dan Scaffolding kode.

## Blocker / Keputusan Pending

- Judul PA aktif di naskah & `PA/latex/config/variables.tex`: **Arsitektur Modular Monolithic Berbasis Event-Driven untuk Sistem Informasi Manajemen Rumah Kost Terintegrasi** (riwayat perubahan judul dari fase awal tetap tercatat di log/ADR).
- Format sitasi IEEE numeric `[1]`–`[28]` (`IEEEtranN.bst`, 23 tersitasi di BAB 1–3 + 5 entri cadangan di `references.bib`).
- `pdflatex`/`latexmk`/`bibtex` belum terpasang di macOS lokal sehingga kompilasi PDF menunggu instalasi MacTeX atau unggah ke Overleaf.

## Link Cepat

- `01_guides/PANDUAN_PENULISAN.md` → aturan kampus
- `02_reference/TEMPLATE_BASELINE.md` → format docx
- `02_reference/TABEL_JURNAL.md` → jurnal terkurasi + positioning kolom
- `03_logs/PROGRESS_LOG.md` → histori bimbingan