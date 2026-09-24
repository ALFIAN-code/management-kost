# Glosarium — Wisma Amal Gorontalo

> Daftar istilah domain terpusat. AI wajib konsisten pakai istilah di kolom `Istilah`. Bahasa Indonesia.

**Terakhir diupdate:** 2025-09-19

| Istilah | Definisi | Sinonim / Jangan pakai | Catatan |
|---|---|---|---|
| Wisma Amal | Properti studi kasus di Gorontalo: kost/hunian sementara untuk mahasiswa & umum | Jangan pakai `hotel` generic | Customizable via Feature Toggle |
| Penghuni | User yang sudah sewa & tinggal aktif | Jangan pakai `penyewa` berganti-ganti | Status: calon → penghuni aktif |
| Calon Penghuni | User terdaftar tapi belum reservasi/approved | `prospect` | Bisa lihat kamar kosong saja |
| Pengelola | Admin yang mengelola operasional harian, akses terbatas sesuai izin Owner | Jangan pakai `admin` generic | RBAC via Spatie |
| Pemilik / Owner | Super admin, akses penuh semua modul, approve pengelola | `owner` | Paling tinggi |
| Kamar | Unit hunian: tipe, lantai, harga harian/bulanan/tahunan, fasilitas, foto | Jangan pakai `room` di docs | Status: Kosong / Dipesan / Terisi* |
| Reservasi | Pemesanan kamar oleh Calon Penghuni, validated sebelum bayar | Jangan pakai `booking` di kode Indo | Anti bentrok jadwal |
| Tagihan | Invoice sewa (bulanan/harian), auto-generate, terhubung pembayaran | Jangan pakai `billing` | Modul Finance |
| Pembayaran | Transaksi via Midtrans (VA/QRIS), status pending/settlement/expire | Jangan pakai `transaction` generic | `midtrans_transaction` table |
| Pengembalian Dana / Refund | Dana kembali 50% jika batal <7 hari (bulanan) / <3 hari (harian) | `refund` | Bayar penuh/DP |
| Tamu | Kunjungan yang dicatat Penghuni (guest logging) | - | Modul Resident |
| Laporan Kerusakan | Laporan fasilitas rusak oleh Penghuni (multi-foto) + timeline reply Admin | `maintenance request` | Modul Maintenance |
| Inventaris | Aset per kamar/fasilitas umum, kondisi & jumlah | - | Modul Inventory |
| Jadwal / Room Schedule | Timeline hunian aktif & reservasi mendatang per kamar | `schedule` | DFD Level 1 |
| Modulith / Modular Monolith | Arsitektur 1 deployment, modul loosely-coupled highly-cohesive | Jangan pakai `microservice` atau `monolith` plain | Pakai `nwidart/laravel-modules` |
| Feature Toggle | Aktif/nonaktif modul per properti via `modules_statuses.json` | `feature flag` | Kost/hotel/villa |

## Singkatan

| Singkatan | Kepanjangan | Konteks |
|---|---|---|
| PA | Proyek Akhir | Skripsi D3 TI PENS |
| PENS | Politeknik Elektronika Negeri Surabaya | Kampus |
| SIM | Sistem Informasi Manajemen |  |
| RBAC | Role-Based Access Control | Spatie |
| VA | Virtual Account | Midtrans |
| QRIS | Quick Response Code Indonesian Standard | Midtrans |
| DFD | Data Flow Diagram | Desain sistem |
| BPMN | Business Process Model and Notation |  |
| ERD | Entity Relationship Diagram |  |

## Aturan untuk AI Agent

- Jika menemukan istilah baru di task/code yang belum ada di tabel, tanya user atau usulkan entry baru — jangan asumsi.
- Konsistensi: pakai istilah di kolom `Istilah` untuk nama variabel/tabel/kolom di docs, bukan sinonim. Di kode pakai Inggris (`Room`, `Resident`, `Payment`) tapi di docs Indonesia konsisten.
- Bedakan `Penghuni` (sudah tinggal) vs `Calon Penghuni` (baru daftar) — sering tertukar di proposal.
