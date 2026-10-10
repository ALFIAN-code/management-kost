# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-10-10
**Fase:** **REWRITE TOTAL (ADR-007) — Roadmap Perancangan & Implementasi Baru** (Step 1: Kaji Kebutuhan & Fitur).
**Progress keseluruhan:** 80% PA naskah (arsip teori/desain lama siap dialihkan ke desain baru), 40% Project/kode (menuju scaffolding ulang modular 13 tabel).

## Pilar Arsitektur Terpadu (ADR-005, ADR-007, ADR-008)

1. **Arsitektur Hunian Dinamis (ADR-008):** Desain *as dynamic as possible*, mendukung kost komersial, asrama gratis, mes karyawan, dan pondok pesantren.
2. **Pemisahan Room vs Occupancy/Schedule (ADR-008):** Room mengelola unit fisik & kapasitas; Schedule mengelola alokasi dinamis orang & waktu huni.
3. **Decoupling Modul Opsional (ADR-008):** 5 Modul Core wajib (User, Property, Room, Schedule, Dashboard) + 5 Modul Opsional plug-and-play (Finance, Maintenance, Inventory, Guest, Notification).
4. **Dynamic RBAC (ADR-008):** Manajemen peran dinamis (permission sets bawaan + pembuatan custom roles oleh pengguna).
5. **Standar Input-Output API:** Format response JSON envelope seragam (`{status, message, data, meta, errors}`), FormRequest input validation, dan DTO transformer.
6. **Modular Monolith Architecture (Backend):** Nol FK fisik lintas modul, komunikasi mutasi via Event Bus, dan pembacaan lintas modul via Module Gateway.

## Apa yang Sudah Selesai

- ✅ ADR-007 (Rewrite Total Kost Bulanan 13 Tabel) & ADR-008 (Arsitektur Dinamis Core vs Opsional) disahkan di `Docs/03_logs/DECISIONS.md`.
- ✅ Pemetaan arsitektur modular baru diselaraskan di `Docs/00_overview/ARCHITECTURE.md`.
- ✅ Kesepakatan roadmap metodologis rekayasa perangkat lunak (Kebutuhan → Alur/Flow → ERD/DFD → Kontrak API → Kode & Naskah).

## Roadmap Kerja Rewrite Terkini

1. ✅ **Step 1 (Selesai):** Pengkajian kebutuhan & daftar fitur lengkap F01–F17 di `PA/docs/System design/DAFTAR_FITUR.md`.
2. ✅ **Step 2 (Selesai):** Pendefinisian alur proses bisnis lengkap di `PA/docs/System design/BPMN/` (8 subfolder alur per fitur).
3. ✅ **Step 3 (Selesai):** Pemodelan data (ERD terisolasi 21 entitas di `PA/docs/System design/ERD/`) & aliran data (DFD L0 & L1 di `PA/docs/System design/DFD/`).
4. 🟡 **Step 4 (Berikutnya):** Spesifikasi Kontrak API REST & skema Event Bus antar-modul.
5. ⚪ **Step 5:** Scaffolding folder baru backend modular monolith & sinkronisasi naskah BAB 3.


## Blocker / Keputusan Pending

- Judul dipertahankan: **Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo).
- Scope Multi-Tenant: Shared-DB with row-level scoping (`building_id`).
- Scope AI MCP: Read-only query & insight reporting (fase 1).

## Link Cepat

- `Docs/00_overview/ARCHITECTURE.md` → index federasi (hub)
- `PA/docs/00_overview/ARCHITECTURE.md` → index skripsi
- `Docs/03_logs/DECISIONS.md` → ADR terbaru (ADR-001 s/d ADR-006)
- `Docs/03_logs/PROGRESS_LOG.md` → histori sesi global