# PA State — Status Naskah Terkini

> 1 halaman. Update tiap sesi bimbingan/revisi.

**Terakhir diupdate:** 2026-10-21
**Fase:** **Penyelarasan Naskah BAB 1–3 (Rewrite NestJS & Generalisasi Domain)**

**Progress:** 80% PA naskah (BAB 1 selesai draf ulang natural, persiapan BAB 2 & 3).

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
- 🟡 **Blocker sitasi**: `[36]` dan `[41]` dipakai di BAB 2 tetapi tidak ada di daftar pustaka; urutan kemunculan di BAB 1 masih mulai dari `[2]`.

## Roadmap Perancangan & Implementasi Baru

1. ✅ **Step 1 (Selesai):** Kaji kebutuhan & daftar fitur resmi (F01–F17).
2. ✅ **Step 2 (Selesai):** Pendefinisian alur proses bisnis lengkap (BPMN).
3. ✅ **Step 3 (Selesai):** Pemodelan data (ERD Dinamis) & aliran data (DFD L0 & L1).
4. ✅ **Step Konseptual Arsitektur (Selesai):** Desain Modular Monolith, Keycloak SSO, Outbound Adapters (disetujui untuk bekal sidang proposal).
5. 🟡 **Next PR / Task Utama:** Revisi dan penulisan ulang naskah modul `bab1` hingga `bab3` untuk menyesuaikan dengan keseluruhan desain sistem konseptual terbaru di atas. (Akan dikerjakan di sesi berikutnya).
6. ⚪ **Step Lanjutan (Pasca Proposal):** Spesifikasi Kontrak API REST, Event Bus, dan Scaffolding kode.

## Blocker / Keputusan Pending

- Judul dipertahankan tanpa perubahan.
- Format sitasi IEEE numeric `[1]`-`[22]` konsisten.
- Lingkup MCP dibatasi read-only untuk keamanan data.

## Link Cepat

- `01_guides/PANDUAN_PENULISAN.md` → aturan kampus
- `02_reference/TEMPLATE_BASELINE.md` → format docx
- `02_reference/TABEL_JURNAL.md` → jurnal terkurasi + positioning kolom
- `03_logs/PROGRESS_LOG.md` → histori bimbingan