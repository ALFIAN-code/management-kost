# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-10-18
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
- ✅ Draft BAB 1 diselaraskan dengan gaya penulisan natural Indonesia (bebas kata kaku/AI-isms).

## Roadmap Kerja Terkini

1. 🟡 **Fase Naskah:** Sinkronisasi BAB 1 (selesai draf), revisi BAB 2 & 3 mengikuti arsitektur NestJS 13 tabel dan Flutter Web.
2. ⚪ **Fase Desain Teknis:** Finalisasi spesifikasi kontrak endpoint REST API & skema event bus NestJS.
3. ⚪ **Fase Implementasi:** Scaffolding basis kode backend baru berbasis NestJS modular & Flutter Web.


## Blocker / Keputusan Pending

- Judul dipertahankan: **Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo).
- Scope Multi-Tenant: Shared-DB with row-level scoping (`building_id`).
- Scope AI MCP: Read-only query & insight reporting (fase 1).

## Link Cepat

- `Docs/00_overview/ARCHITECTURE.md` → index federasi (hub)
- `PA/docs/00_overview/ARCHITECTURE.md` → index skripsi
- `Docs/03_logs/DECISIONS.md` → ADR terbaru (ADR-001 s/d ADR-006)
- `Docs/03_logs/PROGRESS_LOG.md` → histori sesi global