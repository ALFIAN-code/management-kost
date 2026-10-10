# PA State — Status Naskah Terkini

> 1 halaman. Update tiap sesi bimbingan/revisi.

**Terakhir diupdate:** 2026-10-10
**Fase:** **REWRITE TOTAL (ADR-007) — Perancangan Ulang 5 Tahap** (Step 1: Kebutuhan & Fitur)

**Progress:** 80% PA naskah (naskah lama diarsipkan sebagai referensi, penulisan diselaraskan dengan hasil 5 tahap perancangan baru).
## Judul PA

**Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo)

## Pilar Arsitektur Terpadu (ADR-005 & ADR-007)

1. **Modular Monolith Architecture (Backend)**: 3-tier hierarchy, mutasi via event bus, query via Module Gateway, nol FK lintas modul.
2. **Sewa Bulanan Penuh**: Tanpa tarif harian, configurable minimum rental months per gedung.
3. **Clean Architecture (Frontend Flutter)**: Pemisahan Presentation BLoC, Domain UseCase, dan Data DataSource pada single codebase Web + Mobile.
4. **Multi-Tenant System (Multi-Gedung)**: Row-level tenancy berbasis `building_id`.
5. **Standar Input-Output API**: JSON response envelope konsisten (`{status, message, data, meta, errors}`), FormRequest, dan DTO transformer.
6. **Autentikasi Sederhana & Aman**: Sanctum lokal dengan role enum (owner, admin, resident).

## Apa yang Sudah Selesai

- ✅ **ADR-007 Ditetapkan**: Keputusan rewrite total kost bulanan 13 tabel dicatat di `Docs/03_logs/DECISIONS.md`.
- ✅ **Draf Awal Fase 1**: Kebutuhan F1–F12 dan draf ERD 13 tabel di `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`.
- ✅ **Roadmap 5 Langkah Disepakati**: Metodologi rekayasa perangkat lunak bertahap untuk rekonstruksi BAB 3 dan kode.

## Roadmap Perancangan & Implementasi Baru

1. ✅ **Step 1 (Selesai):** Kaji kebutuhan & daftar fitur resmi (F01–F17) di `PA/docs/System design/DAFTAR_FITUR.md`.
2. ✅ **Step 2 (Selesai):** Pendefinisian alur proses bisnis lengkap di `PA/docs/System design/BPMN/` (8 subfolder alur per fitur).
3. ✅ **Step 3 (Selesai):** Pemodelan data (ERD terisolasi 21 entitas di `PA/docs/System design/ERD/`) & aliran data (DFD L0 & L1 di `PA/docs/System design/DFD/`).
4. 🟡 **Step 4 (Berikutnya):** Spesifikasi Kontrak API REST & skema Event Bus.
5. ⚪ **Step 5:** Scaffolding kode backend & update naskah SDD BAB 3.

## Blocker / Keputusan Pending

- Judul dipertahankan tanpa perubahan.
- Format sitasi IEEE numeric `[1]`-`[22]` konsisten.
- Lingkup MCP dibatasi read-only untuk keamanan data.

## Link Cepat

- `01_guides/PANDUAN_PENULISAN.md` → aturan kampus
- `02_reference/TEMPLATE_BASELINE.md` → format docx
- `02_reference/TABEL_JURNAL.md` → jurnal terkurasi + positioning kolom
- `03_logs/PROGRESS_LOG.md` → histori bimbingan