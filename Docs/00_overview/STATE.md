# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-10-03
**Fase:** **BAB 1, 2, 3 Naskah Akademis Lengkap + Keycloak SSO SELESAI** (15 Diagram & Dokumen Terpadu)
**Progress keseluruhan:** 80% PA naskah (BAB 1, 2, 3 naskah utuh ~9.800 kata dengan 6 pilar arsitektur: Standar I/O, Multi-Tenant, MCP AI, Keycloak OIDC SSO, Clean-Modulith), 50% Project/kode.

## Pilar Arsitektur Terpadu (ADR-005 & ADR-006)

1. **Standar Input-Output API:** Format response JSON envelope seragam (`{status, message, data, meta, errors}`), FormRequest input validation, dan DTO transformer.
2. **Multi-Tenant System (Multi-Gedung):** Logical row-level scoping dengan `building_id`, `TenantResolverMiddleware`, dan penugasan akses per gedung untuk pemilik/pengelola.
3. **Model Context Protocol (MCP) with Built-in AI:** Modul MCP Server read-only untuk asisten AI (tanya okupansi, keuangan, kerusakan fasilitas) dengan data grounding terisolasi per tenant.
4. **Single Sign-On (SSO) Berbasis Keycloak OIDC:** Otentikasi terpusat via Keycloak IAM, verifikasi stateless JWKS, JIT Provisioning, dan Spatie RBAC.
5. **Modular Monolith Architecture (Backend):** 3-tier hierarchy (Infra/Auth-Setting, Core/Building-Room-Schedule, Business/Finance-Maintenance-Guest-Inventory-Notification-Mcp) dengan mutasi event-driven dan pembacaan via Module Gateway.
6. **Clean Architecture (Frontend Flutter):** Pemisahan 3 layer (Presentation BLoC, Domain UseCase, Data RepoImpl) pada single codebase Flutter Web dan Mobile.

## Apa yang Sudah Selesai

- ✅ ADR-005 (5 Pilar Konseptual) & ADR-006 (Keycloak OIDC SSO) tercatat di `Docs/03_logs/DECISIONS.md`.
- ✅ `PA/docs/modules/bab1/README.md` diperbarui (gap multi-gedung & SSO, rumusan, tujuan, batasan 6 pilar).
- ✅ `PA/docs/modules/bab2/README.md` diperbarui (11 sub-bab teori penunjang termasuk OIDC/Keycloak).
- ✅ `PA/docs/modules/bab3/README.md` diperbarui (arsitektur Clean-Modulith + MCP + SSO, alur otentikasi, ERD multi-gedung, skenario pengujian komprehensif).
- ✅ 15 folder diagram di `PA/docs/diagrams/`; 2 SVG FINAL arsitektur + ERD aktual + 5 ERD per-cluster HTML resmi docx.
- ✅ Migration WAJIB tereksekusi (2026-10-03): `buildings`, `building_id` 13 tabel, SSO Keycloak, `mcp_tool_logs`, soft-ref 2 FK — 41 tabel, test 523 passed (2 pre-existing failed).
- ✅ Backend staging: Schedule event-driven, perbaikan kontrak `/permissions`, Spatie RBAC 78 permissions.
- ✅ Frontend: Flutter Web / Mobile single codebase, fix singleton SettingBloc.

## Apa Selanjutnya

1. Detail diagram UML/ERD multi-tenant & alur MCP untuk BAB 3.
2. Review naskah BAB 1-3 sebelum kompilasi ke format docx v0.1.

## Blocker / Keputusan Pending

- Judul dipertahankan: **Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo).
- Scope Multi-Tenant: Shared-DB with row-level scoping (`building_id`).
- Scope AI MCP: Read-only query & insight reporting (fase 1).

## Link Cepat

- `Docs/00_overview/ARCHITECTURE.md` → index federasi (hub)
- `PA/docs/00_overview/ARCHITECTURE.md` → index skripsi
- `Docs/03_logs/DECISIONS.md` → ADR terbaru (ADR-001 s/d ADR-006)
- `Docs/03_logs/PROGRESS_LOG.md` → histori sesi global