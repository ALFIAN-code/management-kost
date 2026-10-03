# Progress Log — PA (Bimbingan & Revisi)

> Append-only. Entry baru di paling atas. Sinkron ringkas ke `Docs/03_logs/PROGRESS_LOG.md`.

---

## [2026-10-03 22:05] Update 5 ERD per-module pasca-migration

**Status:** Selesai (sintaks tervalidasi + spot-check visual)
**Dikerjakan:**
- 5 file `permodule/erd_*.html`: +BUILDINGS, +`building_id` (13 tabel domain), +kolom SSO di USERS, +MCP_TOOL_LOGS
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)

---

## [2026-10-03 21:55] Update erd_full_database ke 41 tabel pasca-migration

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- `erd_full_database.mmd`/`.png`: +`BUILDINGS`, +`MCP_TOOL_LOGS`, +`building_id` (7 tabel), +kolom SSO di `USERS`, +10 relasi scopes-softref; render ulang

---

## [2026-10-03 21:50] Sinkronisasi docs pasca-migration (hapus klaim basi + katalog permodule)

**Status:** Selesai
**Dikerjakan:**
- Hapus 3 klaim "belum ada di kode" di BAB 3 §3.6; daftarkan 5 ERD per-cluster sebagai Gambar 3.6c–3.6g; betulkan 39 → 41 tabel
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`

---

## [2026-10-03 21:40] Eksekusi migration WAJIB skema DB (BAB 4 — implementasi target desain)

**Status:** Selesai (523 passed, 2 failed pre-existing)
**Dikerjakan:**
- 5 migration aditif: `buildings`, `building_id` (13 tabel) + `assigned_building_id`, `keycloak_id`+`auth_provider`, `mcp_tool_logs`, soft-ref 2 FK lintas-modul; `User` fillable +3; test suite hijau (minus 2 pre-existing)
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/database/migrations/2026_10_03_00000*.php`, `Modules/Auth/Models/User.php`

---

## [2026-10-03 21:20] Teori pemisahan DB 3 level + matriks 12 modul ke 5 cluster ERD

**Status:** Selesai
**Dikerjakan:**
- BAB 2 §2.2.8: teori 3 tingkatan pemisahan DB (Physical, Schema-per-Module, Logical Schema Ownership)
- BAB 3 §3.6: Tabel 3.3 matriks 12 modul → 5 domain cluster + kamus data jadi §3.6.4
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`

---

## [2026-10-03 21:00] Fix judul tabel tak terbaca di 5 ERD per-module HTML

**Status:** Selesai (terverifikasi visual via screenshot browser)
**Dikerjakan:**
- Akar masalah: CSS boilerplate memaksa teks judul entitas putih di dark mode, header box krem → tak terbaca
- Fix: kunci warna judul `#2a2723` + bold di 5 file `permodule/erd_*.html`
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)

---

## [2026-10-03 20:30] Audit skema aktual + ERD keseluruhan 39 tabel (Gambar 3.6a)

**Status:** Selesai
**Dikerjakan:**
- Audit migration aktual: 39 tabel final per modul + FK fisik + temuan (`building_id` belum ada di kode, kolom hantu, legacy Rental/Resident)
- ERD keseluruhan aktual `erd_full_database` (Gambar 3.6a FINAL) + ERD target multi-tenant (Gambar 3.6b konseptual); BAB 3 §3.6 direferensikan ke keduanya + tabel delta aktual-vs-target
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/erd_full_database.mmd`/`.png`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/02_reference/DATABASE_SCHEMA.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`

---

## [2026-10-03 13:20] Pindah component SVG ke folder 02 + adopsi 2 SVG final

**Status:** Selesai
**Dikerjakan:**
- Memindahkan `component_diagram_modular_monolith_3_tier.svg` dari `01_arsitektur_sistem_terpadu/` ke `02_hierarki_3_tier_modulith/`; referensi Gambar 2.2/3.2 + katalog + STATE diperbarui
**File yang diubah:**
- `PA/docs/diagrams/02_hierarki_3_tier_modulith/component_diagram_modular_monolith_3_tier.svg` (pindahan)
**Dokumen yang diupdate:**
- `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 (BAB 1–3) dengan embed 2 SVG final

---

## [2026-10-03 13:00] Adopsi 2 SVG final arsitektur sebagai diagram resmi docx

**Status:** Selesai
**Dikerjakan:**
- Menetapkan `c4_level2_container_wisma_amal.svg` + `component_diagram_modular_monolith_3_tier.svg` di `PA/docs/diagrams/01_arsitektur_sistem_terpadu/` sebagai diagram resmi (Gambar 2.1/2.2 & 3.1/3.2); `.mmd`/`.png` lama di folder itu disupersede
- Referensi Gambar resmi dimasukkan ke `PA/docs/modules/bab2/README.md` (§2.2.2) dan `PA/docs/modules/bab3/README.md` (§3.3); katalog `PA/docs/diagrams/README.md` baris 01 ditandai ✅ FINAL
**File yang diubah:**
- `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 (BAB 1–3) dengan embed 2 SVG final

---

## [2026-10-03 12:15] Integrasi Single Sign-On (SSO) Keycloak OIDC ke Seluruh Naskah & Diagram

**Status:** Selesai (ADR-006 + 15 Diagram MMD/PNG + Pembaruan BAB 1, 2, 3)
**Dikerjakan:**
- **Pencatatan ADR-006:** Merekam keputusan arsitektur *Single Sign-On (SSO) IAM Berbasis Keycloak OpenID Connect (OIDC)* di `Docs/03_logs/DECISIONS.md`.
- **Pembaruan BAB 1:** Menambahkan analisis gap otentikasi lama, pilar Federated Identity Keycloak SSO, butir rumusan masalah ke-6, tujuan ke-6, dan batasan teknis OIDC.
- **Pembaruan BAB 2:** Menambahkan sub-bab teori `2.2.6 Single Sign-On (SSO), OpenID Connect (OIDC), dan Arsitektur Keycloak IAM` (protokol OIDC/OAuth 2.0, realm, token exchange, stateless verification via JWKS `/certs`, JIT User Provisioning, dan identity brokering).
- **Pembaruan BAB 3:** Memperbarui arsitektur sistem Clean-Modulith + SSO, kamus basis data (tabel `users` dengan `keycloak_id` dan `auth_provider`), spesifikasi API, dan skenario pengujian.
- **Diagram Sequence SSO:** Membuat file `PA/docs/diagrams/15_sequence_sso_keycloak/sequence_sso_keycloak.mmd` dan me-render hasil `sequence_sso_keycloak.png` via `@mermaid-js/mermaid-cli`.
- **Pembaruan Katalog & State:** Memperbarui `PA/docs/diagrams/README.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, dan `PA/docs/00_overview/STATE.md` (progress PA naik ke 80%).
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
- `PA/docs/diagrams/15_sequence_sso_keycloak/**`, `PA/docs/diagrams/README.md`
- `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 11:45] Pembuatan & Rendering 14 Diagram Resmi PA ke Subfolder Terpisah

**Status:** Selesai (14 Diagram Mermaid .mmd + 14 Gambar .png)
**Dikerjakan:**
- Membuat 14 subfolder terstruktur di `PA/docs/diagrams/`:
  1. `01_arsitektur_sistem_terpadu` (Clean-Modulith + MCP AI + Multi-Tenant)
  2. `02_hierarki_3_tier_modulith` (Infrastruktur, Core, Business Boundaries Deptrac)
  3. `03_clean_architecture_frontend` (Presentation BLoC, Domain, Data Layer Single Codebase)
  4. `04_bpmn_reservasi_pembayaran` (BPMN 2.0 Reservasi, Schedule Lock, Midtrans)
  5. `05_bpmn_komplain_pemeliharaan` (BPMN 2.0 Tiket Kerusakan & Penguncian Jadwal)
  6. `06_bpmn_konsultasi_ai_mcp` (BPMN 2.0 Konsultasi AI via Protokol MCP)
  7. `07_use_case_global` (Diagram Use Case 3 Aktor + MCP AI System)
  8. `08_dfd_level_0_context` (Diagram Konteks Sistem SIM Wisma)
  9. `09_dfd_level_1_dekomposisi` (DFD Level 1: 6 Proses & 9 Data Store)
  10. `10_sequence_reservasi_event_driven` (Sequence Pessimistic Lock, Event Bus, Midtrans)
  11. `11_sequence_mcp_ai_tool_call` (Sequence Tool-Use AI, Tenant Guardrail, Grounding)
  12. `12_erd_multi_tenant_global` (ERD Relasi Multi-Gedung berbasis `buildings`)
  13. `13_feature_toggle_architecture` (Mekanisme runtime Module Discovery & Gate)
  14. `14_testing_pyramid` (Piramida Pengujian: Unit, Contract, Tenant, Integration)
- Me-render seluruh 14 file `.mmd` menjadi gambar resolusi tinggi `.png` via `@mermaid-js/mermaid-cli`.
- Membersihkan artefak diagram lama di root `PA/docs/diagrams/` dan memperbarui `PA/docs/diagrams/README.md` sebagai katalog indeks resmi.
**File yang diubah:**
- `PA/docs/diagrams/**` (14 subfolder: `.mmd` dan `.png`)
- `PA/docs/diagrams/README.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh katalog diagram dan log federasi.

---

## [2026-10-03 11:15] Rekonstruksi & Transformasi Penuh Naskah BAB 1, 2, 3 ke Dokumen Resmi

**Status:** Selesai (Naskah BAB 1-3 Lengkap ~9.500 kata)
**Dikerjakan:**
- **BAB 1 PENDAHULUAN (`PA/docs/modules/bab1/README.md`):** Ditulis ulang penuh (~2.800 kata) mencakup urgensi digitalisasi & profil empiris Wisma Amal, dekonstruksi mendalam 4 proposal previous work (tabel komparatif & 7 gap utama), justifikasi ilmiah 5 pilar refaktorisasi, 6 butir rumusan masalah dengan narasi pengantar, 6 butir tujuan koheren, batasan masalah berjustifikasi teknis, manfaat 3 stakeholder, dan sistematika penulisan.
- **BAB 2 KAJIAN PUSTAKA (`PA/docs/modules/bab2/README.md`):** Ditulis ulang penuh (~3.500 kata) mencakup deskripsi permasalahan empiris/teknis, 10 sub-bab teori penunjang mendalam (SIM Properti, 3-Tier Modulith Event-Driven & Gateway, Standar I/O REST Envelope & DTO, Multi-Tenancy Row-Level Scoping, MCP AI Tools & Deterministic Grounding, Clean Architecture Flutter, Basis Data MySQL ACID/MVCC, Midtrans Production Hardening, Testing Pyramid, Living Docs), analisis kritis 14 penelitian terkait (Tabel 2.3 komprehensif), dan sintesis gap statement.
- **BAB 3 METODOLOGI & PERANCANGAN SISTEM (`PA/docs/modules/bab3/README.md`):** Ditulis ulang penuh sebagai Software Design Document komprehensif (~3.200 kata) mencakup deskripsi solusi 5 pilar, metodologi Scrum 4 sprint (114 Story Points) + spesifikasi User Story format Gherkin, diagram blok Clean-Modulith + MCP, pemodelan proses bisnis BPMN (4 alur), Diagram Use Case Global + 4 Use Case Specifications lengkap, DFD L0 & L1, ERD Multi-Tenant + Kamus Data Basis Data lengkap (5 tabel terinci: `buildings`, `rooms`, `schedules`, `invoices`, `mcp_tool_logs`), spesifikasi antarmuka UI/UX (Web Owner Switcher & Chatbot AI, Admin, Penghuni), JSON Schema 4 tool MCP, format response envelope REST API, dan matriks 20 skenario pengujian verifikatif.
- **Pembaruan Dokumen State:** `Docs/00_overview/STATE.md` dan `PA/docs/00_overview/STATE.md` diperbarui (progress PA naik ke 75%).
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`
- `PA/docs/modules/bab2/README.md`
- `PA/docs/modules/bab3/README.md`
- `PA/docs/00_overview/STATE.md`
- `Docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh modul naskah BAB 1-3 dan log federasi.
**Belum selesai / next steps:**
- Persiapan kompilasi dokumen `docx v0.1` (BAB 1–3) untuk bimbingan dosen.

---

## [2026-10-03 10:30] Ekspansi Mendalam Teori Penunjang BAB 2 (2.2.1 - 2.2.10)

**Status:** Selesai
**Dikerjakan:**
- Memperluas secara komprehensif Bab 2.2 Teori Penunjang (dari ~240 baris menjadi 563 baris) mencakup 10 sub-bab teoritis lengkap:
  1. SIM & Digitalisasi Properti Hunian (4 dimensi fungsional & eliminasi human-error).
  2. Evolusi Arsitektur Monolith vs Microservices vs Modulith (DDD, 3-tier hierarchy, event bus write vs gateway read).
  3. Standarisasi Kontrak REST API, Format Envelope JSON, Layered FormRequest Validation, DTO, Living Documentation.
  4. Arsitektur Multi-Tenancy (Row-Level Scoping `building_id`, Global Scope Eloquent, Tenant-Aware RBAC).
  5. Model Context Protocol (MCP) & Built-in AI Assistance (JSON-RPC tools, grounding anti-halusinasi, audit log).
  6. Clean Architecture di Frontend Flutter (The Dependency Rule 3 layer, BLoC pattern, GetIt DI, Single Codebase).
  7. Basis Data Relasional MySQL (ACID, MVCC Pessimistic Locking pencegah double booking, Composite Indexing).
  8. Integrasi Payment Gateway Midtrans Production Patterns (Idempotency Key, SHA-512 Signature, Webhook FSM).
  9. Strategi Pengujian Berlapis (Piramida Pengujian: Unit, API Contract, Tenant Isolation, Integration).
  10. Living Documentation & Architecture Decision Records (ADR).
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Render diagram visual (ERD multi-tenant, BPMN, Sequence MCP tool-use) untuk lampiran/insert docx.

---

## [2026-10-03 10:00] Penyelarasan Naskah PA BAB 1, 2, 3 dengan 5 Pilar Konseptual

**Status:** Selesai
**Dikerjakan:**
- Mengadopsi 5 pilar konseptual (Standar I/O, Multi-Tenant Gedung, MCP AI Assistant, Modular Monolith Event-Driven & Module Gateway, Clean Architecture Frontend) ke dalam draf naskah.
- Update `PA/docs/modules/bab1/README.md`: penajaman gap previous work, 5 pilar posisi PA, rumusan masalah, tujuan, batasan (row-level multi-tenancy & read-only MCP), dan manfaat.
- Update `PA/docs/modules/bab2/README.md`: pengayaan teori (Modulith 3-tier, Multi-Tenancy, MCP & LLM Tool-Use, Kontrak REST JSON, Clean Architecture FE, Database Indexing, Midtrans Hardening) dan gap statement.
- Update `PA/docs/modules/bab3/README.md`: desain Clean-Modulith + MCP, alur AI tool execution, kontrak JSON envelope baku, ERD multi-gedung, skenario pengujian komprehensif.
- Sinkronisasi `PA/docs/00_overview/STATE.md`.
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Render diagram pendukung BAB 3 (BPMN, DFD, Sequence MCP tool-use, ERD v2).
**Catatan/masalah:**
- Judul skripsi tetap dipertahankan.

---

## [2025-09-20 04:30] BAB 2 Draft Penuh selesai — Teori + Narasi Tabel 2.3 (14 baris) + Gap Statement

**Status:** Selesai
**Dikerjakan:**
- Tulis `PA/docs/modules/bab2/README.md` draft penuh: 2.1 Deskripsi Permasalahan, 2.2 Teori Penunjang (9 sub-bab dengan sitasi [1]-[22]), 2.3 Penelitian Terkait (narasi 14 baris dengan positioning eksplisit per baris), 2.4 Gap Statement (5 gap utama)
- Sitasi IEEE numeric [1]-[22] dari DAFTAR_PUSTAKA.md
- Coverage: SIM, Modulith/DDD, Clean Arch, Laravel Modular, Flutter Clean Arch, MySQL, Midtrans, Testing, Living Docs — semua dengan jurnal 2022-2026
- Tabel 2.3: 14 baris narasi (9 jurnal terkait + 4 previous work + PA kita) dengan positioning eksplisit
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Outline BAB 3 detail (diagram BPMN/DFD/Activity/ERD + trace mapping Project/ + mockup + skenario)
- Generate docx v0.1 (BAB1-3) untuk review dosen
**Catatan/masalah:**
- BAB 2 ~4,000 kata, sitasi konsisten [1]-[22], siap review dosen.

---

## [2025-09-20 03:30] BAB 1 Draft Penuh selesai — Previous Work Analysis + Gap + Proposal Baru

**Status:** Selesai
**Dikerjakan:**
- Tulis BAB 1 draft penuh: 1.1 Latar Belakang (3 bagian), 1.2 Rumusan Masalah (5 butir), 1.3 Tujuan (5 butir), 1.4 Batasan, 1.5 Manfaat, 1.6 Sistematika
- Sitasi IEEE numeric [1]-[19] dari DAFTAR_PUSTAKA
- Analisis previous work: tabel 4 proposal + 5 gap eksplisit (fragmentasi, arsitektur inkonsisten, test lemah, web hilang, payment sandbox)
- Posisi PA: 5 perbaikan sistematik (Clean Arch konsisten, Interface-based, Test ≥80%, Web Dashboard, Midtrans production)
**Belum selesai / next steps:**
- Draft BAB 2 penuh (teori 2.2 + narasi tabel 2.3 + gap statement 2.4)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- BAB 1 ~2,500 kata, siap review dosen.

---

## [2025-09-20 02:15] Literature Review Sprint selesai — TABEL_JURNAL 15 jurnal + DAFTAR_PUSTAKA 22 entry

**Status:** Selesai
**Dikerjakan:**
- Search jurnal 2022-2026 via Semantic Scholar + SINTA/Garuda + Web + Midtrans docs
- Isi `TABEL_JURNAL.md`: 15 jurnal terpilih (5 modulith, 4 Flutter Clean Arch, 6 kost Indonesia + Midtrans)
- Update `DAFTAR_PUSTAKA.md`: 22 entry IEEE numeric urut kemunculan BAB1→BAB5 (include previous work [23]-[30])
- Gap statement diperbarui: 5 gap utama
**Belum selesai / next steps:**
- Draft BAB 1 penuh (previous work analysis + gap + proposal baru)
- Draft BAB 2 penuh (teori + 12 penelitian terkait + tabel perbandingan + gap)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- Semua jurnal punya DOI/URL verifikabel.

---

## [2025-09-20 01:15] Koreksi: old-files = referensi previous work, PA progress 0%

**Status:** Selesai (koreksi STATE)
**Dikerjakan:**
- Update STATE: **PA progress 0%** — 4 PDF di `old-files/` adalah **REFERENSI previous work** (4 proposal mahasiswa lain), bukan kerjaan kita
- PA naskah baru: BAB 1 = analisis previous work (state, gap, kesalahan), BAB 2 = teori + kritik previous, BAB 3 = desain sistem perbaikan
- Target minggu ini: Literature Review Sprint → BAB 1-3 draft
**Belum selesai / next steps:**
- Search jurnal 2022-2026 → isi `TABEL_JURNAL.md` 15-20 jurnal
- Draft BAB 1 (previous work analysis + gap + proposal baru)
- Draft BAB 2 (teori + related work + kritik previous)
- Outline BAB 3 (desain sistem baru)
**Catatan/masalah:**
- Jangan copy-paste 4 proposal jadi BAB 1-3 kita — itu previous work, bukan kerjaan kita

---

## [2025-09-19 23:40] Init PA/docs federated

**Status:** Selesai
**Dikerjakan:**
- Buat struktur PA/docs: 00_overview, 01_guides, 02_reference, 03_logs, modules/bab1-5
- Extract baseline penulisan dari 4 PDF proposal → PANDUAN_PENULISAN + TEMPLATE_BASELINE + STACK
- Buat DAFTAR_PUSTAKA awal (8 entry dari proposal) + TABEL_JURNAL (4 terkait + gap) + ERD_GLOBAL + SKILL_BLOCKERS
**File yang diubah:**
- `PA/docs/**` (15 file baru)
**Belum selesai / next steps:**
- Search jurnal baru 2022-2026 untuk TABEL_JURNAL baris 5-15
- Draft modules/bab1-5 (masih kosong)
**Catatan/masalah:**
- Sitasi proposal sebagian belum ada DOI — tandai [NEEDS VERIFY]

---
