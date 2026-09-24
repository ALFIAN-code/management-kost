# Workflow Pengembangan — Scrum

> Alur Git + Scrum untuk PA-Management-kost. Diadaptasi dari 4 proposal PA (Maret–Juni 2025).

**Terakhir diupdate:** 2025-09-19

## Scrum Framework (dipakai di PA)

Scrum dipilih karena modular (4 domain) dan tim terbagi (4 mahasiswa PA). Cocok untuk modular monolith.

**Peran:**
- Product Owner: Pemilik Wisma Amal (Tessy Badriyah dkk) — prioritas fitur
- Scrum Master: Fasilitator sprint
- Dev Team: Backend (Laravel Modules) + Frontend (Flutter) terbagi per domain

**Artefak:**
- Product Backlog = user stories (contoh: "Sebagai calon penghuni, saya ingin reservasi daring")
- Sprint Backlog = story terpilih per sprint
- Increment = fitur demo-able tiap akhir sprint

**Event:**
- Sprint Planning (awal), Daily Scrum, Sprint Review (demo), Retrospective

## Perencanaan Sprint Aktual (dari proposal)

| Sprint | Bulan | Modul Fokus | Rincian |
|---|---|---|---|
| 1 | Maret 2025 | Login & Struktur | Firebase/Sanctum, struktur modular, Flutter setup, login multi-role |
| 2 | April 2025 | Kamar & Reservasi | CRUD kamar, reservasi daring, validasi bentrok, update status |
| 3 | Mei 2025 | Penghuni & Shared | Manajemen data diri, validasi admin, notifikasi |
| 4 | Juni 2025 | Keuangan & Operasional | Midtrans, laporan kerusakan, jadwal cleaning, audit log |

> Di repo saat ini, Sprint 2-4 sudah terimplementasi parsial (lihat `modules_statuses.json`).

## Branching (untuk Project/)

- `main` (prod), `develop` (staging)
- Fitur: `feat/nama-fitur`, fix: `fix/nama-bug`
- Jangan push langsung ke `main` — via PR, minimal 1 approver, CI hijau (`pint` + `analyze` + `test`)

## Workflow untuk PA/docs (Penulisan Skripsi)

Beda dengan kode — workflow PA adalah **write-review-revise**:

1. **Research:** Search jurnal (Semantic Scholar + SINTA) → `PA/docs/02_reference/TABEL_JURNAL.md`
2. **Draft:** Tulis BAB di `PA/docs/modules/bab*/` (markdown) → flag `[CITATION NEEDED]` jika belum ada DOI
3. **Review:** `Imbad0202` integrity gate — cek sitasi exist, claim-source align
4. **Finalize:** Generate `PA/docs/02_reference/TEMPLATE_BASELINE.md` → `python-docx` → `PA/ProyekAkhir.docx` + `validate_thesis_docx.py`

## Workflow untuk AI Agent

- Jika diminta "langsung push ke main" atau "langsung generate docx final" → konfirmasi L1 dulu.
- Tulis ringkasan PR / progress log dalam Indonesia, kode tetap Inggris.
- Setiap selesai sprint/feature, update `Docs/03_logs/PROGRESS_LOG.md` + `Docs/00_overview/STATE.md` (checklist AGENTS.md:3).
