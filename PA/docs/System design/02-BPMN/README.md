# Katalog Alur Proses Bisnis (BPMN / Sequence Flows)

> Folder ini memuat seluruh perancangan alur proses bisnis (**Step 2: Flow Mapping**) dari arsitektur hunian dinamis sistem **PA-Management-kost (ADR-008 & ADR-009)**. Setiap alur memiliki subfolder terpisah yang berisi kode sumber diagram Mermaid (`.mmd`) dan dokumentasi naratif lengkap (`README.md`).

---

## Daftar Alur Proses per Fitur

| No | Subfolder | Nama Alur & Fitur | Kategori Modul | Aktor Terlibat | File Diagram |
|---|---|---|---|---|---|
| **01** | `01_alokasi_penempatan_hunian/` | **Alokasi & Penempatan Hunian** | **CORE** (M4: Schedule, M3: Room) | Calon Penghuni, Pengelola, Sistem | `alur_alokasi_penempatan.mmd` |
| **02** | `02_penagihan_pembayaran/` | **Penagihan & Pembayaran Sewa** | **OPSIONAL** (O1: Finance) | Penghuni, Pengelola, Midtrans Gateway | `alur_penagihan_pembayaran.mmd` |
| **03** | `03_laporan_kerusakan_fasilitas/` | **Tiket Pelaporan Kerusakan** | **OPSIONAL** (O2: Maintenance) | Penghuni, Pengelola, Teknisi | `alur_laporan_kerusakan.mmd` |
| **04** | `04_pemeliharaan_rutin_berkala/` | **Jadwal Pemeliharaan Rutin** | **OPSIONAL** (O2: Maintenance) | Pengelola, Teknisi / Vendor | `alur_pemeliharaan_rutin.mmd` |
| **05** | `05_pengeluaran_operasional/` | **Pencatatan Biaya Operasional** | **OPSIONAL** (O1: Finance) | Pengelola, Pemilik | `alur_pengeluaran_operasional.mmd` |
| **06** | `06_pengawasan_buku_tamu/` | **Buku Tamu & Tamu Menginap** | **OPSIONAL** (O4: Guest) | Penghuni, Pengelola, Tamu | `alur_pengawasan_buku_tamu.mmd` |
| **07** | `07_pengaturan_hak_akses_dinamis/` | **Dynamic RBAC & Role Builder** | **CORE** (M1: User & Access) | Pemilik, Pengguna / Staf | `alur_hak_akses_dinamis.mmd` |
| **08** | `08_pendataan_inventaris_aset/` | **Inventarisasi & Audit Aset** | **OPSIONAL** (O3: Inventory) | Pengelola, Penghuni | `alur_inventaris_aset.mmd` |

---

## Prinsip Desain Alur

1. **Decoupled Architecture:** Modul Core (Alur 01 & 07) berjalan mandiri tanpa mewajibkan modul Opsional (Alur 02, 03, 04, 05, 06).
2. **Payment Barrier Gate:** Alur 02 (Pembayaran) berperan sebagai gerbang validator yang menahan aktivasi hunian hanya jika modul Keuangan diaktifkan untuk gedung tersebut.
3. **Kebijakan Fleksibel Multi-Properti:** Alur 01 mendukung 3 kebijakan pemilihan kamar (`ADMIN_ASSIGN_ONLY`, `SELF_SERVICE_APPROVAL`, `SELF_SERVICE_INSTANT`) sehingga siap digunakan untuk mes, asrama, pondok, maupun rumah kost komersial.
