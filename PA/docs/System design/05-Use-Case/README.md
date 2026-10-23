# UML 2.5 Use Case Diagram — Sistem Manajemen Rumah Kost Terpadu

> **Status:** ✅ Ratified  
> **Tipe:** Standar UML 2.5 Use Case Diagram  
> **Penyimpanan:** `PA/docs/System design/05-Use-Case/`  
> **Referensi Naskah:** BAB 3 §3.4 (*Gambar 3.13 — Use Case Diagram Sistem Manajemen Rumah Kost*)

---

## 1. Ringkasan Diagram

Diagram Use Case ini memodelkan batasan kewenangan fungsional (*role boundaries*) antara para pengguna sistem (*aktor*) dengan 17 fungsionalitas utama (*use cases*) yang disediakan oleh Sistem Manajemen Rumah Kost Terpadu. Pemodelan mencakup **peran bawaan (*default seed roles*)** sebagai acuan saat sistem pertama kali diinisialisasi, sekaligus mengakomodasi **hak akses dinamis (*dynamic RBAC*)** melalui fitur *Role Builder*.

Diagram tersedia dalam tiga format:
- **HTML Interaktif:** `use_case_global.html` (dilengkapi tombol unduh SVG & PNG 2x resolusi tinggi).
- **Vektor SVG:** `use_case_global.svg` (skalabilitas tajam bebas pecah, dimensi 780 x 690 px).
- **PNG 2x:** `use_case_global.png` (resolusi cetak 1560 x 1380 px siap pakai di Word/A4, layout super kompak & bebas whitespace horizontal).

---

## 2. Aktor Sistem

### A. Aktor Manusia (Primary Actors)

| Aktor | Cakupan Wewenang (*Default Scope*) | Peran dalam Sistem |
|---|---|---|
| **Pemilik (*Owner*)** | Multi-Gedung (*Super Admin*) | Wewenang tertinggi portofolio properti. Mendaftarkan gedung baru, mengatur parameter kebijakan tarif (`building_settings`), merancang peran & hak akses kustom (**UC-01 Dynamic RBAC**), memantau dasbor laba-rugi, dan konsultasi AI. |
| **Pengelola (*Admin Gedung*)** | Gedung Binaan (*Tenant Scoped*) | Penanggung jawab operasional harian satu properti. Mengelola kapasitas kamar, mengonfirmasi alokasi sewa, menangani tiket kerusakan, menjadwalkan servis rutin, mengaudit inventaris kamar, mencatat beban operasional kas, dan mengawasi buku tamu. |
| **Penghuni (*Resident*)** | Kamar Sewa Aktif (*Self-Service*) | Pengguna mandiri layanan hunian. Melakukan reservasi kamar, membayar tagihan sewa bulanan online via Midtrans, melapor komplain fasilitas berfoto, mendaftarkan tamu berkunjung, dan mendampingi audit inventaris. |
| **Teknisi Servis** | Penugasan Lapangan (*Staff*) | Menerima surat perintah kerja (SPK) tiket kerusakan dan pemeliharaan preventif berkala, serta melaporkan penyelesaian fisik pekerjaan. |

### B. Aktor Sistem Eksternal (Secondary / External Systems)

| Sistem Eksternal | Protokol Integrasi | Peran Fungsional |
|---|---|---|
| **Keycloak SSO OIDC** | OpenID Connect / JWKS | Penyedia identitas terpusat (*Identity Provider*), otentikasi login, serta penerbit token stateless JWT dengan klaim peran & cakupan gedung. |
| **Mesin AI (MCP Host)** | Model Context Protocol (MCP) | Agen kecerdasan buatan yang mengeksekusi alat bantu (*tool calls*) analitik faktual secara deterministik untuk kueri bahasa alami pemilik/pengelola. |
| **Midtrans Payment Gateway** | REST API SNAP & Webhook Callback | Memfasilitasi pembayaran non-tunai (QRIS, VA Bank, E-Wallet) dan mengirimkan notifikasi callback pelunasan secara real-time. |
| **WhatsApp Gateway** | HTTP Webhook REST | Mengirimkan pesan otomatis berupa lembar tagihan, pengingat jatuh tempo H-3/H-7, kuitansi lunas, dan status perbaikan tiket. |

---

## 3. Spesifikasi Use Case & Relasi

### A. Primary Use Cases

| ID | Nama Use Case | Aktor Terkait | Keterangan Relasi |
|---|---|---|---|
| **UC-01** | Kelola Peran & Hak Akses Dinamis (RBAC) | Pemilik | `<<include>>` UC-00 |
| **UC-02** | Kelola Master Gedung & Aturan Tarif | Pemilik | Akses konfigurasi `building_settings` |
| **UC-03** | Kelola Master Unit Kamar, Tipe, & Kapasitas | Pengelola | Manajemen ketersediaan fisik kamar |
| **UC-04** | Reservasi Kamar & Pilih Durasi Sewa Bulanan | Penghuni, Pengelola | `<<include>>` UC-05 |
| **UC-06** | Bayar Tagihan Sewa Bulanan Mandiri | Penghuni | `<<include>>` UC-07, `<<extend>>` UC-15 |
| **UC-08** | Pantau Portofolio Bisnis & Rekapitulasi Laba-Rugi | Pemilik, Pengelola | Agregasi pendapatan kotor vs beban kas |
| **UC-09** | Lapor Kerusakan Fasilitas (Deskripsi & Foto) | Penghuni | `<<extend>>` UC-15 |
| **UC-10** | Tindak Lanjut Komplain & Penugasan Teknisi | Pengelola, Teknisi | Penugasan SPK & verifikasi perbaikan |
| **UC-11** | Penjadwalan Pemeliharaan Rutin Preventif | Pengelola, Teknisi | Servis berkala AC, pompa air, genset (H-7) |
| **UC-12** | Audit Inventaris Aset Checklist Unit Kamar | Pengelola, Penghuni | Serah terima check-in dan inspeksi check-out |
| **UC-13** | Pengawasan Buku Tamu & Verifikasi Jam Inap | Pengelola, Penghuni | Pra-registrasi tamu & rekam waktu riil |
| **UC-14** | Konsultasi Wawasan Bisnis Bahasa Alami AI | Pemilik | `<<include>>` UC-16 |
| **UC-17** | Catat Pengeluaran Kas Operasional Riil & Nota | Pengelola | Pencatatan beban pemeliharaan & belanja gedung |

### B. Subsystem / Integrated Use Cases

| ID | Nama Sub-Use Case | Tipe Relasi | Penjelasan Arsitektural |
|---|---|---|---|
| **UC-00** | Verifikasi Sesi & Token Stateless JWT (JWKS) | `<<include>>` | Memvalidasi integritas token JWT Keycloak sebelum eksekusi aksi sensitif. |
| **UC-05** | Kunci Baris Jadwal Kamar (*SELECT FOR UPDATE*) | `<<include>>` | Mencegah *double booking* saat dua calon penghuni memesan unit yang sama serentak. |
| **UC-07** | Proses Transaksi SNAP & Webhook Callback | `<<include>>` | Membuka popup pembayaran digital dan menerima verifikasi pelunasan dari Midtrans. |
| **UC-15** | Kirim Notifikasi Pesan Otomatis WhatsApp | `<<extend>>` | Dipicu secara otomatis saat tagihan terbit, pembayaran lunas, atau status komplain selesai. |
| **UC-16** | Eksekusi Tool Analitik Faktual Protokol MCP | `<<include>>` | Pengambilan data langsung dari Module Gateway tanpa risiko halusinasi generatif LLM. |

---

## 4. Pratinjau File

```bash
PA/docs/System design/05-Use-Case/
├── README.md               # Dokumentasi spesifikasi fungsional
├── use_case_global.html    # Berkas sumber diagram interaktif HTML/SVG
├── use_case_global.svg     # Ekspor SVG vektor
└── use_case_global.png     # Ekspor PNG 2x resolusi cetak (2840x2120 px)
```
