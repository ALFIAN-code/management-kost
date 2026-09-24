# Architecture Decision Records — Federated

> Append-only. Jika keputusan berubah, buat entry baru dan tandai lama sebagai Superseded.

---

## ADR-001: Federated Docs (Global Hub → PA/docs + Project/docs)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Proyek PA-Management-kost punya 2 concerns: skripsi (PA) dan sistem (Project). 1 docs raksasa akan basi dan membingungkan AI (campur aturan Laravel vs aturan tulis kampus). User minta Docs global sebagai pointer + komprehensif di masing-masing scope.
**Keputusan:** Struktur federated 3 hub: `Docs/` (global hub) → `PA/docs/` (skripsi BAB1-5, panduan kampus, jurnal) → `Project/docs/` (hub kode) → `backend/docs` & `fe/docs`. `Docs/00_overview/ARCHITECTURE.md` jadi index pointer, bukan detail.
**Alternatif:**
- 1 docs di root saja — ditolak, karena PA dan Project punya siklus & stakeholder beda (dosen vs user Wisma)
- Docs per modul saja tanpa hub — ditolak, AI butuh entry point tunggal tiap sesi (AGENTS.md:1)
**Konsekuensi:** AI wajib baca hub dulu baru routing ke sub-docs. Update `STATE.md` di 3 level. Tradeoff: sedikit overhead, tapi mencegah campur context.

---

## ADR-002: Hybrid Skill sebagai Blocker (Primary: 1-pluto1 thesis-writing)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** User butuh AI bisa menulis PA dengan disiplin (sitasi, template docx, klaim trace ke kode) + search jurnal awal. 6 skill dievaluasi: David-Saeteros, 1-pluto1, Imbad0202 (48k stars), Composio docx, O0000 index, AlessandroCaforio.
**Keputusan:** Primary blocker = `1-pluto1/thesis-writing-en` (code-backed thesis, citation order, source-first, validate_docx), Engine = `Composio docx` (docx-js/ooxml), Rigor = subset `Imbad0202` (deep-research + Stage 2.5 integrity gate), Arsitektur = `AlessandroCaforio` (CLAUDE.md brain + 8 rules always-on).
**Alternatif:**
- Imbad0202 full pipeline — ditolak, overkill untuk D3 (butuh ~$4-6 & hooks)
- David-Saeteros saja — ditolak, tidak cek citation numeric & code evidence
**Konsekuensi:** Aturan blocker ditanam di `PA/docs/02_reference/*` dan `Docs/00_overview/STACK.md` sebagai SOP, bukan sekadar skill install.

---

## ADR-003: Modular Monolith, bukan Microservice

**Tanggal:** 2025-09-19
**Status:** Accepted (dari proposal, dipertahankan)
**Konteks:** Wisma Amal butuh 4 domain terpisah tapi sharing data (reservasi → tagihan → notif) dan tim kecil (4 mahasiswa PA). Microservice menambah kompleksitas jaringan & deployment.
**Keputusan:** `nwidart/laravel-modules` — 1 deployment, modul loosely-coupled highly-cohesive, toggle via `modules_statuses.json`, komunikasi via ServiceInterface.
**Alternatif:** Microservice — ditolak (proposal Nofianto 2021 pakai microservice tapi hanya mobile, tidak modular; overhead tidak sebanding).
**Konsekuensi:** Scaling vertikal dulu, миграция ke microservice bisa stepwise jika properti >1 (lihat Faustino et al. 2024 di proposal).

---

## ADR-004: Flutter BLoC Semi-Clean → Full Clean untuk Fitur Baru

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Repo `fe_wisma_amal_gorontalo` saat ini semi-clean (no interface, repo concrete) untuk kecepatan. Guideline `CLEAN_ARCHITECTURE_GUIDELINE.md` menuntut full Clean (UseCase + Repository Interface).
**Keputusan:** Fitur baru wajib full Clean (BLoC → UseCase → RepositoryInterface → Impl). Fitur lama boleh stay semi-clean, refactor bertahap.
**Konsekuensi:** Konsistensi meningkat, boilerplate bertambah — acceptable untuk PA yang akan di-review dosen.

---
