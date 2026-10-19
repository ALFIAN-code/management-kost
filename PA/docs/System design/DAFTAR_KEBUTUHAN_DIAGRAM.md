# Daftar Kebutuhan Diagram — BAB 1 dan BAB 2

> **Status:** daftar kerja (bukan dokumen naskah)
> **Terakhir diupdate:** 2026-10-18
> **Sumber:** pemindaian naskah `PA/docs/modules/bab1/README.md` dan `bab2/README.md` setelah revisi ADR-007 dan ADR-011.

---

## Ringkasan

| Kategori | Jumlah |
|---|---|
| Diagram sudah ada dan terpakai | 3 |
| Diagram belum ada (wajib dibuat) | 11 |
| Referensi yang perlu diperbaiki | 1 |

Catatan: BAB 1 tidak memakai diagram bernomor. Visual yang muncul di BAB 1 (§1.1.3 tabel pemetaan kelemahan ke pilar) masih berupa tabel teks, sehingga tidak termasuk daftar ini.

---

## A. Diagram yang Sudah Ada

| No | Gambar | Lokasi file | Dipakai di |
|---|---|---|---|
| Gambar 2.2 | Hirarki Modul 3-Tier pada Modular Monolithic | `01-Gambaran-umum/02_arsitektur_backend/hierarki_3_tier_modulith.mmd` | BAB 2 §2.2.2 |
| Gambar 2.4 | Lapisan Clean Architecture pada Flutter | `01-Gambaran-umum/03_arsitektur_frontend/clean_architecture_frontend.mmd` | BAB 2 §2.2.4 |
| Gambar 2.5 | Pembagian Lapisan pada Clean Architecture | `01-Gambaran-umum/03_arsitektur_frontend/clean_architecture_frontend.mmd` | BAB 2 §2.2.5 |

**Masalah:** Gambar 2.4 dan Gambar 2.5 menunjuk file yang sama, padahal sub-bab §2.2.4 membahas Flutter sebagai framework multi-platform, sedangkan §2.2.5 membahas Clean Architecture. Keduanya perlu diagram terpisah. Lihat bagian B.

**Catatan tambahan:** kedua diagram tersebut masih digambar untuk kondisi desain lama. Perlu diperiksa apakah isinya masih sesuai dengan arsitektur NestJS sebelum dipakai ulang.

---

## B. Diagram yang Belum Ada (Wajib Dibuat)

| No | Gambar | Sub-bab | Isi yang harus ditampilkan | Prioritas |
|---|---|---|---|---|
| Gambar 2.1 | Dimensi Fungsional SIM pada Sistem Manajemen Rumah Kost | §2.2.1 | Empat fungsi utama SIM: pencatatan aset fisik, siklus sewa, keuangan dan penagihan, operasional dan pemeliharaan. Menggantikan tabel dimensi fungsional versi lama | Sedang |
| Gambar 2.3 | Pemisahan Antar Modul dan Dependency Injection pada NestJS | §2.2.3 | Dua modul berbeda yang tidak saling bisa mengakses service internal. Menunjukkan modul yang mengekspos fungsi lewat `exports`, dan modul yang tidak mengekspos sehingga tidak bisa disuntik. Ini inti alasan memilih NestJS | **Tinggi** |
| Gambar 2.4b | Flutter Multi-Platform (pisah dari Clean Architecture) | §2.2.4 | Satu basis kode Dart menghasilkan web, Android, dan iOS. Memisahkan dari diagram Clean Architecture | Sedang |
| Gambar 2.6 | Alur Data pada Pola BLoC | §2.2.6 | Widget mengirim event ke bloc, bloc memanggil use case, bloc memancarkan state baru, widget menampilkan. Menunjukkan pemisahan logika bisnis dan tampilan | Sedang |
| Gambar 2.7 | Mekanisme Penguncian Baris untuk Pencegahan Pemesanan Ganda | §2.2.7 | Dua permintaan sewa masuk bersamaan ke kamar yang sama. Satu mendapat `SELECT ... FOR UPDATE`, yang lain harus menunggu. Setelah selesai baru diketahui apakah kamar sudah terisi | **Tinggi** |
| Gambar 2.8 | Isolasi Data Antar Gedung pada Row-Level Scoping | §2.2.8 | Satu tabel dengan kolom `building_id`. Query dari penghulu gedung A hanya mengembalikan baris gedung A, bukan gedung B | **Tinggi** |
| Gambar 2.9 | Alur Verifikasi Token OIDC dengan JWKS | §2.2.9 | Pengguna login di Keycloak, Keycloak menerbitkan token, backend mengunduh kunci publik dari JWKS, lalu memverifikasi tanda tangan token secara lokal tanpa menghubungi Keycloak | **Tinggi** |
| Gambar 2.10 | Komposisi Container pada Sistem Manajemen Rumah Kost | §2.2.10 | Empat container dalam satu jaringan Docker: backend NestJS, PostgreSQL, Keycloak, dan optionally layanan AI. Semuanya dijalankan dengan satu perintah | **Tinggi** |
| Gambar 2.11 | Alur Pembayaran dan Verifikasi Webhook | §2.2.11 | Alur dua arah: penghuni membayar lewat SNAP, lalu Midtrans mengirim webhook. Backend memverifikasi tanda tangan sebelum mengubah status tagihan | Sedang |
| Gambar 2.12 | Bentuk Standar Respons API | §2.2.12 | Perbandingan dua bentuk JSON: jawaban berhasil dan jawaban gagal validasi, beserta pemetaan ke kode HTTP 200 sampai 422 | Sedang |
| Gambar 2.13 | Piramida Pengujian beserta Komposisinya | §2.2.13 | Tiga lapisan pengujian dengan jumlah, waktu, dan biaya. Menandai posisi uji isolasi gedung di lapisan integrasi | Sedang |

---

## C. Referensi yang Perlu Diperbaiki

| No | Masalah | Tindakan |
|---|---|---|
| Gambar 2.14 | Menunjuk ke folder `draft/06_bpmn_konsultasi_ai_mcp/`, yang berisi diagram BPMN alur konsultasi AI | Dipindah ke folder resmi, bukan `draft/`. Nama file diubah agar sesuai sub-bab: `alur_jawaban_cepat_mcp` |

---

## D. Catatan untuk BAB 3

Daftar ini hanya mencakup BAB 1 dan BAB 2. Diagram untuk BAB 3 belum dapat ditetapkan karena naskah BAB 3 masih versi lama.

Diagram yang kemungkinan dibutuhkan di BAB 3, berdasarkan sub-bab yang sudah ada:

| Sub-bab | Kemungkinan dibutuhkan diagram |
|---|---|
| §3.1 Deskripsi Solusi Terpadu | Diagram arsitektur sistem keseluruhan versi NestJS |
| §3.3 Perancangan Arsitektur | Diagram sembilan modul dan kepemilikan 13 tabel |
| §3.4 Pemodelan Proses Bisnis | BPMN alur sewa bulanan, BPMN verifikasi webhook, BPMN konsultasi AI |
| §3.5 Pemodelan Fungsional | Use case global, DFD level 0, DFD level 1 |
| §3.6 Basis Data | ERD 13 tabel (sudah ada di `04-ERD/`, perlu diperbarui) |
| §3.7 Antarmuka Pengguna | Mockup dashboard pemilik, dashboard pengelola, portal penghuni |
| §3.8 Kontrak API dan MCP | Sequence diagram pemesanan sewa, sequence diagram verifikasi webhook |
| §3.9 Skenario Pengujian | Tabel skenario, sudah ada dalam naskah |

Diagram di folder `01-Gambaran-umum/` dan `02-BPMN/` sekarang masih menggambarkan arsitektur versi lama. Seluruhnya perlu diperiksa ulang setelah BAB 3 selesai ditulis.

---

## E. Urutan Pengerjaan

1. **Tinggi** — Gambar 2.3, 2.7, 2.8, 2.9, 2.10. Kelima diagram ini menjadi alasan utama pemilihan teknologi dalam naskah.
2. **Sedang** — Gambar 2.1, 2.4b, 2.6, 2.11, 2.12, 2.13.
3. **Perbaikan** — pindahkan Gambar 2.14 keluar dari folder `draft/`, dan pisahkan Gambar 2.4 dari 2.5.