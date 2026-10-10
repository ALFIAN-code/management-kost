# Progress Log — Federated

> Log kronologis tiap sesi AI. Entry baru di **paling atas**, append-only. Ini "ingatan jangka pendek" AI.

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
