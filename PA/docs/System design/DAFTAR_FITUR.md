# Daftar Kebutuhan & Fitur Sistem (System Features Specification)

> Status: **Resmi Disepakati (ADR-008 & ADR-009)**  
> Lokasi Terpusat: **`PA/docs/System design/DAFTAR_FITUR.md`**  
> Sumber Kebenaran Tunggal (*Single Source of Truth*) untuk Rekayasa Sistem.

---

## 1. Klasifikasi Arsitektur Fitur

Sistem dirancang *as dynamic as possible* untuk mendukung berbagai skenario properti hunian bersama (rumah kost komersial, asrama gratis, mes karyawan, pondok pesantren):
1. **Fitur Core (M1–M5):** Fondasi wajib aktif di semua properti.
2. **Fitur Opsional (O1–O5):** Fitur penunjang *plug & play* yang dapat diaktifkan atau dinonaktifkan per gedung.
3. **Lapisan Ekstensi AI (Adapter):** Asisten AI berbasis protokol MCP yang hidup di atas modul bisnis sebagai adaptor analitik *read-only*.

---

## 2. Rincian Fitur Core (Wajib Selalu Aktif)

| Kode | Nama Fitur | Modul Domain | Aturan Bisnis & Fungsionalitas |
|---|---|---|---|
| **F01** | **Autentikasi Pengguna & Profil** | User & Access Control | Registrasi akun, autentikasi sesi token, pengelolaan profil identitas, kontak, dan biodata dasar penghuni/staf. |
| **F02** | **Dynamic RBAC & Role Builder** | User & Access Control | Menyediakan *permission sets* granular bawaan + fitur pembuatan peran kustom (*custom roles*) secara dinamis oleh pengguna dengan memilih centang izin. |
| **F03** | **Manajemen Multi-Gedung** | Property & Building | Master data gedung/properti multi-lokasi (nama, alamat, kontak penanggung jawab) dan konfigurasi modul aktif per gedung. |
| **F04** | **Kebijakan Konfigurasi Gedung** | Property & Building | Konfigurasi aturan huni dinamis per gedung: durasi minimal sewa (`min_rental_months`), mode alokasi (`booking_policy`: Admin-Only, Self-Service Approval, Self-Service Instant), kebijakan pembayaran pemesanan (`booking_fee_mode`: `FULL_MONTH`, `FIXED_DP`, `NO_DP`), nominal DP (`dp_amount`), masa kedaluwarsa DP (`dp_expiry_hours`), batas hari refund (`cancellation_grace_days`), dan tenggat terbit tagihan (`auto_invoice_lead_days`). |
| **F05** | **Master Kamar & Kapasitas Fisik** | Room Management | Data fisik kamar (nomor, lantai, tipe, harga dasar), **kapasitas maksimal unit (orang/ranjang)**, status fisik unit (`available` / `under_maintenance`). Terpisah dari data jadwal. |
| **F06** | **Alokasi & Penempatan Hunian** | Occupancy & Schedule | Alokasi dinamis orang $\leftrightarrow$ kamar $\leftrightarrow$ rentang waktu huni, validasi anti-bentrok kuota/jadwal, siklus status huni (`upcoming` $\rightarrow$ `active` $\rightarrow$ `completed`). |
| **F07** | **Dashboard Monitoring Hunian** | Occupancy Dashboard | Visualisasi denah kamar, status ketersediaan unit *real-time*, dan pemantauan daftar penghuni aktif per gedung. |

---

## 3. Rincian Fitur Opsional (Plug & Play per Gedung)

| Kode | Nama Fitur | Modul Domain | Aturan Bisnis & Fungsionalitas | Skenario Penggunaan |
|---|---|---|---|---|
| **F08** | **Penagihan Sewa Berkala & DP** | Finance & Billing | Penerbitan invoice otomatis per siklus huni. Mengadopsi pola *Two-Phase Invoicing* untuk penanganan DP (Invoice DP terbit saat booking + Invoice Pelunasan H-3 sebelum masuk) tanpa tabel cicilan; siklus sewa bulan berikutnya memakai *Anniversary Billing Cycle* (jatuh tempo sesuai tanggal mulai huni). | **Aktif:** Kost / Komersial.<br>**Mati:** Asrama / Mes / Pondok gratis. |
| **F09** | **Pembayaran Digital, Kasir & Refund** | Finance & Billing | Pembayaran digital otomatis via Midtrans SNAP (VA/QRIS) dengan webhook settlement + pembayaran manual diverifikasi admin. Dilengkapi alur **Pengembalian Dana (*Refund*) Semi-Manual**: pengajuan digital oleh penghuni, verifikasi batas pembatalan & denda oleh admin di menu *Refund Requests*, eksekusi transfer m-banking oleh admin + unggah struk bukti transfer, serta pelepasan otomatis status unit kamar menjadi *available*. | Aktif jika properti memungut pembayaran sewa / memfasilitasi pembatalan berbayar. |
| **F10** | **Denda Keterlambatan Flat** | Finance & Billing | Penambahan denda flat otomatis jika invoice melewati batas tanggal jatuh tempo + masa tenggang (*grace period*). | Toggleable per gedung. |
| **F11** | **Pengeluaran Operasional (*Expenses*)** | Finance & Billing | Pencatatan kas keluar riil gedung (listrik PLN, air PAM, WiFi, gaji staf, perlengkapan, servis) + unggah foto nota/struk untuk laporan laba bersih. | Aktif untuk transparansi arus kas operasional. |
| **F12** | **Tiket Kerusakan Fasilitas** | Maintenance | Penghuni mengajukan komplain kerusakan + foto bukti; pengelola verifikasi & tugaskan teknisi; isolasi status kamar menjadi `under_maintenance` jika fatal. | Aktif jika properti butuh tiket aduan fasilitas digital. |
| **F13** | **Pemeliharaan Rutin Berkala** | Maintenance | Agenda perawatan preventif berkala fasilitas umum (servis AC, kuras toren, fogging) + sistem pengingat H-7 + catat realisasi biaya servis. | Aktif untuk pemeliharaan terjadwal fasilitas gedung. |
| **F14** | **Inventarisasi & Audit Aset** | Asset & Inventory | Pendataan perabotan/barang per kamar + inspeksi checklist kondisi fisik barang (baik/rusak/hilang) saat momen *check-in* dan *check-out*. | Aktif jika gedung memiliki fasilitas furnitur lengkap. |
| **F15** | **Pengawasan Buku Tamu** | Guest Logging | Pencatatan tamu berkunjung (check-in/check-out) + opsi penambahan biaya inap ke invoice penghuni jika tamu menginap melebihi batas waktu. | Aktif jika properti menerapkan aturan jam malam/tamu. |
| **F16** | **Notifikasi Otomatis & Pengingat Manual** | Notification | Otomasi pengiriman pesan via WhatsApp/Email saat invoice terbit (H-7), pengingat jatuh tempo (H-1), peringatan hari H, konfirmasi bayar lunas, dan aduan selesai. Dilengkapi tombol aksi **"Kirim Pengingat" (*Manual Reminder Trigger*)** pada antarmuka tagihan pengelola untuk menagih penghuni secara fleksibel sewaktu-waktu. | Aktif jika terhubung ke gateway pesan eksternal. |

---

## 4. Lapisan Ekstensi AI (External Adapter Layer)

| Kode | Nama Fitur | Komponen | Aturan Bisnis & Fungsionalitas | Posisi Arsitektur |
|---|---|---|---|---|
| **F17** | **Asisten Cerdas Analitik** | MCP Server Adapter | Layanan query analitik *read-only* bagi Asisten AI berbasis protokol Model Context Protocol (JSON-RPC) untuk menjawab pertanyaan okupansi, ketersediaan, keuangan, dan tiket komplain. | Hidup di atas modul bisnis; tidak mengotori tabel bisnis inti. |

---

## 5. Hubungan Fitur dengan Alur BPMN
Seluruh fitur di atas terhubung langsung dengan 8 Alur Proses Bisnis di folder:
`PA/docs/System design/BPMN/`
* F03, F04, F05, F06, F07 $\rightarrow$ `01_alokasi_penempatan_hunian/`
* F08, F09, F10 $\rightarrow$ `02_penagihan_pembayaran/`
* F12 $\rightarrow$ `03_laporan_kerusakan_fasilitas/`
* F13 $\rightarrow$ `04_pemeliharaan_rutin_berkala/`
* F11 $\rightarrow$ `05_pengeluaran_operasional/`
* F15 $\rightarrow$ `06_pengawasan_buku_tamu/`
* F01, F02 $\rightarrow$ `07_pengaturan_hak_akses_dinamis/`
* F14 $\rightarrow$ `08_pendataan_inventaris_aset/`
* F16 $\rightarrow$ Terpasang sebagai event listener di Alur 01, 02, 03, 04.
