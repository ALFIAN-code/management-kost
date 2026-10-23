# BAB 1 — PENDAHULUAN

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[28]` terurut sesuai kemunculan pertama pada teks.

**Judul Proyek Akhir:**
*Arsitektur Modular Monolithic Berbasis Event-Driven untuk Sistem Informasi Manajemen Rumah Kost Terintegrasi.*

---

## 1.1 Latar Belakang Masalah

### 1.1.1 Urgensi Transformasi Digital Manajemen Rumah Kost Multi-Gedung

Kebutuhan hunian sewa sementara di kawasan perkotaan terus meningkat seiring pertambahan mahasiswa dan pekerja perantau [2]. Bisnis rumah kost berkembang dari sekadar usaha sampingan perseorangan menjadi sektor properti sewa mikro yang menuntut pengelolaan profesional [1]. Sebagian pemilik kini mengelola lebih dari satu gedung kost (*multi-building properties*) di lokasi yang berbeda untuk memperluas jangkauan pasar.

Pengelolaan properti multi-gedung tanpa sistem informasi terpusat memicu kendala operasional harian:
1. **Pencatatan Tercecer:** Data kamar, penghuni, dan riwayat pembayaran dicatat terpisah pada buku atau lembar sebar (*spreadsheet*). Pengelola kesulitan mengetahui unit mana yang kosong, siapa penghuni aktif, atau siapa yang menunggak pembayaran [1].
2. **Pemesanan Ganda (*Double Booking*):** Kesepakatan sewa yang dibuat lewat pesan instan sering memicu bentrok jadwal karena tidak ada mekanisme penguncian kamar terpusat saat transaksi berlangsung [3].
3. **Penagihan dan Rekonsiliasi Manual:** Bukti transfer bank diperiksa satu per satu secara manual. Proses ini memakan waktu, rawan terlewat, dan membuat pemilik kesulitan memantau arus kas nyata (*cash flow*) lintas properti [4].
4. **Penanganan Kerusakan Fasilitas Tidak Terpantau:** Keluhan kerusakan fasilitas disampaikan lewat obrolan lisan atau chat yang mudah tertimbun, sehingga perbaikan terlambat ditangani dan aset fisik cepat rusak [4].

Kondisi tersebut menuntut adanya Sistem Informasi Manajemen (SIM) berbasis web yang mampu memisahkan data tiap gedung secara aman, mengotomatiskan penerbitan tagihan dan verifikasi pembayaran digital, serta menampilkan ringkasan performa seluruh properti secara langsung kepada pemilik [1][4].

---

### 1.1.2 Telaah Kritis Empat Sistem Lama

Upaya awal digitalisasi pengelolaan rumah kost telah diinisiasi pada Juni 2025 melalui empat proposal proyek akhir yang terpisah [5][6][7][8]:

| No | Proposal / Domain | Peneliti & NRP | Fokus Awal |
|---|---|---|---|
| 1 | Manajemen Penghuni & Tamu | Rasyidatur (3123500039) | Profil penghuni, buku tamu, dan riwayat sewa [5]. |
| 2 | Kamar & Reservasi | Roihanah (3123500005) | Master kamar, ketersediaan unit, dan validasi bentrok [6]. |
| 3 | Keuangan & Transaksi | Rizal (3123500060) | Tagihan berkala, pembayaran Midtrans, dan rekap keuangan [7]. |
| 4 | Operasional & Pemeliharaan | Bagus (3123500031) | Tiket komplain kerusakan, inventaris kamar, dan jadwal servis [8]. |

Meskipun keempat proposal di atas mengusulkan penggunaan arsitektur modular, penelusuran mendalam terhadap kode sistem tersebut mengungkap sembilan kelemahan struktural yang nyata:

1. **Ketiadaan Dukungan Multi-Gedung (*Multi-Tenancy*):** Kode dan skema basis data lama hanya dirancang untuk satu gedung tunggal. Pemilik tidak bisa mengelola cabang properti baru tanpa memasang instalasi server dan basis data terpisah.
2. **Modularitas Semu (*Tight Coupling*):** Pembagian folder di backend Laravel mengandalkan pustaka pihak ketiga, namun pemisahan antar modul tidak benar-benar diterapkan. Service pada modul keuangan memanggil langsung model dari modul kamar, dan relasi *Foreign Key* fisik dipasang melintasi batas domain. Akibatnya modul tidak bisa dipisahkan atau diuji secara mandiri [9].
3. **Format Respons API Tidak Baku:** Struktur respons JSON antar-endpoint berbeda-beda. Inkonsistensi format status, data paginasi, dan pesan kesalahan validasi HTTP 422 menimbulkan kendala pada sisi antarmuka web.
4. **Struktur Frontend Tidak Terisolasi:** Lapisan penampil (BLoC) pada aplikasi Flutter mengakses repository secara langsung tanpa perantara *UseCase*. Logika bisnis bercampur dengan komponen antarmuka, sehingga kode sulit diuji lewat *unit test* [16].
5. **Ketiadaan Antarmuka Kueri Cepat Berbasis AI:** Pemilik dan pengelola harus memeriksa beberapa menu satu per satu secara manual untuk mengetahui tingkat keterisian kamar atau total tunggakan sewa. Belum ada antarmuka kueri berbasis *Model Context Protocol* (MCP) yang menghubungkan model kecerdasan buatan (*Large Language Model* / LLM) dengan basis data operasional secara terstandarisasi dan aman [21].
6. **Pengujian Terotomasi Belum Diterapkan:** Pengujian hanya mengandalkan pengecekan manual fungsional dasar tanpa adanya *unit test*, pengujian kontrak API, maupun pengujian integrasi terotomasi [22].
7. **Integrasi Pembayaran Belum Memenuhi Standar Produksi:** Pembayaran digital via Midtrans baru sebatas lingkungan uji coba (*sandbox*) tanpa mekanisme pencegah transaksi ganda (*idempotency key*) dan tanpa validasi tanda tangan kriptografis pada webhook [25].
8. **Mekanisme Autentikasi Masih Primitif:** Pengelolaan akun pada sistem lama hanya mengandalkan autentikasi dasar tanpa fitur keamanan standar industri. Sistem belum memiliki validasi email pengguna, mekanisme pemulihan akun atau lupa kata sandi (*forgot password*), serta alur manajemen sesi yang terstandarisasi, sehingga akun rentan dan pengembang terbebani membuat fitur autentikasi secara manual dari nol [19].
9. **Model Bisnis Bercabang dan Pembengkakan Basis Data:** Sistem lama mencoba melayani sewa harian, mingguan, bulanan, dan tahunan sekaligus, lengkap dengan skema uang muka (*down payment*) dan pengembalian dana (*refund*). Akibatnya, skema basis data membengkak hingga 41 tabel dengan banyak kolom mati, duplikasi data tagihan, dan tabel penampung sementara yang tidak diperlukan.

---


## 1.2 Rumusan Masalah

Berdasarkan latar belakang tersebut, rumusan masalah dalam Proyek Akhir ini adalah:
1. Bagaimana merancang dan menerapkan arsitektur **Modular Monolith pada NestJS** dengan sembilan modul terenkapsulasi, dan nol *Foreign Key* lintas modul?
2. Bagaimana membangun sistem **Multi-Tenant Row-Level Scoping** berbasis `building_id` agar data antar gedung terisolasi secara aman?
3. Bagaimana menerapkan **Clean Architecture pada Flutter** yang memisahkan logika bisnis dari antarmuka pengguna?
4. Bagaimana menyusun **standarisasi kontrak input-output API** dan dokumentasi interaktif berbasis Swagger?
5. Bagaimana merancang modul MCP Server yang hanya dapat membaca data, agar model *Artificial Intelligence* memperoleh jawaban operasional secara cepat tanpa melanggar batas hak akses gedung?
6. Bagaimana mengintegrasikan **Single Sign-On (SSO) berbasis Keycloak OpenID Connect (OIDC)** dengan verifikasi stateless JWKS pada backend NestJS dan pemetaan hak akses berbasis gedung?
7. Bagaimana menyederhanakan **proses bisnis sewa menjadi bulanan murni** dengan aturan minimal durasi sewa yang dapat diatur per gedung?
8. Bagaimana mengimplementasikan **pembayaran digital Midtrans siap produksi** dan memverifikasi keandalan sistem melalui pengujian perangkat lunak berlapis?
---

## 1.3 Tujuan Penelitian

Tujuan yang ingin dicapai melalui Proyek Akhir ini adalah:
1. Menghasilkan backend **Modular Monolith berbasis NestJS** yang memisahkan domain sistem ke dalam sembilan modul mandiri tanpa ketergantungan relasi fisik basis data.
2. Mewujudkan mekanisme **Multi-Tenancy** yang menjamin isolasi data antar gedung kost pada basis data bersama (*shared database*).
3. Mengembangkan antarmuka sistem berbasis **Flutter Web** dengan penerapan Clean Architecture yang terstruktur dan mudah dipelihara.
4. Menerapkan **kontrak API yang seragam dan type-safe** yang tersinkronisasi otomatis dengan dokumentasi OpenAPI.
5. Menyediakan modul *MCP Server* yang terhubung dengan model *Artificial Intelligence* agar pemilik dan pengelola memperoleh jawaban operasional secara instan.
6. Menerapkan sistem **Single Sign-On (SSO) berbasis Keycloak OpenID Connect** guna menyediakan autentikasi terpusat yang aman, menangani verifikasi email dan reset kata sandi secara otomatis, serta terintegrasi dengan pembatasan hak akses per gedung.
7. Menerapkan **skema basis data 13 tabel** untuk mengakomodasi sewa bulanan dan aturan fleksibel per gedung tanpa duplikasi data.
8. Membangun integrasi **Midtrans yang aman dan idempoten** serta membuktikan stabilitas sistem melalui pengujian berlapis dengan tingkat kelulusan yang terukur.

---

## 1.4 Batasan Masalah

Ruang lingkup dan batasan dalam penelitian Proyek Akhir ini mencakup:
1. **Lingkup Domain Sistem:** Sistem mencakup modul Pengguna (`Auth`), Gedung (`Building`), Kamar (`Room`), Kontrak Sewa (`Lease`), Keuangan (`Finance`), Komplain Kerusakan (`Maintenance`), Buku Tamu (`Guest`), Inventaris (`Inventory`), dan Notifikasi WhatsApp (`Notification`).
2. **Satuan dan Skema Sewa:** Sistem hanya melayani masa sewa dalam satuan **bulan penuh**. Batas minimal durasi sewa ditentukan per gedung melalui pengaturan sistem (`min_rental_months`). Pemesanan unit mendukung opsi pembayaran penuh bulan pertama maupun uang tanda jadi (*Down Payment* / DP flat) yang diatur per gedung melalui mekanisme *Two-Phase Invoicing*, serta pembatalan reservasi difasilitasi melalui pengajuan *refund* semi-manual berbukti transfer resmi. Skema sewa harian, mingguan, dan tahunan tidak didukung.
3. **Peran Pengguna (*Roles*):** Hak akses dibatasi untuk tiga kategori pengguna: Pemilik (*Owner* seluruh gedung), Pengelola (*Admin* yang ditugaskan pada gedung tertentu), dan Penghuni (*Resident* kamar aktif).
4. **Platform Antarmuka:** Pengujian fungsionalitas dan antarmuka difokuskan pada platform **Web (Flutter Web)** untuk peramban desktop dan tablet. Kode antarmuka dirancang dengan Clean Architecture agar siap dikompilasi ke aplikasi mobile pada masa mendatang, namun evaluasi kinerja aplikasi mobile fisik berada di luar ruang lingkup pengujian proyek akhir ini.
5. **Model Multi-Tenancy:** Pemisahan data multi-gedung menggunakan pendekatan *Shared Database with Row-Level Scoping* (`building_id`), bukan pemisahan basis data per gedung.
6. **Autentikasi dan Manajemen Identitas Pengguna:** Otentikasi terpusat dikelola oleh server Keycloak berbasis protokol OpenID Connect (OIDC). Backend NestJS bertindak sebagai *Resource Server* yang memvalidasi token JWT secara *stateless* melalui JWKS dan memetakan klaim token ke dalam peran sistem (*Owner*, *Admin*, *Resident*) beserta batas gedung (`building_id`).
7. **Batasan Asisten *Artificial Intelligence* (MCP):** Modul *MCP Server* hanya melakukan operasi baca (*read-only tool calls*) untuk menyuplai data faktual bagi model *Artificial Intelligence*. Model tersebut tidak diberi wewenang mengubah data operasional secara otomatis tanpa persetujuan pengguna (*human-in-the-loop*).
8. **Integrasi Eksternal:** Layanan pihak ketiga mencakup gerbang pembayaran Midtrans SNAP (Virtual Account dan QRIS) serta pengiriman notifikasi transaksi melalui WhatsApp Gateway (Fonnte/Open-WA).
9. **Metodologi Pengembangan:** Sistem dikembangkan menggunakan kerangka kerja Scrum dalam 4 siklus *sprint*.

---

## 1.5 Manfaat Penelitian

### 1.5.1 Manfaat Bagi Pemilik dan Pengelola Properti
- **Kemudahan Pemantauan Terpusat:** Mempermudah pemantauan operasional banyak gedung kost secara terpusat melalui satu portal dashboard web.
- **Akselerasi Pengambilan Keputusan via MCP dan LLM:** Integrasi *Model Context Protocol* (MCP) dengan model kecerdasan buatan (*Large Language Model* / LLM) mempercepat penarikan informasi operasional. Pemilik dan pengelola dapat menanyakan ringkasan okupansi, tagihan tertunggak, atau status komplain secara instan lewat percakapan bahasa alami tanpa harus membuka menu dan halaman sistem satu per satu.
- **Otomasi Finansial dan Rekonsiliasi:** Mengeliminasi pencatatan manual dan meminimalkan kesalahan verifikasi pembayaran melalui otomasi penagihan berkala dan verifikasi Midtrans.

### 1.5.2 Manfaat Bagi Penghuni
- Mempermudah pemilihan kamar, reservasi unit tanpa risiko pemesanan ganda, serta pembayaran tagihan resmi melalui saluran pembayaran digital.
- Memberikan transparansi penanganan komplain fasilitas melalui tiket laporan kerusakan berlampiran foto.

### 1.5.3 Manfaat Bagi Penulis dan Akademisi
- Memberikan studi empiris mengenai tahapan refaktorisasi arsitektur perangkat lunak dari sistem lama yang terfragmentasi menjadi Modular Monolith berbasis NestJS.
- Memberikan rujukan teknis mengenai reduksi kompleksitas basis data dari 41 tabel menjadi 13 tabel domain bersih tanpa mengorbankan fungsionalitas bisnis utama.

---

## 1.6 Sistematika Penulisan

Laporan Proyek Akhir ini disusun dalam lima bab:
- **BAB 1 PENDAHULUAN:** Berisi latar belakang masalah operasional kost multi-gedung, telaah kritis atas kelemahan sistem lama, rasionalisasi penulisan ulang ke NestJS 13 tabel, rumusan masalah, tujuan, batasan, manfaat, serta sistematika penulisan.
- **BAB 2 KAJIAN PUSTAKA:** Membahas landasan teori mengenai Sistem Informasi Manajemen Properti, arsitektur Modular Monolith pada ekosistem Node.js/NestJS, manajemen identitas Keycloak OIDC, protokol integrasi kecerdasan buatan Model Context Protocol (MCP), Clean Architecture pada Flutter Web, isolasi data Multi-Tenancy, integritas basis data relasional MySQL, integrasi gerbang pembayaran Midtrans, dan piramida pengujian perangkat lunak.
- **BAB 3 METODOLOGI DAN PERANCANGAN SISTEM:** Menguraikan metodologi Scrum (peran, siklus 4 sprint, backlog), perancangan arsitektur Modular Monolith 9 modul NestJS, pemodelan proses bisnis (BPMN), use case, Data Flow Diagram (DFD), perancangan 13 tabel basis data beserta kamus data lengkap, alur otentikasi Keycloak OIDC via JWKS, spesifikasi teknis tool server MCP, rancangan antarmuka Flutter Web, spesifikasi kontrak REST API, dan skenario pengujian.
- **BAB 4 IMPLEMENTASI DAN EVALUASI:** Mendokumentasikan implementasi backend NestJS, integrasi Keycloak OIDC, integrasi modul server MCP, frontend Flutter Web, integrasi Midtrans dan WhatsApp, serta menyajikan hasil pengujian sistem (*unit test*, *contract test*, *tenant isolation test*, dan *integration test*).
- **BAB 5 PENUTUP:** Menyajikan kesimpulan atas hasil refaktorisasi sistem dan pencapaian tujuan penelitian, serta memaparkan saran pengembangan untuk penambahan fitur pada masa mendatang.
