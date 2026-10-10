# Spesifikasi Aliran Data (DFD) — Sistem Manajemen Properti Terpadu

> **Pusat Kebenaran Aliran Data (*Single Source of Truth*):** Dokumen ini memetakan seluruh pertukaran informasi antara entitas eksternal, proses komputasi fungsional, dan *data store* terisolasi pada arsitektur Modular Monolith sistem hunian dinamis.
> 
> *Diagram Sumber & Visualizer Interaktif (Dilengkapi Fitur Download SVG & PNG High-Res 2x untuk Kertas A4 Word):*
> - **DFD Level 0 (Diagram Konteks Standar):** [`dfd_level_0_context.html`](dfd_level_0_context.html) & [`DFD_LEVEL_0_CONTEXT.mmd`](DFD_LEVEL_0_CONTEXT.mmd)
> - **DFD Level 1 (Dekomposisi Fungsional 3-Kolom Standar):** [`dfd_level_1_dekomposisi.html`](dfd_level_1_dekomposisi.html) & [`DFD_LEVEL_1_DEKOMPOSISI.mmd`](DFD_LEVEL_1_DEKOMPOSISI.mmd)

---

## 1. DFD Level 0 — Diagram Konteks Sistem (Standar DeMarco / Yourdon)

Diagram Konteks menggambarkan batas luar sistem (*system boundary*) yang diwakili oleh **satu proses sentral berbentuk lingkaran (0.0)** yang berinteraksi dengan **entitas eksternal (*terminator*) berbentuk persegi panjang**. Sesuai kaidah formal Yourdon & DeMarco, diagram konteks tidak menampilkan simbol *data store* karena penyimpanan berada di dalam internal sistem 0.0.

### A. Entitas Eksternal (Terminators)
1. **Pemilik Properti (*Owner*):**
   - **Data Masuk ke Sistem (Input):** Setup gedung/properti, kebijakan operasional & tarif, konfigurasi modul dinamis (`building_settings`), dan penugasan peran kustom (*Custom RBAC*).
   - **Data Keluar dari Sistem (Output):** Laporan okupansi hunian, laporan arus kas riil & piutang sewa, serta ringkasan audit trail pengguna.
2. **Pengelola Gedung (*Admin*):**
   - **Data Masuk ke Sistem (Input):** Input kamar, tipe fasilitas, penempatan kamar penghuni (*Admin-Assign*), verifikasi approval tiket kerusakan, dan pencatatan kas beban operasional.
   - **Data Keluar dari Sistem (Output):** Antrean pengajuan huni baru, tiket keluhan masuk, alert agenda servis preventif jatuh tempo H-7, serta rekapitulasi buku tamu aktif.
3. **Penghuni / Calon Penghuni (*Resident*):**
   - **Data Masuk ke Sistem (Input):** Registrasi akun & unggah identitas, formulir pemilihan kamar mandiri (*Self-Service*), konfirmasi bayar tagihan, tiket komplain fasilitas + foto, dan input tamu menginap.
   - **Data Keluar dari Sistem (Output):** Konfirmasi alokasi huni, lembar tagihan invoice & kuitansi, serta progres penanganan tiket aduan.
4. **Midtrans Payment Gateway (Sistem Eksternal):**
   - **Data Masuk ke Sistem (Input):** HTTP Webhook callback status transaksi (`settlement`, `expire`, `deny`).
   - **Data Keluar dari Sistem (Output):** Permintaan token SNAP berserta rincian nominal dan order ID tagihan.
5. **WhatsApp / Email Gateway (Sistem Eksternal — Fonnte / Open-WA):**
   - **Data Masuk ke Sistem (Input):** Sinyal konfirmasi pesan terkirim (*delivery receipt / acknowledgement*).
   - **Data Keluar dari Sistem (Output):** Muatan pesan otomatis (*message payload*) beserta nomor WhatsApp tujuan.
6. **External AI Client / MCP Host (Adapter Eksternal):**
   - **Data Masuk ke Sistem (Input):** Perintah JSON-RPC 2.0 eksekusi tool (*read-only tool call request*).
   - **Data Keluar dari Sistem (Output):** Respon data faktual teragregasi secara terstruktur (*deterministic JSON grounded*).

---

## 2. DFD Level 1 — Dekomposisi Fungsional (10 Proses, mencakup F01–F17)

Layout **per-baris proses**: Data Store (kiri, 2 garis paralel) · Proses lingkaran (tengah) · Entitas luar (kanan). Setiap aliran punya jalur horizontal sendiri → tidak ada panah bersilangan dan label tidak tertimpa. Entitas/data store yang muncul berulang digambar ulang sebagai **duplikat** (tanda garis miring di pojok entitas / garis vertikal tambahan di data store) sesuai konvensi Gane & Sarson. Biru = Input ke proses, Merah = Output dari proses.

Sumber data diagram ada di array `P` dalam `dfd_level_1_dekomposisi.html` (ubah di sana, layout otomatis).

| Proses | Fitur | Entitas | Data Store |
|---|---|---|---|
| 1.0 Kelola Akun & Hak Akses | F01, F02 | Penghuni, Pengelola, Pemilik | D1 |
| 2.0 Kelola Gedung & Kebijakan | F03, F04 | Pemilik | D2 |
| 3.0 Kelola Kamar | F05 | Pengelola, Penghuni | D2 (R), D3 |
| 4.0 Kelola Alokasi & Dashboard | F06, F07 | Penghuni, Pengelola, Pemilik | D2/D3/D5 (R), D4 |
| 5.0 Kelola Keuangan | F08, F09, F10, F11 | Penghuni, Pengelola, Pemilik, Midtrans | D2/D4 (R), D5 |
| 6.0 Kelola Pemeliharaan | F12, F13 | Penghuni, Pengelola | D3 (W status), D6 |
| 7.0 Kelola Inventaris Aset | F14 | Pengelola, Pemilik | D3 (R), D7 |
| 8.0 Kelola Buku Tamu | F15 | Penghuni, Pengelola | D4 (R), D5 (W biaya inap), D8 |
| 9.0 Kirim Notifikasi | F16 | WhatsApp/Email, Pengelola | D5/D6 (R event), D9 |
| 10.0 Layani Asisten AI (MCP) | F17 | AI Client | D3, D4, D5, D6 (read-only) |

## 3. Data Store

| ID | Nama | Pemilik Write |
|---|---|---|
| D1 | Pengguna & Role | 1.0 |
| D2 | Gedung & Pengaturan | 2.0 |
| D3 | Kamar & Tipe | 3.0 (6.0 hanya ubah status via event) |
| D4 | Alokasi Hunian | 4.0 |
| D5 | Keuangan | 5.0 (8.0 tambah biaya inap via event) |
| D6 | Pemeliharaan | 6.0 |
| D7 | Inventaris Aset | 7.0 |
| D8 | Buku Tamu | 8.0 |
| D9 | Log Notifikasi | 9.0 |
