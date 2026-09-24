# AI Agent Rules — PA-Management-kost (Federated)

> File ini WAJIB dibaca AI di **setiap awal sesi**, sebelum menulis kode/naskah apa pun.
> Alasan: AI tidak punya ingatan antar sesi. Folder `Docs/` + `PA/docs/` + `Project/docs/` adalah pengganti ingatan — sumber kebenaran (source of truth).

## 0. Prinsip Dasar

1. **Dokumentasi = definisi "selesai".** Task belum selesai kalau docs relevan belum diupdate.
2. **Jangan asumsi konteks chat sebelumnya.** Kalau tidak tertulis di docs, anggap tidak terjadi.
3. **Log append-only.** `PROGRESS_LOG.md`, `CHANGELOG.md`, `DECISIONS.md` tambah entry baru, jangan timpa/hapus.
4. **Perubahan besar butuh persetujuan eksplisit** (L1 Supervised default).
5. **Jangan copy-paste mentah.** Selective copy sesuai stack (lihat AGENTS.md:7 template v3).

---

## 1. SEBELUM Mulai Kerja (WAJIB — Federated Routing)

Baca berurutan, jangan dilompat:

1. `Docs/03_logs/PROGRESS_LOG.md` → 3-5 entry terakhir (ingatan jangka pendek global).
2. `Docs/00_overview/STATE.md` → ringkasan 1 halaman (fase, progress, blocker).
3. `Docs/00_overview/ARCHITECTURE.md` → **hub federasi**: tentukan scope task.
4. **Routing (pilih satu):**
   - **Task PA (naskah):** → baca `PA/docs/03_logs/PROGRESS_LOG.md` → `PA/docs/00_overview/STATE.md` → `PA/docs/00_overview/ARCHITECTURE.md` → `PA/docs/01_guides/PANDUAN_PENULISAN.md` → `PA/docs/02_reference/SKILL_BLOCKERS.md` → modul `PA/docs/modules/bab*/` yang relevan.
   - **Task Project (kode):** → baca `Project/docs/00_overview/STATE.md` → `Project/docs/00_overview/ARCHITECTURE.md` → pilih `backend-wismaamalgorontalo/docs/` ATAU `fe_wisma_amal_gorontalo/docs/` → modul yang relevan.
5. `Docs/00_overview/STACK.md` → cek stack (Laravel 11 modular + Flutter BLoC).
6. `Docs/03_logs/DECISIONS.md` → cek ADR yang membatasi pendekatan (modulith, Scrum, numeric citation).
7. `Docs/01_guides/GLOSSARY.md` → istilah Wisma (Penghuni vs Calon, dll).

**Jika file belum ada/kosong:** jangan menebak — tanya user atau scan codebase lalu konfirmasi (L1).
**Jika instruksi chat bertentangan dengan DECISIONS:** konfirmasi eksplisit sebelum override.

## 2. SELAMA Kerja

- Unit kecil, mudah direview. Jangan ubah schema/arsitektur/konvensi tanpa izin.
- Dampak besar (auth, payment Midtrans, migrasi, breaking) → tanya dulu.
- **Source-first untuk PA:** klaim BAB3/4 wajib jejak ke `Project/backend-wismaamalgorontalo/Modules/*` atau `Project/fe_wisma_amal_gorontalo/lib/*` atau DOI. Tanpa bukti → `[CODE EVIDENCE NEEDED]` / `[CITATION NEEDED]`.
- **Sitasi verifikabel:** cek via Semantic Scholar/Crossref. Dilarang fabrikasi referensi.
- Jika kerjakan 1 modul, baca file modulnya dulu (`Docs/modules/*` + sub-docs modul).

## 3. SETELAH Selesai (WAJIB sebelum "selesai")

| Jenis perubahan | Dokumen yang diupdate |
|---|---|
| Struktur global / federasi | `Docs/00_overview/ARCHITECTURE.md` + `Docs/modules/*` |
| Naskah PA (BAB) | `PA/docs/modules/bab*/` + `PA/docs/00_overview/STATE.md` |
| Aturan tulis / template | `PA/docs/01_guides/PANDUAN_PENULISAN.md` / `02_reference/TEMPLATE_BASELINE.md` |
| Jurnal / pustaka | `PA/docs/02_reference/TABEL_JURNAL.md` + `DAFTAR_PUSTAKA.md` |
| Kode backend | `Project/backend-wismaamalgorontalo/docs/modules/*.md` + `02_reference/*` jika schema/API berubah + `KNOWLEDGE_BASE.md` (living) |
| Kode frontend | `Project/fe_wisma_amal_gorontalo/docs/modules/*.md` |
| Keputusan penting | `Docs/03_logs/DECISIONS.md` (+ `PA/docs/03_logs/DECISIONS.md` jika soal naskah) |
| **Setiap sesi (selalu)** | `Docs/03_logs/PROGRESS_LOG.md` + `Docs/00_overview/STATE.md` (+ PROGRESS_LOG scope yang dikerjakan) |

**Checklist:**
- [ ] `Docs/03_logs/PROGRESS_LOG.md` entry baru di paling atas?
- [ ] `Docs/00_overview/STATE.md` + STATE scope (PA/Project) sinkron?
- [ ] Modul docs sinkron (global + scope)?
- [ ] Tidak ada `[...]` tersisa di file yang disentuh?

## 4. Format Entry PROGRESS_LOG.md

```
## [YYYY-MM-DD HH:mm] Judul singkat task
**Status:** Selesai / Sebagian / Blocked
**Dikerjakan:**
- poin
**File yang diubah:**
- path
**Dokumen yang diupdate:**
- docs/...
**Belum selesai / next steps:**
- poin
**Catatan/masalah:**
- poin
```

## 5. Larangan

- Jangan hapus history logs. Jangan duplikasi docs di luar federasi.
- Jangan bilang "sudah dijelaskan sebelumnya" — harusnya ada di docs.
- Jangan generate docs panjang tapi basi. Singkat, akurat, berguna sesi berikutnya.
- Jangan buat file baru di docs tanpa konfirmasi (L1).

---

## 6. Info Project

- **Nama:** PA-Management-kost — Sistem Informasi Wisma Amal Gorontalo
- **Deskripsi:** Modular monolith kost (pemilik/pengelola/penghuni), 4 domain + core
- **Tech stack:** Laravel 11 + nwidart/modules, Flutter 3.8.1 BLoC + GetIt + AutoRoute, MySQL, Midtrans, Open-WA
- **Tipe stack:** `fullstack`
- **Command:**
  - `install (BE):` `composer install && npm install` di `Project/backend-wismaamalgorontalo`
  - `dev (BE):` `composer run dev`
  - `test (BE):` `php artisan test`
  - `install (FE):` `flutter pub get` di `Project/fe_wisma_amal_gorontalo`
  - `analyze (FE):` `flutter analyze`
  - `generate (FE):` `dart run build_runner build --delete-conflicting-outputs`
- **Area terlarang tanpa izin:** `modules_statuses.json`, Midtrans keys, `DECISIONS.md`, schema DB final
- **Path boilerplate:** `/Users/allvvnt/alfianSpace/files/agent-docs-template-v3`

## 7. Mode Otonomi (Default: L1 Supervised)

Boleh ubah kode/naskah sesuai task, tapi **wajib tanya dulu** sebelum: (a) init ulang docs, (b) file baru di docs, (c) stack baru, (d) ubah DECISIONS, (e) generate docx final, (f) push ke main.
