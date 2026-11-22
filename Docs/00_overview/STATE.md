# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-11-22
**Fase:** **Revisi Penguji Selesai pada `PA/latex/` (BAB 1–3, 10 Modul + AI, 28 Diagram Terverifikasi)**
**Progress keseluruhan:** 90% PA naskah (revisi penguji BAB 1–3, ERD sistem lama 34 tabel, Flowchart Evaluasi, 28 diagram `.png`, & 28 entri BibTeX selesai dan terverifikasi di `PA/latex/`), 40% Project/kode.

## Pilar Arsitektur Terpadu (ADR-007, ADR-011)

1. **Generalisasi Domain Kost Multi-Gedung (ADR-011):** Menghapus dependensi studi kasus tunggal (Wisma Amal); sistem ditujukan untuk manajemen rumah kost multi-gedung secara umum.
2. **Backend Modular Monolith NestJS (ADR-011):** 9 modul terenkapsulasi bawaan (`@Module()`), nol FK fisik lintas modul, event-driven mutasi, dan pembacaan via Module Gateway.
3. **Skema Basis Data 21 Tabel Domain (ADR-014):** Skema basis data terpadu 21 tabel domain utama (24 entitas fisik) pada `erd_sistem_dinamis.html` / `erd_sistem_dinamis.png`, mencakup 9 modul (4 Core + 5 Opsional) dengan pemetaan 1-ke-1 terhadap 17 fitur sistem dan nol FK fisik lintas modul via soft-reference.
4. **Platform Antarmuka Web-First (Flutter Web) (ADR-011):** Prioritas implementasi dan pengujian fungsional pada Flutter Web (desktop/tablet), kesiapan mobile sebagai *expansion readiness*.
5. **Standarisasi Kontrak REST API & DTO:** Amplop JSON seragam `{status, message, data, meta, errors}`, validasi DTO `class-validator`, dan dokumentasi otomatis OpenAPI Swagger.
6. **Identity & Access Management (Keycloak SSO OIDC):** Server Keycloak mandiri untuk email validation, forgot password, dan session handling; NestJS verifikasi stateless JWT via JWKS + tenant scoping `building_id`.
7. **Dashboard Analitik & Integrasi MCP AI:** Endpoint agregasi baca operasional serta modul server MCP read-only untuk memfasilitasi asisten AI/LLM dalam kueri data cepat pemilik/pengelola.

## Apa yang Sudah Selesai

- ✅ ADR-007 (Rewrite Total Kost Bulanan 13 Tabel) disahkan di `Docs/03_logs/DECISIONS.md`.
- ✅ ADR-011 (Generalisasi Domain, Backend NestJS, Platform Web-First) disahkan di `Docs/03_logs/DECISIONS.md`.
- ✅ ADR-012 (PostgreSQL Basis Data Utama & Docker Wajib Deployment) disahkan di `Docs/03_logs/DECISIONS.md`.
- ✅ ADR-013 (Kebijakan Booking DP Dinamis Two-Phase Invoicing, Alur Refund Semi-Manual Berbukti Transfer, dan Otomasi Penagihan Siklus Ulang Tahun) disahkan di `Docs/03_logs/DECISIONS.md`.
- ✅ Draft BAB 1 diselaraskan dengan gaya penulisan natural Indonesia (bebas kata kaku/AI-isms).
- ✅ **BAB 3 Rekonstruksi Desain Sistem Selesai**: Naskah ditulis ulang berfokus murni pada desain sistem & diagram fungsional (Arsitektur Terpadu, 9 Alur Bisnis, DFD Level 0 & 1, ERD Skema Perluasan 18–19 Tabel, Mockup Antarmuka) sesuai proposal acuan. Kode endpoint mentah & konfigurasi kontainer diarsipkan ke `DRAFT_v1_2026-10-21.md`.
- ✅ **BAB 3 §3.6.3 Klasifikasi Modul Core dan Opsional ditambahkan**: sub-bab baru di `PA/docs/modules/bab3/README.md` mengklasifikasikan 10 modul (5 core wajib aktif + 5 opsional plug-and-play) dengan tabel utama dan penjelasan konteks data tanpa FK fisik lintas modul.
- ✅ **BAB 3 §3.6.4 Scenario Pengujian Kombinasi Modul & Diagram Klasifikasi Modul disahkan**: 6 skenario pengujian dengan pendekatan Core Baseline + Individual, diagram visual vektor SVG di `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.html` (beserta export SVG dan PNG 2x resolusi cetak) dirancang ramah bagi orang awam tanpa kode teknis. Disematkan sebagai Gambar 3.19 di naskah.
- ✅ **BAB 2 §2.1.6 Evolusi Desain Sistem ditambahkan**: sub-bab baru di `PA/docs/modules/bab2/README.md` sebagai jembatan antara permasalahan dan teori penunjang, dengan 2 gambar desain sistem lama (arsitektur keseluruhan + ERD 41 tabel) dan tabel perbandingan 6 aspek sistem lama vs baru.
- ✅ **Environment produksi aktif & terbarukan** — stack Laravel 11 + MySQL 8 + Flutter Web ter-deploy di server `ALLVVNT` (`100.92.12.28`) via Docker Compose, diekspos Cloudflare Tunnel di `wismaamal.allvvnt.my.id` (frontend) dan `api-wismaamal.allvvnt.my.id` (API + Swagger `/docs/api`). Seluruh UI frontend dan seed data backend telah diterjemahkan ke Bahasa Inggris, serta CanvasKit di-host lokal (`--no-web-resources-cdn`) untuk kelancaran rendering di Safari tanpa CDN eksternal.
- ✅ **Seluruh diagram HTML dinormalisasi ke light mode** (2026-10-22): diagram Arsitektur Backend Modular Monolith diubah dari tema gelap ke terang tanpa mengubah tata letak, ERD per-modul dipaksa light mode agar tidak mengikuti tema gelap sistem, dan ekspor `.svg`/`.png` dibangun ulang agar sinkron dengan HTML.
- ✅ **Skala tipografi & resolusi seluruh diagram sistem diperbesar** (2026-10-22): seluruh diagram HTML inti (`arsitektur_backend_modulith`, `arsitektur_terpadu`, `dfd_level_0_context`, `dfd_level_1_dekomposisi`, `erd_13_tabel`, `erd_sistem_dinamis`) ditingkatkan ukuran font (14–28px, tebal 700–800) dan diekspor ulang ke SVG serta PNG 2x resolusi tinggi agar tajam dan terbaca jelas pada skala dokumen Word/A4 16 cm.
- ✅ **Redesain 9 Alur BPMN ke Format HTML Interaktif & Bebas Whitespace** (2026-10-22): seluruh 9 alur bisnis dikonversi dari diagram sekuens/mermaid kaku menjadi diagram kolaborasi BPMN 2.0 (Pool/Lane) berorientasi proses bisnis (non-teknis), dilengkapi tombol download SVG dan PNG 2x resolusi tinggi.
- ✅ **Penyempurnaan Total Routing Panah & Resolusi Overlap BPMN** (2026-10-23): revisi menyeluruh terhadap 6 diagram BPMN (alur 01, 02, 03, 04, 06, 08) untuk mengeliminasi overlap panah, memastikan arah panah vertikal hanya keluar dari sisi atas/bawah yang tepat, memisahkan koridor vertikal, dan menunggalkan titik akhir alur.
- ✅ **UML 2.5 Use Case Diagram Global** (2026-10-23): implementasi diagram interaktif HTML di `PA/docs/System design/05-Use-Case/use_case_global.html` beserta ekspor SVG dan PNG 2x resolusi cetak (1560x1380 px) berdesain super kompak bebas celah horizontal (780x690 px), mencakup 4 aktor manusia, 4 sistem eksternal, dan 17 use case (13 primer, 4 sub-use case terintegrasi).
- ✅ **Sinkronisasi BAB 1–3 & Daftar Pustaka dengan PDF Master** (2026-11-22): `PA/docs/modules/bab1..bab3`, `DAFTAR_PUSTAKA_LENGKAP.md`, `figures_to_images.py`, dan `full_draft.md` telah diselaraskan dengan `PA/master/Naskah Proyek Akhir 1.0.pdf` beserta 27 gambar `.png` ter-embed.
- ✅ **Restrukturisasi BAB 1–2 & Setup Proyek LaTeX `PA/latex/` (`buku-pa-pens-latex`)** (2026-11-22): `bab1` & `bab2` dirapikan sesuai struktur resmi PENS (sitasi awal BAB 1 kini berurutan mulai `[1]`, blocker sitasi `[2]` sebelum `[1]` terselesaikan). `PA/latex/` kini menjadi **Source of Truth** baru naskah PA berisi `variables.tex`, `packages.tex` (`listings`), `references.bib` (28 entri), 27 gambar `.png` di `assets/diagrams/`, konversi penuh `bab1.tex`–`bab3.tex`, dan kerangka `bab4.tex`–`bab5.tex` bersih (terverifikasi via skrip Python).

## Roadmap Kerja Terkini

1. 🟡 **Fase Naskah (LaTeX):** `PA/latex/` siap — kompilasi PDF (`make proposal-v2` / `make progres-v2` / `make buku`) menunggu instalasi `mactex-no-gui` lokal atau upload ke Overleaf, serta pengisian `pages/` prelim & BAB 4–5 saat fase Buku PA.
2. ⚪ **Fase Desain Teknis:** Finalisasi spesifikasi kontrak endpoint REST API & skema event bus NestJS.
3. ⚪ **Fase Implementasi:** Scaffolding basis kode backend baru berbasis NestJS modular & Flutter Web.
4. 🟡 **Operasionalisasi:** Menulis panduan deploy repeatable di `Docs/`, memperbaiki letak workflow CI ke root repo, dan mengisi kredensial Midtrans.


## Blocker / Keputusan Pending

- Judul dipertahankan: **Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo).
- Scope Multi-Tenant: Shared-DB with row-level scoping (`building_id`).
- Scope AI MCP: Read-only query & insight reporting (fase 1).

## Link Cepat

- `Docs/00_overview/ARCHITECTURE.md` → index federasi (hub)
- `PA/docs/00_overview/ARCHITECTURE.md` → index skripsi
- `Docs/03_logs/DECISIONS.md` → ADR terbaru (ADR-001 s/d ADR-006)
- `Docs/03_logs/PROGRESS_LOG.md` → histori sesi global