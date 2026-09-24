# Progress Log — Federated

> Log kronologis tiap sesi AI. Entry baru di **paling atas**, append-only. Ini "ingatan jangka pendek" AI.

---

## [2026-09-22 14:45] Fix red screen feature-toggles — singleton SettingBloc di-close halaman lain

**Status:** Selesai (user perlu hot restart / refresh browser FE)
**Dikerjakan:**
- Error `Bad state: Cannot add new events after calling close` di `#/app/setting/feature-toggles`. Akar masalah: `landing_cms_page.dart` memakai `BlocProvider(create: serviceLocator<SettingBloc>())` padahal SettingBloc singleton GetIt → saat halaman Landing CMS di-close, singleton ikut ke-close → halaman Setting berikutnya `add()` ke BLoC mati → red screen
- Fix 1 baris: `BlocProvider(create:)` → `BlocProvider.value` (tidak close on dispose). Audit pola sama se-app: semua `create: serviceLocator<X>` lain adalah factory (RoomBloc, GuestBloc, dsb → aman); `MyReservationBloc.close()` juga aman (factory). Hanya 1 titik bug ini
- Verifikasi: `flutter analyze` file bersih + `flutter build web` sukses
**File yang diubah:**
- `Project/fe_wisma_amal_gorontalo/lib/presentation/pages/setting/landing_cms/landing_cms_page.dart`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Refresh/hot-restart FE web lalu ulangi alur: Setting → Landing Page → kembali → Kelola Modul dan Fitur
**Catatan/masalah:**
- Aturan: singleton GetIt dilarang masuk `BlocProvider(create:)` — selalu `BlocProvider.value`. Factory bebas keduanya

---

## [2026-09-22 14:00] Setup ulang BE di branch staging (refactor Schedule, event-driven)

**Status:** Selesai (2 test gagal pre-existing, di luar scope)
**Dikerjakan:**
- User pindah ke branch `staging` (arsitektur baru: Rental/Resident dihapus → modul Schedule, event-driven, deptrac). Staging ternyata sudah berisi fix lama: scramble aman, phpunit sqlite, `myPermissions` balas map, PermissionSeeder 73 rows
- Fix sisa di staging: `AuthController::me()` → `->load('roles')` (badge GUEST), +6 permission ke super-admin (`view-resident-dashboard`, `complete-resident-profile`, `finance-me-*` 4) — verifikasi silang: 70/70 key FE ada di DB & di super-admin
- Setup: `composer install`, `migrate:fresh --seed`, restart serve :8000. Verifikasi: login 200, `/permissions` 72 item + roles, `/me` ada roles
- Test: 523 passed, 2 failed (`EndpointMatrixTest` dashboard admin/resident 404) — TERBUKTI pre-existing via stash test (gagal juga tanpa perubahan saya). Tidak diperbaiki (butuh implementasi endpoint Dashboard, di luar task setup)
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/Modules/Auth/Http/Controllers/AuthController.php` (`me()` load roles)
- `Project/backend-wismaamalgorontalo/Modules/Auth/database/seeders/RolePermissionSeeder.php` (+6 untuk super-admin)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Logout + login ulang di FE (refresh permission tersimpan)
- 2 test dashboard 404 menunggu fix endpoint Dashboard (modul `Modules/Dashboard`) di sesi terpisah
**Catatan/masalah:**
- Staging paksa pola baru (baca `CATATAN_ARSITEKTUR.md` sebelum ubah kode): komunikasi tulis antar-modul via Event, aturan deptrac, API shape stabil
- `.env` MySQL Docker dipertahankan sesuai pilihan sesi lalu (default staging = sqlite)

---

## [2026-09-22 13:45] Fix permission super-admin minim (24) + badge GUEST — seeder + /me

**Status:** Selesai (butuh user logout+login ulang di FE)
**Dikerjakan:**
- Diagnosa: sidebar (`app_layout.dart`) gate tiap menu via `context.can(PermissionKeys.X)` vs permission tersimpan. Super-admin cuma pegang 24 permission (Auth+Room+Lease); ~46 key FE (finance-*, inventory, maintenance, resident, guest, notif, setting, create-lease, ...) tidak ada barisnya di DB → menu tidak tampil. Ironisnya role `admin` malah punya permission finance yang tidak dimiliki super-admin
- Fix `PermissionSeeder.php`: tambah 48 permission (total 78 baris). Verifikasi silang: 70/70 key `PermissionKeys` FE kini ada di DB
- Fix `RolePermissionSeeder.php`: super-admin = `syncPermissions(Permission::all())` (selalu penuh otomatis walau permission baru ditambah nanti). Role admin/resident/member tidak diubah
- Fix badge GUEST: `GET /me` tidak me-load relasi `roles` → FE baca null → fallback 'GUEST'. `AuthController::me()` kini `->load('roles')`. Terverifikasi `/me` balas `roles: [super-admin]`
- Re-seed Auth saja (idempoten) + restart `artisan serve` (cache permission in-memory proses lama). Verifikasi API: `/permissions` → 78 item, roles `[super-admin]`
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/Modules/Auth/database/seeders/PermissionSeeder.php` (+48 rows)
- `Project/backend-wismaamalgorontalo/Modules/Auth/database/seeders/RolePermissionSeeder.php` (super-admin = all)
- `Project/backend-wismaamalgorontalo/Modules/Auth/Http/Controllers/AuthController.php` (`me()` load roles)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- WAJIB: logout lalu login ulang di FE web (daftar permission tersimpan di storage saat login — sesi lama masih pegang 24 permission)
- Badge profil super-admin tampil 'GUEST' karena tidak punya biodata resident (`/resident/profile` balas "belum melengkapi biodata") — itu wajar by design; badge role kini ikut `/me` jadi benar
**Catatan/masalah:**
- Role `admin` belum diberi permission baru (finance lanjutan, inventory, dst) — sengaja tidak diubah; tugaskan via menu Peran/Izin di UI jika perlu

---

## [2026-09-22 13:30] Fix FE login TypeError — kontrak /api/permissions tidak cocok (List vs Map)

**Status:** Selesai
**Dikerjakan:**
- Keluhan: FE web tampil `TypeError: ... 'List<dynamic>' is not a subtype of 'Map...'` saat login, padahal BE balas 200. Akar masalah: crash BUKAN di login, tapi di panggilan lanjutan `GET /api/permissions` di `AuthRepositoryImpl.login()` — `myPermissions` balas `data` sebagai List string, sedangkan FE (`auth_datasource.getPermissions`) wajib Map `{permissions, roles}`
- Fix BE `Modules/Auth/Http/Controllers/AuthController.php::myPermissions`: balas `{permissions: [...], roles: [...]}` untuk user login maupun guest
- Verifikasi: `GET /api/permissions` + token → `{permissions: 24 item, roles: [super-admin]}`; guest → `{permissions: [view-room], roles: [guest]}`
- Cek docs BE: tidak ada API_REFERENCE yang menyebut kontrak endpoint ini → tidak ada docs API yang perlu disinkronkan
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/Modules/Auth/Http/Controllers/AuthController.php` (`myPermissions`)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- User coba login ulang dari FE web (tidak perlu rebuild — yang berubah hanya BE)
**Catatan/masalah:**
- Bug ini pre-existing (kontrak BE/FE memang tidak cocok sejak awal), bukan akibat re-seed/phpunit.xml sesi sebelumnya — re-seed hanya mereset ID user + mematikan token lama

---

## [2026-09-22 13:15] Fix login 500 — DB dev ke-wipe oleh php artisan test, re-seed + sqlite testing

**Status:** Selesai
**Dikerjakan:**
- Diagnosa `POST /api/login` 500 "Terjadi kesalahan sistem": tabel `users` kosong (0 users, 0 rooms) — penyebabnya `php artisan test` sesi sebelumnya jalan lawan DB dev MySQL (baris sqlite di `phpunit.xml` masih dikomen) lalu RefreshDatabase me-wipe semua tabel
- Re-seed: `php artisan db:seed --force` → users 22 + rooms 8 kembali, `POST /api/login` 200 OK
- Fix permanen: uncomment `DB_CONNECTION=sqlite` + `DB_DATABASE=:memory:` di `phpunit.xml` → `php artisan test` 10 passed TANPA menyentuh DB dev (users=22, rooms=8 intact)
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/phpunit.xml` (sqlite :memory: untuk testing)
- (data) re-seed DB dev `wisma_amal`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Silakan login ulang dari FE — endpoint sudah 200
- Catatan: `AuthController@login` men-swallow exception jadi pesan generik (tanpa log) — pertimbangkan tambah `\Log::error` di catch untuk debug berikutnya
**Catatan/masalah:**
- Jangan jalankan `php artisan test` sebelum fix ini jika DB dev berisi data penting — sekarang aman karena testing pakai sqlite memory

---

## [2026-09-22 11:00] Setup local Backend+Frontend (MySQL Docker, fix Scramble)

**Status:** Selesai
**Dikerjakan:**
- Start MariaDB 10.11 via Docker (`wisma-mysql`, port 3306, DB `wisma_amal`)
- Fix `config/scramble.php`: `url('/api')` → `env('APP_URL').'/api'` (sebelumnya semua `php artisan` crash di console karena request null)
- Backend: `composer install`, `npm install`, `.env` baru (DB mysql 127.0.0.1:3306), `key:generate`, `migrate`, `db:seed` (roles + 8 room)
- Verifikasi: `GET /up` 200, `GET /docs/api` OK, `POST /api/login` (superadmin@app.com) OK, `php artisan test` 10 passed
- Frontend: `flutter pub get`, `build_runner` (24 outputs), `flutter analyze` 0 error (116 info/warning saja)
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/config/scramble.php`
- `Project/backend-wismaamalgorontalo/.env` (baru, dari `.env.example`)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `Project/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- FE `localURl` masih `https://api.wismaamal.com` — ganti ke `http://localhost:8000` (atau `10.0.2.2:8000` untuk emulator Android) agar FE tembak BE lokal
- Isi `MIDTRANS_*` + `FONNTE_TOKEN` di `.env` jika mau tes payment/notif
- `composer run dev` untuk dev penuh (serve + queue + vite)
**Catatan/masalah:**
- DB di docker-compose repo tidak expose port → pakai container mandiri `wisma-mysql` agar artisan lokal bisa konek
- Flutter lokal 3.41.2 (repo target 3.8.1) — pub get/build OK, warning deprecation `withOpacity` dll wajar

---

## [2025-09-20 02:45] Penelitian Terkait (BAB 2.3) lengkap — 14 baris dengan positioning eksplisit

**Status:** Selesai
**Dikerjakan:**
- Update `PA/docs/02_reference/TABEL_JURNAL.md`: tambah kolom **Perbandingan & Positioning PA Kita** untuk 19 jurnal (khusus 14-18 penelitian terkait kost)
- Update `PA/docs/modules/bab2/README.md`: tabel Penelitian Terkait 14 baris (12 jurnal + 4 previous work + PA kita) dengan kolom **Perbandingan & Positioning** eksplisit
- Coverage: 4 previous work + 5 jurnal modulith/clean arch + 5 jurnal kost Indonesia 2024-2026 + Midtrans docs
**File yang diubah:**
- `PA/docs/02_reference/TABEL_JURNAL.md`, `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `PA/docs/02_reference/TABEL_JURNAL.md`, `PA/docs/modules/bab2/README.md`
**Belum selesai / next steps:**
- Draft BAB 1 penuh (previous work analysis + gap + proposal baru)
- Draft BAB 2 penuh (teori 2.2 + narasi tabel 2.3 + gap statement)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- Setiap baris tabel 2.3 punya positioning eksplisit vs PA kita (bukan hanya kritik generic)

---

## [2025-09-20 02:15] Literature Review Sprint selesai — TABEL_JURNAL 15 jurnal + DAFTAR_PUSTAKA 22 entry

**Status:** Selesai
**Dikerjakan:**
- Search jurnal 2022-2026 via Semantic Scholar + SINTA/Garuda + Web + Midtrans docs
- Isi `PA/docs/02_reference/TABEL_JURNAL.md`: 15 jurnal terpilih (5 modulith, 4 Flutter Clean Arch, 6 kost Indonesia + Midtrans)
- Update `PA/docs/02_reference/DAFTAR_PUSTAKA.md`: 22 entry IEEE numeric urut kemunculan BAB1→BAB5 (include previous work [23]-[30])
- Gap statement diperbarui: 5 gap utama (Clean Arch konsisten, test coverage, living docs, web+mobile, Midtrans production)
**File yang diubah:**
- `PA/docs/02_reference/TABEL_JURNAL.md`, `PA/docs/02_reference/DAFTAR_PUSTAKA.md`
**Dokumen yang diupdate:**
- `PA/docs/02_reference/TABEL_JURNAL.md`, `DAFTAR_PUSTAKA.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Draft BAB 1 penuh (previous work analysis + gap + proposal baru) — gunakan TABEL_JURNAL
- Draft BAB 2 penuh (teori + 12 penelitian terkait + tabel perbandingan + gap)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- Semua jurnal punya DOI/URL verifikabel. Previous work [23]-[30] sebagai internal reference.

---

## [2025-09-20 01:15] Koreksi pemahaman: old-files = referensi previous work, PA progress 0%

**Status:** Selesai (koreksi STATE)
**Dikerjakan:**
- Update `Docs/00_overview/STATE.md` & `PA/docs/00_overview/STATE.md`: **PA progress 0%** — 4 PDF di `PA/old-files/` adalah **REFERENSI previous work** (4 proposal mahasiswa lain Juni 2025), bukan kerjaan kita
- PA naskah baru: BAB 1 = analisis previous work (state, gap, kesalahan), BAB 2 = teori + kritik previous, BAB 3 = desain sistem perbaikan
- Target minggu ini: Literature Review Sprint → BAB 1-3 draft (tanpa sentuh kode)
**File yang diubah:**
- `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Search jurnal 2022-2026 → isi `PA/docs/02_reference/TABEL_JURNAL.md` 15-20 jurnal
- Draft BAB 1 (previous work analysis + gap + proposal baru)
- Draft BAB 2 (teori + related work + kritik previous)
- Outline BAB 3 (desain sistem baru)
**Catatan/masalah:**
- Koreksi penting: jangan copy-paste 4 proposal jadi BAB 1-3 kita — itu previous work, bukan kerjaan kita

---

## [2025-09-20 00:10] Setup federated selesai + wiring AGENTS.md

**Status:** Selesai
**Dikerjakan:**
- Selesaikan `Docs/modules/*` (wisma-core, room-reservation, resident-guest, finance-midtrans, operational-maintenance)
- Selesaikan `PA/docs/` (BAB1-5 stubs, PANDUAN_PENULISAN, TEMPLATE_BASELINE, DAFTAR_PUSTAKA, TABEL_JURNAL, ERD_GLOBAL, SKILL_BLOCKERS, logs)
- Selesaikan `Project/docs/` hub + `backend/docs/` (9 modul stubs, API_REFERENCE, DATABASE_SCHEMA) + `fe/docs/` (5 modul stubs, API_STYLE konsumsi)
- Tulis `AGENTS.md` root federated routing + verifikasi: 63 file docs, tanpa placeholder `[...]` aktual
**File yang diubah:**
- `Docs/modules/*.md`, `PA/docs/**`, `Project/docs/**`, `Project/backend-wismaamalgorontalo/docs/**`, `Project/fe_wisma_amal_gorontalo/docs/**`, `AGENTS.md`
**Dokumen yang diupdate:**
- `Docs/00_overview/STATE.md` (tetap 45%), `PA/docs/00_overview/STATE.md`, `Project/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Search jurnal baru 2022-2026 → isi TABEL_JURNAL baris 5-15
- Audit backend `Modules/*` aktual → isi modules/*.md detail
- Audit `fe/lib/` vs guideline → catat deviasi
**Catatan/masalah:**
- Stub backend `auth.md` terverifikasi OK (Status Done, struktur benar)

---

## [2025-09-19 23:30] Init Federated Docs untuk PA-Management-kost

**Status:** Selesai
**Dikerjakan:**
- Extract 4 PDF proposal `PA/old-files/` (Penghuni&Tamu, Kamar&Reservasi, Keuangan, Operasional) jadi knowledge untuk PA & Project
- Init `Docs/` hub global: README, 00_overview (ARCHITECTURE, STATE, STACK), 01_guides (GLOSSARY, CONVENTIONS, WORKFLOW, GETTING_STARTED), 02_reference (API_STYLE, DATABASE_SCHEMA, INTEGRASI), 03_logs
- Adopt stack federated: Laravel 11 Modular + Flutter 3.8.1 BLoC + Midtrans, selective copy v3 (tidak copy stacks/ mentah)
- Buat wiring pointer federasi Docs → PA/docs & Project/docs
**File yang diubah:**
- `Docs/README.md`, `Docs/00_overview/*`, `Docs/01_guides/*`, `Docs/02_reference/*`
- `AGENTS.md` (root routing) — next step
**Dokumen yang diupdate:**
- `Docs/00_overview/ARCHITECTURE.md`, `STATE.md`, `STACK.md`
**Belum selesai / next steps:**
- Init `PA/docs/` komprehensif (BAB1-5, PANDUAN_PENULISAN dari template, TABEL_JURNAL, TEMPLATE_BASELINE, skill blockers)
- Init `Project/docs/` hub + `backend/docs` + `fe/docs` (adopt KNOWLEDGE_BASE & CLEAN_ARCH guideline)
**Catatan/masalah:**
- 4 PDF berhasil di-extract, ERD global sudah di-merge dari 4 versi
- Docs global sudah tidak ada placeholder `[...]` — siap jadi hub

---

<!-- Template entry baru — copy ke atas
## [YYYY-MM-DD HH:mm] Judul
**Status:** Selesai / Sebagian / Blocked
**Dikerjakan:**
-
**File yang diubah:**
-
**Dokumen yang diupdate:**
-
**Belum selesai / next steps:**
-
**Catatan/masalah:**
-
-->
