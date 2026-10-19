# PA State — Status Naskah Terkini

> 1 halaman. Update tiap sesi bimbingan/revisi.

**Terakhir diupdate:** 2026-10-18
**Fase:** **Penyelarasan Naskah BAB 1–3 (Rewrite NestJS & Generalisasi Domain)**

**Progress:** 80% PA naskah (BAB 1 selesai draf ulang natural, persiapan BAB 2 & 3).

## Judul PA

**Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum**

## Pilar Arsitektur Terpadu (ADR-007, ADR-011)

1. **Generalisasi Domain Kost Multi-Gedung**: Solusi umum pengelolaan kost komersial multi-gedung tanpa keterikatan kaku pada satu nama properti.
2. **Modular Monolith NestJS**: 9 modul mandiri, penegakan batas modul bawaan framework, komunikasi event-driven, dan nol FK fisik lintas modul.
3. **Penyederhanaan Skema 13 Tabel**: Fokus sewa bulanan murni, konfigurasi per gedung (`building_settings`), mengeliminasi 28 tabel warisan.
4. **Antarmuka Web-First (Flutter Web)**: Prioritas implementasi dan evaluasi fungsional pada Web, dengan arsitektur Clean Architecture yang siap ekspansi ke Mobile.
5. **Standar Kontrak REST API & DTO**: Response envelope seragam, validasi ketat `class-validator`, dan dokumentasi otomatis OpenAPI Swagger.
6. **Identity & Access Management (Keycloak SSO OIDC)**: Integrasi Keycloak untuk menangani email validation, forgot password, dan session out-of-the-box; backend NestJS verifikasi stateless JWT via JWKS.
7. **Dashboard Analitik & Integrasi MCP AI**: Agregasi baca metrik operasional serta modul server MCP read-only untuk kueri cepat asisten AI/LLM bagi pemilik dan pengelola.

## Apa yang Sudah Selesai

- ✅ **ADR-007 & ADR-011 Ditetapkan**: Keputusan rewrite 13 tabel bulanan, transisi ke NestJS, platform web-first, dan generalisasi domain kost dicatat di `Docs/03_logs/DECISIONS.md`.
- ✅ **BAB 1 Naskah Diperbarui**: Ditulis ulang dengan gaya bahasa natural Indonesia, bebas dari istilah kaku dan dependensi wisma tunggal.

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