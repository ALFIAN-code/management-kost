# Project State — Ringkasan Terkini

> Ringkasan 1 halaman untuk AI & manusia agar cepat paham konteks tanpa baca semua `docs/`. Update tiap sesi (bagian dari `AGENTS.md:3` checklist). Maks 400 kata.

**Terakhir diupdate:** 2026-09-22 11:00
**Fase:** Development — **Literature Review Sprint SELESAI**, PA Progress 15% (siap draft BAB 1-3); **local env ready** (BE serve :8000 + MySQL Docker + FE pub get OK)
**Progress keseluruhan:** 45% kode (backend modular aktif, frontend ready), **15% PA naskah** (lit-review done, TABEL_JURNAL 15 jurnal, DAFTAR_PUSTAKA 22 entry)
**Tipe stack:** `fullstack` — Laravel 11 Modular + Flutter 3.8.1 (lihat `STACK.md`)

## Apa yang Sudah Jalan (Kode + Lit-Review)

- 4 proposal sebelumnya (old-files) selesai Juni 2025: Penghuni&Tamu (Rasyidatur), Kamar&Reservasi (Roihanah), Keuangan (Rizal), Operasional&Maintenance (Bagus) — **ini REFERENSI previous work**
- Backend `backend-wismaamalgorontalo`: 9 modul aktif (Room, Resident, Finance, Maintenance, Auth, Inventory, Setting, Rental, Notification), Repository-Service pattern, MySQL, Spatie RBAC
- Frontend `fe_wisma_amal_gorontalo`: Semi-Clean Architecture, BLoC + GetIt + AutoRoute + Dio, secure_storage, siap refactor ke full Clean
- Docs federated lengkap: `Docs/` hub + `PA/docs/` (struktur, PANDUAN_PENULISAN, TEMPLATE_BASELINE, TABEL_JURNAL 15 jurnal, DAFTAR_PUSTAKA 22 entry, skills 43 file) + `Project/docs/` hub + backend/fe docs
- ✅ Literature Review Sprint: 15 jurnal terpilih (5 modulith, 4 Flutter Clean Arch, 6 kost Indonesia + Midtrans), 22 entry IEEE numeric, gap statement 5 gap utama

## Apa yang Sedang Dikerjakan (Draft BAB 1-3 Sprint — minggu ini)

**PA Naskah Progress: 15%** — Literature Review Sprint **SELESAI**, siap draft BAB 1-3.
- ✅ Search jurnal 2022-2026 (Semantic Scholar + SINTA/Garuda) → `TABEL_JURNAL.md` 15 jurnal terpilih
- ✅ `DAFTAR_PUSTAKA.md` 22 entry IEEE numeric urut kemunculan
- ✅ Gap statement: 5 gap utama (Clean Arch konsisten, test coverage ≥80%, living docs sync, web+mobile terintegrasi, Midtrans production-ready)
- 🔄 **Next: Draft BAB 1 penuh → BAB 2 penuh → Outline BAB 3 detail**

## Apa Selanjutnya (Next Steps)

1. Draft BAB 1 penuh (previous work analysis + gap + proposal baru) — gunakan TABEL_JURNAL
2. Draft BAB 2 penuh (teori + 12 penelitian terkait + tabel perbandingan + gap statement)
3. Outline BAB 3 detail (diagram BPMN/DFD/Activity/ERD + trace mapping Project/ + mockup + skenario)
4. Generate docx draft v0.1 (BAB1-3) untuk review dosen

## Blocker / Keputusan Pending

- Judul final PA baru: 1 judul integrasi sistem perbaikan (PA-DEC-001 Proposed)
- Style sitasi: numeric `[1]` (proposal previous) dipertahankan — konfirmasi pembimbing
- Frontend web owner/admin: React vs Flutter Web — konsistenkan dengan implementasi baru

## Link Cepat

- `Docs/00_overview/ARCHITECTURE.md` → index federasi (hub)
- `PA/docs/00_overview/ARCHITECTURE.md` → index skripsi
- `Project/docs/00_overview/ARCHITECTURE.md` → index kode
- `Docs/03_logs/PROGRESS_LOG.md` → detail 3-5 sesi terakhir
- `Docs/03_logs/DECISIONS.md` → ADR terbaru
- `PA/docs/01_guides/PANDUAN_PENULISAN.md` → aturan tulis kampus
