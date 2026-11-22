# BAB 1 — PENDAHULUAN

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[28]` terurut sesuai kemunculan pertama pada teks.

**Judul Proyek Akhir:**
*Arsitektur Modular Monolithic Berbasis Event-Driven untuk Sistem Informasi Manajemen Rumah Kost Terintegrasi.*

---

## 1.1 Latar Belakang

Pengelolaan rumah kost kini menuntut pencatatan dan tata kelola operasional yang tertib karena telah berkembang menjadi bisnis properti sewa mikro [1]. Seiring meningkatnya kebutuhan hunian sementara di kawasan perkotaan, banyak pemilik properti mulai mengelola lebih dari satu gedung kost (*multi-building properties*) di lokasi yang berbeda [2].

Ketika beberapa gedung kost masih dikelola menggunakan buku catatan manual, lembar sebar (*spreadsheet*), dan aplikasi pesan instan, muncul empat kendala operasional utama:
1. **Pencatatan data tercecer:** Informasi kamar, penghuni, dan riwayat pembayaran tersimpan terpisah, sehingga pemilik sulit memantau ketersediaan kamar, penghuni aktif, dan tunggakan lintas gedung secara serentak [1].
2. **Pemesanan ganda (*double booking*):** Kesepakatan sewa melalui pesan instan tanpa penguncian kamar terpusat sering memicu bentrok jadwal hunian [3].
3. **Penagihan dan rekonsiliasi manual:** Pemeriksaan bukti transfer satu per satu memakan waktu, rawan terlewat, dan menghambat pemantauan arus kas (*cash flow*) [4].
4. **Penanganan kerusakan fasilitas tidak terpantau:** Keluhan kerusakan yang disampaikan lewat obrolan pesan mudah tertimbun sehingga perbaikan terlambat dan aset fisik cepat menurun kualitasnya [4].

Upaya digitalisasi sebelumnya telah dirintis pada Juni 2025 melalui **empat proyek akhir terpisah** yang masing-masing menangani penghuni dan tamu, kamar dan reservasi, keuangan, serta operasional pemeliharaan [5][6][7][8]. Namun, hasil evaluasi terhadap sistem lama tersebut menunjukkan bahwa keempatnya masih berjalan sebagai **empat modul/aplikasi yang terfragmentasi tanpa batas arsitektur yang tegas**, dengan basis data yang membengkak hingga **34 tabel domain** (42+ tabel termasuk tabel infrastruktur *framework*), hanya melayani satu gedung (*single-tenant*), belum menggunakan autentikasi standar, serta belum menyediakan antarmuka analitik berbasis kecerdasan buatan [9][19]. Rincian evaluasi sistem lama dibahas pada Bab II.

Untuk mengatasi keterbatasan tersebut, Proyek Akhir ini merancang ulang (*rewrite*) sistem lama ke dalam satu backend terpadu berbasis arsitektur ***Modular Monolithic* yang *event-driven*** dengan total **10 modul terenkapsulasi** (4 modul inti/*core* dan 6 modul *opsional*, termasuk **1 modul *Artificial Intelligence* berbasis *Model Context Protocol***) [1][4][9]. Dengan pendekatan ini, setiap domain bisnis terisolasi dengan jelas tanpa ketergantungan *Foreign Key* lintas modul, mendukung pengelolaan banyak gedung dalam satu basis data (*multi-tenancy*), serta siap diintegrasikan dengan asisten AI untuk mempercepat pengambilan keputusan operasional.

---

## 1.2 Permasalahan

Berdasarkan latar belakang tersebut, permasalahan yang diangkat dalam Proyek Akhir ini dirumuskan menjadi lima poin berikut:
1. Bagaimana merancang dan menerapkan arsitektur ***Modular Monolith* pada NestJS** dengan sepuluh modul terenkapsulasi tanpa *Foreign Key* fisik lintas modul, serta antarmuka **Flutter Web** berbasis *Clean Architecture* dan kontrak API yang seragam?
2. Bagaimana menjamin isolasi data antar gedung kost melalui mekanisme ***Multi-Tenant Row-Level Scoping*** (`building_id`) yang terintegrasi dengan autentikasi ***Single Sign-On* (SSO) berbasis Keycloak OpenID Connect**?
3. Bagaimana menyederhanakan **proses bisnis sewa menjadi berbasis bulanan** dengan integrasi gerbang pembayaran digital **Midtrans SNAP** yang aman dan idempoten?
4. Bagaimana merancang dan mengintegrasikan **satu modul *Artificial Intelligence* (`AI / MCP Assistant`)** ke dalam arsitektur *Modular Monolith* untuk menjawab kueri operasional secara *read-only* tanpa melanggar batas hak akses gedung?
5. Bagaimana mengukur keandalan sistem secara menyeluruh melalui pengujian *black-box* fungsional, pengujian kombinasi modul, pengujian isolasi *multi-tenant*, pengujian idempotensi *webhook*, serta pengujian akurasi dan keamanan Modul AI?

---

## 1.3 Batasan Masalah

Ruang lingkup dan batasan dalam Proyek Akhir ini mencakup:
1. **Lingkup Domain Sistem (10 Modul):** Sistem mencakup **4 modul *core*** yaitu Pengguna (`Auth`), Gedung (`Building`), Kamar (`Room`), dan Kontrak Sewa (`Lease`), serta **6 modul *opsional*** yaitu Keuangan (`Finance`), Komplain Kerusakan (`Maintenance`), Buku Tamu (`Guest`), Inventaris (`Inventory`), Notifikasi WhatsApp (`Notification`), dan Asisten Kecerdasan Buatan (`AI / MCP Assistant`).
2. **Satuan dan Skema Sewa:** Sistem hanya melayani masa sewa dalam satuan **bulan penuh**. Batas minimal durasi sewa ditentukan per gedung melalui pengaturan sistem (`min_rental_months`). Pemesanan unit mendukung pembayaran penuh bulan pertama maupun uang tanda jadi (*Down Payment* / DP flat) per gedung melalui skema *Two-Phase Invoicing*, serta pembatalan reservasi melalui pengajuan *refund* semi-manual berlampiran bukti transfer resmi. Skema sewa harian, mingguan, dan tahunan tidak didukung.
3. **Peran Pengguna (*Roles*):** Hak akses dibatasi untuk tiga kategori pengguna: Pemilik (*Owner* seluruh gedung), Pengelola (*Admin* yang ditugaskan pada gedung tertentu), dan Penghuni (*Resident* kamar aktif).
4. **Platform Antarmuka:** Pengujian fungsionalitas dan antarmuka difokuskan pada platform **Web (Flutter Web)** untuk peramban desktop dan tablet. Kode antarmuka dirancang dengan *Clean Architecture* agar siap dikompilasi ke aplikasi mobile di kemudian hari, namun evaluasi kinerja aplikasi mobile fisik berada di luar ruang lingkup pengujian proyek akhir ini.
5. **Model Multi-Tenancy:** Pemisahan data multi-gedung memakai pendekatan *Shared Database with Row-Level Scoping* (`building_id`), bukan pemisahan basis data fisik per gedung.
6. **Autentikasi dan Manajemen Identitas Pengguna:** Autentikasi terpusat dikelola server Keycloak berbasis protokol OpenID Connect (OIDC). Backend NestJS berperan sebagai *Resource Server* yang memvalidasi token JWT secara *stateless* melalui JWKS lalu memetakan klaim token ke peran sistem (*Owner*, *Admin*, *Resident*) beserta batas gedung (`building_id`).
7. **Batasan Modul *Artificial Intelligence* (`AI / MCP Assistant`):** Modul AI berjalan pada lingkup *read-only tool calls* melalui *Module Gateway* untuk menyuplai data faktual bagi *Large Language Model* (LLM), serta tidak diberi wewenang mengubah data operasional secara otomatis tanpa persetujuan pengguna (*human-in-the-loop*).
8. **Integrasi Eksternal:** Layanan pihak ketiga mencakup gerbang pembayaran Midtrans SNAP (Virtual Account dan QRIS) serta pengiriman notifikasi transaksi melalui WhatsApp Gateway (Fonnte/Open-WA).
9. **Metodologi Pengembangan:** Sistem dikembangkan menggunakan kerangka kerja Scrum dalam 4 siklus *sprint*.

---

## 1.4 Tujuan

Selaras dengan permasalahan yang dirumuskan, tujuan yang ingin dicapai pada Proyek Akhir ini adalah:
1. Menghasilkan sistem manajemen rumah kost dengan backend ***Modular Monolith* berbasis NestJS** yang memisahkan domain ke dalam sepuluh modul mandiri tanpa *Foreign Key* fisik lintas modul, serta antarmuka **Flutter Web** berbasis *Clean Architecture* dengan kontrak API yang seragam dan terdokumentasi OpenAPI.
2. Mewujudkan mekanisme ***Multi-Tenancy* (`building_id`)** yang terintegrasi dengan ***Single Sign-On* (SSO) Keycloak OpenID Connect** dan verifikasi token *stateless* JWKS untuk menjamin keamanan serta isolasi data antar gedung.
3. Mengimplementasikan **proses bisnis sewa bulanan** (*Two-Phase Invoicing* dan penagihan otomatis) yang terintegrasi dengan pembayaran digital **Midtrans SNAP** bervalidasi *webhook* yang idempoten.
4. Membangun **satu modul mandiri `AI / MCP Assistant`** di dalam arsitektur *Modular Monolith* yang mampu melayani kueri data operasional pemilik/pengelola secara *read-only* dan mematuhi batas hak akses gedung.
5. Membuktikan keandalan dan kesesuaian rancangan sistem melalui **lima skenario evaluasi terukur**, meliputi pengujian *black-box* fungsional, pengujian kombinasi modul (*plug-and-play*), pengujian isolasi *multi-tenant*, pengujian idempotensi *webhook* Midtrans, serta pengujian akurasi dan keamanan *read-only* Modul AI.

---

## 1.5 Manfaat

Manfaat yang diharapkan dari Proyek Akhir ini terbagi menjadi dua kelompok pengguna:

### 1.5.1 Bagi Pemilik dan Pengelola Properti
1. **Kemudahan pemantauan terpusat:** Memudahkan pemantauan operasional banyak gedung kost melalui satu dasbor web.
2. **Percepatan pengambilan keputusan via Modul AI (`AI / MCP Assistant`):** Pemilik dan pengelola dapat menanyakan ringkasan okupansi, tagihan tertunggak, atau status komplain lewat percakapan bahasa alami tanpa membuka menu satu per satu.
3. **Otomasi finansial dan rekonsiliasi:** Mengurangi pencatatan manual dan kesalahan verifikasi pembayaran lewat penagihan berkala otomatis serta verifikasi Midtrans.

### 1.5.2 Bagi Penghuni
1. Memudahkan pemilihan kamar, reservasi unit tanpa risiko pemesanan ganda, serta pembayaran tagihan resmi lewat kanal digital.
2. Memberikan transparansi penanganan komplain fasilitas melalui tiket laporan kerusakan berlampiran foto.

---

## 1.6 Sistematika Penulisan

Sistematika pembahasan dalam laporan Proyek Akhir ini disusun sebagai berikut:

- **Bab 1 Pendahuluan**
  Menjelaskan latar belakang, permasalahan, batasan masalah, tujuan, manfaat, dan sistematika penulisan.
- **Bab 2 Kajian Pustaka**
  Menjelaskan deskripsi permasalahan sistem lama, teori penunjang, dan penelitian terkait yang mendukung Proyek Akhir.
- **Bab 3 Desain Sistem**
  Menjelaskan deskripsi solusi dan perancangan sistem yang diusulkan pada Proyek Akhir.
- **Bab 4 Eksperimen dan Analisis**
  Menjelaskan parameter eksperimen, karakteristik data, tempat dan waktu uji coba, spesifikasi peralatan, hasil eksperimen, serta analisis hasil.
- **Bab 5 Penutup**
  Berisi kesimpulan terhadap penelitian yang dilakukan dan saran untuk pengembangan selanjutnya.
