# PA State — Status Naskah Terkini

> 1 halaman. Update tiap sesi bimbingan/revisi.

**Terakhir diupdate:** 2026-10-03
**Fase:** **BAB 1, BAB 2, BAB 3 Naskah Akademis Lengkap + Keycloak SSO SELESAI** (15 Diagram & Naskah Terpadu)
**Progress:** 80% PA naskah — BAB 1 penuh (~2.800 kata), BAB 2 komprehensif (~3.700 kata), BAB 3 Software Design Document lengkap (~3.300 kata), 15 Diagram MMD+PNG, TABEL_JURNAL 19 jurnal, DAFTAR_PUSTAKA 22 entry.

## Judul PA

**Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo)

## Pilar Arsitektur Terpadu (ADR-005 & ADR-006)

1. **Modular Monolith Architecture (Backend)**: 3-tier hierarchy, komunikasi mutasi event-driven, dan query via Module Gateway.
2. **Clean Architecture (Frontend Flutter)**: Pemisahan Presentation BLoC, Domain UseCase, dan Data DataSource pada single codebase Web + Mobile.
3. **Multi-Tenant System (Multi-Gedung)**: Row-level tenancy berbasis `building_id` dan `TenantResolverMiddleware` untuk pengelolaan portofolio multi-gedung.
4. **Standar Input-Output API**: JSON response envelope konsisten (`{status, message, data, meta, errors}`), FormRequest, dan DTO transformer.
5. **Single Sign-On (SSO) Berbasis Keycloak OIDC**: Otentikasi terpusat via Keycloak IAM, stateless JWKS verification, JIT user provisioning, dan Spatie RBAC.
6. **Model Context Protocol (MCP) with Built-in AI**: Asisten cerdas dengan tools read-only untuk analisis okupansi, laporan keuangan, dan komplain dengan batasan tenant.

## Apa yang Sudah Selesai

- ✅ **BAB 1 Naskah Akademis Lengkap**: Latar belakang empiris, dekonstruksi 4 proposal previous work (termasuk gap SSO & multi-gedung), justifikasi pilar posisi PA, rumusan masalah (7 butir), tujuan, batasan, manfaat, dan sistematika.
- ✅ **BAB 2 Kajian Pustaka Komprehensif**: Teori penunjang mendalam (11 sub-bab: SIM Properti, Modulith 3-tier & Event-Driven, Standar I/O API REST, Multi-Tenancy Row-Level Scoping, MCP AI & LLM Tool-Use, Keycloak OIDC SSO, Clean Architecture Flutter, Basis Data MySQL ACID/MVCC, Midtrans Production Hardening, Testing Pyramid, Living Docs), telaah 14 penelitian terkait, dan gap statement.
- ✅ **BAB 3 Software Design Document (SDD) Lengkap**: Deskripsi solusi pilar terpadu, metodologi Scrum 4 sprint (114 SP) + User Story format Gherkin, diagram blok Clean-Modulith + MCP + SSO, pemodelan proses bisnis BPMN (4 alur), Use Case Global & Use Case Specifications lengkap, DFD L0 & L1, ERD multi-tenant & Kamus Data Basis Data lengkap (6 tabel terinci termasuk `users` dengan `keycloak_id`), spesifikasi antarmuka UI/UX, JSON Schema 4 tool MCP, format envelope REST API, dan matriks 20 skenario pengujian.
- ✅ **15 folder diagram**: tersimpan di `PA/docs/diagrams/`; 2 SVG FINAL arsitektur (Gambar 2.1/2.2 & 3.1/3.2) + ERD aktual (Gambar 3.6a) + 5 ERD per-cluster HTML terverifikasi (Gambar 3.6c–3.6g) resmi docx.
- ✅ **Migration WAJIB tereksekusi** (2026-10-03): 41 tabel, test BE 523 passed (2 pre-existing failed).
- ✅ **ADR-005 & ADR-006**: Keputusan arsitektur tercatat di `Docs/03_logs/DECISIONS.md`.

## Apa Selanjutnya

1. Persiapan kompilasi dokumen `docx v0.1` (BAB 1–3) untuk bimbingan dosen.
2. Review naskah lengkap bersama pembimbing.

## Blocker / Keputusan Pending

- Judul dipertahankan tanpa perubahan.
- Format sitasi IEEE numeric `[1]`-`[22]` konsisten.
- Lingkup MCP dibatasi read-only untuk keamanan data.

## Link Cepat

- `01_guides/PANDUAN_PENULISAN.md` → aturan kampus
- `02_reference/TEMPLATE_BASELINE.md` → format docx
- `02_reference/TABEL_JURNAL.md` → jurnal terkurasi + positioning kolom
- `03_logs/PROGRESS_LOG.md` → histori bimbingan