# Progress Log — Federated

> Log kronologis tiap sesi AI. Entry baru di **paling atas**, append-only. Ini "ingatan jangka pendek" AI.

---

## [2026-11-04 12:35] Implementasi Fitur Client (SSO, Multi-Tenant, Batch Kamar) & Update Deployment Server ALLVVNT
**Status:** Selesai
**Dikerjakan:**
- Membuat branch terpisah `client/saas-multitenant` untuk pekerjaan kustom klien tanpa mengganggu branch `develop`.
- Backend:
  1. Menambahkan siklus pemulihan akun & email via SMTP: endpoint `forgot-password`, `verify-otp`, `reset-password`, serta migrasi `email_verification_tokens`.
  2. Menambahkan alur verifikasi email otomatis saat pendaftaran (`AuthService::register` memicu `sendEmailVerificationOtp`) serta endpoint `POST /api/email/verify-otp` dan `POST /api/email/resend-otp`.
  3. Menambahkan template email HTML modern untuk OTP reset password & verifikasi email.
  4. Menambahkan SSO Google Login via endpoint `google-login` dengan verifikasi token & JIT Provisioning.
  5. Menambahkan Multi-Tenancy (Row-Level Scoping `building_id`, `TenantContext`, `TenantScope`, `BelongsToTenant`, `TenantResolverMiddleware`, serta `BuildingController`).
  6. Menambahkan fitur kamar massal (Batch Generator rentang nomor `rooms/batch-generate`, bulk store, dan import CSV).
  7. Menulis automated tests `AuthLifecycleTest` dan `BatchRoomAndTenancyTest` (100% Passed).
- Frontend:
  1. Redesain halaman `ChangePasswordPage`: memperbaiki teks judul yang sebelumnya buram/samar (low contrast) di dark mode, membatasi lebar form (`maxWidth: 580`) agar proporsional di layar lebar, menambahkan panduan kekuatan sandi real-time, dan menggunakan tombol emerald primer.
  2. Redesain halaman `RegisterPage`: mendukung pendaftaran terintegrasi dengan Google SSO dan langsung mengarahkan ke halaman verifikasi email.
  3. Menambahkan halaman baru `VerifyEmailPage` (`/verify-email`): input OTP 6 digit berfont monospace, hitung mundur kirim ulang 60 detik, dan navigasi otomatis setelah akun terverifikasi.
  4. Menambahkan halaman pemulihan akun 3 langkah (`ForgotPasswordPage`) berbasis token desain studio.
  5. Menambahkan tombol Google Sign-in dan link "Lupa kata sandi?" di `LoginPage`.
  6. Menambahkan modal generator kamar massal (`BatchRoomGeneratorDialog`) dengan live dynamic preview kamar.
  7. Menambahkan widget pemilihan properti/cabang (`PropertySelectorWidget`).
  8. Membangun bundle release Flutter Web (`flutter build web --release`).
- Server Deployment:
  1. Sinkronisasi source code backend dan bundle prebuilt frontend web ke server ALLVVNT (`/home/alfian/wismaamal-deploy/`).
  2. Menjalankan Docker build dan recreate container (`wismaamal_backend_app`, `wismaamal_frontend_web`, `wismaamal_queue_worker`).
  3. Menjalankan migrasi database di container produksi (`email_verification_tokens_table`).
  4. Verifikasi live HTTP 200 untuk `https://api-wismaamal.allvvnt.my.id/up`, `https://wismaamal.allvvnt.my.id/`, dan endpoint publik baru.
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/*`
- `Project/fe_wisma_amal_gorontalo/*`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Pengujian interaktif end-to-end oleh pengguna/klien pada browser.
**Catatan/masalah:**
- Tidak ada kendala teknis; seluruh layanan Docker dan database di server ALLVVNT berjalan sehat.

---

## [2026-10-29 09:50] Ratifikasi Final Skema 21 Tabel Domain dan Sinkronisasi Naskah Bab 1–3
**Status:** Selesai
**Dikerjakan:**
- Menetapkan skema 21 tabel domain utama (24 entitas fisik) dari `PA/docs/System design/04-ERD/erd_sistem_dinamis.html` sebagai Single Source of Truth rancangan basis data sistem.
- Memperbarui ADR-014 di `Docs/03_logs/DECISIONS.md` dan menambahkan `PA-DEC-004` di `PA/docs/03_logs/DECISIONS.md`.
- Memperbarui naskah lokal `PA/docs/modules/bab3/README.md`:
  1. §3.6 dan §3.6.1 diselaraskan ke skema 21 tabel domain.
  2. Gambar 3.18 dikaitkan ke `PA/docs/System design/04-ERD/erd_sistem_dinamis.png`.
  3. Menjabarkan rincian 21 tabel domain pada 9 modul (M1–M4 Core, O1–O5 Opsional) secara utuh.
- Menyelaraskan seluruh referensi "18–19 tabel" menjadi "skema 21 tabel domain" di `bab1/README.md`, `bab2/README.md`, `bab3/DESAIN_REWRITE_FASE1.md`, dan `full_draft.md`.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/modules/bab1/README.md`
- `PA/docs/modules/bab2/README.md`
- `PA/docs/modules/full_draft.md`
- `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`
- `Docs/03_logs/DECISIONS.md`
- `PA/docs/03_logs/DECISIONS.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
- `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Pengguna menerapkan prompt koreksi pada Google Doc/PDF untuk deskripsi 21 tabel dan pembersihan sisa teks.
- Melanjutkan perancangan visual Mockup Antarmuka Web (§3.7) untuk 3 role.

---

## [2026-10-29 07:35] Penyelarasan Redaksi Naskah BAB 3 dengan Diagram Lego Klasifikasi Modul
**Status:** Selesai
**Dikerjakan:**
- Menyelaraskan teks naskah pada `PA/docs/modules/bab3/README.md` (§3.6.3 dan §3.6.4):
  1. Menambahkan kolom *Nama Fungsi Awam* di Tabel 3.6.3 agar sejalan dengan label pada balok diagram Lego.
  2. Menyisipkan 4 poin penjelasan naratif analogi susunan balok Lego di bawah Gambar 3.19: Module Gateway sebagai baseplate ungu, Modul Inti sebagai balok biru pondasi tetap, Modul Tambahan sebagai balok hijau plug & play, serta balok Keuangan terangkat sebagai bukti independensi saat fitur dimatikan.
  3. Menyeragamkan istilah label modul tambahan di Tabel 3.6.4 pengujian (Keuangan & Tagihan, Perawatan, Inventaris, Buku Tamu, Notifikasi).
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Tahap berikutnya: Melanjutkan perancangan visual Mockup Antarmuka Web (§3.7) untuk 3 role.

## [2026-10-29 07:20] Redesain Diagram Klasifikasi Modul: Ilustrasi Lego
**Status:** Selesai (tampilan akhir belum dicek mata oleh AI, mohon dicek pengguna)
**Dikerjakan:**
- Mengganti isi `04-ERD/diagram_klasifikasi_modul.{html,svg,png}` dengan ilustrasi gaya Lego: alas ungu *Module Gateway*, 5 brick hijau modul tambahan di atas alas (satu terangkat, berlabel "Dilepas: sistem tetap berjalan"), 5 brick biru modul inti di bawah alas.
- Tanpa kartu, bullet, kode fitur, atau istilah teknis. Gambar 3.19 di BAB 3 tidak berubah (file PNG sama).
**File yang diubah:**
- `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.{html,svg,png}`
**Belum selesai / next steps:**
- Pengguna cek tampilan; revisi warna/label bila perlu.

## [2026-10-29 07:05] Redesain Diagram Klasifikasi Modul Menjadi SVG Vektor & Ekspor PNG 2x
**Status:** Selesai
**Dikerjakan:**
- Merekonstruksi `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.html` menjadi diagram vektor SVG utuh dengan tata letak visual modern standar publikasi:
  1. Header bar profesional dengan tombol ekspor SVG & PNG (2x resolusi cetak).
  2. Modul Tambahan (Opsional) berdesain hijau emerald dengan saklar virtual (ON / OFF) per gedung.
  3. Jalur penghubung fleksibel (Loose Coupling Bus) dengan panah putus-putus dua arah, menegaskan nol keterikatan kaku (nol FK fisik).
  4. Modul Inti (Core) berdesain biru kokoh sebagai pondasi wajib selalu aktif di seluruh gedung.
  5. Kotak perbandingan dunia nyata: Kost Komersial (Semua Fitur ON) vs Asrama/Mes Gratis (Keuangan OFF, tanpa error database).
  6. Mengeliminasi seluruh istilah teknis/kode fitur (F01, dsb.) dan menggunakan bahasa alami yang mudah dipahami orang awam.
- Merender otomatis `diagram_klasifikasi_modul.svg` dan `diagram_klasifikasi_modul.png` (resolusi 2240x1710 px, 200 KB) menggunakan headless Edge.
- Memperbarui penomoran gambar di `PA/docs/modules/bab3/README.md`: `Gambar 3.19` disematkan untuk Diagram Klasifikasi Modul, dan nomor mockup diselaraskan menjadi `Gambar 3.20`, `3.21`, dan `3.22` berurutan tanpa jeda.
- Menambahkan indeks diagram di `PA/docs/System design/README.md`.
**File yang diubah:**
- `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.html` (rekonstruksi SVG)
- `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.svg` (baru)
- `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.png` (baru)
- `PA/docs/modules/bab3/README.md`
- `PA/docs/System design/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tahap berikutnya: Melanjutkan perancangan visual Mockup Antarmuka Web (§3.7) untuk 3 role dalam format komponen modern.

## [2026-10-29] Tambah Sub-bab 3.6.4 Scenario Pengujian Kombinasi Modul + Diagram Klasifikasi Modul di BAB 3
**Status:** Selesai
**Dikerjakan:**
- Menambahkan sub-bab `3.6.4 Scenario Pengujian Kombinasi Modul` di `PA/docs/modules/bab3/README.md`, setelah `3.6.3` dan sebelum `3.7 Rancangan Antarmuka Pengguna`.
- Menggunakan pendekatan Core Baseline + Individual (6 skenario) agar tidak terlalu banyak kombinasi, sesuai dengan permintaan dosen pembimbing agar tidak berlebihan.
- Setiap skenario memastikan lima modul core wajib aktif, setiap modul opsional diuji 1-1 terhadap core, dan modul tambahan dapat dinyalakan/matikan secara bebas tanpa gangguan inti sistem.
- Membuat file diagram HTML `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.html` untuk 3.6.3, dengan desain sederhana, non-teknis, tanpa kode fitur (F01, dst), sehingga mudah dipahami orang awam.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.html` (baru)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tidak ada.
**Catatan/masalah:**
- Tidak ada istilah "bagian Hana" yang dimasukkan ke dokumen; menggunakan istilah netral "modul utama" / "modul tambahan".

## [2026-10-29] Tambah Sub-bab 3.6.3 Klasifikasi Modul Core dan Opsional di BAB 3
**Status:** Selesai
**Dikerjakan:**
- Menambahkan sub-bab `3.6.3 Klasifikasi Modul: Core dan Opsional` di `PA/docs/modules/bab3/README.md`, setelah `3.6.2 Aturan Integritas dan Validasi Data` dan sebelum `3.7 Rancangan Antarmuka Pengguna`.
- Menyusun tabel klasifikasi 10 modul (5 core + 5 opsional) dengan fitur dan tabel utama masing-masing, selaras dengan ADR-008 dan DAFTAR_FITUR.
- Menjelaskan konteks data antar-modul tanpa FK fisik (soft-reference melalui `building_id` dan klaim token JWT).
- Aturan utama: lima modul core wajib aktif di semua kombinasi uji; modul opsional plug-and-play per gedung.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menambahkan sub-bab `3.6.4 Scenario Pengujian Kombinasi Modul` (testing independensi modul saat off), sesuai permintaan dosen pembimbing.
- Menyusun ilustrasi diagram untuk konsep modular monolith yang mudah dipahami orang awam.
**Catatan/masalah:**
- Tidak ada istilah "bagian Hana" yang dimasukkan ke dokumen; menggunakan istilah netral "modul core" / "modul utama".

## [2026-10-29] Ratifikasi ADR-014 dan Sesuaikan Referensi Skema Basis Data (13 → 18–19 Tabel)
**Status:** Selesai
**Dikerjakan:**
- Menulis **ADR-014** di `Docs/03_logs/DECISIONS.md`: perluasan skema basis data dari 13 tabel (ADR-007) menjadi 18–19 tabel domain untuk menampung F02 (Dynamic RBAC: `roles`, `permissions`, `role_permissions`), F11 (`expenses`), dan F13 (`maintenance_schedules`), selaras dengan ADR-008. Nol FK lintas modul tetap ditegakkan.
- Menyesuaikan semua referensi "13 tabel" di naskah aktif menjadi "skema perluasan 18–19 tabel" atau setara:
  - `PA/docs/modules/bab3/README.md`: §3 intro, §4 Lapisan Data, §3.6, §3.6.1, tabel perbandingan
  - `PA/docs/modules/bab1/README.md`: tujuan #7, manfaat #2, sistematika BAB 1 & BAB 3
  - `PA/docs/modules/full_draft.md`: tujuan #7, manfaat #2, sistematika BAB 1 & BAB 3, lapis data, ke-2, tabel sprint, catatan cakupan fitur, endpoint expenses, layanan docker, jadwal minggu ke-2
  - `PA/docs/modules/bab2/README.md`: tabel perbandingan §2.1.6
  - `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`: poin 3
- File arsip/draft (`DRAFT_v1_2026-10-21.md`, `ARSIP_DESAIN_LAMA.md`) dibiarkan sebagai catatan historis.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md` (ADR-014 ditambahkan)
- `PA/docs/modules/bab3/README.md`
- `PA/docs/modules/bab1/README.md`
- `PA/docs/modules/full_draft.md`
- `PA/docs/modules/bab2/README.md`
- `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- ERD (`erd_13_tabel`) perlu diperbarui untuk mencakup tabel baru, atau diganti nama sesuai cakupan baru.
- DFD Level 1 (D1–D13) perlu ditinjau ulang apakah perlu diperluas menjadi D1–D18/D19.
**Catatan/masalah:**
- File `.drawio.png` di `08-design-lama/` ukuran besar (150 KB dan 1,19 MB), dapat dioptimasi nanti.

## [2026-10-29] Tambah Sub-bab Evolusi Desain Sistem di BAB 2 §2.1.6
**Status:** Selesai
**Dikerjakan:**
- Menambahkan sub-bab `2.1.6 Evolusi Desain Sistem Sebelum dan Sesudah Rewrite` di `PA/docs/modules/bab2/README.md`, sebagai jembatan antara §2.1 Deskripsi Permasalahan dan §2.2 Teori Penunjang.
- Memasang dua gambar desain sistem lama: `Gambar 2.10` Arsitektur Keseluruhan Sistem Sebelum Rewrite dan `Gambar 2.11` ERD Sistem Sebelum Rewrite (41 Tabel), dari file `.drawio.png` di `PA/docs/System design/08-design-lama/`.
- Menyisipkan Tabel perbandingan 6 aspek (framework, basis data, batas modul, autentikasi, gedung, model sewa) antara sistem lama dan baru, dengan silang ke `BAB 3 §3.6 Rancangan Basis Data` dan `§3.6.1 ERD`.
- Penomoran sub-bab menggunakan 1, 2, 3 (bukan nested 2.1.6.x) agar tidak terlalu dalam.
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menulis ADR-014 untuk mengamendemen ADR-007 (13 tabel → skema perluasan 18–19 tabel sesuai Opsi B), lalu sesuaikan referensi "13 tabel" di `bab3/README.md`, `bab1/README.md`, dan `full_draft.md`.
**Catatan/masalah:**
- File `.drawio.png` diekspor sebagai PNG asli tanpa re-export; ukuran file besar (150 KB dan 1,19 MB), dapat dioptimasi nanti.
**Status:** Selesai
**Dikerjakan:**
- Membuat diagram BPMN 2.0 resmi untuk alur kerja teknis engineering di `PA/docs/System design/02-BPMN/10_pembatalan_sewa_dan_refund/`:
  1. `alur_pembatalan_dan_refund.html`: Berkas interaktif berbasis SVG dengan tombol unduh SVG & PNG.
  2. `alur_pembatalan_dan_refund.svg`: Berkas vektor resolusi tinggi.
  3. `alur_pembatalan_dan_refund.png`: Berkas raster resolusi tinggi (1340x730 px).
  4. `README.md`: Spesifikasi alur, kamus data transisi status (*State Machine*), dan detail teknis scheduler/m-banking.
- Memodelkan 4 swimlane (Penghuni, Sistem Kost NestJS, Payment Gateway Midtrans, Pengelola Properti).
- Mengintegrasikan logika booking DP via Midtrans SNAP, penguncian status `Reserved`, cron job H-3 pelunasan, permohonan refund digital, transfer bank m-banking manual oleh pengelola, pengunggahan struk bukti transfer resmi, hingga pelepasan unit kamar kembali menjadi `available`.
- Memperbarui indeks BPMN di `PA/docs/System design/02-BPMN/README.md` dan `PA/docs/System design/README.md`.
**File yang diubah:**
- `PA/docs/System design/02-BPMN/10_pembatalan_sewa_dan_refund/*`
- `PA/docs/System design/02-BPMN/README.md`
- `PA/docs/System design/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Tahap berikutnya: Melanjutkan perancangan visual Mockup Antarmuka Web (§3.7) untuk 3 role dalam format komponen modern (shadcn/ui style).

---

## [2026-10-23 03:15] Sinkronisasi Total Naskah BAB 1–3 dengan PDF dan Integrasi Aturan DP & Refund
**Status:** Selesai (ACC Diterapkan)
**Dikerjakan:**
- Menyinkronkan seluruh naskah `bab1`, `bab2`, dan `bab3` di `PA/docs/modules/` dengan draf PDF terkini:
  1. **BAB 1:** Menyelaraskan judul resmi (*Arsitektur Modular Monolithic Berbasis Event-Driven untuk Sistem Informasi Manajemen Rumah Kost Terintegrasi.*), judul subbab 1.1.2, serta memperbarui batasan masalah §1.4 butir 2 mencakup pemesanan DP *Two-Phase Invoicing* dan *refund* semi-manual.
  2. **BAB 2:** Menata urutan diagram teori penunjang menjadi berurutan (Gambar 2.1 s.d. 2.9), membuat dan menautkan aset BLoC (`gambar_2_4_bloc_flow.png`), menautkan 6 diagram teori baru di `06-Teori-Penunjang/`, serta mengeliminasi sitasi blocker `[36]` dan `[41]`.
  3. **BAB 3:** Menghapus subbab Activity Diagram yang redundan, menata penomoran subbab (3.6 Rancangan Basis Data, 3.7 Rancangan Antarmuka), memperbarui tautan diagram DFD, Use Case (UML 2.5), dan ERD, serta menyisipkan detail logika bisnis DP & Refund pada §3.1, Tabel 3.1, §3.3.1, §3.3.2, dan aturan integritas data §3.6.2 butir 10.
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`
- `PA/docs/modules/bab2/README.md`
- `PA/docs/modules/bab3/README.md`
- `PA/docs/System design/06-Teori-Penunjang/gambar_2_4_bloc_flow.{html,svg,png}`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Melanjutkan ke tahap perancangan visual Mockup Antarmuka Web (§3.7) untuk 3 role (Pemilik, Pengelola, Penghuni) dengan gaya komponen modern (shadcn/ui style).

---

## [2026-10-23 02:35] Ratifikasi ADR-013: Kebijakan Booking DP Dinamis (Two-Phase Invoicing), Alur Refund Semi-Manual, dan Penagihan Anniversary Cycle
**Status:** Selesai
**Dikerjakan:**
- Meratifikasi ADR-013 di `Docs/03_logs/DECISIONS.md` untuk memfasilitasi kebutuhan bisnis riil manajemen kost general multi-gedung tanpa menambah tabel cicilan baru:
  1. Kebijakan DP dinamis per gedung via `building_settings` (`booking_fee_mode`: `FULL_MONTH`, `FIXED_DP`, `NO_DP`).
  2. Pendekatan *Two-Phase Invoicing* (Invoice DP + Invoice Pelunasan H-3 masuk, tanpa tabel cicilan; tabel `invoices` cukup ditambah enum `type`).
  3. Alur pengembalian dana (*Refund*) semi-manual: pengajuan digital calon penghuni $\rightarrow$ verifikasi admin di menu *Refund Requests* $\rightarrow$ transfer m-banking manual $\rightarrow$ unggah bukti struk transfer $\rightarrow$ pelepasan unit kamar otomatis menjadi *available*.
  4. Siklus penagihan *Anniversary Date* (sesuai tanggal mulai huni) terbit H-7 otomatis, notifikasi dua arah (penghuni & admin), serta tombol aksi "Kirim Pengingat" (*Manual Reminder Trigger*) pada antarmuka tagihan pengelola.
- Memperbarui spesifikasi fitur F04, F08, F09, dan F16 di `PA/docs/System design/DAFTAR_FITUR.md`.
- Memperbarui `Docs/00_overview/STATE.md` menyelaraskan status arsitektur terbaru.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`
- `PA/docs/System design/DAFTAR_FITUR.md`
- `Docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Melanjutkan penyusunan draf Mockup Antarmuka Web (§3.8) untuk 3 role dalam format komponen modern (shadcn/ui style).

---

## [2026-10-23 01:16] Pembuatan 6 Diagram Teori Penunjang BAB 2 (Format HTML, SVG, PNG 2x)
**Status:** Selesai (Draf Siap Review)
**Dikerjakan:**
- Membuat 6 diagram teori penunjang BAB 2 yang dirancang ringkas, konseptual, dan minim whitespace di `PA/docs/System design/06-Teori-Penunjang/`:
  1. `gambar_2_3_nestjs_modul_di`: Pemisahan Modul & Dependency Injection pada NestJS (§2.2.3).
  2. `gambar_2_8_row_level_scoping`: Isolasi Data Antar Gedung pada Row-Level Scoping (§2.2.8).
  3. `gambar_2_9_oidc_jwks`: Alur Verifikasi Token OIDC dengan JWKS (§2.2.9).
  4. `gambar_2_11_midtrans_webhook`: Alur Pembayaran SNAP & Verifikasi Webhook (§2.2.11).
  5. `gambar_2_13_piramida_pengujian`: Piramida Pengujian beserta Komposisinya (§2.2.13).
  6. `gambar_2_14_mcp`: Alur Konsultasi AI via Model Context Protocol (§2.2.14).
- Setiap diagram dilengkapi file interaktif HTML dengan tombol unduh SVG dan PNG (2x resolusi cetak), serta aset vektor .svg dan raster .png siap pakai.
- Menyusun dokumentasi spesifikasi dan kamus di `PA/docs/System design/06-Teori-Penunjang/README.md`.
- Memperbarui daftar pustaka indeks di `PA/docs/System design/README.md`.
**File yang diubah:**
- `PA/docs/System design/06-Teori-Penunjang/*`
- `PA/docs/System design/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu tanggapan/ACC pengguna untuk diagram teori penunjang sebelum disisipkan ke naskah `PA/docs/modules/bab2/README.md`.

---

## [2026-10-23 10:45] Pembuatan UML 2.5 Use Case Diagram Global dalam Format HTML, SVG, dan PNG 2x

**Status:** Selesai
**Dikerjakan:**
- Membuat diagram Use Case global terpadu berbasis standar UML 2.5 di `PA/docs/System design/05-Use-Case/use_case_global.html` dengan batas sistem (*System Boundary*), 4 aktor manusia (*Default Seed Roles* & *Dynamic RBAC*), 4 sistem eksternal, dan relasi `<<include>>` serta `<<extend>>`.
- Memodelkan 13 Use Case Primer dan 4 Sub-Use Case Terintegrasi mencakup autentikasi JWT JWKS, reservasi anti-bentrok, pembayaran SNAP Midtrans, notifikasi WhatsApp, serta kueri wawasan bisnis analitik via MCP.
- Memperbaiki tata letak diagram menjadi sangat padat dan ringkas (780x690 px, reduksi lebar dari 1420 px -> 1080 px -> 780 px, mengeliminasi celah horizontal antara kolom dari 180 px menjadi 35 px) serta melenyapkan rongga kosong horizontal tanpa mengurangi satu pun komponen informasi.
- Memperbaiki fitur ekspor PNG di browser yang sebelumnya terhalang sintaks komentar XML ganda, serta menghitung ulang titik singgung garis relasi aktor dan panah secara matematis agar menempel pas pada perimeter elips tanpa menembus atau mengambang.
- Merender aset vektor `use_case_global.svg` (780x690) dan raster `use_case_global.png` (1560x1380 px resolusi 2x cetak).
- Menyusun dokumentasi spesifikasi use case dan kamus relasi aktor di `PA/docs/System design/05-Use-Case/README.md`.
- Memperbarui indeks pusat rancangan sistem di `PA/docs/System design/README.md`.
**File yang diubah:**
- `PA/docs/System design/05-Use-Case/use_case_global.html`
- `PA/docs/System design/05-Use-Case/use_case_global.svg`
- `PA/docs/System design/05-Use-Case/use_case_global.png`
- `PA/docs/System design/05-Use-Case/README.md`
- `PA/docs/System design/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tampilkan before-after teks naskah Bab 3 §3.4 (Gambar 3.13) dan tunggu ACC user sebelum menyisipkan gambar use case.

---

## [2026-10-23 09:30] Perbaikan Total Routing Panah, Titik Sambung, dan Resolusi Overlap pada 6 Diagram BPMN 2.0

**Status:** Selesai
**Dikerjakan:**
- Merombak total tata letak dan penjaluran panah (sequence flows) pada 6 diagram BPMN 2.0 sesuai hasil review pengguna agar bebas overlap, rapi, dan mudah dibaca:
  1. `01_alokasi_penempatan_hunian`: Restrukturisasi kolom alur durasi, cek bentrok kamar, gateway komersial, terbit tagihan, dan pembayaran online/tunai tanpa persilangan panah.
  2. `02_penagihan_pembayaran`: Memisahkan jalur metode bayar digital (Col 5) dan tunai (Col 6) ke koridor vertikal terpisah sehingga tidak memotong kotak; merapikan panah denda agar masuk pas ke sisi bawah kotak tagihan.
  3. `03_laporan_kerusakan_fasilitas`: Menata alur murni kiri-ke-kanan; panah turun hanya keluar dari sisi bawah kotak sumber dan masuk dari atas kotak target; menghilangkan loop balik penugasan teknisi yang memotong kotak.
  4. `04_pemeliharaan_rutin_berkala`: Mengoreksi jalur panah serah nota teknisi dan input verifikasi pengelola agar tidak saling timpa; menggabungkan cabang biaya servis (Ya/Tidak) ke satu End Event tunggal yang jelas dan definitif.
  5. `06_pengawasan_buku_tamu`: Memindahkan kotak registrasi kedatangan fisik tamu luar agar koridor vertikal form rencana penghuni ke sistem tidak memotong kotak identitas tamu; menunggalkan titik akhir alur.
  6. `08_pendataan_inventaris_aset`: Memisahkan koridor vertikal jalur audit baik (Col 5-A) dan jalur kerusakan/denda (Col 5-B & Col 6); memposisikan kotak denda di luar kolom riwayat audit sehingga panah tagihan denda ke penghuni naik bebas tanpa menabrak kotak sistem; merapikan posisi End Event.
- Merender ulang seluruh berkas HTML ke format SVG vektor dan PNG resolusi tinggi (2x scale) menggunakan helper headless Chrome.
**File yang diubah:**
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.html`
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.svg`
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.png`
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.html`
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.svg`
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.png`
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.html`
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.svg`
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.png`
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.html`
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.svg`
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.png`
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.html`
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.svg`
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.png`
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.html`
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.svg`
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tunggu konfirmasi akhir user mengenai visualisasi 9 diagram BPMN hasil revisi.
- Lakukan commit Git terhadap seluruh berkas diagram sistem rancangan terpadu.
**Catatan/masalah:**
- Seluruh penjaluran vertikal antar swimlane kini mengadopsi prinsip single unobstructed corridor sehingga panah tidak pernah melintasi atau memotong elemen lain.

---

## [2026-10-22 19:15] Konversi Seluruh Alur BPMN ke Format HTML Interaktif, SVG, dan PNG 2x Resolusi Tinggi

**Status:** Selesai
**Dikerjakan:**
- Mengonversi seluruh 9 alur proses bisnis di `PA/docs/System design/02-BPMN` dari format sequence/mermaid whitespace berlebih menjadi diagram kolaborasi BPMN 2.0 berbasis HTML/SVG interaktif dengan tata letak swimlane ringkas dan proporsional:
  1. `01_alokasi_penempatan_hunian`: Alur kolaborasi Penghuni, Sistem Kost, Payment GW, dan Pengelola untuk penempatan kamar dan kontrak sewa bulanan.
  2. `02_penagihan_pembayaran`: Alur siklus penagihan berkala, timer pemantauan jatuh tempo, penalti keterlambatan, metode digital/tunai, serta pelunasan invoice.
  3. `03_laporan_kerusakan_fasilitas`: Alur tiket komplain kerusakan kamar, evaluasi urgensi/fatalitas pengelola, penugasan teknisi, perbaikan, hingga verifikasi penutupan tiket.
  4. `04_pemeliharaan_rutin_berkala`: Alur penjadwalan pemeliharaan preventif (AC, pompa, air), notifikasi H-7, pelaksanaan servis vendor, rekalkulasi periode depan, dan pencatatan beban.
  5. `05_pengeluaran_operasional`: Alur pencatatan pengeluaran riil pengelola, validasi bukti nota, rekalkulasi arus kas, serta dashboard laba-rugi bagi Pemilik (Owner).
  6. `06_pengawasan_buku_tamu`: Alur registrasi rencana tamu oleh penghuni, check-in fisik identitas di pengelola/keamanan, periode kunjungan, check-out kepulangan, dan kalkulasi inap.
  7. `07_pengaturan_hak_akses_dinamis`: Alur konfigurasi RBAC granular, pemilihan peran bawaan vs perancangan peran kustom, penugasan ke akun pengguna, dan penegakan guard menu.
  8. `08_pendataan_inventaris_aset`: Alur registrasi inventaris master kamar, audit fisik terverifikasi saat check-in/out, penanganan kerusakan aset, serta penerbitan tiket servis & tagihan denda kelalaian.
  9. `09_konsultasi_ai_mcp`: Alur konsultasi bahasa alami pemilik ke Mesin AI, validasi kepemilikan gedung, kueri data operasional/finansial faktual, anti-halusinasi, dan penyajian narasi wawasan terstruktur.
- Menyederhanakan penamaan aktivitas dan gateway agar fokus pada alur bisnis (non-teknis) tanpa mencantumkan nama endpoint kaku/prematur.
- Merender dan mengekspor seluruh diagram menjadi file SVG vektor dan PNG resolusi tinggi (2x scale) menggunakan helper headless renderer.
- Memperbarui katalog `PA/docs/System design/02-BPMN/README.md`.
**File yang diubah:**
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.html` (baru)
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.svg` (baru)
- `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.png` (diperbarui)
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.html` (baru)
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.svg` (baru)
- `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.png` (diperbarui)
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.html` (baru)
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.svg` (baru)
- `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.png` (diperbarui)
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.html` (baru)
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.svg` (baru)
- `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.png` (diperbarui)
- `PA/docs/System design/02-BPMN/05_pengeluaran_operasional/alur_pengeluaran_operasional.html` (baru)
- `PA/docs/System design/02-BPMN/05_pengeluaran_operasional/alur_pengeluaran_operasional.svg` (baru)
- `PA/docs/System design/02-BPMN/05_pengeluaran_operasional/alur_pengeluaran_operasional.png` (diperbarui)
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.html` (baru)
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.svg` (baru)
- `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.png` (diperbarui)
- `PA/docs/System design/02-BPMN/07_pengaturan_hak_akses_dinamis/alur_hak_akses_dinamis.html` (baru)
- `PA/docs/System design/02-BPMN/07_pengaturan_hak_akses_dinamis/alur_hak_akses_dinamis.svg` (baru)
- `PA/docs/System design/02-BPMN/07_pengaturan_hak_akses_dinamis/alur_hak_akses_dinamis.png` (diperbarui)
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.html` (baru)
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.svg` (baru)
- `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.png` (diperbarui)
- `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.html` (baru)
- `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.svg` (baru)
- `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.png` (diperbarui)
- `PA/docs/System design/02-BPMN/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Review pengguna untuk hasil visualisasi diagram BPMN 2.0 baru.
- Commit git seluruh aset diagram dan dokumentasi perancangan sistem.

---

## [2026-10-22 18:30] Peningkatan Tipografi & Resolusi Seluruh Diagram Sistem (Siap Cetak Word/A4 16cm)

**Status:** Selesai
**Dikerjakan:**
- Memperbesar ukuran font dan menebalkan tipografi seluruh diagram arsitektur, DFD, dan ERD di `PA/docs/System design` agar terbaca tajam saat disematkan pada dokumen Word/A4 (~16 cm lebar cetak):
  1. `01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`: font judul diperbesar (23px bold, sub 18px), kanvas disesuaikan ke 1420x1460, ekspor SVG dan PNG resolusi tinggi (2840x2920) diperbarui.
  2. `01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html`: font komponen utama diperbesar (18–22px, weight 700–800), label relasi diperbesar (15px), legenda dilebarkan dan diselaraskan, ekspor SVG dan PNG (2800x3060) diperbarui.
  3. `03-DFD/dfd_level_0_context.html`: font proses sentral diperbesar (28px/15px/13.5px), entitas (17px bold), label aliran data (12.5px bold), posisi label diperbaiki dari tabrakan garis, ekspor SVG dan PNG (2400x2000) diperbarui.
  4. `03-DFD/dfd_level_1_dekomposisi.html`: lebar kanvas diperbesar ke 1420px, font proses (17px/15px/13px), data store (15px/13.5px), entitas luar (15px/13px), label panah dipertebal (12.5–13px bold) dengan background pill anti-tumpang tindih, ekspor SVG dan PNG (2840x6054) diperbarui.
  5. `04-ERD/erd_13_tabel.html`: lebar kanvas 1420px, lebar tabel diperluas ke 190px (RH: 22px, HH: 28px), font kolom diperbesar (12px bold, tag key/tipe 10.5px bold), ekspor SVG dan PNG (2840x2054) diperbarui.
  6. `04-ERD/erd_sistem_dinamis.html`: diselaraskan dengan skala lebar kanvas 1420px (TW: 190px, RH: 22px), font diperbesar (12px bold monospace, header 14px bold), ekspor SVG dan PNG (2840x2670) diperbarui.
- Memperbaiki helper renderer Chrome headless (`render_diagram.py`) agar mendukung protokol `file://` lokal dan pemilihan elemen SVG terbesar secara otomatis.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html`
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.svg`
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.svg`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.png`
- `PA/docs/System design/03-DFD/dfd_level_0_context.html`
- `PA/docs/System design/03-DFD/dfd_level_0_context.svg`
- `PA/docs/System design/03-DFD/dfd_level_0_context.png`
- `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.html`
- `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.svg`
- `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.png`
- `PA/docs/System design/04-ERD/erd_13_tabel.html`
- `PA/docs/System design/04-ERD/erd_13_tabel.svg`
- `PA/docs/System design/04-ERD/erd_13_tabel.png`
- `PA/docs/System design/04-ERD/erd_sistem_dinamis.html`
- `PA/docs/System design/04-ERD/erd_sistem_dinamis.svg`
- `PA/docs/System design/04-ERD/erd_sistem_dinamis.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu konfirmasi user atas seluruh diagram yang telah di-render ulang sebelum lanjut ke tahap penulisan/bab berikutnya.

---

## [2026-10-22 17:54] Normalisasi Light Mode Seluruh Diagram HTML di System Design

**Status:** Selesai
**Dikerjakan:**
- Mengubah `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html` dari tema gelap ke terang (body `#1a1b26` → `#f1f5f9`, kanvas `#16161e` → `#ffffff`, teks header `#fff` → `#0f172a`, garis/konektor `#8da0b8` → `#64748b`, panel `#1b1c28` → `#f1f5f9`, label tier `#5fd0b0`/`#f0997b` → `#0f6e56`/`#993c1d`). Geometri, posisi, dan urutan elemen tidak berubah sama sekali (verifikasi: 283 token warna SVG, urutan identik, hanya nilai hex yang berganti).
- Memaksa light mode pada 5 ERD per-modul di `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/*.html` yang sebelumnya mengikuti `prefers-color-scheme` sistem: atribut `data-mode="light"` pada elemen `<html>` + `color-scheme: light` pada `:root`, sehingga tema Mermaid dan `light-dark()` selalu memilih palet terang.
- Mengaudit 6 diagram HTML lain (`arsitektur_terpadu`, `dfd_level_0_context`, `dfd_level_1_dekomposisi`, `erd_13_tabel`, `erd_sistem_dinamis`) — seluruhnya sudah terang, tidak ada perubahan.
- Membangun ulang ekspor `.svg` dan `.png` yang tertinggal pada versi gelap: `arsitektur_backend_modulith.svg/.png` (1210×1160) dan `arsitektur_terpadu.svg/.png` (1400×1530, sebelumnya masih 1400×1010 versi lama) memakai Chrome headless.
- Verifikasi visual seluruh diagram melalui browser (tangkapan layar) — tidak ada elemen dark yang tersisa dan tata letak identik dengan versi sebelumnya.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.svg`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.png`
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.svg`
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png`
- `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/erd_1_auth_rbac.html`
- `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/erd_2_kamar_jadwal_tamu.html`
- `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/erd_3_keuangan.html`
- `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/erd_4_maintenance.html`
- `PA/docs/System design/draft/12_erd_multi_tenant_global/permodule/erd_5_setting_pendukung.html`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Diagram berbasis Mermaid (`.mmd`) di `02-BPMN`, `03-DFD`, `04-ERD` sudah dirender dengan latar putih (`-b white`) sehingga tidak perlu penyesuaian warna.
- Bila ada diagram HTML baru, gunakan palet terang yang sama: panel `#f1f5f9`, garis `#64748b`, teks `#0f172a`/`#475569`.
**Catatan/masalah:**
- `PA/docs/System design/draft/` berstatus arsip obsolete (README System design), perubahan di sana murni kosmetik agar tetap konsisten saat dibuka.

---

## [2026-10-21 20:28] Perbaikan Cache Stale Cloudflare & Safari: Penambahan Cache-Buster & Header No-Cache Nginx

**Status:** Selesai
**Dikerjakan:**
- Mengidentifikasi akar masalah teks Bahasa Indonesia yang masih muncul pada browser pengguna: Cloudflare edge cache (`cf-cache-status: HIT`, `max-age=14400`) dan disk cache Safari menyimpan file unversioned `main.dart.js` lama karena Nginx sebelumnya tidak menyetel header `Cache-Control`.
- Memperbarui `Project/fe_wisma_amal_gorontalo/docker/nginx.conf` dengan aturan no-cache ketat: `Cache-Control "no-store, no-cache, must-revalidate, proxy-revalidate, max-age=0" always;` untuk berkas `.html`, `.json`, `flutter_bootstrap.js`, dan `main.dart.js`.
- Menambahkan mekanisme cache-busting otomatis pada skrip build `redeploy_fe.sh` dengan menyuntikkan parameter versi dinamis `?v=v_<timestamp>` ke referensi `flutter_bootstrap.js` di `index.html` dan `main.dart.js` di `flutter_bootstrap.js`.
- Membangun ulang dan men-deploy container `wismaamal_frontend_web` di server produksi.
- Verifikasi response header dari Cloudflare: `index.html` berstatus `DYNAMIC`, `flutter_bootstrap.js` berstatus `BYPASS`, dan `main.dart.js?v=...` berstatus `BYPASS` dengan ukuran 4.634.151 bytes (bundle baru berbahasa Inggris).
**File yang diubah:**
- `Project/fe_wisma_amal_gorontalo/docker/nginx.conf`
- `Project/fe_wisma_amal_gorontalo/web/index.html`
- `/private/var/folders/zg/_3q0l41d4z31cfdl82751zym0000gn/T/opencode/redeploy_fe.sh`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Pengguna dapat me-refresh Safari (atau Cmd + Shift + R) untuk memuat bundle versi baru.

---

## [2026-10-21 20:05] Lokalisasi Bahasa Inggris Penuh FE/BE, Solusi CanvasKit Lokal Safari, & Re-deploy Produksi

**Status:** Selesai
**Dikerjakan:**
- Menerjemahkan seluruh UI frontend Flutter ke Bahasa Inggris (120+ file diubah mencakup halaman landing, autentikasi, dasbor pemilik/pengelola, inventaris, pemeliharaan, keuangan, resident portal, dan pengaturan).
- Mempertahankan integritas teknis: permission keys (`view-dashboard`, dll.), route constants, payload JSON API, dan format Rupiah (`Rp`).
- Menyesuaikan inisialisasi locale tanggal di Flutter (`main.dart` dan `DateFormat`) ke `en_US`.
- Menerjemahkan seeder dan enum di backend Laravel ke Bahasa Inggris: `FeatureToggleSeeder`, `SettingDatabaseSeeder`, `RoleSeeder`, `PermissionSeeder`, `RolePermissionSeeder`, `DummyDataSeeder`, `FineSeeder`, `RoomStatus`, `GuestBillStatus`, `GuestRelationship`, `JenisPengeluaranTetap`.
- Menambahkan populasi `UserProfile` pada `DummyDataSeeder` agar profil dan pekerjaan penghuni terisi lengkap dalam Bahasa Inggris.
- Memperbaiki penanganan `updateOrCreate` pada `RoleSeeder` dan izin write pada storage container backend.
- Menjalankan re-seed database produksi live di container `wismaamal_backend_app` dan membersihkan cache aplikasi via `optimize:clear`.
- Mengatasi isu blank page Safari pada Flutter Web dengan melakukan build lokal berflag `--no-web-resources-cdn` (CanvasKit mandiri/lokal di `/canvaskit/canvaskit.wasm` tanpa dependensi CDN gstatic).
- Memaketkan dan mengunggah hasil build web ke server ALLVVNT, merebuild image `wismaamal/frontend-web`, serta me-restart container `wismaamal_frontend_web`.
- Verifikasi akhir: `flutter analyze` 0 error, endpoint publik `https://wismaamal.allvvnt.my.id` (HTTP 200), `canvaskit.wasm` (HTTP 200), dan `https://api-wismaamal.allvvnt.my.id/up` (HTTP 200) aktif dengan konten data berbahasa Inggris.
**File yang diubah:**
- 120+ file di `Project/fe_wisma_amal_gorontalo/lib/`
- `Project/backend-wismaamalgorontalo/Modules/Auth/database/seeders/*`
- `Project/backend-wismaamalgorontalo/Modules/Setting/database/seeders/SettingDatabaseSeeder.php`
- `Project/backend-wismaamalgorontalo/Modules/Finance/database/seeders/FineSeeder.php`
- `Project/backend-wismaamalgorontalo/Modules/Finance/Enums/JenisPengeluaranTetap.php`
- `Project/backend-wismaamalgorontalo/Modules/Finance/Services/FinanceService.php`
- `Project/backend-wismaamalgorontalo/Modules/Guest/Enums/*`
- `Project/backend-wismaamalgorontalo/Modules/Room/Enums/RoomStatus.php`
- `Project/backend-wismaamalgorontalo/Modules/Schedule/Http/Controllers/AdminResidentController.php`
- `Project/backend-wismaamalgorontalo/database/seeders/DummyDataSeeder.php`
- `Project/backend-wismaamalgorontalo/database/seeders/FeatureToggleSeeder.php`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Project/docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Pengujian interaktif end-to-end melalui browser pada berbagai skenario pengguna (admin, staf, penghuni).

---

## [2026-10-21 19:15] Rekonstruksi Ulang BAB 3 Naskah PA: Fokus Desain Sistem & Diagram Fungsional

**Status:** Selesai
**Dikerjakan:**
- Mengarsipkan draf lama BAB 3 yang memuat detail teknis berlebih (endpoint JSON, docker-compose, JSON schema) ke `PA/docs/modules/bab3/DRAFT_v1_2026-10-21.md`.
- Memperbaiki diagram antarmuka frontend `c4_level3_flutter_clean_architecture.svg` dari "Laravel 11 API" menjadi "NestJS API" dan merender ulang versi PNG.
- Menulis ulang `PA/docs/modules/bab3/README.md` berstruktur murni Desain Sistem sesuai panduan proposal PA:
  - §3.1 Deskripsi Solusi (6 pilar perbaikan sistem, Tabel 3.1 Fitur F01–F17).
  - §3.2 Desain Sistem (Arsitektur Terpadu 4 lapis, Dekomposisi 3-Tier NestJS 9 modul, dan Clean Architecture Flutter Web — Gambar 3.1 s/d 3.3).
  - §3.3 Alur Proses Bisnis (9 alur sequence/flowchart proses operasional — Gambar 3.4 s/d 3.12).
  - §3.4 Use Case Diagram (Spesifikasi peran pengguna & pemetaan fungsi — Gambar 3.13 placeholder).
  - §3.5 Data Flow Diagram (DFD Level 0 dengan 7 terminator, DFD Level 1 dengan 10 proses dan 13 data store — Gambar 3.14 & 3.15).
  - §3.6 Activity Diagram (Alur alokasi huni dan tiket kerusakan — Gambar 3.16 & 3.17 placeholder).
  - §3.7 Rancangan Basis Data (ERD 13 tabel PostgreSQL, Kamus Data 13 tabel, serta 9 aturan integritas validasi — Gambar 3.18).
  - §3.8 Rancangan Antarmuka Pengguna (Deskripsi dasbor pemilik, dasbor pengelola, dan portal penghuni — Gambar 3.19 s/d 3.21 placeholder).
- Memperbarui helper `figures_to_images.py` agar otomatis memetakan referensi `.svg` ke `.png`.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/modules/bab3/DRAFT_v1_2026-10-21.md`
- `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/c4_level3_flutter_clean_architecture.svg` dan `.png`
- `PA/docs/modules/figures_to_images.py`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Penyusunan gambar visual untuk 6 diagram yang masih placeholder (Use Case, 2 Activity Diagram, 3 Mockup UI).

---

## [2026-10-21 17:15] Deploy Stack Wisma Amal ke Server ALLVVNT via Docker Compose + Cloudflare Tunnel

**Status:** Selesai
**Dikerjakan:**
- Audit server `ALLVVNT` (CachyOS, 4 vCPU, RAM 7,7 GB, disk sisa 77 GB) via Tailscale `100.92.12.28`. Hasil: Docker 29.9.1 + Compose v5.6.0 tersedia, tidak ada PHP/Node/MySQL di host, `cloudflared` sudah berjalan, port 8080 dipakai Nextcloud AIO, port 3000/9050/9051 dipakai layanan lain.
- Menentukan target deploy bersama pemilik: **stack yang ada (Laravel 11 + MySQL 8 + Flutter Web)** — bukan stack NestJS hasil rewrite ADR-011 — dengan eksposur **Cloudflare Tunnel**.
- Menyinkronkan source backend dan frontend ke `~/wismaamal-deploy/` di server memakai rsync dengan pola exclude ber-anchor (`--exclude=/path`), lalu membuat `docker-compose.yml` dan `.env` produksi khusus server (password DB acak, `APP_DEBUG=false`, `APP_TIMEZONE=Asia/Jakarta`).
- Menyesuaikan compose agar tidak bentrok dengan Nextcloud: phpMyAdmin dipindah ke `127.0.0.1:8081`, seluruh port aplikasi di-bind ke loopback saja sehingga hanya dapat diakses lewat tunnel.
- Membangun tiga image lokal di server tanpa registry: `wismaamal/backend-app` (php:8.2-fpm + ekstensi PHP + composer install), `wismaamal/backend-web` (nginx + public/), dan `wismaamal/frontend-web` (nginx + bundle Flutter Web hasil build lokal dengan `--dart-define=BASE_URL=https://api-wismaamal.allvvnt.my.id`, menghindari unduhan image Flutter 5,5 GB di server).
- Menjalankan migrasi (semua `Ran`, 41+ tabel termasuk `cache`, `jobs`, `cache_locks`), `storage:link`, `optimize:clear`, serta seluruh seeder: `DatabaseSeeder`, `DummyDataSeeder`, `FeatureToggleSeeder`, dan seeder modul Finance, Schedule, Dashboard, Notification.
- Mengonfigurasi Cloudflare Tunnel `alfian-home-server` (`df9f5ccd-04f2-4fb3-b569-58c75566d2aa`) lewat Cloudflare API: menambah rule ingress `wismaamal.allvvnt.my.id → localhost:8002` dan `api-wismaamal.allvvnt.my.id → localhost:8001`, tanpa menyentuh rule lama `cloud.allvvnt.my.id → localhost:11000`.
- Mengerjakan ulang record DNS CNAME `wismaamal` dan `api-wismaamal` dari tunnel mati `cc728a42-…` ke tunnel aktif `df9f5ccd-…` (sebelumnya keduanya mengembalikan HTTP 530).
- Verifikasi publik dari server: frontend 200, `/up` 200, `/docs/api` 200, `POST /api/login` 200 dengan token dan role, `main.dart.js` 200, serta `cloud.allvvnt.my.id` tetap 302 (Nextcloud tidak terganggu).
**File yang diubah:**
- Server: `~/wismaamal-deploy/{docker-compose.yml,.env,modules_statuses.json}`, `~/wismaamal-deploy/backend/**`, `~/wismaamal-deploy/frontend/**`
- Server: `/etc/docker/` tidak diubah; `systemctl mask sleep/suspend/hibernate.target` + `iw dev wlan0 set power_save off` (mitigasi server yang terputus saat beban berat)
- Repo: tidak ada perubahan kode aplikasi
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- CI GitHub Actions di `Project/*/.github/workflows/deploy.yml` tidak pernah ter-trigger karena `.github/workflows` harus berada di root repo; image GHCR juga private sehingga server butuh PAT untuk menarik.
- Kunci Midtrans masih kosong → modul Finance belum bisa memproses pembayaran sungguhan.
- Belum ada panduan deployment repeatable di `Docs/`;.compose di server masih hasil adaptasi manual.
- Stack yang berjalan masih Laravel + MySQL, jadi belum sesuai ADR-011/ADR-012 (NestJS + PostgreSQL).
**Catatan/masalah:**
- Server sempat dua kali terputus dari Tailscale saat menjalankan build Docker dan pull image besar; penyebabnya power management Wi-Fi dan auto-suspend, sudah dimitigasi dengan mask target suspend dan mematikan power save Wi-Fi.
- `storage/framework/views` dan `bootstrap/cache` sempat hilang saat sinkronisasi karena pola exclude rsync tidak di-anchor; keduanya kini ikut tersalin dan build berjalan.
- Akun demo hasil seeding: `admin@wismaamal.com` / `staff@wismaamal.com` / `ahmad@example.com`, sandi `password`.

---

## [2026-10-21 16:05] Audit dan Penyelarasan Konsistensi BAB 3 terhadap Desain Final

**Status:** Selesai
**Dikerjakan:**
- Menjalankan audit silang antara naskah BAB 3 dengan diagram HTML, diagram Mermaid, dan dokumen desain (ADR-007, ADR-011, ADR-012, DESAIN_REWRITE_FASE1).
- Menyamakan nama modul pada Tabel 3.1 dengan sembilan modul pada Tabel 3.7 dan kedua diagram arsitektur; F07 kini ditandai sebagai fungsi baca agregat di atas modul Lease dan Room, bukan modul tersendiri.
- Menyamakan story points Tabel 3.2 dengan penjumlahan Tabel 3.3: 21, 21, 27, 26 poin dengan total 95 poin, sebelumnya tertulis 26, 30, 32, 26 dan 114 poin.
- Menambahkan daftar sembilan event antar modul beserta penerbit dan penanganinya, mencakup `LeaseCreated`, `InvoiceIssued`, `PaymentSettled`, `InvoiceOverdue`, `RoomDamaged`, `RoomRepaired`, `GuestCheckedOut`, `AssetDamagedOrLost`, dan `MaintenanceServiceCompleted`.
- Menyamakan path endpoint pada Tabel 3.17 dengan path yang dipakai diagram Mermaid, dan melengkapi tabel dengan endpoint yang baru muncul pada diagram.
- Menomori ulang sembilan gambar agar berurutan sesuai kemunculan dalam naskah; sebelumnya diagram BPMN bernomor 3.6 sampai 3.9 berada sebelum diagram DFD 3.3 sampai 3.5.
- Menyesuaikan path pada lima berkas Mermaid: `api/finance/expenses` menjadi `api/expenses`, `api/finance/invoices` menjadi `api/invoices`, `api/finance/reports/cashflow` menjadi `api/dashboard/summary`, `api/mcp/rpc` menjadi `/mcp/tools/call`, dan dua endpoint tamu menjadi `POST /api/guests/{id}/check-in` serta `POST /api/guests/{id}/checkout`. Diagram konsultasi AI kini mencantumkan keempat tool yang tersedia.
- Hasil audit akhir: sembilan modul, tiga belas tabel, sepuluh proses DFD, sembilan event, story points, nomor tabel 1 sampai 21, nomor gambar 1 sampai 9, dan seluruh berkas rujukan konsisten.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/System design/02-BPMN/*/*.mmd` dan `*.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tiga fitur (F02, F11, F13) belum memiliki tabel pada skema 13 tabel dan ditandai sebagai perluasan skema.
- Daftar Gambar dan Daftar Tabel belum dibuat pada dokumen akhir.
- Blocker sitasi `[36]`, `[41]`, dan urutan kemunculan `[1]` masih terbuka.
**Catatan/masalah:**
- Naskah kini 8.047 kata dengan 21 tabel dan 9 gambar.

---

## [2026-10-21 15:35] Pipeline Build Docx: Render Diagram dan Sisipkan Gambar ke Naskah

**Status:** Selesai
**Dikerjakan:**
- Menambah `PA/docs/modules/figures_to_images.py`: merender diagram Mermaid (mermaid-cli) dan diagram HTML (headless Edge, SVG diambil dari DOM lalu dirender ulang) menjadi PNG, serta mengubah catatan gambar pada markdown menjadi embed gambar.
- Menambah `PA/docs/modules/build-docx.sh`: pipeline empat langkah, yaitu render diagram, penggabungan BAB 1 sampai BAB 5 beserta Daftar Pustaka, penyisipan gambar, dan konversi ke docx memakai Pandoc dengan Daftar Isi otomatis.
- Memperbaiki tiga cacat pada perekaman diagram HTML: pilihan elemen SVG mengambil ikon tombol dan bukan diagram, atribut namespace `xmlns` hilang saat serialisasi DOM, dan ukuran jendela render membuat gambar bersisip ruang kosong.
- Rujukan Gambar 2.14 pada BAB 2 diarahkan ke lokasi baru `02-BPMN/09_konsultasi_ai_mcp/`.
- Menghasilkan `PA/docs/modules/ProyekAkhir_PA.docx` (86 halaman, 9 gambar tertanam) sebagai uji pipeline; berkas ini dapat dihapus karena naskah akan dibangun ulang dengan template kampus.
**File yang diubah:**
- `PA/docs/modules/figures_to_images.py` (baru)
- `PA/docs/modules/build-docx.sh` (baru)
- `PA/docs/modules/bab2/README.md`
- `PA/docs/System design/**/*.png` dan `*.svg` (hasil render)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- `template_pens.docx` belum ada di `PA/docs/modules/`, sehingga konversi memakai style bawaan Pandoc. Setelah template tersedia, pipeline memakainya secara otomatis.
- Tiga fitur (F02, F11, F13) masih tanpa tabel pada skema 13 tabel.
- `04-ERD/erd_sistem_dinamis.html` versi lama dan folder `System design/draft/` belum diarsipkan.
**Catatan/masalah:**
- Berkas `full_draft.md` dan `Proposal_Proyek_Akhir_Bagus.docx` milik pengguna ditulis ulang oleh pipeline baru; isi keduanya setara.

---

## [2026-10-21 14:05] Penyelarasan Diagram BAB 3: 5 Berkas HTML, 9 Diagram Mermaid, dan Render PNG

**Status:** Selesai
**Dikerjakan:**
- `01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html` (baru): diagram arsitektur terpadu empat lapis — tiga dasbor Flutter Web, adapter Keycloak OIDC, REST API NestJS, MCP Server, sembilan modul pada tiga tier, module gateway, adapter keluar, dan PostgreSQL.
- `01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html` (diperbarui): 4 modul inti dan 5 modul bisnis sesuai ADR-007, PostgreSQL, NestJS Guard JWT, Keycloak OpenID Connect.
- `03-DFD/dfd_level_0_context.html` (diperbarui): Keycloak ditambahkan sebagai entitas luar ketujuh, seluruh label aliran diselaraskan.
- `03-DFD/dfd_level_1_dekomposisi.html` (diperbarui): 10 proses dan 13 data store sesuai kamus data, ditambah entitas Teknisi dan Model Bahasa AI.
- `04-ERD/erd_13_tabel.html` (baru): ERD 13 tabel pada sembilan panel modul; dua FK fisik digambar, sisanya ditandai soft-reference.
- Sembilan berkas `.mmd` pada `02-BPMN/`: istilah usang diganti (Modul Schedule menjadi Lease, Frontend UI Web/Mobile menjadi Flutter Web, event Occupancy menjadi Lease, MySQL menjadi PostgreSQL, status kamar diseragamkan), lalu dirender menjadi PNG 3x di folder masing-masing memakai mermaid-cli.
- Alur alokasihunian ditulis ulang mengikuti desain final: sewa bulanan, validasi minimum sewa gedung, penguncian baris, dan payment barrier Finance.
- Tabel katalog BPMN dan Tabel proses DFD Level 1 diselaraskan; penomoran tabel kini 3.1 sampai 3.21 berurutan.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html` (baru)
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
- `PA/docs/System design/03-DFD/dfd_level_0_context.html`
- `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.html`
- `PA/docs/System design/04-ERD/erd_13_tabel.html` (baru)
- `PA/docs/System design/02-BPMN/*/*.mmd` dan `*.png`
- `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Tiga fitur belum memiliki tabel pada skema 13 tabel, yaitu F02 peran kustom, F11 pengeluaran operasional, dan F13 pemeliharaan rutin berkala. Ketiganya ditandai pada diagram Mermaid dan dicatat pada naskah sebagai perluasan skema.
- `04-ERD/erd_sistem_dinamis.html` versi lama 21 tabel masih ada dan belum diarsipkan.
- `System design/draft/` masih memuat versi lama tiga diagram BPMN dan use case.
- `docs-generator.sh` belum merender Mermaid menjadi gambar saat konversi ke docx. mermaid-cli sudah terpasang, tinggal menambahkan langkah render.
**Catatan/masalah:**
- Mesin layout ERD yang lama tidak dapat menggambar relasi lintas modul, sehingga FK `buildings.owner_id` hanya ditandai lewat tag kolom.

---

## [2026-10-21 13:35] Penyesuaian Format Diagram BAB 3 (HTML untuk Gambaran Umum, DFD, ERD; Mermaid untuk BPMN)

**Status:** Selesai
**Dikerjakan:**
- Menyesuaikan seluruh rujukan gambar di `PA/docs/modules/bab3/README.md` mengikuti klarifikasi format: gambaran umum, DFD, dan ERD memakai HTML, sedangkan BPMN memakai notasi Mermaid pada berkas `.mmd`.
- Gambar yang dipertahankan sembilan buah: 3.1 arsitektur terpadu (HTML), 3.2 dekomposisi modulith 3-tier (HTML), 3.3 DFD Level 0 (HTML), 3.4 DFD Level 1 (HTML), 3.5 ERD 13 tabel (HTML), 3.6 alokasi penempatan (Mermaid), 3.7 penagihan dan pembayaran (Mermaid), 3.8 laporan kerusakan (Mermaid), 3.9 konsultasi AI (Mermaid).
- Rujukan gambar yang dihapus: alur kerja Scrum, papan sprint, sequence OIDC, dua diagram aktivitas, sequence reservasi, use case global, tiga mockup antarmuka, dan komposisi container. Uraian teks pada §3.4.4, §3.4.5, §3.5.1, §3.7, dan §3.9 tetap dipertahankan.
- Menambah Tabel 3.12 berisi katalog sembilan diagram BPMN beserta fitur dan alur utamanya.
- Memindahkan `bpmn_konsultasi_ai_mcp.mmd` dari `System design/draft/06_bpmn_konsultasi_ai_mcp/` ke `System design/02-BPMN/09_konsultasi_ai_mcp/` agar sejajar dengan delapan alur lain.
- Memperbaiki satu karakter rusak pada `PA/docs/modules/referensi/README.md` ("Dilarang添加 referensi" menjadi "Dilarang menambahkan referensi").
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.mmd` (pemindahan)
- `PA/docs/modules/referensi/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Empat berkas HTML yang sudah ada masih menggambarkan arsitektur lama: `arsitektur_backend_modulith.html`, `dfd_level_0_context.html`, `dfd_level_1_dekomposisi.html`, dan `erd_sistem_dinamis.html`.
- `arsitektur_terpadu.html` dan `erd_13_tabel.html` belum dibuat.
- Sembilan berkas Mermaid masih memakai istilah lama seperti Modul Schedule dan Frontend UI Web/Mobile.
- Pipeline `docs-generator.sh` belum merender Mermaid menjadi gambar saat konversi ke docx.
**Catatan/masalah:**
- Nomor tabel pada naskah kini 3.1 sampai 3.21 dan nomor gambar 3.1 sampai 3.9, keduanya berurutan tanpa lompatan.

---

## [2026-10-21 13:09] Penyelarasan Ulang Teks BAB 3 ke Arsitektur Final (NestJS, Keycloak, PostgreSQL, 13 Tabel)

**Status:** Selesai untuk bagian teks; 19 diagram HTML menyusul
**Dikerjakan:**
- Menulis ulang `PA/docs/modules/bab3/README.md` (5.341 menjadi 7.609 kata) agar konsisten dengan ADR-007, ADR-011, dan ADR-012.
- Mengganti seluruh kotak ASCII dan tabel ASCII menjadi tabel markdown (20 tabel) dan 19 rujukan gambar bernomor berurutan.
- Menambahkan bagian yang sebelumnya belum ada: alur OIDC dan JWKS (§3.3.3), struktur direktori backend (§3.3.2), dua diagram aktivitas (§3.4.4-3.4.5), use case UC-03 dan UC-05, DFD Level 0 dan Level 1, rancangan Docker Compose (§3.9), timeline delapan minggu (§3.10.1), dan instrumen kuesioner (§3.10.2).
- Memperbarui istilah usang: Laravel menjadi NestJS, Spatie menjadi Keycloak OIDC, MySQL menjadi PostgreSQL, modul Schedule menjadi Lease, 12 modul menjadi 9 modul, 41 tabel menjadi 13 tabel, durase harian dan tahunan menjadi bulanan saja, header `X-Building-ID` menjadi klaim `building_id` pada token, serta Pest dan deptrac menjadi Jest, Supertest, dan ESLint.
- Memindahkan desain lama (ERD 41 tabel, matriks 12 modul, kamus data 6 tabel) ke `PA/docs/modules/bab3/ARSIP_DESAIN_LAMA.md` supaya isi lama tidak hilang tetapi tidak lagi mengganggu alur naskah.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
- `PA/docs/modules/bab3/ARSIP_DESAIN_LAMA.md` (baru)
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/00_overview/STATE.md`
- `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- 19 diagram dan mockup HTML belum dibuat; lokasi berkas target sudah disebut pada setiap rujukan gambar di naskah.
- Diagram lama di `PA/docs/System design/` masih menggambarkan arsitektur lama (12 modul, 41 tabel) dan perlu digantikan.
- Blocker sitasi belum dibereskan: `[36]` dan `[41]` dipakai di BAB 2 tetapi tidak ada di daftar pustaka, dan urutan kemunculan di BAB 1 masih dimulai dari `[2]`.
**Catatan/masalah:**
- Label tabel memakai pola `**Tabel 3.x - Judul**` agar tetap terbaca di markdown; pipeline docx perlu membaca pola ini atau dikonversi ke `custom-style`.
- Dua berkas docx hasil percobaan sebelumnya (`ProyekAkhir_BAB1_BAB2_v0.4.docx` dan `ProyekAkhir_PA_lengkap_v0.5.docx`) masih ada di `PA/docs/` dan dapat dihapus bila tidak diperlukan.

---

## [2026-10-21 12:37] Perbaikan Paket DOCX v0.4: Relasi Footer Hilang

**Status:** Selesai
**Dikerjakan:**
- Menemukan penyebab `ProyekAkhir_BAB1_BAB2_v0.4.docx` tidak bisa dibuka di Pages dan Google Docs: `document.xml` merujuk `rIdFtr2` (footer halaman pertama) tetapi relasi itu tidak tertulis di `word/_rels/document.xml.rels`. Paket OOXML jadi tidak konsisten.
- Menambahkan relasi `rIdFtr2` beserta part `word/footer2.xml`, lalu memperbaiki urutan elemen `w:shd` pada style Source Code.
- Memvalidasi ulang paket: content type setiap part, seluruh relasi dan target, semua `r:id`/`r:embed`, urutan elemen `pPr`/`rPr`/`sectPr`/`style`/`tblPr`/`tcPr`, serta well-formed XML. Hasil: 0 masalah.
- Menguji buka file di Pages 14.4 lewat AppleScript: dokumen berhasil dibuka.
**File yang diubah:**
- `PA/docs/ProyekAkhir_BAB1_BAB2_v0.4.docx` (digenerate ulang)
**Dokumen yang diupdate:**
- `PA/docs/03_logs/CHANGELOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu konfirmasi user apakah file sudah bisa dibuka di Google Docs.
- Blocker sitasi (`[36]`, `[41]`, urutan `[1]`) masih terbuka.
**Catatan/masalah:**
- Diagnosis awal (aplikasi Google Drive sebagai penyebab) keliru; file memang cacat pada relasi footer.

---

## [2026-10-21 12:26] Generate DOCX BAB 1 + BAB 2 (v0.4) via Pandoc

**Status:** Sebagian (draft docx jadi, dua blocker sitasi belum dibereskan)
**Dikerjakan:**
- Menyusun pipeline Markdown -> DOCX dengan Pandoc 3.12.1 mengikuti `PA/docs/01_guides/docs-convertion.md`.
- Membuat `reference.docx` kustom: A4, margin 4-4-3-3 cm, Times New Roman 12 pt, spasi 1,5, Heading 1 kapital di tengah + mulai halaman baru, Heading 2-3 bold hitam, caption 10 pt, tabel berbingkai 10 pt, daftar pustaka hanging indent.
- Menyusun cover, Daftar Isi (field TOC yang dimuat Word saat dibuka), nomor halaman romawi untuk front matter dan arab untuk isi.
- Menggabungkan `modules/bab1/README.md` + `modules/bab2/README.md` + `modules/referensi/DAFTAR_PUSTAKA_LENGKAP.md` menjadi satu dokumen.
- Gambar 2.2, 2.4, 2.5 disisipkan dari `System design/`; 11 gambar lain ditandai "(belum tersedia)".
- Menambahkan caption `Tabel 1.1 Empat Proposal Previous Work` dan `Tabel 2.1 Penelitian Terkait` di dokumen hasil (belum ditulis di markdown sumber).
- Memperbaiki list yang menempel pada paragraf pengantar agar dikenali Pandoc (hanya di salinan build, sumber tidak diubah).
**File yang diubah:**
- `PA/docs/ProyekAkhir_BAB1_BAB2_v0.4.docx` (baru)
**Dokumen yang diupdate:**
- `PA/docs/03_logs/CHANGELOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Blocker sitasi: urutan kemunculan di body dimulai dari `[2]`, bukan `[1]`. `[36]` dan `[41]` dipakai di BAB 2 tetapi tidak ada di `DAFTAR_PUSTAKA_LENGKAP.md` (28 entri).
- 11 gambar BAB 2 belum tersedia.
- Daftar Gambar dan Daftar Tabel belum dibuat (butuh caption ber-SEQ field).
- Pipeline build masih di direktori sementara, belum disimpan di repo.
**Catatan/masalah:**
- Isi naskah markdown tidak diubah. Semua transformasi (caption tabel, gambar, perbaikan list) hanya terjadi di salinan build.
- Layout belum diverifikasi visual di Word/LibreOffice (keduanya tidak terpasang di mesin ini).

---

## [2026-10-18 11:15] Rekonstruksi Penuh BAB 3: NestJS Modular Monolith, BPMN, DFD, ERD 13 Tabel, & Kontrak REST/MCP

**Status:** Selesai
**Dikerjakan:**
- Menulis ulang `PA/docs/modules/bab3/README.md` (Metodologi dan Perancangan Sistem):
  1. §3.1: Deskripsi solusi terpadu sistem informasi manajemen rumah kost multi-gedung berbasis NestJS, Keycloak OIDC, MCP AI, dan Flutter Web.
  2. §3.2: Rincian 4 siklus sprint Scrum dan user stories sewa bulanan dengan `min_rental_months` serta kueri analitik AI.
  3. §3.3: Diagram arsitektur Clean-Modulith NestJS, dekomposisi 9 modul, 13 tabel domain bersih, dan nol FK fisik lintas modul.
  4. §3.4: BPMN alur sewa bulanan dan pembayaran Midtrans SNAP, tiket komplain berfoto, dan kueri analitik via MCP JSON-RPC 2.0.
  5. §3.5: Use Case global dan DFD Level 0 & Level 1 dengan 13 data store logis.
  6. §3.6: Diagram ERD tunggal 13 tabel domain bersih dan kamus data komprehensif 13 tabel.
  7. §3.7: Desain antarmuka Flutter Web responsif (dashboard pemilik dengan multi-gedung switcher & panel asisten AI MCP, dashboard pengelola, portal penghuni).
  8. §3.8: Spesifikasi teknis tool server MCP (JSON Schema) dan kontrak endpoint REST API.
  9. §3.9: Matriks skenario pengujian piramida (Supertest, Jest, Flutter Test, ESLint module boundary).
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Tinjau bersama naskah BAB 3
- Perbarui diagram arsitektur visual / SVG bila diperlukan
- Lanjut ke tahap perancangan teknis / scaffolding backend NestJS

---

## [2026-10-10 15:11] Penyelesaian Desain Konseptual & Penjadwalan Revisi BAB 1-3

**Status:** Selesai
**Dikerjakan:**
- Mengonfirmasi bahwa seluruh bekal konseptual sistem untuk sidang proposal (Daftar Fitur, BPMN, DFD, ERD, dan Arsitektur Backend) telah selesai dirancang dan disetujui.
- Menambahkan task "Revisi Naskah Modul BAB 1 - BAB 3" ke dalam antrean (Next Steps) di `STATE.md`. Task ini akan dikerjakan pada sesi berikutnya, untuk menyelaraskan isi naskah skripsi dengan rancangan sistem terbaru.
**File yang diubah:**
- `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menulis/Merevisi naskah `PA/docs/modules/bab1/` hingga `bab3/` (Sesi Berikutnya).

---

## [2026-10-10 15:06] Keputusan Arsitektur: Adapter Pattern untuk Integrasi Eksternal (ADR-010)

**Status:** Selesai
**Dikerjakan:**
- Mencatat keputusan strategis (ADR-010) terkait penanganan layanan pihak ketiga (Midtrans, WhatsApp/Fonnte, Email).
- Menyepakati penggunaan pola **Hexagonal Architecture (Ports and Adapters)** untuk menghindari *vendor lock-in*. Modul bisnis tidak akan memanggil vendor secara langsung (hardcode), melainkan melalui *Interfaces* dan *Adapters*.
- Sengaja **tidak mengubah diagram arsitektur** pada turn ini karena User sedang mendesain diagramnya sendiri.
**Dokumen yang diupdate:**
- `Docs/03_logs/DECISIONS.md` (Menambahkan ADR-010)
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu hasil desain diagram arsitektur final yang sedang disesuaikan oleh user.

---

## [2026-10-10 15:04] ADR-010: Pola Integrasi Pihak Ketiga & Update Arsitektur

**Status:** Selesai
**Dikerjakan:**
- Mencatat keputusan arsitektural (ADR-010) terkait penggunaan **Ports and Adapters (Gateway Pattern)** untuk integrasi layanan pihak ketiga (Midtrans, Fonnte/SMTP).
- Menghindari *vendor lock-in* dan menerapkan *Dependency Inversion* menggunakan antarmuka dan adapter (misal: `PaymentGatewayContract` $\rightarrow$ `MidtransAdapter`).
- Memperbarui diagram HTML arsitektur backend untuk menyisipkan layer **External Integration Adapters** sebelum menembak ke API eksternal.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
**Dokumen yang diupdate:**
- `Docs/03_logs/DECISIONS.md`
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Tahap perencanaan desain selesai, bersiap menuju implementasi atau pembahasan komponen sistem lain.

---

## [2026-10-10 14:52] Penggabungan Kelengkapan Diagram Arsitektur

**Status:** Selesai
**Dikerjakan:**
- Mendesain ulang `arsitektur_backend_modulith.html` dengan menggabungkan kelengkapan dari desain kolom (ada layer Klien, Adapter API, Database MySQL, Midtrans, dan API WhatsApp/Email).
- Mempertahankan struktur visual yang simpel dan jelas bergaya "puzzle" (Modul Core di sayap kiri, Opsional di sayap kanan, dan Gateway di tengah).
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu konfirmasi final mengenai hasil penggabungan arsitektur ini.

---

## [2026-10-10 14:48] Revisi Desain Visual Diagram Arsitektur

**Status:** Selesai
**Dikerjakan:**
- Mendesain ulang `arsitektur_backend_modulith.html` untuk kembali mengikuti gaya visual dari desain lama (tata letak puzzle dengan node kiri-kanan terhubung ke Module Gateway di tengah).
- Menghapus referensi teknologi spesifik (Laravel) karena framework backend belum diputuskan final.
- Menyesuaikan 5 modul Core di sisi kiri dan 6 modul Opsional (termasuk MCP Adapter) di sisi kanan.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Menunggu konfirmasi kelayakan bentuk visual yang baru ini.

---

## [2026-10-10 14:45] Pembaruan Diagram Arsitektur Backend (Modular Monolith)

**Status:** Selesai
**Dikerjakan:**
- Membuat diagram arsitektur backend interaktif baru di `arsitektur_backend_modulith.html` menggunakan konvensi HTML-first SVG export.
- Menyesuaikan struktur dengan **10 Modul** (5 Core + 5 Optional) sesuai dengan rancangan terbaru di `ARCHITECTURE.md`.
- Menggantikan posisi Sanctum Auth dengan **Keycloak IAM** (External SSO) pada adapter layer diagram.
- Memperbarui `hierarki_3_tier_modulith.mmd` untuk menjaga konsistensi dengan perubahan struktur modul dan Keycloak.
**File yang diubah:**
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html`
- `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/hierarki_3_tier_modulith.mmd`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Meminta review user untuk diagram arsitektur backend baru.
- Menunggu konfirmasi user mengenai field `building_id` di tabel role (seperti log sebelumnya).
**Catatan/masalah:**
- Tidak ada masalah. Layout diagram kini lebih ringkas dan sesuai dengan standar yang diminta.

---

## [2026-10-10 14:35] Koreksi ERD: tabel users diselaraskan dengan ADR-006 (Keycloak SSO)

**Status:** Selesai
**Dikerjakan:** Hapus `users.password`, tambah `keycloak_sub` (UK) + `last_login_at` di `erd_sistem_dinamis.html` & `ERD_SISTEM_DINAMIS.mmd`. `users` kini proyeksi lokal identitas Keycloak; autentikasi di Keycloak, otorisasi (roles/permissions dinamis) tetap lokal.
**Next:** Konfirmasi user soal `user_roles.building_id` (role per gedung) & sinkron README ERD.

---

## [2026-10-10 14:33] Redesign ERD HTML + konvensi "diagram = HTML dulu"

**Status:** Selesai (menunggu review user)
**Dikerjakan:**
- `erd_sistem_dinamis.html` ditulis ulang: panel per modul (Core solid, Opsional putus-putus), 21 tabel lengkap kolomnya, FK intra-modul bergaris crow's foot, soft-ref lintas modul sebagai tag oranye `→tabel` (tanpa garis silang). Layout otomatis dari array data, export SVG/PNG.
- Konvensi baru di `PA/docs/01_guides/CONVENTIONS.md` §Diagram: semua diagram dibuat sebagai HTML dulu.
**Catatan:** Ditambahkan kolom `building_settings.min_rental_months` (dibutuhkan F04, belum ada di `.mmd`) — perlu konfirmasi user. Gap lain: belum ada tabel audit log (F02) dan realisasi biaya servis (F13).

---

## [2026-10-10 14:30] Redesign DFD Level 1 — layout per-baris, 10 proses (F01–F17 lengkap)

**Status:** Selesai (menunggu review user)
**Dikerjakan:**
- Versi 6 proses sebelumnya ditolak (label tertimpa panah, fitur tidak lengkap). Diganti 10 proses (1.0–10.0) yang memetakan seluruh F01–F17 dan 9 data store (D1–D9, selaras ERD).
- Layout di-generate JS dari array data: tiap aliran punya jalur horizontal sendiri, label berlatar putih, entitas/data store duplikat ditandai (Gane & Sarson) → nol persilangan.
**File yang diubah:** `PA/docs/System design/DFD/dfd_level_1_dekomposisi.html`, `PA/docs/System design/DFD/README.md`
**Belum selesai / next steps:** `DFD_LEVEL_1_DEKOMPOSISI.mmd` masih versi 6 proses (perlu disinkronkan bila tetap dipakai); lanjut Step 4 API.

---

## [2026-10-10 14:25] Penyempurnaan DFD Level 0 & Level 1 ke Standar Akademis Murni (3 Kolom Sesuai Contoh Gambar 2, 3, 4)

**Status:** Selesai (Standar Akademis Terverifikasi, Sangat Rapi, & Terbaca Jelas)
**Dikerjakan:**
- **Penyusunan Ulang DFD Level 0 ([`dfd_level_0_context.html`](file:///Users/allvvnt/alfianSpace/Kampus/PA-Management-kost/PA/docs/System%20design/DFD/dfd_level_0_context.html)):**
  - Mengubah notasi proses sentral menjadi Lingkaran (*Bubble*) murni bernomor `0.0 SISTEM INFORMASI MANAJEMEN PROPERTI & HUNIAN DINAMIS` sesuai standar Yourdon & DeMarco (Gambar 4).
  - Entitas luar persegi panjang di kiri (Pemilik, Pengelola, Penghuni) dan kanan (Midtrans, WhatsApp Gateway, AI Client).
  - Aliran panah siku orthogonal dengan pembeda tegas: Garis Biru (Input ke Sistem) & Garis Merah (Output ke Entitas).
- **Penyusunan Ulang DFD Level 1 ([`dfd_level_1_dekomposisi.html`](file:///Users/allvvnt/alfianSpace/Kampus/PA-Management-kost/PA/docs/System%20design/DFD/dfd_level_1_dekomposisi.html)):**
  - Menerapkan format 3 kolom presisi sesuai referensi baku pengguna (Gambar 3):
    1. **Kolom Kiri (Data Store):** Notasi 2 garis horizontal paralel terbuka (`D1` s/d `D6`).
    2. **Kolom Tengah (Proses):** Simbol Lingkaran bertingkat (`1.0` s/d `6.0`).
    3. **Kolom Kanan (Entitas Luar):** Simbol Persegi Panjang (Pemilik, Pengelola, Penghuni, Layanan Luar).
  - Mengatur aliran data rapi tanpa kusut:
    - Garis **Biru** untuk Aliran Masuk (*Input / Read Query*).
    - Garis **Merah** untuk Aliran Keluar (*Output / Write Mutation / Response*).
    - Legenda Input (Biru) & Output (Merah) di pojok kanan atas serta judul `DFD LEVEL 1` (bold underline) di kiri atas.
- **Penyelarasan Naskah & Skrip Pendukung:**
  - Mengupdate [`DFD_LEVEL_1_DEKOMPOSISI.mmd`](file:///Users/allvvnt/alfianSpace/Kampus/PA-Management-kost/PA/docs/System%20design/DFD/DFD_LEVEL_1_DEKOMPOSISI.mmd) dan [`README.md`](file:///Users/allvvnt/alfianSpace/Kampus/PA-Management-kost/PA/docs/System%20design/DFD/README.md) agar selaras dengan dekomposisi 6 proses fungsional dan matriks 6 data store terisolasi.
  - Memastikan tombol **Download SVG** dan **Download PNG (2x High-Res)** berfungsi sempurna untuk disematkan ke naskah skripsi (.docx).
**File yang diubah:**
- `PA/docs/System design/DFD/dfd_level_0_context.html`
- `PA/docs/System design/DFD/dfd_level_1_dekomposisi.html`
- `PA/docs/System design/DFD/DFD_LEVEL_1_DEKOMPOSISI.mmd`
- `PA/docs/System design/DFD/README.md`
- `Docs/03_logs/PROGRESS_LOG.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/System design/DFD/README.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 4: Spesifikasi Kontrak API REST & Skema Event Bus antar-modul di `PA/docs/System design/API/`.

---

## [2026-10-10 14:15] Pembuatan Visualizer HTML Interaktif untuk DFD & ERD dengan Fitur Export SVG & PNG

**Status:** Selesai (Rapi, Ringkas, & Siap Dokumen A4)
**Dikerjakan:**
- Merancang visualizer HTML interaktif mandiri (*zero external dependencies*) dengan estetika modern, layout ringkas horizontal, dan tipografi jelas yang pas untuk format dokumen:
  1. [`dfd_level_0_context.html`](PA/docs/System%20design/DFD/dfd_level_0_context.html): Implementasi persis referensi visual pengguna (Kartu hijau mint di kiri, pill ungu sentral, kartu abu-abu di kanan, dan label aliran horizontal rapi).
  2. [`dfd_level_1_dekomposisi.html`](PA/docs/System%20design/DFD/dfd_level_1_dekomposisi.html): Visualizer 9 proses domain dan 9 data store terisolasi dengan pembagian zona Core vs Opsional.
  3. [`erd_sistem_dinamis.html`](PA/docs/System%20design/ERD/erd_sistem_dinamis.html): Visualizer model data 21 entitas dengan tab "Diagram Ringkas A4" (overview modular) dan "Kamus Tabel Lengkap" (detail atribut, PK, FK, soft-ref).
- Menyematkan tombol **Download SVG** (vektor loss-less) dan **Download PNG (2x High-Res)** pada setiap berkas HTML untuk memudahkan ekspor ke naskah skripsi (.docx).
- Memperbarui dokumentasi `PA/docs/System design/DFD/README.md` dan `PA/docs/System design/ERD/README.md`.
**File yang diubah:**
- `PA/docs/System design/DFD/dfd_level_0_context.html`, `PA/docs/System design/DFD/dfd_level_1_dekomposisi.html`, `PA/docs/System design/ERD/erd_sistem_dinamis.html`, `PA/docs/System design/DFD/README.md`, `PA/docs/System design/ERD/README.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/System design/DFD/README.md`, `PA/docs/System design/ERD/README.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 4: Spesifikasi Kontrak API REST & Skema Event Bus antar-modul di `PA/docs/System design/API/`.

---

## [2026-10-10 13:58] Step 3: Perumusan Model Data (ERD Dinamis) & Aliran Data (DFD L0 & L1)

**Status:** Selesai (Dirumuskan & Didokumentasikan Lengkap)
**Dikerjakan:**
- **Penetapan Status Folder `draft/`:** Menandai seluruh subfolder lama (04–16) di `PA/docs/System design/draft/` sebagai arsip legacy (*obsolete / superseded*) pasca-keputusan full rewrite (ADR-007 & ADR-008).
- **Perumusan Model Data (Step 3A - ERD Dinamis):**
  - Membuat diagram Mermaid [`ERD_SISTEM_DINAMIS.mmd`](PA/docs/System%20design/ERD/ERD_SISTEM_DINAMIS.mmd) dengan 21 entitas logis yang terbagi ke dalam 9 modul domain (Core M1–M4 & Opsional O1–O5).
  - Menerapkan arsitektur *Modular Monolith* dengan **nol physical foreign key lintas modul** (komunikasi antar modul murni *soft reference* terindeks + Domain Event Bus).
  - Menerapkan pemisahan tegas antara fisik kamar (`rooms`, `room_types`, `room_images`) dan dimensi waktu sewa/alokasi (`occupancies`, `occupancy_members`), serta isolasi multi-tenant (`building_id`).
  - Menyusun Kamus Data komprehensif 21 tabel di [`PA/docs/System design/ERD/README.md`](PA/docs/System%20design/ERD/README.md).
- **Perumusan Aliran Data (Step 3B - DFD Level 0 & Level 1):**
  - Membuat Diagram Konteks Level 0 [`DFD_LEVEL_0_CONTEXT.mmd`](PA/docs/System%20design/DFD/DFD_LEVEL_0_CONTEXT.mmd) memetakan interaksi 6 entitas eksternal (Owner, Admin, Resident, Midtrans, WhatsApp/Email Gateway, External AI Client/MCP).
  - Membuat Diagram Dekomposisi Fungsional Level 1 [`DFD_LEVEL_1_DEKOMPOSISI.mmd`](PA/docs/System%20design/DFD/DFD_LEVEL_1_DEKOMPOSISI.mmd) memetakan 9 proses fungsional domain dan 9 data store terisolasi (`D1` s/d `D9`).
  - Menyusun spesifikasi aliran data lengkap di [`PA/docs/System design/DFD/README.md`](PA/docs/System%20design/DFD/README.md).
- Memperbarui katalog master [`PA/docs/System design/README.md`](PA/docs/System%20design/README.md) dan sinkronisasi status roadmap di `Docs/00_overview/STATE.md` serta `PA/docs/00_overview/STATE.md`.
**File yang diubah:**
- `PA/docs/System design/draft/README.md`, `PA/docs/System design/ERD/**`, `PA/docs/System design/DFD/**`, `PA/docs/System design/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `PA/docs/System design/README.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 4: Spesifikasi Kontrak API REST & Skema Event Bus antar-modul di `PA/docs/System design/API/`.

---

## [2026-10-10 13:53] Eliminasi Folder Diagrams & Pembaruan Menyeluruh Seluruh Pointer Dokumen ke System design

**Status:** Selesai (100% Bersih & Sinkron)
**Dikerjakan:**
- Menghapus symlink/folder `PA/docs/diagrams` secara permanen sehingga tidak ada lagi folder bernama `diagrams` di lingkungan proyek.
- Memperbarui seluruh pointer dokumen aktif yang sebelumnya merujuk ke `diagrams` menjadi `PA/docs/System design/`:
  - `PA/docs/README.md`: Menambahkan `System design/` pada bagan struktur pohon dokumen.
  - `PA/docs/00_overview/ARCHITECTURE.md`: Menambahkan pointer `System design/` pada tabel BAB 3 dan diagram alur penulisan.
  - `PA/docs/modules/bab2/README.md`: Memperbarui seluruh referensi Gambar 2.1–2.8 ke `PA/docs/System design/`.
  - `PA/docs/modules/bab3/README.md`: Memperbarui seluruh referensi Gambar 3.1–3.11 ke `PA/docs/System design/`.
  - `Docs/02_reference/DATABASE_SCHEMA.md`: Memperbarui path referensi ERD visual ke `PA/docs/System design/`.
  - `PA/docs/System design/README.md`: Memperbarui perintah CLI ekspor/re-render Mermaid ke `PA/docs/System design`.
- Merapikan struktur folder `PA/docs/System design/` dengan memindahkan seluruh subfolder diagram (04–16) dari `draft/` ke root dan menghapus direktori `draft/`.
- Verifikasi otomatis: 0 occurrences `diagrams` tersisa di seluruh dokumen aktif (hanya tersimpan di histori log).
**File yang diubah:**
- `PA/docs/README.md`, `PA/docs/00_overview/ARCHITECTURE.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `Docs/02_reference/DATABASE_SCHEMA.md`, `PA/docs/System design/README.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 3: Perumusan Model Data (ERD Dinamis) dan Aliran Data (DFD Level 0 & Level 1) langsung di `PA/docs/System design/`.

---

## [2026-10-10 13:46] Sentralisasi Folder PA/docs/System design/ sebagai Single Source of Truth & Penyesuaian Rules

**Status:** Selesai (Disepakati & Disinkronkan)
**Dikerjakan:**
- Mengubah nama folder sentral perancangan sistem menjadi `PA/docs/System design/` dan membuat symlink `PA/docs/diagrams -> System design` untuk kompatibilitas mundur.
- Menetapkan `PA/docs/System design/` sebagai satu-satunya pusat sumber kebenaran (*Single Source of Truth*) untuk desain sistem (Daftar Fitur F01–F17, 8 Alur BPMN, DFD, ERD, dan Arsitektur) guna mencegah fragmentasi dokumen dan multi-tafsir.
- Memperbarui aturan proyek `AGENTS.md` (Prinsip Dasar No. 6 dan tabel kewajiban pembaruan dokumen) agar setiap keputusan diskusi yang disetujui pengguna secara otomatis langsung dicatat ke `PA/docs/System design/` dan `DECISIONS.md` pada turn yang sama.
- Memperbarui pointer dan roadmap di `Docs/00_overview/STATE.md` serta `PA/docs/00_overview/STATE.md` (Step 1 dan Step 2 selesai 100%, siap lanjut ke Step 3 ERD & DFD).
**File yang diubah:**
- `AGENTS.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 3: Perumusan Model Data (ERD Dinamis) dan Aliran Data (DFD Level 0 Konteks & DFD Level 1 Dekomposisi) di `PA/docs/System design/`.

---

## [2026-10-10 13:35] Pembuatan Folder Terstruktur PA/docs/diagrams/BPMN/ untuk Seluruh 8 Alur (100% Coverage)

**Status:** Selesai (Terstruktur Lengkap 100%)
**Dikerjakan:**
- Membuat folder terpadu `PA/docs/diagrams/BPMN/` dengan 8 subfolder terisolasi sesuai seluruh domain modul:
  1. `01_alokasi_penempatan_hunian/` (`alur_alokasi_penempatan.mmd` + `README.md`)
  2. `02_penagihan_pembayaran/` (`alur_penagihan_pembayaran.mmd` + `README.md`)
  3. `03_laporan_kerusakan_fasilitas/` (`alur_laporan_kerusakan.mmd` + `README.md`)
  4. `04_pemeliharaan_rutin_berkala/` (`alur_pemeliharaan_rutin.mmd` + `README.md`)
  5. `05_pengeluaran_operasional/` (`alur_pengeluaran_operasional.mmd` + `README.md`)
  6. `06_pengawasan_buku_tamu/` (`alur_pengawasan_buku_tamu.mmd` + `README.md`)
  7. `07_pengaturan_hak_akses_dinamis/` (`alur_hak_akses_dinamis.mmd` + `README.md`)
  8. `08_pendataan_inventaris_aset/` (`alur_inventaris_aset.mmd` + `README.md`)
- Membuat katalog master `PA/docs/diagrams/BPMN/README.md`.
- Memperbarui katalog utama `PA/docs/diagrams/README.md`.
**File yang diubah:**
- `PA/docs/diagrams/BPMN/**` (17 file), `PA/docs/diagrams/README.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Lanjut ke Step 3: Penurunan ke ERD dan DFD.

---

## [2026-10-10 13:20] Step 2: Perancangan Alur Proses Bisnis & Payment Gatekeeper Dinamis

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Merumuskan 6 alur proses bisnis inti dan pendukung sistem hunian dinamis:
  1. Flow 1: Alur Alokasi & Penempatan Hunian (Occupancy & Placement).
  2. Flow 2: Alur Penagihan & Pembayaran (Billing & Payment via Midtrans/Manual).
  3. Flow 3: Alur Penanganan Tiket Kerusakan Fasilitas (Maintenance Report).
  4. Flow 4: Alur Pemeliharaan Rutin Berkala Gedung (Preventive Maintenance).
  5. Flow 5: Alur Pencatatan Pengeluaran Operasional (Operational Expenses).
  6. Flow 6: Alur Pengawasan Buku Tamu (Guest Logging).
  7. Flow 7: Alur Konfigurasi Hak Akses Dinamis (Dynamic RBAC).
- Mengintegrasikan konsep *Payment Barrier Gate* dan opsi kebijakan pemilihan kamar (`ADMIN_ASSIGN_ONLY`, `SELF_SERVICE_APPROVAL`, `SELF_SERVICE_INSTANT`) pada `building_settings`.
- Memperbarui diagram `PA/docs/diagrams/04_bpmn_reservasi_pembayaran/bpmn_reservasi_pembayaran.mmd`.
- Mencatat dokumentasi lengkap alur di `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md` (§7).
**File yang diubah:**
- `PA/docs/diagrams/04_bpmn_reservasi_pembayaran/bpmn_reservasi_pembayaran.mmd`, `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Lanjut ke Step 3: Penurunan hasil flow dan kebutuhan ke struktur data (ERD) dan aliran data (DFD L0/L1).

---

## [2026-10-10 13:10] ADR-009: Penempatan MCP sebagai External AI Adapter Layer

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Menetapkan posisi arsitektural Model Context Protocol (MCP):
  - MCP diposisikan sebagai **External AI Adapter Layer** yang hidup di atas modul domain bisnis (sejajar dengan REST API Controller).
  - MCP bukan bagian dari domain bisnis inti, tidak memiliki database bisnis sendiri, dan tidak masuk ke dokumen data/ERD operasional.
  - Sifat akses MCP adalah *read-only query* via Module Gateway yang sensitif terhadap status aktif/tidaknya modul opsional per gedung.
- Mencatat ADR-009 di `Docs/03_logs/DECISIONS.md`.
- Memperbarui diagram arsitektur layer di `Docs/00_overview/ARCHITECTURE.md`.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Finalisasi Step 1 (Kebutuhan & Fitur) dan lanjut ke Step 2 (Perancangan Alur / Flow Diagram).

---

## [2026-10-10 13:05] ADR-008: Pemisahan Room vs Schedule & Decoupling Finance ke Modul Opsional

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Merumuskan keputusan arsitektur dinamis ADR-008 untuk mendukung multi-kasus properti (kost komersial, asrama, mes karyawan, pondok pesantren):
  1. Memisahkan Room Management (aset fisik & kapasitas) dari Occupancy & Schedule (alokasi dinamis orang & waktu huni).
  2. Menggeser Finance & Billing menjadi modul Opsional (toggleable), sehingga gedung non-komersial bisa mengelola hunian tanpa penagihan/uang.
  3. Mengadopsi Dynamic RBAC di modul User & Access Control (permission sets granular + kustom role dinamis).
  4. Menetapkan 5 Modul Core (User, Property, Room, Schedule, Dashboard) dan 5 Modul Opsional (Finance, Maintenance, Inventory, Guest, Notification).
- Mencatat ADR-008 di `Docs/03_logs/DECISIONS.md`.
- Memperbarui diagram alur dan tabel modul di `Docs/00_overview/ARCHITECTURE.md`.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Penyusunan detail pemetaan kebutuhan fitur granular Step 1 berbasis arsitektur dinamis baru.
- Lanjut ke Step 2: Perancangan alur proses bisnis (Flow Diagram).

---

## [2026-10-10 12:25] Penetapan roadmap perancangan rewrite: Kebutuhan -> Alur (Flow) -> ERD & DFD

**Status:** In Progress
**Dikerjakan:**
- Menyepakati metodologi perancangan bertahap rewrite total ADR-007:
  1. Step 1: Pengkajian kebutuhan & daftar fitur (F1–F12).
  2. Step 2: Perumusan alur bisnis proses & happy path (output: flow diagram / BPMN).
  3. Step 3: Penurunan ke struktur data & aliran data (ERD 13 tabel final & DFD L0/L1).
  4. Step 4: Kontrak API REST & event-driven bus.
  5. Step 5: Eksekusi scaffolding backend modular & revisi naskah BAB 3.
- Mengupdate target dan status tahapan di STATE global dan PA.
**File yang diubah:**
- `Docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Eksekusi Step 1: Pengkajian kebutuhan & batasan fitur dari awal.
- Eksekusi Step 2: Perancangan alur proses (happy path & status).

---

## [2026-10-07 10:30] Fase 1 selesai: DESAIN_REWRITE_FASE1 + kamus 13 tabel + revisi BAB 1/2

**Status:** Selesai
**Dikerjakan:**
- Dokumen baru `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`: kebutuhan F1–F12, ERD 13 tabel, kontrak API 14 endpoint, 4 event, daftar hapus desain lama.
- BAB 3 §3.6.6 kamus data rewrite; BAB 1 §1.4 batasan rewrite; BAB 2: sewa bulanan (§2.2.1) + arsip teori MCP/Keycloak (§2.2.5–2.2.6).
**File yang diubah:**
- `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md` (baru), `PA/docs/modules/bab3/README.md`, `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `Docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Fase 2: scaffold folder baru backend rewrite

---

## [2026-10-07 09:00] ADR-007: rewrite total kost bulanan 13 tabel + fondasi di BAB 3

**Status:** Selesai (desain; eksekusi Fase 1 berikutnya)
**Dikerjakan:**
- Kajian audit: jejak harian mayoritas kode mati; kompleksitas dari duplikasi (dua stack tagihan, dua cache, dua blokir, skema DP, legacy). Keputusan: rewrite folder baru, sewa bulanan + `min_rental_months` per gedung, 13 tabel, nol FK lintas modul.
- Catat ADR-007; BAB 3 §3.3.1 (pemetaan 9 modul) + §3.6.2 (ERD 13 tabel) baru; §3.6.3–3.6.5 lama ditandai Arsip; STATE global + PA dialihkan ke fase rewrite.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `PA/docs/modules/bab3/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Fase 1: dokumen kebutuhan per fitur + ERD final + kontrak API → revisi BAB 1–3

---

## [2026-10-04 13:00] Fix arah panah & padding tepi diagram Testing Pyramid

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Memperbaiki orientasi panah indikator kiri (menunjuk lurus ke atas) dan kanan (menunjuk lurus ke bawah) dengan koordinat polygon langsung (bukan marker rotasi SVG).
- Melebarkan canvas viewBox menjadi `1060x670` dan memberi margin 60px di sisi kiri & kanan sehingga seluruh teks rotasi tidak terpotong tepi canvas.
- Re-render PNG 2x resolusi (2120x1340) via `svgexport`.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.svg`
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-04 12:45] Perbaikan geometri visual Testing Pyramid (eliminasi text overflow)

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Memperbaiki kalkulasi geometri trapesium pada `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.svg`:
  - Melebarkan apex atas puncak piramida (Tier 1 E2E) menjadi 420px $\rightarrow$ 490px dasar atas, sehingga seluruh teks bullet, subjudul, dan badge tertampung sempurna dengan padding aman (tanpa overflow keluar garis).
  - Me-render ulang `testing_pyramid.png` (resolusi 2x 1880x1320) via `svgexport`.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.svg`
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-04 12:30] Pembuatan ulang Testing Pyramid sejati berbasis SVG & PNG 2x

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Membuat ulang diagram `14_testing_pyramid` dalam bentuk **Piramida Bertingkat Sejati (True Pyramid Shape)** menggunakan SVG vektor murni (`testing_pyramid.svg`) dan di-render ke PNG 2x (`testing_pyramid.png` resolusi 1760x1240) menggunakan skill `architecture-diagram-generator`:
  - 4 Tingkat Trapesium Warna Bergradasi: Puncak E2E Tests (`#fce4ec`), Tingkat 3 Tenant & Integration Tests (`#fff3e0`), Tingkat 2 Contract Tests (`#e8eaf6`), dan Dasar Piramida Unit Tests ≥80% (`#e8f5e9`).
  - Indikator sisi kiri (Biaya & Waktu Eksekusi) dan sisi kanan (Volume & Kecepatan Eksekusi).
  - Badge kakas pengujian (Playwright/Flutter Driver, Pest, Schema Assertions, Mocktail).
- Memperbarui referensi di `PA/docs/modules/bab2/README.md` (§2.2.10) dan katalog `PA/docs/diagrams/README.md`.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.svg` (baru)
- `PA/docs/diagrams/14_testing_pyramid/testing_pyramid.png` (render ulang 2x)
- `PA/docs/diagrams/README.md`
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-04 12:15] Pembuatan skill global architecture-diagram-generator

**Status:** Selesai
**Dikerjakan:**
- Membuat skill global baru di `/Users/allvvnt/.agents/skills/architecture-diagram-generator/SKILL.md` untuk standardisasi pembuatan diagram arsitektur enterprise modern (C4 container/component, sequence, protocol pipeline, dan domain ERD).
- Mendokumentasikan aturan visual 2-line hierarchy (`Title 14px bold`, `Subtitle 12px muted`), palet warna token per tier/role, template SVG murni, aturan Mermaid `.mmd`, dan workflow ekspor PNG 2x resolusi via `svgexport` & `mermaid-cli`.
**File yang diubah:**
- `/Users/allvvnt/.agents/skills/architecture-diagram-generator/SKILL.md` (baru)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-04 12:00] Penyelarasan Diagram MCP (16) dengan Format & Desain SVG Final

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Membuat ulang diagram `16_cara_kerja_mcp_protokol` dalam format **SVG (`cara_kerja_mcp_protokol.svg`)** dan me-render ke **PNG 2x resolusi (`cara_kerja_mcp_protokol.png`)** mengikuti standar desain arsitektur yang komprehensif:
  - **Pengguna** (Owner/Pengelola) `bertanya` ke **AI Host**.
  - **AI Host** (LLM `pilih tool` <-> MCP Client `hasil tool`).
  - Koneksi protokol: `JSON-RPC 2.0 + Bearer token` ke **MCP Server** (Modul Mcp di Laravel 11 API).
  - Pipeline internal MCP Server: `Auth dan tenant` -> `Tool registry` -> `Tool handler`.
  - Eksekusi ke **Module Gateway** (Query gateway untuk baca, Event bus untuk tulis) -> **Modul Bisnis** (`Finance`, `Maintenance`, `Guest`, `Modul lain`).
- Memperbarui file `.mmd` yang bersesuaian, katalog `diagrams/README.md`, dan naskah `PA/docs/modules/bab2/README.md` (§2.2.5).
**File yang diubah:**
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/cara_kerja_mcp_protokol.svg`
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/cara_kerja_mcp_protokol.png`
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/cara_kerja_mcp_protokol.mmd`
- `PA/docs/diagrams/README.md`
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-04 11:35] Diagram dasar protokol MCP (16) + teori fondasi §2.2.5

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Folder `16_cara_kerja_mcp_protokol/`: diagram Host–Client–Server, 3 primitif (Tools/Resources/Prompts), siklus JSON-RPC; render `.png` OK
- BAB 2 §2.2.5: sub-bab baru "Cara Kerja Dasar Protokol MCP" sebagai Gambar 2.4; renumber sequence 2.5, SSO 2.6, clean 2.7, testing 2.8 (+ sub-bab MCP 3→4); sinkron katalog + BAB 3 ref 2.7→2.8 + STATE
**File yang diubah:**
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 22:15] Lengkapi referensi Gambar di BAB 2–3 untuk semua 15 folder diagram

**Status:** Selesai (terverifikasi: BAB 2 Gambar 2.1–2.7, BAB 3 Gambar 3.1–3.10 + 3.11a–g, tanpa lompat/duplikat)
**Dikerjakan:**
- BAB 2: tambah Gambar 2.3 (feature toggle), 2.4 (sequence MCP), 2.5 (sequence SSO), 2.6 (clean arch FE), 2.7 (testing pyramid)
- BAB 3: tambah Gambar 3.3–3.5 (BPMN), 3.4/3.7 (sequence), 3.8 (use case), 3.9–3.10 (DFD); renumber ERD 3.6a–g → 3.11a–g; tukar Tabel 3.2/3.3 agar urut; §3.9 rujuk Gambar 2.7
- Katalog `diagrams/README.md`: tiap baris kini memuat nomor Gambar
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 22:05] Update 5 ERD per-module pasca-migration (buildings, building_id, SSO, MCP log)

**Status:** Selesai (sintaks tervalidasi mermaid-cli + spot-check visual browser)
**Dikerjakan:**
- erd_1: +`assigned_building_id`, +`keycloak_id` UK, +`auth_provider` di USERS
- erd_2: +entitas BUILDINGS (+relasi owns/scopes) +`building_id` (ROOMS, ROOM_SCHEDULES, GUESTS, GUEST_BILLS)
- erd_3: +`building_id` (INVOICES, FINES, REFUND_REQUESTS, EXPENSES, FIXED_EXPENSE_ENTRIES)
- erd_4: +`building_id` (MAINTENANCE_REQUESTS, MAINTENANCE_SCHEDULES)
- erd_5: +`building_id` (INVENTORIES, NOTIFICATION_LOGS) +entitas MCP_TOOL_LOGS (+relasi queries/scopes)
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 21:55] Update erd_full_database ke 41 tabel (buildings + mcp_tool_logs + building_id)

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Tambah entitas `BUILDINGS` + `MCP_TOOL_LOGS`, kolom `building_id` (7 tabel utama), `users.keycloak_id/auth_provider/assigned_building_id`, dan 10 relasi scopes-softref ke `erd_full_database.mmd`; render ulang `.png`
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/erd_full_database.mmd`/`.png`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 21:50] Sinkronisasi docs pasca-migration: hapus 3 klaim basi + katalog permodule

**Status:** Selesai
**Dikerjakan:**
- Perbaiki 3 pernyataan basi di BAB 3 §3.6 (klaim "belum ada di kode" untuk buildings/keycloak/mcp → SUDAH terimplementasi 2026-10-03)
- Daftarkan 5 ERD per-cluster HTML sebagai Gambar 3.6c–3.6g resmi di katalog + BAB 3 §3.6; betulkan hitungan 39 → 41 tabel
- Tambah bullet eksekusi migration ke STATE global & PA
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 21:40] Eksekusi migration WAJIB: buildings, building_id, SSO, MCP log, soft-ref 2 FK

**Status:** Selesai (523 passed, 2 failed pre-existing dashboard — sama seperti baseline 2026-09-22)
**Dikerjakan:**
- 5 migration aditif baru (tanpa ubah migration lama): `buildings`, `building_id` (13 tabel domain) + `users.assigned_building_id`, `users.keycloak_id`+`auth_provider`, `mcp_tool_logs`, drop FK `refund_requests.schedule_id` + `maintenance_requests.room_id` → soft-ref (pola defensif existing)
- Model `User` fillable +3 kolom; `pint --test` PASS 6 file
- Verifikasi: `migrate:fresh` SQLite bersih (41 tabel), `php artisan test` 523 passed / 2 failed (dashboard admin/resident 404 — pre-existing, di luar scope)
- Catatan: MySQL lokal (`wisma_amal`) tidak dapat dijangkau (docker daemon mati) — verifikasi via SQLite; `.env` tidak diubah
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/database/migrations/2026_10_03_00000*.php` (5 file baru), `Modules/Auth/Models/User.php` (fillable)
**Dokumen yang diupdate:**
- `Docs/02_reference/DATABASE_SCHEMA.md` (§5 delta + §6 history), `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- TenantResolverMiddleware + Global Scope + Keycloak JWKS verify + MCP tools (fase implementasi BAB 4)
- 2 test dashboard 404 menunggu fix endpoint Dashboard
**Catatan/masalah:**
- Kategori OPSIONAL (drop `lease_id`/`resident_id` legacy, fix tipe `rooms.price`) sengaja tidak dikerjakan — di luar scope persetujuan

---

## [2026-10-03 21:20] Teori pemisahan DB 3 level + matriks 12 modul ke 5 cluster ERD

**Status:** Selesai
**Dikerjakan:**
- BAB 2 §2.2.8: tambah teori 3 tingkatan pemisahan DB Modulith (Physical per-Module, Schema-per-Module, Logical Schema Ownership — pilihan sistem) sebagai jawaban antisipasi pertanyaan penguji
- BAB 3 §3.6: tambah Tabel 3.3 matriks ketertelusuran 12 modul → 5 domain cluster ERD + renumber kamus data ke §3.6.4 (perbaikan duplikat §3.6.2)
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 21:00] Fix judul tabel tak terbaca di 5 ERD per-module HTML

**Status:** Selesai (terverifikasi visual via screenshot browser)
**Dikerjakan:**
- Akar masalah: boilerplate CSS memaksa teks nama entitas ke `var(--text-primary)` (putih di dark mode) sementara header box mermaid berwarna krem → judul tak terbaca
- Fix di 5 file `permodule/erd_*.html`: warna teks judul dikunci `#2a2723` (gelap) + bold via `color` dan `fill`
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 20:30] Audit skema aktual + ERD keseluruhan 39 tabel

**Status:** Selesai
**Dikerjakan:**
- Audit seluruh migration + model via subagen: 39 tabel final, FK fisik lintas-modul, temuan `building_id` 0 hasil, kolom hantu `is_highlighted`, tipe `rooms.price` string, legacy `lease_id`/`resident_id`, drift SQLite vs MySQL
- Buat `erd_full_database.mmd` + render `.png` (Gambar 3.6a resmi) di folder 12; ERD konseptual lama jadi Gambar 3.6b (target)
- Tulis ulang `Docs/02_reference/DATABASE_SCHEMA.md` (inventaris aktual + delta target §5); referensi ERD dimasukkan ke BAB 3 §3.6
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/erd_full_database.mmd`/`.png`, `PA/docs/diagrams/README.md`, `Docs/02_reference/DATABASE_SCHEMA.md`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 dengan embed ERD 3.6a
**Catatan/masalah:**
- Multi-tenant/Keycloak/MCP murni target desain, belum ada di kode — jujur dicatat di delta §5 untuk BAB 4

---

## [2026-10-03 13:20] Pindah component SVG ke folder 02 + adopsi 2 SVG final

**Status:** Selesai
**Dikerjakan:**
- Memindahkan `component_diagram_modular_monolith_3_tier.svg` dari `01_arsitektur_sistem_terpadu/` ke `02_hierarki_3_tier_modulith/`; referensi Gambar 2.2/3.2 + katalog + STATE diperbarui
**File yang diubah:**
- `PA/docs/diagrams/02_hierarki_3_tier_modulith/component_diagram_modular_monolith_3_tier.svg` (pindahan)
**Dokumen yang diupdate:**
- `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 (BAB 1–3) dengan embed 2 SVG final

---

## [2026-10-03 13:00] Adopsi 2 SVG final arsitektur sebagai diagram resmi docx

**Status:** Selesai
**Dikerjakan:**
- Menetapkan `c4_level2_container_wisma_amal.svg` + `component_diagram_modular_monolith_3_tier.svg` di `PA/docs/diagrams/01_arsitektur_sistem_terpadu/` sebagai diagram resmi (Gambar 2.1/2.2 & 3.1/3.2); `.mmd`/`.png` lama di folder itu disupersede
- Referensi Gambar resmi dimasukkan ke `PA/docs/modules/bab2/README.md` (§2.2.2) dan `PA/docs/modules/bab3/README.md` (§3.3); katalog `PA/docs/diagrams/README.md` baris 01 ditandai ✅ FINAL
**File yang diubah:**
- `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 (BAB 1–3) dengan embed 2 SVG final
**Catatan/masalah:**
- File SVG buatan user, tidak di-render ulang via mermaid-cli

---

## [2026-10-03 12:15] Integrasi Single Sign-On (SSO) Keycloak OIDC ke Seluruh Naskah & Diagram

**Status:** Selesai (ADR-006 + 15 Diagram MMD/PNG + Pembaruan BAB 1, 2, 3)
**Dikerjakan:**
- Mencatat ADR-006 di `Docs/03_logs/DECISIONS.md`: Single Sign-On (SSO) IAM Berbasis Keycloak OIDC.
- Memperbarui BAB 1, BAB 2 (sub-bab 2.2.6), dan BAB 3 (tabel users `keycloak_id` & flow OIDC) pada `PA/docs/modules/`.
- Membuat dan me-render diagram `15_sequence_sso_keycloak` (MMD + PNG) di `PA/docs/diagrams/`.
- Sinkronisasi katalog diagram, `ARCHITECTURE.md`, dan `STATE.md` (Global & PA).
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
- `PA/docs/diagrams/15_sequence_sso_keycloak/**`, `PA/docs/diagrams/README.md`
- `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 11:45] Pembuatan & Rendering 14 Diagram Resmi PA ke Subfolder Terpisah

**Status:** Selesai (14 Diagram Mermaid .mmd + 14 Gambar .png)
**Dikerjakan:**
- Membuat 14 subfolder terstruktur di `PA/docs/diagrams/` untuk seluruh kebutuhan visual BAB 2 & 3:
  1. `01_arsitektur_sistem_terpadu/`
  2. `02_hierarki_3_tier_modulith/`
  3. `03_clean_architecture_frontend/`
  4. `04_bpmn_reservasi_pembayaran/`
  5. `05_bpmn_komplain_pemeliharaan/`
  6. `06_bpmn_konsultasi_ai_mcp/`
  7. `07_use_case_global/`
  8. `08_dfd_level_0_context/`
  9. `09_dfd_level_1_dekomposisi/`
  10. `10_sequence_reservasi_event_driven/`
  11. `11_sequence_mcp_ai_tool_call/`
  12. `12_erd_multi_tenant_global/`
  13. `13_feature_toggle_architecture/`
  14. `14_testing_pyramid/`
- Me-render seluruh 14 file `.mmd` menjadi gambar resolusi tinggi `.png` via `@mermaid-js/mermaid-cli`.
- Membersihkan artefak diagram lama di root `PA/docs/diagrams/` dan memperbarui `PA/docs/diagrams/README.md` sebagai katalog indeks resmi.
**File yang diubah:**
- `PA/docs/diagrams/**` (14 subfolder: `.mmd` dan `.png`)
- `PA/docs/diagrams/README.md`
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 11:15] Rekonstruksi & Transformasi Penuh Naskah BAB 1, 2, 3 ke Dokumen Resmi

**Status:** Selesai (Naskah BAB 1-3 Lengkap ~9.500 kata)
**Dikerjakan:**
- Transformasi seluruh dokumen naskah di `PA/docs/modules/` dari ringkasan poin menjadi naskah Laporan Proyek Akhir (LPA) akademis yang utuh dan siap translasi ke docx:
  - `PA/docs/modules/bab1/README.md`: Naskah penuh (~2.800 kata), profil empiris, telaah 4 proposal previous work, justifikasi 5 pilar, rumusan masalah (6 butir), tujuan, batasan teknis, manfaat, sistematika.
  - `PA/docs/modules/bab2/README.md`: Naskah penuh (~3.500 kata), 10 sub-bab teori penunjang mendalam (Modulith 3-tier, Multi-Tenancy, MCP AI, REST Envelope, Clean FE, MySQL ACID/MVCC, Midtrans, Testing, Living Docs), telaah 14 penelitian terkait (Tabel 2.3), dan gap statement.
  - `PA/docs/modules/bab3/README.md`: Software Design Document lengkap (~3.200 kata), Scrum 4 sprint (114 SP) + User Story Gherkin, diagram Clean-Modulith + MCP, BPMN (4 alur), Use Case Specifications lengkap, DFD L0/L1, ERD & Kamus Basis Data 5 tabel, Mockup UI/UX, JSON Schema MCP, kontrak REST API, dan matriks 20 skenario pengujian.
  - Sinkronisasi `STATE.md` (Global & PA) ke 75% progress.
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh modul naskah PA dan ringkasan state.

---

## [2026-10-03 10:30] Ekspansi Mendalam Teori Penunjang BAB 2 (2.2.1 - 2.2.10)

**Status:** Selesai
**Dikerjakan:**
- Memperluas secara komprehensif Bab 2.2 Teori Penunjang naskah PA (dari ~240 baris menjadi 563 baris) mencakup 10 sub-bab teoritis lengkap: SIM Hunian, Evolusi Monolith vs Microservices vs Modulith (3-tier hierarchy, event bus write, gateway read), Standar I/O API Envelope, Multi-Tenancy Row-Level Scoping, MCP AI & Tool Catalog Grounding, Clean Architecture Flutter 3-layer, Basis Data MySQL ACID/MVCC, Midtrans Production Hardening, Testing Pyramid, dan Living Documentation.
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 10:00] Penyelarasan 5 Pilar Konseptual PA di Seluruh Dokumentasi

**Status:** Selesai
**Dikerjakan:**
- Merumuskan dan mencatat ADR-005 di `Docs/03_logs/DECISIONS.md`: 5 pilar konseptual (Standar Input-Output API, Multi-Tenant Multi-Gedung, MCP with Built-in AI, Modular Monolith Event-Driven & Module Gateway, Clean Architecture FE).
- Memperbarui `PA/docs/modules/bab1/README.md`: Analisis gap previous work (7 gap), posisi PA (5 pilar), rumusan masalah (6 butir), tujuan, batasan, dan manfaat.
- Memperbarui `PA/docs/modules/bab2/README.md`: Teori penunjang komprehensif (3-Tier Modulith, Multi-Tenancy Row-Level Scoping, MCP & LLM Tool-Use, Standarisasi Kontrak REST, Clean Architecture FE, MySQL Indexing, Midtrans Hardening) dan gap statement.
- Memperbarui `PA/docs/modules/bab3/README.md`: Desain sistem Clean-Modulith + MCP, alur komunikasi AI via MCP tool-use, format baku JSON envelope, ERD multi-gedung (`buildings`), dan tabel skenario pengujian komprehensif (tenant isolation, contract testing, AI grounding).
- Memperbarui `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, dan `Docs/02_reference/API_STYLE.md`.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `Docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/02_reference/API_STYLE.md`
- `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh dokumen hub federasi dan modul naskah BAB 1-3.
**Belum selesai / next steps:**
- Render diagram visual (ERD multi-tenant, BPMN, Sequence MCP tool-use) untuk lampiran/insert docx.
**Catatan/masalah:**
- Judul skripsi dipertahankan tetap sesuai registrasi resmi.

---

## [2025-09-20 05:00] Koreksi diagram: + Module Gateway Layer (semua modul via gateway, bukan langsung)

**Status:** Selesai
**Dikerjakan:**
- Arsitektur disesuaikan gambar aktual (Infrastructure: Auth / Core: Room-Schedule-Setting / Event Bus / Business: Finance-Maintenance-Guest-Inventory-Notification + MySQL/Midtrans/WhatsApp Fonnte) + **Module Gateway Layer baru**
- Buat ulang 3 diagram: `01_arsitektur_modulith_gateway.mmd`, `02_modular_boundaries_gateway.mmd`, `03_sequence_via_gateway.mmd`; hapus 3 file lama yang salah; `04_erd*` + `05_feature_toggle*` tetap
- Update `PA/docs/modules/bab3/README.md` §3.3.1 + catatan Module Gateway = BARU
- Update `PA/docs/diagrams/README.md` (daftar versi gateway)
**File yang diubah:**
- `PA/docs/diagrams/*gateway*.mmd`, `PA/docs/diagrams/README.md`, `PA/docs/modules/bab3/README.md`
**Belum selesai / next steps:**
- Render 5 PNG via mermaid-cli / mermaid.live, review, insert ke docx BAB 3
**Catatan/masalah:**
- .mmd belum di-render ke PNG (mmdc tidak tersedia di env ini) — render manual

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

## [2025-09-20 03:30] BAB 1 Draft Penuh selesai — Previous Work Analysis + Gap + Proposal Baru

**Status:** Selesai
**Dikerjakan:**
- Tulis `PA/docs/modules/bab1/README.md` draft penuh (1.1 Latar Belakang 3 bagian, 1.2 Rumusan Masalah 5 butir, 1.3 Tujuan 5 butir, 1.4 Batasan, 1.5 Manfaat, 1.6 Sistematika)
- Sitasi IEEE numeric dari DAFTAR_PUSTAKA: [1]-[19] terpakai
- Struktur: Konteks Umum → Analisis Previous Work (tabel 4 proposal + 5 gap) → Posisi PA Kita (5 perbaikan utama)
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`
**Dokumen yang diupdate:**
- `PA/docs/modules/bab1/README.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Draft BAB 2 penuh (teori 2.2 + narasi tabel 2.3 + gap statement 2.4)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- BAB 1 ~2,500 kata, siap review dosen. Sitasi konsisten numeric [1]-[19].

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
