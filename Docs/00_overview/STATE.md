# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-10-23
**Fase:** **REWRITE TOTAL (ADR-007, ADR-011)** — Generalisasi Domain Kost Multi-Gedung, Backend NestJS, Frontend Web-First (Flutter Web).
**Progress keseluruhan:** 80% PA naskah (penyelarasan BAB 1–3 ke arsitektur NestJS & generalisasi kost), 40% Project/kode (persiapan scaffolding repo NestJS).

## Pilar Arsitektur Terpadu (ADR-007, ADR-011)

1. **Generalisasi Domain Kost Multi-Gedung (ADR-011):** Menghapus dependensi studi kasus tunggal (Wisma Amal); sistem ditujukan untuk manajemen rumah kost multi-gedung secara umum.
2. **Backend Modular Monolith NestJS (ADR-011):** 9 modul terenkapsulasi bawaan (`@Module()`), nol FK fisik lintas modul, event-driven mutasi, dan pembacaan via Module Gateway.
3. **Penyederhanaan Skema 13 Tabel Domain (ADR-007):** Sewa bulanan murni, aturan per gedung (`building_settings`), mengeliminasi 28 tabel warisan berlebih.
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
- ✅ **BAB 3 Rekonstruksi Desain Sistem Selesai**: Naskah ditulis ulang berfokus murni pada desain sistem & diagram fungsional (Arsitektur Terpadu, 9 Alur Bisnis, DFD Level 0 & 1, ERD 13 Tabel, Mockup Antarmuka) sesuai proposal acuan. Kode endpoint mentah & konfigurasi kontainer diarsipkan ke `DRAFT_v1_2026-10-21.md`.
- ✅ **Environment produksi aktif & terbarukan** — stack Laravel 11 + MySQL 8 + Flutter Web ter-deploy di server `ALLVVNT` (`100.92.12.28`) via Docker Compose, diekspos Cloudflare Tunnel di `wismaamal.allvvnt.my.id` (frontend) dan `api-wismaamal.allvvnt.my.id` (API + Swagger `/docs/api`). Seluruh UI frontend dan seed data backend telah diterjemahkan ke Bahasa Inggris, serta CanvasKit di-host lokal (`--no-web-resources-cdn`) untuk kelancaran rendering di Safari tanpa CDN eksternal.
- ✅ **Seluruh diagram HTML dinormalisasi ke light mode** (2026-10-22): diagram Arsitektur Backend Modular Monolith diubah dari tema gelap ke terang tanpa mengubah tata letak, ERD per-modul dipaksa light mode agar tidak mengikuti tema gelap sistem, dan ekspor `.svg`/`.png` dibangun ulang agar sinkron dengan HTML.
- ✅ **Skala tipografi & resolusi seluruh diagram sistem diperbesar** (2026-10-22): seluruh diagram HTML inti (`arsitektur_backend_modulith`, `arsitektur_terpadu`, `dfd_level_0_context`, `dfd_level_1_dekomposisi`, `erd_13_tabel`, `erd_sistem_dinamis`) ditingkatkan ukuran font (14–28px, tebal 700–800) dan diekspor ulang ke SVG serta PNG 2x resolusi tinggi agar tajam dan terbaca jelas pada skala dokumen Word/A4 16 cm.
- ✅ **Redesain 9 Alur BPMN ke Format HTML Interaktif & Bebas Whitespace** (2026-10-22): seluruh 9 alur bisnis dikonversi dari diagram sekuens/mermaid kaku menjadi diagram kolaborasi BPMN 2.0 (Pool/Lane) berorientasi proses bisnis (non-teknis), dilengkapi tombol download SVG dan PNG 2x resolusi tinggi.
- ✅ **Penyempurnaan Total Routing Panah & Resolusi Overlap BPMN** (2026-10-23): revisi menyeluruh terhadap 6 diagram BPMN (alur 01, 02, 03, 04, 06, 08) untuk mengeliminasi overlap panah, memastikan arah panah vertikal hanya keluar dari sisi atas/bawah yang tepat, memisahkan koridor vertikal, dan menunggalkan titik akhir alur.
- ✅ **UML 2.5 Use Case Diagram Global** (2026-10-23): implementasi diagram interaktif HTML di `PA/docs/System design/05-Use-Case/use_case_global.html` beserta ekspor SVG dan PNG 2x resolusi cetak (1560x1380 px) berdesain super kompak bebas celah horizontal (780x690 px), mencakup 4 aktor manusia, 4 sistem eksternal, dan 17 use case (13 primer, 4 sub-use case terintegrasi).
- 🟡 **Blocker sitasi** masih terbuka: `[36]`, `[41]`, dan urutan kemunculan `[1]`.

## Roadmap Kerja Terkini

1. 🟡 **Fase Naskah:** Sinkronisasi BAB 1 (selesai draf), revisi BAB 2 & 3 mengikuti arsitektur NestJS 13 tabel dan Flutter Web.
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