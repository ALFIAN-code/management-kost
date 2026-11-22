# BAB 2 — KAJIAN PUSTAKA

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[28]` terurut sesuai kemunculan pertama pada teks.

Bab ini menguraikan rincian permasalahan pada sistem manajemen rumah kost yang telah dikembangkan sebelumnya, dilanjutkan dengan teori-teori penunjang yang menjadi landasan perancangan ulang arsitektur, serta ulasan penelitian terkait untuk mempertegas posisi dan kebaruan Proyek Akhir ini.

---

## 2.1 Deskripsi Permasalahan

Penelitian ini berfokus pada perancangan ulang (*refactoring* / *rewrite*) sistem informasi manajemen rumah kost yang sebelumnya diinisiasi pada Juni 2025 sebagai *previous work* melalui empat proyek akhir terpisah [5][6][7][8]. Pembagian ruang lingkup keempat sistem lama tersebut dirangkum pada Tabel 2.1.

**Tabel 2.1 : Penelitian Sistem Lama**

| No | Proposal / Domain | Peneliti & NRP | Fokus Awal |
|---|---|---|---|
| 1 | Manajemen Penghuni & Tamu | Rasyidatur (3123500039) | Profil penghuni, buku tamu, dan riwayat sewa [5]. |
| 2 | Kamar & Reservasi | Roihanah (3123500005) | Master kamar, ketersediaan unit, dan validasi bentrok [6]. |
| 3 | Keuangan & Transaksi | Rizal (3123500060) | Tagihan berkala, pembayaran Midtrans, dan rekap keuangan [7]. |
| 4 | Operasional & Pemeliharaan | Bagus (3123500031) | Tiket komplain kerusakan, inventaris kamar, dan jadwal servis [8]. |

### 2.1.1 Temuan Kelemahan Struktural Sistem Lama

Meskipun keempat proposal di atas mengusulkan arsitektur modular, penelusuran langsung terhadap kode dan skema basis data sistem lama mengungkap delapan kelemahan struktural yang menjadi dasar perancangan solusi pada Bab III:

1. **Modularitas Semu dan *Tight Coupling* Antar-Domain:**
   Sistem lama membagi domain Penghuni, Kamar, Keuangan, dan Operasional ke dalam folder modul Laravel menggunakan pustaka pihak ketiga, namun pemisahan tersebut tidak ditegakkan oleh kerangka kerja [9]. *Service* pada modul keuangan memanggil langsung model milik modul kamar, dan relasi *Foreign Key* fisik dipasang melintasi batas domain. Akibatnya, perubahan di satu modul berisiko merusak modul lain, dan tidak ada modul yang dapat dipisahkan atau diuji secara mandiri [9].
2. **Model Bisnis Bercabang dan Pembengkakan Basis Data (34 Tabel Domain):**
   Skema basis data sistem lama mencoba melayani varian sewa harian, mingguan, bulanan, dan tahunan sekaligus, lengkap dengan skema uang muka (*down payment*) dan pengembalian dana (*refund*). Model tersebut membuat skema domain membengkak hingga **34 tabel domain dan RBAC** (serta lebih dari 42 tabel secara keseluruhan di basis data aktual termasuk tabel infrastruktur bawaan *framework*) dengan banyak duplikasi struktur (dua mekanisme penerbitan tagihan antara `invoices` dan `guest_bills`, dua tabel *cache* penghuni aktif antara `finance_active_tenants` dan `guest_active_contexts`, serta tabel gemuk `room_schedules` yang mencampur biodata penghuni dengan jadwal sewa) [6][7]. Pelacakan riwayat transaksi dan pemeliharaan skema pun menjadi rumit [7][8].
3. **Ketiadaan Dukungan Multi-Gedung (*Multi-Tenancy*):**
   Kode dan skema basis data dirancang hanya untuk satu gedung fisik. Ketika pemilik menambah cabang properti baru, tidak ada mekanisme pemisahan data penyewa (*tenant isolation*), sehingga pengembang terpaksa memasang instalasi server dan basis data terpisah untuk tiap gedung. Biaya pemeliharaan ikut berlipat dan laporan keuangan gabungan seluruh properti sulit disusun [18].
4. **Kontrak Respons API Tidak Baku dan Hak Akses Belum Dinamis:**
   Setiap *endpoint* REST mengembalikan struktur JSON yang berbeda-beda pada format `status`, paginasi, dan pesan kesalahan validasi HTTP 422, sehingga sisi antarmuka web harus menangani setiap kasus secara terpisah [18]. Di sisi otorisasi, hak akses pengguna masih ditanam kaku di dalam kode (*hardcoded*) dan belum dibatasi per gedung, sehingga pengelola satu gedung dapat melihat atau mengubah data gedung lain dan pemilik tidak leluasa mengatur izin staf sesuai tugas lapangan [5][6][16].
5. **Mekanisme Autentikasi Masih Primitif:**
   Pengelolaan akun hanya memakai autentikasi dasar berupa kombinasi email dan kata sandi. Belum tersedia validasi email saat pendaftaran, pemulihan lupa kata sandi (*forgot password*), pengaturan masa berlaku sesi terstandarisasi, maupun autentikasi dua faktor (*multi-factor authentication*). Selain berisiko terhadap kebocoran akun, waktu pengembangan juga habis terserap untuk membangun fitur autentikasi standar dari nol [5][6][19].
6. **Struktur Antarmuka (*Frontend*) Tidak Terisolasi:**
   Lapisan presentasi (BLoC) pada aplikasi Flutter lama mengakses *repository* secara langsung tanpa perantara *UseCase*. Logika bisnis bercampur dengan komponen antarmuka, sehingga sulit diuji melalui *unit test* [16].
7. **Integrasi Pembayaran Belum Memenuhi Standar Produksi:**
   Pembayaran digital via Midtrans baru berjalan di lingkungan uji coba (*sandbox*) tanpa pencegahan transaksi ganda (*idempotency key*) dan tanpa verifikasi tanda tangan kriptografis pada *webhook* [25].
8. **Ketiadaan Antarmuka Kueri Cepat Berbasis AI:**
   Untuk mengetahui tingkat keterisian kamar atau total tunggakan sewa, pemilik dan pengelola harus membuka beberapa menu satu per satu secara manual. Sistem lama belum menyediakan antarmuka kueri berbasis *Model Context Protocol* (MCP) yang menghubungkan model kecerdasan buatan (*Large Language Model* / LLM) dengan data operasional secara aman [21].

### 2.1.2 Evolusi Desain Sistem Sebelum *Rewrite*

Bagian ini menyajikan dua artefak desain sistem sebelum *rewrite* (*before*) agar pembaca melihat konteks di balik keputusan arsitektur baru (*after*) yang dirancang pada Subbab 3.2 dan Subbab 3.6 di Bab III.

#### 1. Arsitektur Sebelum *Rewrite* (Sistem Lama)

Sistem lama merupakan gabungan dari **4 proyek akhir terpisah** yang diimplementasikan menggunakan Laravel dan basis data MySQL dengan pembagian **8 kelompok modul** (`Auth/RBAC`, `Room`, `Schedule`, `Finance`, `Guest`, `Maintenance`, `Setting`, dan `Inventory/Notification`), namun pemisahannya hanya sebatas struktur folder dan tidak ditegakkan kerangka kerja. Modul keuangan masih bisa memanggil langsung model milik modul kamar, dan relasi *Foreign Key* fisik dipasang melintasi batas domain. Seluruh komponen berjalan dalam satu aplikasi monolitik tanpa batas isolasi teknis dan satu basis data MySQL, seperti ditunjukkan pada Gambar 2.1. Hasil perombakannya menjadi **1 arsitektur *Modular Monolith* berbasis NestJS berisi 10 modul terenkapsulasi (4 modul *core* dan 6 modul *opsional*, termasuk Modul `AI / MCP Assistant`)** disajikan pada Subbab 3.2 (Gambar 3.1 dan Gambar 3.2) di Bab III.

> **Gambar 2.1 — Arsitektur Keseluruhan Sistem Sebelum Rewrite:** `PA/docs/System design/08-design-lama/desain_sistem-1. Arsitektur Keseluruhan.drawio.png`

#### 2. Basis Data Sebelum *Rewrite* (ERD Sistem Lama)

Karena dirancang untuk mendukung sewa harian, mingguan, bulanan, dan tahunan sekaligus beserta cabang skema *down payment* dan *refund*, basis data domain sistem lama membengkak hingga **34 tabel domain dan RBAC** dengan berbagai duplikasi tabel turunan serta relasi *Foreign Key* fisik lintas modul. Struktur ERD sistem lama ditunjukkan pada Gambar 2.2. Penyederhanaan skema 34 tabel ini menjadi rancangan basis data baru yang ramping (**21 tabel domain utama**), bebas duplikasi, dan tanpa *Foreign Key* lintas modul dibahas rinci pada Subbab 3.6.1 (Gambar 3.18) di Bab III.

> **Gambar 2.2 — Entity Relationship Diagram Sistem Sebelum Rewrite:** `PA/docs/System design/08-design-lama/erd_sistem_lama.png`

Perbedaan struktural antara sistem lama (*existing system*) dan sistem baru yang diusulkan dirangkum pada Tabel 2.2.

#### Tabel 2.2 : Perbandingan Sistem Lama (*Existing System*) dan Sistem Baru

| Aspek Perbandingan | Sistem Lama (*Existing System*) | Sistem Baru (Usulan Proyek Akhir) |
|---|---|---|
| **Jumlah & Struktur Modul** | **4 proyek akhir terpisah** (implementasi gabungan **8 kelompok modul** hanya sebatas folder tanpa isolasi teknis) | **1 backend *Modular Monolithic* NestJS** berisi **10 modul terenkapsulasi** (**4 *Core* + 6 *Opsional***) |
| **Komunikasi Antar-Modul** | Pemanggilan langsung model lintas modul & *Foreign Key* fisik lintas domain | Terisolasi via ***Module Gateway*** dan ***Event Bus*** tanpa *Foreign Key* fisik lintas modul |
| **Skema Basis Data** | **34 tabel domain & RBAC** (42+ tabel aktual termasuk tabel infrastruktur), terdapat tabel gemuk & duplikasi *cache* aktif | **21 tabel domain utama**, ramping, terisolasi per modul, dan bebas duplikasi |
| **Dukungan Multi-Gedung** | *Single-tenant* (1 gedung per instalasi server/basis data) | ***Multi-Tenant Row-Level Scoping*** (`building_id`) dalam 1 basis data terpadu |
| **Autentikasi & Otorisasi** | Email dan kata sandi dasar tanpa verifikasi email/SSO | ***Single Sign-On* (SSO) Keycloak OIDC**, verifikasi *stateless* JWKS, dan RBAC dinamis |
| **Integrasi Pembayaran** | Midtrans *sandbox* tanpa *idempotency key* & verifikasi *webhook* | Midtrans SNAP siap produksi dengan *idempotency key* dan verifikasi *signature webhook* |
| **Dukungan Asisten AI** | Belum tersedia | **1 Modul Mandiri `AI / MCP Assistant`** berbasis *Model Context Protocol* (*read-only*) |

---

## 2.2 Teori Penunjang

### 2.2.1 Sistem Informasi Manajemen

Sistem Informasi Manajemen (SIM) adalah sistem berbasis komputer yang mengumpulkan, menyimpan, mengolah, dan menyajikan data agar dapat dipakai sebagai dasar pengambilan keputusan dalam sebuah organisasi [1]. Secara sederhana, SIM mengubah data mentah menjadi informasi yang berguna, lalu informasi itu dipakai untuk perencanaan, pengendalian, dan evaluasi kinerja.

Pada industri properti sewa, SIM menjalankan tiga fungsi yang saling terkait. Pertama, mencatat kondisi fisik properti seperti unit kamar, fasilitas, dan barang di dalamnya. Kedua, merekam seluruh transaksi sewa dari awal kontrak sampai pembayaran terakhir. Ketiga, menyusun laporan keuangan yang bisa dipercaya pemilik sebagai dasar mengambil keputusan.

PA ini memakai konsep SIM sebagai kerangka dasar karena ketiga fungsi tersebut tercakup di dalam sistem yang dibangun. Yang membedakan sistem ini dari sistem lama adalah letak otomasi. Pada sistem lama, laporan okupansi dan tunggakan harus dihimpun manual dengan membuka beberapa menu satu per satu. Pada sistem yang dirancang, data sudah tersusun begitu masuk sehingga laporan terbentuk otomatis dan tidak perlu diketik ulang.

---

### 2.2.2 Arsitektur Modular Monolithic

Arsitektur modular monolithic membangun aplikasi sebagai satu kesatuan utuh, tetapi membaginya ke dalam modul-modul yang masing-masing punya tanggung jawab dan tidak saling bergantung langsung [9]. Bedanya dengan monolitik konvensional terletak pada pemisahan antar modul. Pada monolitik biasa, pemisahan hanya berupa struktur folder, sehingga service di satu bagian tetap bisa memanggil bagian lain tanpa batasan. Pada modular monolithic, pemisahan antar modul ditegakkan dan komunikasi antar modul harus lewat kontrak yang disepakati.

Prinsip batas tersebut diambil dari konsep *bounded context* dalam Domain-Driven Design, yang dipakai untuk menentukan di mana sebuah modul harus berakhir [10]. Setiap modul diperlakukan sebagai satu bagian bisnis dengan aturan main sendiri. Modul keuangan misalnya punya aturan penghitungannya sendiri, dan modul kamar punya aturan tentang ketersediaan unit. Keduanya tidak boleh saling membaca data secara langsung, melainkan berkomunikasi lewat kontrak yang telah ditentukan.

PA ini memakai pendekatan ini karena alasan utamanya adalah kemudahan waktu depan. Ketika bisnis berkembang dan muncul kebutuhan baru, misalnya perlu menambah modul laporan keuangan atau modul pengarsipan dokumen, penambahan tersebut cukup dilakukan dengan membuat modul terpisah dan mendaftarkannya, tanpa mengubah modul yang sudah berjalan. Sebaliknya, ketika ada modul yang tidak lagi dibutuhkan, modul itu bisa dihapus beserta seluruh isinya tanpa meninggalkan jejak di modul lain.

Kemudahan inilah yang tidak dimiliki sistem lama. Folder modulnya memang ada, tetapi karena batasnya tidak ditegakkan, modul keuangan tetap bisa membaca tabel modul kamar. Akibatnya tidak ada satu pun bagian yang bisa dilepas atau diuji sendiri tanpa melibatkan modul lain. Batas yang benar-benar dipaksakan oleh kerangka kerja membuat penambahan dan penghapusan modul menjadi pekerjaan yang biasa, bukan proses yang perlu dikhawatirkan.

> **Gambar 2.3 — Arsitektur Modular Monolithic:** `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.png`

---

### 2.2.3 NestJS

NestJS adalah kerangka kerja backend berbasis Node.js dan TypeScript yang dirancang untuk membangun aplikasi server dengan struktur modular [13]. Berbeda dari framework konvensional yang mengharuskan pengembang membuat struktur folder sendiri, NestJS menyediakan pemisahan antar modul sebagai bagian dari kerangka kerjanya. Setiap unit kerja dibungkus dekorator `@Module()` yang menentukan layanan mana yang boleh diekspor ke modul lain dan mana yang disembunyikan di dalam modul tersebut.

Dua mekanisme membuat hal itu bekerja. Pertama, *encapsulation*. Layanan yang tidak didaftarkan pada daftar `exports` tidak akan pernah bisa disuntik oleh modul lain, meskipun keduanya berada di repositori yang sama. Kedua, *dependency injection*. Setiap kelas menerima dependensinya dari wadah aplikasi, bukan membuatnya sendiri, sehingga mudah diganti dengan tiruan saat pengujian. Selain itu, NestJS dibangun di atas Node.js yang bekerja dengan model I/O non-blocking, sehingga permintaan yang menunggu jawaban dari layanan luar tidak menahan proses lain.

PA ini memilih NestJS karena pemisahan antar modul ditegakkan oleh kerangka kerjanya sendiri, bukan oleh disiplin tim. Ketika modul keuangan mencoba menulis kueri ke tabel milik modul kamar, kode itu akan gagal sejak tahap build, bukan baru ketahuan saat pengujian. Pengalaman sistem lama menunjukkan bahwa pemisahan yang hanya dijaga lewat aturan tertulis akan cepat dilanggar ketika waktu pengembangan sedang menekan. Dengan NestJS, pelanggaran aturan menjadi kesalahan teknis, bukan pilihan penyusun kode.

> **Gambar 2.4 — Struktur Modul dan Dependency Injection pada NestJS:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_3_nestjs_modul_di.png`

---

### 2.2.4 Flutter

Flutter adalah kerangka kerja antarmuka lintas platform yang dikembangkan oleh Google dengan bahasa pemrograman Dart [15]. Semua tampilan pada aplikasi disusun dari komponen yang namanya *widget*. Satu basis kode yang sama dapat dikompilasi menjadi aplikasi web, aplikasi Android, maupun aplikasi iOS, tanpa menulis ulang lapisan tampilannya. Karena itu Flutter disebut multi-platform, sebab satu proyek dapat dipakai untuk beberapa perangkat sekaligus.

PA ini memakai Flutter dengan target utama berupa aplikasi web. Alasan memilih lingkungan web adalah lingkup penggunaan sistem: pengoperasian harian dilakukan dari komputer atau tablet di ruang pengelola, sehingga tampilan lebar lebih sesuai. Arsitektur yang dipakai juga memperjelas alasan itu. Karena logika bisnis disimpan di lapisan domain yang murni Dart tanpa bergantung pada sistem operasi maupun peramban, lapisan tersebut tetap bisa dipakai ulang ketika aplikasi dikompilasi untuk perangkat mobile di kemudian hari. Jadi kesiapan ekspansi ke mobile muncul sebagai hasil dari struktur kode, bukan sebagai target tambahan yang harus dirancang terpisah.

---

### 2.2.5 Clean Architecture

Clean Architecture adalah pola arsitektur yang memisahkan program menjadi lapisan-lapisan dengan aturan ketergantungan satu arah [16]. Lapisan paling dalam berisi entitas dan aturan bisnis yang murni, lapisan tengah berisi use case, dan lapisan luar menangani presentasi serta akses data. Aturan utamanya sederhana: lapisan dalam tidak boleh mengenal keberadaan lapisan luar.

Pada aplikasi Flutter, pemisahan ini menjawab satu masalah yang sering muncul. Kode pada lapisan tampilan biasanya mengambil data langsung dari repository, sehingga logika bisnis ikut bercampur dengan komponen antarmuka. Akibatnya, menguji sebuah aturan bisnis berarti menyalakan seluruh tampilan beserta koneksi jaringan. Dengan Clean Architecture, aturan bisnis berdiri sendiri tanpa framework apa pun, sehingga bisa diuji dalam hitungan milidetik.

PA ini memakai Clean Architecture pada sisi antarmuka karena pemisahan tersebut memudahkan dua hal. Pertama, pengujian: setiap lapisan punya fokus yang jelas, sehingga aturan bisnis dapat diuji tanpa lapisan lain, dan pengujian antarmuka cukup memeriksa pemetaan state ke tampilan. Kedua, perubahan pada bagian tertentu tidak menimpa bagian lain. Contohnya, apabila format jawaban API berubah, cukup ubah lapisan data; lapisan domain dan lapisan presentasi tidak perlu disentuh karena keduanya tidak tahu bentuk data mentah.

> **Gambar 2.5 — Penerapan Clean Architecture pada Aplikasi Flutter:** `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/c4_level3_flutter_clean_architecture.png`

---

### 2.2.6 BLoC (Business Logic Component)

BLoC adalah pola pengelolaan *state* pada Flutter yang memisahkan pemicu perubahan state dari proses perubahannya [15]. Alurnya sederhana: widget mengirim *event*, *bloc* yang menerima event itu memanggil use case, lalu *bloc* memancarkan *state* baru dalam bentuk objek yang tidak bisa diubah setelah dibuat.

Pola ini membuat aliran data pada antarmuka berjalan satu arah dan mudah dilacak. Urutannya dapat dibaca langsung dari kode: dari widget, ke event, ke use case, ke state, lalu kembali ke widget. Berbeda dengan pemanggilan `setState` yang menyatukan pemicu dan perubahan di dalam satu widget, BLoC memisahkannya sehingga transisi state bisa diuji tanpa menampilkan antarmuka sama sekali.

PA ini memakai BLoC karena pola ini sebenarnya memaksa struktur kode menjadi tertata. BLoC hanya bekerja jika logika bisnis berada di use case terpisah dari widget yang memunculkannya. Umumnya, pengembang yang langsung memuat data dan memprosesnya di dalam widget akan membuat pola ini mustahil diterapkan. Dengan BLoC, pemisahan antara logika bisnis dan tampilan bukan lagi pilihan disiplin, melainkan syarat agar pola tersebut berjalan.

> **Gambar 2.6 — Alur Pengelolaan State Menggunakan Pola BLoC:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_4_bloc_flow.png`

---

### 2.2.7 PostgreSQL

PostgreSQL adalah sistem manajemen basis data relasional *open-source* yang dikenal konsisten dengan standar SQL, mendukung transaksi dengan integritas tinggi, dan menyediakan penanganan konkurensi yang matang [17]. Yang membedakannya dari basis data relasional lain terletak pada tiga hal yang dipakai langsung pada sistem ini.

Pertama, tipe numerik `NUMERIC` dipakai untuk seluruh nilai uang. Tipe ini menyimpan angka desimal secara tepat, sehingga penjumlahan tagihan tidak pernah menghasilkan selisih satu rupiah akibat pembulatan. Kedua, tipe `JSONB` dipakai untuk menyimpan payload *event* dan parameter *tool* MCP, sekaligus memudahkan pencarian di dalam struktur tersebut. Ketiga, PostgreSQL menyediakan penguncian baris dengan `SELECT ... FOR UPDATE`, yaitu mengunci baris yang sedang dibaca selama transaksi masih berjalan.

Mekanisme penguncian itulah yang dipakai untuk mencegah dua orang memesan kamar yang sama pada saat bersamaan. Saat permintaan sewa masuk, baris kamar dikunci lebih dulu, lalu diperiksa apakah sudah ada kontrak aktif di periode tersebut. Kalau belum ada, kontrak disimpan di dalam transaksi yang sama; kalau sudah ada, transaksi dibatalkan dan permintaan kedua ditolak. Selama penguncian masih aktif, permintaan lain untuk kamar yang sama harus mengantre. Inilah yang membuat pemesanan ganda tidak mungkin terjadi meski beberapa orang menekan tombol sewa pada milidetik yang sama.

---

### 2.2.8 Multi-Tenancy dengan Row-Level Scoping

Dalam pengembangan aplikasi berbasis *SaaS* (*Software as a Service*) untuk properti multi-gedung, pemilihan model *multi-tenancy* menentukan bagaimana data antar-gedung (*tenant*) diisolasi dalam satu ekosistem *backend*. Secara arsitektur, terdapat dua pendekatan utama dalam menangani pemisahan data ini: *Database-Level Isolation* (pemisahan database fisik per gedung) dan *Application-Level Isolation* melalui *Shared Database with Row-Level Scoping*.

Pendekatan pertama memberikan isolasi tingkat tinggi, namun tidak efisien secara operasional karena setiap penambahan gedung baru menuntut migrasi skema terpisah dan membebani pengelolaan koneksi basis data. Oleh karena itu, Proyek Akhir ini menerapkan model **Shared Database dengan Row-Level Scoping** berbasis kolom penanda `building_id`.

1. **Efisiensi Migrasi Skema:** Perubahan struktur tabel atau pembaruan migrasi basis data cukup dieksekusi sekali secara global tanpa perlu mengulang skrip migrasi per database gedung.
2. **Optimalisasi Agregasi Portofolio:** Pemilik properti membutuhkan laporan keuangan dan tingkat okupansi lintas gedung secara *real-time*. Dengan basis data bersama, laporan gabungan dapat ditarik menggunakan kueri agregasi tunggal tanpa mekanisme *distributed join*.
3. **Integritas di Lapisan Aplikasi:** Isolasi data ditegakkan secara ketat melalui penambahan filter `building_id` secara otomatis pada setiap kueri ORM di tingkat *backend* NestJS, yang dipetakan langsung dari klaim token akses JWT pengguna.

> **Gambar 2.7 — Pendekatan Multi-Tenancy Shared Database dengan Row-Level Scoping:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_8_row_level_scoping.png`

---

### 2.2.9 Single Sign-On, OpenID Connect, dan Keycloak

Single Sign-On (SSO) adalah mekanisme yang memungkinkan pengguna cukup sekali masuk untuk mengakses beberapa aplikasi sekaligus, tanpa mengulang kredensial di setiap aplikasi [19]. Pada sistem yang punya banyak modul atau banyak aplikasi terpisah, mekanisme ini menghemat waktu pengguna sekaligus mengurangi jumlah kata sandi yang harus dikelola.

OpenID Connect (OIDC) adalah standar yang mengatur lapisan identitas di atas OAuth 2.0. Bedanya, OAuth 2.0 hanya mengatur pendelegasian hak akses, sedangkan OIDC menambahkan identitas: setelah pengguna berhasil masuk, aplikasi menerima *token* berisi informasi siapa penggunanya. Token tersebut berbentuk JWT dan ditandatangani secara digital, sehingga pihak lain bisa memastikan token itu benar berasal dari penyedia identitas dan belum kedaluwarsa. Karena tanda tangannya dapat diperiksa tanpa menghubungi server pengeluar token, proses verifikasi bisa dijalankan secara lokal dan cepat.

Keycloak adalah *identity and access management* open-source yang mendukung OIDC, SSO, dan pengelolaan peran [20]. Yang sering tidak dikerjakan sendiri oleh aplikasi adalah justru hal-hal standar ini: verifikasi email saat pendaftaran, pemulihan kata sandi ketika pengguna lupa, masa berlaku sesi, dan pencatatan aktivitas login. Pada sistem lama seluruh itu harus dibuat satu per satu, dan bagian yang paling sering tertinggal justru yang paling penting, yaitu pemulihan akun.

PA ini memakai Keycloak karena tiga alasan. Pertama, fitur keamanan yang dibutuhkan sudah tersedia sehingga waktu pengembangan bisa dipakai untuk aturan bisnis sewa. Kedua, peran pengguna seperti pemilik, pengelola, dan penghuni cukup diatur di satu tempat, lalu diteruskan ke backend lewat isi token. Ketiga, backend cukup memverifikasi tanda tangan token tanpa perlu menghubungi Keycloak pada setiap permintaan, sehingga waktu tanggap tidak bertambah. Perlu dicatat bahwa Keycloak menambah satu layanan yang harus dijalankan dan dipelihara, dan pembagian peran harus disusun di Keycloak dengan cermat supaya tetap sinkron dengan aturan pada sistem.

> **Gambar 2.8 — Alur Autentikasi SSO Berbasis OpenID Connect dengan Keycloak:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_9_oidc_jwks.png`

---

### 2.2.10 Docker dan Docker Compose

Docker adalah platform *containerization* yang membungkus aplikasi beserta seluruh dependensinya ke dalam satu unit bernama *image* [23]. Image ini berisi semua yang diperlukan untuk menjalankan aplikasi: kode, pustaka, konfigurasi, sampai sistem operasi dasar. Karena isinya lengkap dan tidak bergantung pada isi mesin, aplikasi yang berjalan di laptop pengembang akan berjalan sama persis di server.

Perbedaan utama Docker dengan cara lama adalah pemisahan antara apa yang ada di kode dan apa yang ada di komputer. Pada pendekatan lama, setiap orang memasang PostgreSQL dan Keycloak dengan versi masing-masing, dan versi yang berbeda sering menyebabkan program berjalan di satu komputer tetapi gagal di komputer lain. Dengan Docker, versi PostgreSQL dan Keycloak dituliskan di satu berkas konfigurasi, lalu dijalankan apa adanya di mana saja.

Docker Compose adalah kelanjutannya. Compose membaca satu berkas yang menjelaskan beberapa container sekaligus, lalu menjalankan semuanya dengan satu perintah. PA ini punya tiga komponen yang harus jalan bersamaan: backend NestJS, basis data PostgreSQL, dan Keycloak. Compose dipakai agar ketiganya bisa dijalankan, dihentikan, dan dibuild ulang tanpa langkah manual yang berbeda-beda.

---

### 2.2.11 Midtrans SNAP

Midtrans adalah penyedia layanan gerbang pembayaran yang menghubungkan aplikasi dengan jaringan pembayaran bank dan dompet digital. Midtrans SNAP merupakan layanan andalannya: SNAP menyediakan antarmuka pembayaran siap pakai dalam bentuk *pop-up*, sehingga penghuni tidak perlu meninggalkan aplikasi untuk menyelesaikan transaksi [25]. SNAP mendukung kanal Virtual Account, QRIS, dan dompet digital.

Integrasi berjalan dua arah. Dari sisi sistem, backend meminta token pembayaran lalu meneruskannya ke antarmuka SNAP, dan penghuni menyelesaikan pembayaran di sana. Dari sisi Midtrans, setiap kali status pembayaran berubah, Midtrans mengirim *webhook* ke alamat yang didaftarkan. Di sinilah bagian yang perlu diperhatikan berada: *webhook* adalah permintaan yang masuk dari luar, sehingga harus diperiksa sebelum dipercayai.

Ada dua perlindungan yang dipakai pada sistem ini. Yang pertama, penomoran pesanan. Setiap permintaan pembayaran diberi nomor unik, sehingga ketika gangguan jaringan memicu pengiriman ulang permintaan, Midtrans mengenali bahwa itu transaksi yang sama dan tidak membuat tagihan ganda. Yang kedua, verifikasi tanda tangan. Setiap *webhook* disertai tanda tangan yang dihitung dari nomor pesanan, kode status, jumlah pembayaran, dan kunci rahasia. Backend menghitung ulang tanda tangan itu; kalau tidak cocok, permintaan ditolak dan status tagihan tidak diubah. Tanpa dua perlindungan ini, siapa pun yang mengetahui alamat *webhook* bisa memalsukan pembayaran.

> **Gambar 2.9 — Alur Transaksi dan Pembayaran Digital via Midtrans SNAP:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_11_midtrans_webhook.png`

---

### 2.2.12 Standar Kontrak Input-Output REST API

REST API adalah gaya komunikasi yang paling umum dipakai antaraplikasi web. Yang dikirim berupa permintaan HTTP, dan jawabannya berupa *response* dengan kode status yang menyatakan berhasil atau gagal. Kelemahannya, pengembang kerap membuat format respons secara bebas, sehingga struktur antar-endpoint menjadi tidak konsisten. Hal ini membebani lapisan antarmuka (*frontend*) karena harus menangani berbagai pola respons dan pesan galat yang bervariasi secara redundan.

Untuk mengatasi permasalahan tersebut, sistem ini menerapkan standar kontrak input-output yang tersentralisasi melalui *uniform response envelope*. Setiap *endpoint* diatur agar selalu mengembalikan respons dengan lima kunci utama yang seragam: `status` (menunjukkan status berhasil/gagal), `message` (keterangan yang dapat dibaca manusia), `data` (isi *payload* utama), `meta` (informasi tambahan seperti penomoran halaman), dan `errors` (rincian kesalahan validasi yang mengacu pada standar *Problem Details*).

Sebagai perbandingan langsung, berikut adalah kontras antara format respons sistem lama yang tidak terstandarisasi dengan format baru yang diterapkan pada kasus pembuatan kontrak sewa (*Create Lease*):

1. **Contoh Respons Gagal (*Error* / Gagal Validasi):**
   - *Format Lama (Tidak Standar):* Setiap *endpoint* mengembalikan struktur yang berbeda-beda dan tidak spesifik pada kolom input yang bermasalah.

     ```json
     {
       "success": false,
       "error_message": "Durasi kurang dari minimal gedung dan kamar sudah terisi."
     }
     ```

   - *Format Baru (Sistem Ini - Standar Problem Details):* Mengembalikan rincian *field* yang mengalami kesalahan validasi (kode HTTP 422) sehingga aplikasi Flutter dapat langsung memetakannya ke masing-masing kolom form input secara presisi.

     ```json
     {
       "status": false,
       "message": "Validasi masukan gagal",
       "errors": {
         "duration_months": [
           "Durasi sewa minimal untuk gedung ini adalah 3 bulan."
         ],
         "room_id": [
           "Kamar sedang disewa atau tidak tersedia pada periode tersebut."
         ]
       }
     }
     ```

2. **Contoh Respons Berhasil (*Success*):**
   - *Format Lama (Tidak Standar):* Properti data yang dikembalikan tidak konsisten (kadang menggunakan `camelCase` atau `snake_case` secara acak) dan seringkali hanya mengembalikan ID tanpa rincian objek.

     ```json
     {
       "code": 200,
       "msg": "OK",
       "data": 12
     }
     ```

   - *Format Baru (Sistem Ini):* Mengembalikan struktur objek data secara lengkap, konsisten, dan menggunakan kode HTTP 201 (*Created*) untuk data baru.

     ```json
     {
       "status": true,
       "message": "Kontrak sewa berhasil dibuat",
       "data": {
         "lease_id": 12,
         "room_number": "A-02",
         "duration_months": 3,
         "total_amount": 2550000,
         "status": "pending"
       }
     }
     ```

Kode status yang dipakai pada sistem ini mengikuti ketetapan umum HTTP:
- **Kode 200 dan 201:** Permintaan berhasil diproses atau data baru berhasil dibuat.
- **Kode 400:** Permintaan tidak sesuai format (*bad request*).
- **Kode 401:** Token autentikasi tidak tersedia atau sudah kedaluwarsa (*unauthorized*).
- **Kode 403:** Pengguna tidak memiliki hak akses (*forbidden*) terhadap data gedung tersebut.
- **Kode 404:** Data yang diminta tidak ditemukan (*not found*).
- **Kode 422:** Masukan data melanggar aturan bisnis (*unprocessable entity*), misalnya durasi sewa di bawah batas minimum gedung.

Dengan seluruh kemungkinan respons yang mengikuti pola amplop seragam ini, sisi antarmuka (*frontend* Flutter Web) cukup menuliskan satu fungsi penanganan global untuk mengelola seluruh status dan galat API secara bersih.

---

### 2.2.13 Model Context Protocol

Model Context Protocol (MCP) adalah standar terbuka yang menghubungkan model kecerdasan buatan dengan sumber data dan fungsi di luar model tersebut [21]. Sebagian besar pertanyaan operasional membutuhkan data nyata yang tidak ada di dalam model, sehingga tanpa akses ke data itu model hanya bisa menebak.

MCP menjawab dengan memisahkan tiga peran. *Host* adalah aplikasi yang berinteraksi dengan pengguna, misalnya kolom tanya-jawab pada dasbor. *Client* adalah konektor di dalam host yang meneruskan permintaan ke server. *Server* adalah layanan yang menyediakan data dan fungsi. Ketiganya berkomunikasi memakai pesan JSON-RPC 2.0, yaitu format pertukaran pesan yang sudah disepakati dan tersedia di banyak bahasa pemrograman.

Server MCP mengekspos tiga jenis kemampuan. *Resources* berisi data yang bisa dibaca, misalnya data gedung. *Prompts* berisi templat instruksi, misalnya cara menulis jawaban sebagai analis properti. *Tools* berisi fungsi yang dijalankan model ketika dibutuhkan, misalnya menghitung tingkat keterisian kamar. Karena sebuah *tool* adalah kode yang benar-benar dijalankan, komponen ini harus diperlakukan dengan hati-hati.

Oleh karena itu, pada sistem ini semua *tools* yang diekspos hanya berfungsi membaca. Tidak ada satu pun fungsi yang mengubah data. Dengan begitu, jawaban yang muncul di kolom tanya-jawab pasti berdasarkan angka yang benar-benar ada di basis data, dan keputusan penting tetap diambil manusia.

> **Gambar 2.10 — Integrasi Model Context Protocol (MCP) dengan Basis Data Operasional:** `PA/docs/System design/06-Teori-Penunjang/gambar_2_14_mcp.png`

---

## 2.3 Penelitian Terkait

Beberapa penelitian terdahulu membahas sistem informasi manajemen rumah kost. Penelitian tersebut ditinjau untuk melihat apa yang sudah dikerjakan, apa yang masih menjadi masalah, serta posisi penelitian ini di antaranya.

Penelitian pertama dilakukan oleh Wahyuni pada tahun 2025 dengan judul "Pengembangan Sistem Informasi Pengelolaan Kos Berbasis Website Dengan Menggunakan Framework Codeigniter" [2]. Penelitian ini membangun aplikasi web pencatatan data kost. Metode yang digunakan adalah prototyping dengan Codeigniter dan MySQL. Hasilnya berupa aplikasi pencatatan kamar dan penghuni, tetapi hanya mampu mengelola satu gedung dan belum memisahkan hak akses per peran.

Penelitian kedua diterbitkan pada tahun 2025 dengan judul "Pengembangan Sistem Manajemen Kos Berbasis Aplikasi Mobile pada Kos SidoRame12" [3]. Metode yang digunakan adalah prototyping dengan Flutter dan Laravel. Hasilnya berupa aplikasi mobile dengan pencatatan status kamar dan pengingat pembayaran, tetapi belum mendukung beberapa gedung dan belum ada pengujian otomatis.

Penelitian ketiga dilakukan oleh Ayyubi pada tahun 2024 dengan judul "Rancang Bangun Sistem Informasi Pembayaran Kost Berbasis Mobile pada Kost WS Barokah Selokaton" [4]. Penelitian ini membangun layanan pembayaran sewa secara daring. Metode yang digunakan adalah waterfall dengan Flutter dan Midtrans SNAP. Hasilnya berupa pembayaran digital, tetapi integrasi Midtrans masih berjalan di lingkungan uji coba tanpa perlindungan terhadap transaksi ganda.

Penelitian keempat diterbitkan pada tahun 2025 dengan judul "Kelola Kosku" [26]. Penelitian ini membangun sistem akuntansi sewa lengkap. Metode yang digunakan adalah MVVM dengan Flutter dan Supabase. Hasilnya mencakup tagihan bulanan otomatis, denda keterlambatan, dan uang jaminan, tetapi memakai basis data non-relasional sehingga integritas transaksi lemah.

Penelitian kelima dilakukan oleh Bintang, Purnamasari, dan Maulana pada tahun 2026 dengan judul "Transformasi Digital Pengelolaan Kos" [27]. Penelitian ini bertujuan mengubah operasional kost menjadi berbasis digital. Metode yang digunakan adalah Scrum dengan Laravel dan Midtrans. Hasilnya berupa penagihan otomatis dan notifikasi WhatsApp, tetapi struktur modul pada backend masih belum tegas.

Penelitian keenam dilakukan oleh Nurfaqih, Budihartono, dan Syefudin pada tahun 2026 dengan judul "Rancang Bangun Sistem Informasi Manajemen Kost Berbasis Web Menggunakan Framework Laravel" [28]. Metode yang digunakan adalah waterfall dengan Laravel 12 dan MySQL. Hasilnya berupa aplikasi web dengan ketersediaan kamar langsung, pengingat tagihan, dan tiket komplain, tetapi hanya untuk satu gedung.

Empat proposal previous work juga ditinjau sebagai pembanding [5] sampai [8]. Keempatnya memakai Scrum dengan pembagian modul sesuai domain, tetapi pemisahan antar modul tidak ditegakkan.

Berdasarkan telaah tersebut, terlihat pola yang berulang. Sebagian besar sistem hanya mampu melayani satu gedung. Sebagian sudah mengotomasi tagihan tetapi belum menguji tiap modul secara terpisah. Autentikasi masih berupa email dan kata sandi tanpa pemulihan akun.

**Tabel 2.2 : Penelitian Terkait**

| No | Peneliti & Tahun | Judul Penelitian | Metode & Teknologi | Hasil & Keterbatasan (Gap) |
|---|---|---|---|---|
| 1 | Wahyuni (2025) [2] | Pengembangan Sistem Informasi Pengelolaan Kos Berbasis Website Dengan Menggunakan Framework Codeigniter Pada Wisma Mutiara Selaras | Prototyping, CodeIgniter, MySQL | Mencatat data kamar dan penghuni berbasis web, tetapi hanya mendukung satu gedung dan belum memisahkan hak akses per peran. |
| 2 | JATI (2025) [3] | Pengembangan Sistem Manajemen Kos Berbasis Aplikasi Mobile pada Kos SidoRame12 | Prototyping, Flutter, Laravel | Menyediakan pencatatan status kamar dan pengingat pembayaran mobile, tetapi belum mendukung multi-gedung dan tanpa pengujian otomatis. |
| 3 | Ayyubi (2024) [4] | Rancang Bangun Sistem Informasi Pembayaran Kost Berbasis Mobile pada Kost WS Barokah Selokaton | Waterfall, Flutter, Midtrans SNAP | Menyediakan pembayaran sewa digital, tetapi integrasi Midtrans masih sebatas lingkungan uji coba (*sandbox*) tanpa *idempotency key* dan validasi *webhook*. |
| 4 | JSCR (2025) [26] | Kelola Kosku: Sistem Informasi Akuntansi Mobile dengan Anniversary Billing, Auto-Penalty, Security Deposit, dan Depresiasi PMK 72/2023 | MVVM, Flutter, Supabase | Mencakup tagihan bulanan otomatis, denda, dan deposit, namun model bisnis terlalu bercabang dan integritas transaksi relasional lemah. |
| 5 | Bintang dkk. (2026) [27] | Transformasi Digital Pengelolaan Kos: Sistem Berbasis Laravel dengan Integrasi Pembayaran Non-tunai | Scrum, Laravel, Midtrans, WhatsApp | Mengotomasi penagihan dan notifikasi WhatsApp, tetapi batas modul pada backend belum ditegakkan secara teknis. |
| 6 | Nurfaqih dkk. (2026) [28] | Rancang Bangun Sistem Informasi Manajemen Kost Berbasis Web Menggunakan Framework Laravel | Waterfall, Laravel 12, MySQL | Menyediakan info ketersediaan kamar, pengingat tagihan, dan tiket komplain, tetapi hanya melayani satu gedung tunggal. |
| 7 | Rasyidatur [5], Roihanah [6], Rizal [7], Bagus [8] (2025) | Empat Proposal Sistem Informasi Manajemen Rumah Kost (Penghuni & Tamu, Kamar & Reservasi, Keuangan, Operasional) | Scrum, Laravel 11, Flutter, MySQL (41 Tabel) | Modularitas masih semu (*tight coupling* dan FK lintas modul), skema membengkak hingga 41 tabel, hanya satu gedung, dan autentikasi masih primitif. |
| 8 | Bagus Alfian (2026) – Penelitian Ini | Arsitektur Modular Monolithic Berbasis Event-Driven untuk Sistem Informasi Manajemen Rumah Kost Terintegrasi | Scrum, Modular Monolith NestJS, Flutter Web (Clean Arch), PostgreSQL, Keycloak OIDC, MCP | 9 modul terenkapsulasi (nol FK lintas modul), multi-gedung (*row-level scoping*), sewa bulanan fleksibel per gedung, SSO Keycloak, Midtrans idempoten, dan asisten AI via MCP *read-only*. |

---

### 2.3.1 Sintesis dan Gap Statement

Berdasarkan telaah atas penelitian terkait pada §2.3 dan evaluasi terhadap empat proposal *previous work*, ditemukan lima kesenjangan yang belum diselesaikan oleh penelitian terdahulu.

**1. Modular Monolithic yang Belum Diterapkan dengan Benar**

Hampir semua penelitian yang memakai istilah *modular monolithic* pada Tabel 2.2 membaginya hanya pada level struktur folder. Modul keuangan tetap bisa membaca tabel modul kamar secara langsung. Relasi *Foreign Key* juga dipasang melintasi batas domain. Akibatnya, tidak ada bagian yang bisa diuji atau dilepas tanpa menarik bagian lain. Empat *previous work* mengalami hal yang sama [5] sampai [8].

Masalahnya bukan pada istilah yang dipakai, melainkan pada cara penerapannya. Pemisahan antar modul yang hanya berupa kesepakatan tertulis akan dilanggar ketika waktu pengembangan sedang menekan. Pada penelitian kost, pemisahan yang dipaksakan oleh kerangka kerja belum pernah dipakai.

**2. Hanya Mendukung Satu Gedung**

Tiga dari enam penelitian eksternal pada Tabel 2.2 menghasilkan sistem untuk satu gedung fisik. Ketika pemilik menambah properti, satu-satunya pilihan adalah memasang instalasi dan basis data terpisah untuk setiap gedung [2] [3] [28]. Akibatnya, laporan gabungan seluruh portofolio tidak bisa disusun tanpa menggabungkan data dari beberapa tempat.

**3. Autentikasi Masih Bersifat Primitif**

Semua penelitian pada Tabel 2.2 mengelola kredensial pengguna secara mandiri di dalam basis data. Tidak satu pun menyediakan verifikasi email, pemulihan kata sandi, dan manajemen sesi yang terstandarisasi. Akibatnya, risiko kebocoran akun tinggi, dan waktu pengembangan tersedot untuk membangun fitur keamanan yang seharusnya tersedia siap pakai [5] sampai [8].

**4. Model Sewa Terlalu Bercabang**

Kelola Kosku, misalnya, menangani tagihan bulanan otomatis, denda keterlambatan, dan uang jaminan sekaligus [26]. Fitur itu dibuat sangat lengkap, sementara fitur lain pada sistem yang sama masih sederhana. Justru kedalaman satu fitur inilah yang menjadi masalah. Model bisnis yang bercabang memaksa skema basis data ikut bercabang.

Pada *previous work*, hal ini terlihat paling jelas. Sistem harus melayani satuan sewa harian, bulanan, dan tahunan sekaligus, sampai basis data tumbuh menjadi empat puluh satu tabel dengan banyak kolom yang sudah tidak dipakai [5] sampai [8]. Kesenjangan ini bukan pada jumlah fiturnya, melainkan pada cara aturan bisnisnya ditata. Aturan yang berbeda antar gedung lebih tepat disimpan sebagai konfigurasi.

**5. Belum Tersedia Jawaban Cepat lewat Asisten *Artificial Intelligence***

Pemilik kost sering butuh jawaban cepat: berapa tingkat keterisian kamar bulan ini, atau siapa yang sedang menunggak. Pada penelitian terdahulu, jawaban itu harus dihimpun dengan membuka beberapa halaman satu per satu. Belum ada penelitian sistem manajemen kost yang menyediakan akses baca lewat protokol standar yang menghubungkan model *Artificial Intelligence* dengan data operasional.

*Model Context Protocol* menyediakan jalan keluar. Protokol ini memungkinkan model *Artificial Intelligence* memanggil fungsi baca pada data operasional. Batasannya jelas: fungsi yang diekspos hanya membaca dan tidak mengubah apa pun. Dengan begitu, jawaban yang muncul selalu berdasarkan angka yang benar-benar ada.

Proyek Akhir ini menjawab kelima kesenjangan tersebut melalui perancangan **Sistem Informasi Manajemen Rumah Kost Berbasis Arsitektur Modular Monolithic**. Pemisahan antar modul ditegakkan oleh kerangka NestJS sehingga tiap bagian bisa diuji terpisah. Sistem dirancang untuk beberapa gedung, bukan satu gedung. Autentikasi memakai standar industri agar pemulihan kata sandi dan verifikasi email tidak dibangun dari nol. Model bisnis disederhanakan menjadi sewa bulanan dengan aturan per gedung. Jawaban cepat disediakan lewat *Model Context Protocol* dengan model *Artificial Intelligence* yang hanya bisa membaca data.

---
