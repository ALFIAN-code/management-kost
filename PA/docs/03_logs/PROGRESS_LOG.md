# Progress Log — PA (Bimbingan & Revisi)

> Append-only. Entry baru di paling atas. Sinkron ringkas ke `Docs/03_logs/PROGRESS_LOG.md`.

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
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/System design/DFD/README.md`
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
- `PA/docs/System design/DFD/dfd_level_0_context.html`, `PA/docs/System design/DFD/dfd_level_1_dekomposisi.html`, `PA/docs/System design/ERD/erd_sistem_dinamis.html`, `PA/docs/System design/DFD/README.md`, `PA/docs/System design/ERD/README.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/System design/DFD/README.md`, `PA/docs/System design/ERD/README.md`
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
- `PA/docs/System design/draft/README.md`, `PA/docs/System design/ERD/**`, `PA/docs/System design/DFD/**`, `PA/docs/System design/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `PA/docs/System design/README.md`
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
- `PA/docs/README.md`, `PA/docs/00_overview/ARCHITECTURE.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `Docs/02_reference/DATABASE_SCHEMA.md`, `PA/docs/System design/README.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
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
- `AGENTS.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 3: Perumusan Model Data (ERD Dinamis) dan Aliran Data (DFD Level 0 Konteks & DFD Level 1 Dekomposisi) di `PA/docs/System design/`.

---

## [2026-10-10 13:35] Pembuatan Folder Terstruktur PA/docs/diagrams/BPMN/ untuk Seluruh 8 Alur (100% Coverage)

**Status:** Selesai (Terstruktur Lengkap 100%)
**Dikerjakan:**
- Membuat folder master `PA/docs/diagrams/BPMN/` dengan 8 subfolder alur per fitur:
  1. `01_alokasi_penempatan_hunian/` (`alur_alokasi_penempatan.mmd` + `README.md`)
  2. `02_penagihan_pembayaran/` (`alur_penagihan_pembayaran.mmd` + `README.md`)
  3. `03_laporan_kerusakan_fasilitas/` (`alur_laporan_kerusakan.mmd` + `README.md`)
  4. `04_pemeliharaan_rutin_berkala/` (`alur_pemeliharaan_rutin.mmd` + `README.md`)
  5. `05_pengeluaran_operasional/` (`alur_pengeluaran_operasional.mmd` + `README.md`)
  6. `06_pengawasan_buku_tamu/` (`alur_pengawasan_buku_tamu.mmd` + `README.md`)
  7. `07_pengaturan_hak_akses_dinamis/` (`alur_hak_akses_dinamis.mmd` + `README.md`)
  8. `08_pendataan_inventaris_aset/` (`alur_inventaris_aset.mmd` + `README.md`)
- Membuat katalog `PA/docs/diagrams/BPMN/README.md` dan sinkronisasi ke `PA/docs/diagrams/README.md`.
**File yang diubah:**
- `PA/docs/diagrams/BPMN/**` (17 file), `PA/docs/diagrams/README.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Lanjut ke Step 3: Pemodelan data (ERD) dan aliran data (DFD L0/L1).


---

## [2026-10-10 13:20] Step 2: Perancangan Alur Proses Bisnis & Payment Gatekeeper Dinamis

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Merumuskan alur proses bisnis terperinci (Flow 1–7) dengan pemisahan Core dan Optional.
- Menetapkan peranan modul Finance sebagai *Payment Barrier Gate* dan variasi kebijakan pemilihan kamar (`ADMIN_ASSIGN_ONLY`, `SELF_SERVICE_APPROVAL`, `SELF_SERVICE_INSTANT`).
- Memperbarui diagram di `PA/docs/diagrams/04_bpmn_reservasi_pembayaran/bpmn_reservasi_pembayaran.mmd` dan dokumen `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md` (§7).
**File yang diubah:**
- `PA/docs/diagrams/04_bpmn_reservasi_pembayaran/bpmn_reservasi_pembayaran.mmd`, `PA/docs/modules/bab3/DESAIN_REWRITE_FASE1.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Lanjut ke Step 3: Pemodelan data (ERD) dan aliran data (DFD L0/L1).

---

## [2026-10-10 13:10] ADR-009: Penempatan MCP sebagai External AI Adapter Layer

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Menetapkan Model Context Protocol (MCP) sebagai **External AI Adapter Layer** yang berada di atas modul-modul bisnis.
- MCP tidak masuk ke dalam dokumen inti data/ERD operasional dan bersifat *read-only consumer* via Module Gateway.
- Mencatat ADR-009 di `Docs/03_logs/DECISIONS.md`.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Melanjutkan ke Step 2: Perancangan alur proses bisnis (Flow Diagram).

---

## [2026-10-10 13:05] ADR-008: Pemisahan Room vs Schedule & Decoupling Finance ke Modul Opsional

**Status:** Selesai (Disepakati & Dicatat)
**Dikerjakan:**
- Merumuskan keputusan arsitektur dinamis ADR-008 untuk mendukung skenario multi-properti (kost komersial, asrama, mes karyawan, pondok pesantren):
  1. Memisahkan Room Management (aset fisik & kapasitas) dari Occupancy & Schedule (alokasi dinamis orang & waktu huni).
  2. Menggeser Finance & Billing menjadi modul Opsional (toggleable), sehingga gedung non-komersial bisa mengelola hunian tanpa penagihan/uang.
  3. Mengadopsi Dynamic RBAC di modul User & Access Control (permission sets granular + kustom role dinamis).
  4. Menetapkan 5 Modul Core (User, Property, Room, Schedule, Dashboard) dan 5 Modul Opsional (Finance, Maintenance, Inventory, Guest, Notification).
- Mencatat ADR-008 di `Docs/03_logs/DECISIONS.md`.
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/03_logs/PROGRESS_LOG.md`, `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Pemetaan detail kebutuhan fungsional Step 1 berbasis arsitektur dinamis baru.

---

## [2026-10-10 12:25] Penetapan roadmap perancangan rewrite: Kebutuhan -> Alur (Flow) -> ERD & DFD

**Status:** In Progress
**Dikerjakan:**
- Menyepakati 5 langkah sistematis perancangan sistem rewrite total (ADR-007):
  1. Step 1: Kaji kebutuhan & batasan fitur (F1–F12).
  2. Step 2: Rancang alur proses bisnis & happy path (Flowchart/BPMN).
  3. Step 3: Turunkan ke struktur data (ERD 13 tabel) & aliran data (DFD L0/L1).
  4. Step 4: Spesifikasi kontrak API REST & integrasi event-driven.
  5. Step 5: Scaffolding kode backend & pembaharuan naskah SDD BAB 3.
- Mengupdate STATE skripsi dan global log.
**File yang diubah:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Mulai Step 1: Diskusi dan verifikasi kebutuhan fitur dari awal bersama user.

---

## [2026-10-07 09:00] ADR-007 rewrite: fondasi desain 13 tabel di BAB 3

**Status:** Selesai (desain)
**Dikerjakan:**
- BAB 3 §3.3.1 (9 modul rewrite) + §3.6.2 (ERD bulanan 13 tabel) baru; bagian lama ditandai Arsip.
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`
**Belum selesai / next steps:**
- Fase 1: dokumen kebutuhan + revisi total BAB 1–3

---

## [2026-10-04 13:00] Fix arah panah & padding tepi diagram Testing Pyramid

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Perbaiki orientasi panah kiri/kanan (lurus ke atas/bawah), beri margin 60px di kedua sisi agar teks tidak terpotong, dan re-render PNG 2x via `svgexport`.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/**`

---

## [2026-10-04 12:45] Perbaikan geometri visual Testing Pyramid (eliminasi text overflow)

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Memperbaiki proporsi trapesium puncak pada `testing_pyramid.svg` dan render ulang `testing_pyramid.png` 2x: teks subjudul, bullet point, dan badge kini berada rapi di dalam batas kontainer piramida dengan margin lega.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/**`

---

## [2026-10-04 12:30] Pembuatan ulang Testing Pyramid sejati berbasis SVG & PNG 2x

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Membuat ulang diagram `14_testing_pyramid` menjadi bentuk piramida bertingkat sejati (SVG + PNG 2x) dengan 4 tier (Unit Base ≥80%, Contract, Tenant Integration, E2E) dan indikator biaya vs kecepatan; update naskah BAB 2 dan katalog diagram.
**File yang diubah:**
- `PA/docs/diagrams/14_testing_pyramid/**`, `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`

---

## [2026-10-04 12:15] Pembuatan skill global architecture-diagram-generator

**Status:** Selesai
**Dikerjakan:**
- Membuat skill baru `architecture-diagram-generator` di `~/.agents/skills/` berisi panduan pembuatan diagram arsitektur modern (C4 container, 3-tier component, MCP protocol pipeline, per-module ERD, CSS dark/light contrast fix, dan resep render 2x PNG).
**File yang diubah:**
- `/Users/allvvnt/.agents/skills/architecture-diagram-generator/SKILL.md` (baru)

---

## [2026-10-04 12:00] Penyelarasan Diagram MCP (16) dengan Format & Desain SVG Final

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Membuat ulang diagram `16_cara_kerja_mcp_protokol` dalam format **SVG (`cara_kerja_mcp_protokol.svg`)** dan me-render ke **PNG (`cara_kerja_mcp_protokol.png`)** mengikuti standar desain arsitektur final (Pengguna -> AI Host [LLM & MCP Client] -> JSON-RPC -> MCP Server [Auth/Tenant, Registry, Handler] -> Module Gateway -> Modul Bisnis).
- Update naskah `PA/docs/modules/bab2/README.md` dan katalog diagram.
**File yang diubah:**
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/**`, `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`

---

## [2026-10-04 11:35] Diagram dasar protokol MCP (16) + teori fondasi §2.2.5

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- Diagram `16_cara_kerja_mcp_protokol` (Gambar 2.4) + sub-bab fondasi MCP di §2.2.5; renumber Gambar 2.5–2.8
**File yang diubah:**
- `PA/docs/diagrams/16_cara_kerja_mcp_protokol/`, `PA/docs/modules/bab2/README.md`, `PA/docs/diagrams/README.md`

---

## [2026-10-03 22:15] Lengkapi referensi Gambar di BAB 2–3 untuk semua 15 folder diagram

**Status:** Selesai (BAB 2: 2.1–2.7, BAB 3: 3.1–3.10 + 3.11a–3.11g)
**Dikerjakan:**
- Lengkapi Gambar yang belum dirujuk + renumber ERD ke 3.11a–g + perbaiki urutan Tabel 3.2/3.3
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `PA/docs/00_overview/STATE.md`

---

## [2026-10-03 22:05] Update 5 ERD per-module pasca-migration

**Status:** Selesai (sintaks tervalidasi + spot-check visual)
**Dikerjakan:**
- 5 file `permodule/erd_*.html`: +BUILDINGS, +`building_id` (13 tabel domain), +kolom SSO di USERS, +MCP_TOOL_LOGS
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)

---

## [2026-10-03 21:55] Update erd_full_database ke 41 tabel pasca-migration

**Status:** Selesai (terverifikasi visual)
**Dikerjakan:**
- `erd_full_database.mmd`/`.png`: +`BUILDINGS`, +`MCP_TOOL_LOGS`, +`building_id` (7 tabel), +kolom SSO di `USERS`, +10 relasi scopes-softref; render ulang

---

## [2026-10-03 21:50] Sinkronisasi docs pasca-migration (hapus klaim basi + katalog permodule)

**Status:** Selesai
**Dikerjakan:**
- Hapus 3 klaim "belum ada di kode" di BAB 3 §3.6; daftarkan 5 ERD per-cluster sebagai Gambar 3.6c–3.6g; betulkan 39 → 41 tabel
**File yang diubah:**
- `PA/docs/modules/bab3/README.md`, `PA/docs/diagrams/README.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`

---

## [2026-10-03 21:40] Eksekusi migration WAJIB skema DB (BAB 4 — implementasi target desain)

**Status:** Selesai (523 passed, 2 failed pre-existing)
**Dikerjakan:**
- 5 migration aditif: `buildings`, `building_id` (13 tabel) + `assigned_building_id`, `keycloak_id`+`auth_provider`, `mcp_tool_logs`, soft-ref 2 FK lintas-modul; `User` fillable +3; test suite hijau (minus 2 pre-existing)
**File yang diubah:**
- `Project/backend-wismaamalgorontalo/database/migrations/2026_10_03_00000*.php`, `Modules/Auth/Models/User.php`

---

## [2026-10-03 21:20] Teori pemisahan DB 3 level + matriks 12 modul ke 5 cluster ERD

**Status:** Selesai
**Dikerjakan:**
- BAB 2 §2.2.8: teori 3 tingkatan pemisahan DB (Physical, Schema-per-Module, Logical Schema Ownership)
- BAB 3 §3.6: Tabel 3.3 matriks 12 modul → 5 domain cluster + kamus data jadi §3.6.4
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`

---

## [2026-10-03 21:00] Fix judul tabel tak terbaca di 5 ERD per-module HTML

**Status:** Selesai (terverifikasi visual via screenshot browser)
**Dikerjakan:**
- Akar masalah: CSS boilerplate memaksa teks judul entitas putih di dark mode, header box krem → tak terbaca
- Fix: kunci warna judul `#2a2723` + bold di 5 file `permodule/erd_*.html`
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/permodule/erd_*.html` (5 file)

---

## [2026-10-03 20:30] Audit skema aktual + ERD keseluruhan 39 tabel (Gambar 3.6a)

**Status:** Selesai
**Dikerjakan:**
- Audit migration aktual: 39 tabel final per modul + FK fisik + temuan (`building_id` belum ada di kode, kolom hantu, legacy Rental/Resident)
- ERD keseluruhan aktual `erd_full_database` (Gambar 3.6a FINAL) + ERD target multi-tenant (Gambar 3.6b konseptual); BAB 3 §3.6 direferensikan ke keduanya + tabel delta aktual-vs-target
**File yang diubah:**
- `PA/docs/diagrams/12_erd_multi_tenant_global/erd_full_database.mmd`/`.png`, `PA/docs/modules/bab3/README.md`
**Dokumen yang diupdate:**
- `Docs/02_reference/DATABASE_SCHEMA.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`

---

## [2026-10-03 13:20] Pindah component SVG ke folder 02 + adopsi 2 SVG final

**Status:** Selesai
**Dikerjakan:**
- Memindahkan `component_diagram_modular_monolith_3_tier.svg` dari `01_arsitektur_sistem_terpadu/` ke `02_hierarki_3_tier_modulith/`; referensi Gambar 2.2/3.2 + katalog + STATE diperbarui
**File yang diubah:**
- `PA/docs/diagrams/02_hierarki_3_tier_modulith/component_diagram_modular_monolith_3_tier.svg` (pindahan)
**Dokumen yang diupdate:**
- `PA/docs/diagrams/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`
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
- `PA/docs/00_overview/STATE.md`, `Docs/00_overview/STATE.md`, `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Kompilasi docx v0.1 (BAB 1–3) dengan embed 2 SVG final

---

## [2026-10-03 12:15] Integrasi Single Sign-On (SSO) Keycloak OIDC ke Seluruh Naskah & Diagram

**Status:** Selesai (ADR-006 + 15 Diagram MMD/PNG + Pembaruan BAB 1, 2, 3)
**Dikerjakan:**
- **Pencatatan ADR-006:** Merekam keputusan arsitektur *Single Sign-On (SSO) IAM Berbasis Keycloak OpenID Connect (OIDC)* di `Docs/03_logs/DECISIONS.md`.
- **Pembaruan BAB 1:** Menambahkan analisis gap otentikasi lama, pilar Federated Identity Keycloak SSO, butir rumusan masalah ke-6, tujuan ke-6, dan batasan teknis OIDC.
- **Pembaruan BAB 2:** Menambahkan sub-bab teori `2.2.6 Single Sign-On (SSO), OpenID Connect (OIDC), dan Arsitektur Keycloak IAM` (protokol OIDC/OAuth 2.0, realm, token exchange, stateless verification via JWKS `/certs`, JIT User Provisioning, dan identity brokering).
- **Pembaruan BAB 3:** Memperbarui arsitektur sistem Clean-Modulith + SSO, kamus basis data (tabel `users` dengan `keycloak_id` dan `auth_provider`), spesifikasi API, dan skenario pengujian.
- **Diagram Sequence SSO:** Membuat file `PA/docs/diagrams/15_sequence_sso_keycloak/sequence_sso_keycloak.mmd` dan me-render hasil `sequence_sso_keycloak.png` via `@mermaid-js/mermaid-cli`.
- **Pembaruan Katalog & State:** Memperbarui `PA/docs/diagrams/README.md`, `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, dan `PA/docs/00_overview/STATE.md` (progress PA naik ke 80%).
**File yang diubah:**
- `Docs/03_logs/DECISIONS.md`, `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`
- `PA/docs/diagrams/15_sequence_sso_keycloak/**`, `PA/docs/diagrams/README.md`
- `Docs/00_overview/ARCHITECTURE.md`, `Docs/00_overview/STATE.md`, `PA/docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`, `Docs/03_logs/PROGRESS_LOG.md`

---

## [2026-10-03 11:45] Pembuatan & Rendering 14 Diagram Resmi PA ke Subfolder Terpisah

**Status:** Selesai (14 Diagram Mermaid .mmd + 14 Gambar .png)
**Dikerjakan:**
- Membuat 14 subfolder terstruktur di `PA/docs/diagrams/`:
  1. `01_arsitektur_sistem_terpadu` (Clean-Modulith + MCP AI + Multi-Tenant)
  2. `02_hierarki_3_tier_modulith` (Infrastruktur, Core, Business Boundaries Deptrac)
  3. `03_clean_architecture_frontend` (Presentation BLoC, Domain, Data Layer Single Codebase)
  4. `04_bpmn_reservasi_pembayaran` (BPMN 2.0 Reservasi, Schedule Lock, Midtrans)
  5. `05_bpmn_komplain_pemeliharaan` (BPMN 2.0 Tiket Kerusakan & Penguncian Jadwal)
  6. `06_bpmn_konsultasi_ai_mcp` (BPMN 2.0 Konsultasi AI via Protokol MCP)
  7. `07_use_case_global` (Diagram Use Case 3 Aktor + MCP AI System)
  8. `08_dfd_level_0_context` (Diagram Konteks Sistem SIM Wisma)
  9. `09_dfd_level_1_dekomposisi` (DFD Level 1: 6 Proses & 9 Data Store)
  10. `10_sequence_reservasi_event_driven` (Sequence Pessimistic Lock, Event Bus, Midtrans)
  11. `11_sequence_mcp_ai_tool_call` (Sequence Tool-Use AI, Tenant Guardrail, Grounding)
  12. `12_erd_multi_tenant_global` (ERD Relasi Multi-Gedung berbasis `buildings`)
  13. `13_feature_toggle_architecture` (Mekanisme runtime Module Discovery & Gate)
  14. `14_testing_pyramid` (Piramida Pengujian: Unit, Contract, Tenant, Integration)
- Me-render seluruh 14 file `.mmd` menjadi gambar resolusi tinggi `.png` via `@mermaid-js/mermaid-cli`.
- Membersihkan artefak diagram lama di root `PA/docs/diagrams/` dan memperbarui `PA/docs/diagrams/README.md` sebagai katalog indeks resmi.
**File yang diubah:**
- `PA/docs/diagrams/**` (14 subfolder: `.mmd` dan `.png`)
- `PA/docs/diagrams/README.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh katalog diagram dan log federasi.

---

## [2026-10-03 11:15] Rekonstruksi & Transformasi Penuh Naskah BAB 1, 2, 3 ke Dokumen Resmi

**Status:** Selesai (Naskah BAB 1-3 Lengkap ~9.500 kata)
**Dikerjakan:**
- **BAB 1 PENDAHULUAN (`PA/docs/modules/bab1/README.md`):** Ditulis ulang penuh (~2.800 kata) mencakup urgensi digitalisasi & profil empiris Wisma Amal, dekonstruksi mendalam 4 proposal previous work (tabel komparatif & 7 gap utama), justifikasi ilmiah 5 pilar refaktorisasi, 6 butir rumusan masalah dengan narasi pengantar, 6 butir tujuan koheren, batasan masalah berjustifikasi teknis, manfaat 3 stakeholder, dan sistematika penulisan.
- **BAB 2 KAJIAN PUSTAKA (`PA/docs/modules/bab2/README.md`):** Ditulis ulang penuh (~3.500 kata) mencakup deskripsi permasalahan empiris/teknis, 10 sub-bab teori penunjang mendalam (SIM Properti, 3-Tier Modulith Event-Driven & Gateway, Standar I/O REST Envelope & DTO, Multi-Tenancy Row-Level Scoping, MCP AI Tools & Deterministic Grounding, Clean Architecture Flutter, Basis Data MySQL ACID/MVCC, Midtrans Production Hardening, Testing Pyramid, Living Docs), analisis kritis 14 penelitian terkait (Tabel 2.3 komprehensif), dan sintesis gap statement.
- **BAB 3 METODOLOGI & PERANCANGAN SISTEM (`PA/docs/modules/bab3/README.md`):** Ditulis ulang penuh sebagai Software Design Document komprehensif (~3.200 kata) mencakup deskripsi solusi 5 pilar, metodologi Scrum 4 sprint (114 Story Points) + spesifikasi User Story format Gherkin, diagram blok Clean-Modulith + MCP, pemodelan proses bisnis BPMN (4 alur), Diagram Use Case Global + 4 Use Case Specifications lengkap, DFD L0 & L1, ERD Multi-Tenant + Kamus Data Basis Data lengkap (5 tabel terinci: `buildings`, `rooms`, `schedules`, `invoices`, `mcp_tool_logs`), spesifikasi antarmuka UI/UX (Web Owner Switcher & Chatbot AI, Admin, Penghuni), JSON Schema 4 tool MCP, format response envelope REST API, dan matriks 20 skenario pengujian verifikatif.
- **Pembaruan Dokumen State:** `Docs/00_overview/STATE.md` dan `PA/docs/00_overview/STATE.md` diperbarui (progress PA naik ke 75%).
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`
- `PA/docs/modules/bab2/README.md`
- `PA/docs/modules/bab3/README.md`
- `PA/docs/00_overview/STATE.md`
- `Docs/00_overview/STATE.md`
- `PA/docs/03_logs/PROGRESS_LOG.md`
- `Docs/03_logs/PROGRESS_LOG.md`
**Dokumen yang diupdate:**
- Seluruh modul naskah BAB 1-3 dan log federasi.
**Belum selesai / next steps:**
- Persiapan kompilasi dokumen `docx v0.1` (BAB 1–3) untuk bimbingan dosen.

---

## [2026-10-03 10:30] Ekspansi Mendalam Teori Penunjang BAB 2 (2.2.1 - 2.2.10)

**Status:** Selesai
**Dikerjakan:**
- Memperluas secara komprehensif Bab 2.2 Teori Penunjang (dari ~240 baris menjadi 563 baris) mencakup 10 sub-bab teoritis lengkap:
  1. SIM & Digitalisasi Properti Hunian (4 dimensi fungsional & eliminasi human-error).
  2. Evolusi Arsitektur Monolith vs Microservices vs Modulith (DDD, 3-tier hierarchy, event bus write vs gateway read).
  3. Standarisasi Kontrak REST API, Format Envelope JSON, Layered FormRequest Validation, DTO, Living Documentation.
  4. Arsitektur Multi-Tenancy (Row-Level Scoping `building_id`, Global Scope Eloquent, Tenant-Aware RBAC).
  5. Model Context Protocol (MCP) & Built-in AI Assistance (JSON-RPC tools, grounding anti-halusinasi, audit log).
  6. Clean Architecture di Frontend Flutter (The Dependency Rule 3 layer, BLoC pattern, GetIt DI, Single Codebase).
  7. Basis Data Relasional MySQL (ACID, MVCC Pessimistic Locking pencegah double booking, Composite Indexing).
  8. Integrasi Payment Gateway Midtrans Production Patterns (Idempotency Key, SHA-512 Signature, Webhook FSM).
  9. Strategi Pengujian Berlapis (Piramida Pengujian: Unit, API Contract, Tenant Isolation, Integration).
  10. Living Documentation & Architecture Decision Records (ADR).
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`
**Belum selesai / next steps:**
- Render diagram visual (ERD multi-tenant, BPMN, Sequence MCP tool-use) untuk lampiran/insert docx.

---

## [2026-10-03 10:00] Penyelarasan Naskah PA BAB 1, 2, 3 dengan 5 Pilar Konseptual

**Status:** Selesai
**Dikerjakan:**
- Mengadopsi 5 pilar konseptual (Standar I/O, Multi-Tenant Gedung, MCP AI Assistant, Modular Monolith Event-Driven & Module Gateway, Clean Architecture Frontend) ke dalam draf naskah.
- Update `PA/docs/modules/bab1/README.md`: penajaman gap previous work, 5 pilar posisi PA, rumusan masalah, tujuan, batasan (row-level multi-tenancy & read-only MCP), dan manfaat.
- Update `PA/docs/modules/bab2/README.md`: pengayaan teori (Modulith 3-tier, Multi-Tenancy, MCP & LLM Tool-Use, Kontrak REST JSON, Clean Architecture FE, Database Indexing, Midtrans Hardening) dan gap statement.
- Update `PA/docs/modules/bab3/README.md`: desain Clean-Modulith + MCP, alur AI tool execution, kontrak JSON envelope baku, ERD multi-gedung, skenario pengujian komprehensif.
- Sinkronisasi `PA/docs/00_overview/STATE.md`.
**File yang diubah:**
- `PA/docs/modules/bab1/README.md`, `PA/docs/modules/bab2/README.md`, `PA/docs/modules/bab3/README.md`, `PA/docs/00_overview/STATE.md`
**Dokumen yang diupdate:**
- `PA/docs/03_logs/PROGRESS_LOG.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Render diagram pendukung BAB 3 (BPMN, DFD, Sequence MCP tool-use, ERD v2).
**Catatan/masalah:**
- Judul skripsi tetap dipertahankan.

---

## [2025-09-20 04:30] BAB 2 Draft Penuh selesai — Teori + Narasi Tabel 2.3 (14 baris) + Gap Statement

**Status:** Selesai
**Dikerjakan:**
- Tulis `PA/docs/modules/bab2/README.md` draft penuh: 2.1 Deskripsi Permasalahan, 2.2 Teori Penunjang (9 sub-bab dengan sitasi [1]-[22]), 2.3 Penelitian Terkait (narasi 14 baris dengan positioning eksplisit per baris), 2.4 Gap Statement (5 gap utama)
- Sitasi IEEE numeric [1]-[22] dari DAFTAR_PUSTAKA.md
- Coverage: SIM, Modulith/DDD, Clean Arch, Laravel Modular, Flutter Clean Arch, MySQL, Midtrans, Testing, Living Docs — semua dengan jurnal 2022-2026
- Tabel 2.3: 14 baris narasi (9 jurnal terkait + 4 previous work + PA kita) dengan positioning eksplisit
**File yang diubah:**
- `PA/docs/modules/bab2/README.md`
**Dokumen yang diupdate:**
- `PA/docs/modules/bab2/README.md`, `PA/docs/00_overview/STATE.md`
**Belum selesai / next steps:**
- Outline BAB 3 detail (diagram BPMN/DFD/Activity/ERD + trace mapping Project/ + mockup + skenario)
- Generate docx v0.1 (BAB1-3) untuk review dosen
**Catatan/masalah:**
- BAB 2 ~4,000 kata, sitasi konsisten [1]-[22], siap review dosen.

---

## [2025-09-20 03:30] BAB 1 Draft Penuh selesai — Previous Work Analysis + Gap + Proposal Baru

**Status:** Selesai
**Dikerjakan:**
- Tulis BAB 1 draft penuh: 1.1 Latar Belakang (3 bagian), 1.2 Rumusan Masalah (5 butir), 1.3 Tujuan (5 butir), 1.4 Batasan, 1.5 Manfaat, 1.6 Sistematika
- Sitasi IEEE numeric [1]-[19] dari DAFTAR_PUSTAKA
- Analisis previous work: tabel 4 proposal + 5 gap eksplisit (fragmentasi, arsitektur inkonsisten, test lemah, web hilang, payment sandbox)
- Posisi PA: 5 perbaikan sistematik (Clean Arch konsisten, Interface-based, Test ≥80%, Web Dashboard, Midtrans production)
**Belum selesai / next steps:**
- Draft BAB 2 penuh (teori 2.2 + narasi tabel 2.3 + gap statement 2.4)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- BAB 1 ~2,500 kata, siap review dosen.

---

## [2025-09-20 02:15] Literature Review Sprint selesai — TABEL_JURNAL 15 jurnal + DAFTAR_PUSTAKA 22 entry

**Status:** Selesai
**Dikerjakan:**
- Search jurnal 2022-2026 via Semantic Scholar + SINTA/Garuda + Web + Midtrans docs
- Isi `TABEL_JURNAL.md`: 15 jurnal terpilih (5 modulith, 4 Flutter Clean Arch, 6 kost Indonesia + Midtrans)
- Update `DAFTAR_PUSTAKA.md`: 22 entry IEEE numeric urut kemunculan BAB1→BAB5 (include previous work [23]-[30])
- Gap statement diperbarui: 5 gap utama
**Belum selesai / next steps:**
- Draft BAB 1 penuh (previous work analysis + gap + proposal baru)
- Draft BAB 2 penuh (teori + 12 penelitian terkait + tabel perbandingan + gap)
- Outline BAB 3 detail (diagram + trace mapping Project/)
**Catatan/masalah:**
- Semua jurnal punya DOI/URL verifikabel.

---

## [2025-09-20 01:15] Koreksi: old-files = referensi previous work, PA progress 0%

**Status:** Selesai (koreksi STATE)
**Dikerjakan:**
- Update STATE: **PA progress 0%** — 4 PDF di `old-files/` adalah **REFERENSI previous work** (4 proposal mahasiswa lain), bukan kerjaan kita
- PA naskah baru: BAB 1 = analisis previous work (state, gap, kesalahan), BAB 2 = teori + kritik previous, BAB 3 = desain sistem perbaikan
- Target minggu ini: Literature Review Sprint → BAB 1-3 draft
**Belum selesai / next steps:**
- Search jurnal 2022-2026 → isi `TABEL_JURNAL.md` 15-20 jurnal
- Draft BAB 1 (previous work analysis + gap + proposal baru)
- Draft BAB 2 (teori + related work + kritik previous)
- Outline BAB 3 (desain sistem baru)
**Catatan/masalah:**
- Jangan copy-paste 4 proposal jadi BAB 1-3 kita — itu previous work, bukan kerjaan kita

---

## [2025-09-19 23:40] Init PA/docs federated

**Status:** Selesai
**Dikerjakan:**
- Buat struktur PA/docs: 00_overview, 01_guides, 02_reference, 03_logs, modules/bab1-5
- Extract baseline penulisan dari 4 PDF proposal → PANDUAN_PENULISAN + TEMPLATE_BASELINE + STACK
- Buat DAFTAR_PUSTAKA awal (8 entry dari proposal) + TABEL_JURNAL (4 terkait + gap) + ERD_GLOBAL + SKILL_BLOCKERS
**File yang diubah:**
- `PA/docs/**` (15 file baru)
**Belum selesai / next steps:**
- Search jurnal baru 2022-2026 untuk TABEL_JURNAL baris 5-15
- Draft modules/bab1-5 (masih kosong)
**Catatan/masalah:**
- Sitasi proposal sebagian belum ada DOI — tandai [NEEDS VERIFY]

---
