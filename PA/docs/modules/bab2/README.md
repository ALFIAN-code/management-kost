# BAB 2 — Kajian Pustaka

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[22]` terurut sesuai kemunculan pertama pada teks.

---

## 2.1 Deskripsi Permasalahan Empiris dan Teknis

Penelitian ini berfokus pada **refactoring** sistem informasi manajemen rumah kost yang sebelumnya telah dikembangkan sebagai *previous work* oleh empat mahasiswa [5][6][7][8]. Sebelum merancang ulang, sistem lama dianalisis lebih dahulu untuk menemukan hambatan teknis yang menjadi dasar rewrite ini. Lima masalah berikut merupakan temuan utama yang menjadi dasar pemetaan kelemahan pada BAB 1 dan pemetaan solusi pada BAB 3:

1. **Modularitas Semu dan *Tight Coupling* Antar-Domain:**
   Sistem lama memisahkan domain Penghuni, Kamar, Keuangan, dan Operasional ke dalam folder-modul terpisah, tetapi pemanggilan dari satu modul masih diakses langsung oleh modul lain tanpa adanya lapisan penengah (*layer*) yang memisahkan keduanya [9]. Service pada modul keuangan, misalnya, memanggil langsung model milik modul kamar, dan relasi *Foreign Key* fisik dipasang melintasi batas domain. Akibatnya, perubahan pada satu modul berisiko merusak modul lain, dan tidak ada modul yang dapat diuji secara independen [9].

2. **Basis Data yang Bercabang dan Menggandakan Data:**
   Skema basis data dari sistem lama mendukung varian sewa harian, bulanan, dan tahunan sekaligus, lengkap dengan mekanisme uang muka (*down payment*) dan pengembalian dana (*refund*). Model ini menyebabkan basis data membengkak menjadi 41 tabel, dengan banyak tabel turunan yang saling menggandakan (dua mekanisme penerbitan tagihan, dua cache penghuni aktif, dan dua tabel penguncian kamar) serta kolom-kolom yang sudah tidak lagi dipakai pemanya [6][7]. Struktur seperti ini membuat pemeliharaan skema dan pelacakan riwayat transaksi semakin sulit dilakukan [7][8].

3. **Kontrak Data dan Hak Akses yang Tidak Seragam:**
   Setiap endpoint REST mengembalikan struktur JSON yang tidak konsisten, perbedaan muncul pada format `status`, struktur paginasi, dan pesan kesalahan validasi. Akibatnya, sisi antarmuka web harus menangani setiap kasus secara berbeda [18]. Selain itu, meskipun pembagian peran sudah ada, belum ada pembatasan akses berbasis gedung, sehingga pengelola pada satu gedung dapat melihat atau mengubah data gedung lain [5][6][16].

4. **Mekanisme Autentikasi yang Belum Matang:**
   Sistem lama hanya mengandalkan autentikasi sederhana berupa kombinasi email dan kata sandi. Belum ada verifikasi email saat pendaftaran, belum ada mekanisme pemulihan kata sandi ketika pengguna lupa (*forgot password*), belum ada pengaturan masa berlaku sesi, dan belum ada lapisan keamanan tambahan seperti autentikasi dua faktor (*multi-factor authentication*). Akibatnya, risiko kebocoran dan penyalahgunaan akun cukup tinggi, dan Sebagian besar anggaran pengembangan pun teralokasikan untuk membangun fitur autentikasi dari nol [5][6][19].

5. **Keterbatasan Dukungan Multi-Gedung (*Multi-Tenancy*):**
   Rancangan awal mengasumsikan hanya satu gedung fisik. Ketika bisnis berkembang ke beberapa properti, pendekatan tanpa pemisahan data penyewa (*tenant isolation*) memaksa pengembang memasang instalasi server dan basis data terpisah untuk setiap gedung baru. Pendekatan ini melipatgandakan biaya pemeliharaan dan menyulitkan pemilik untuk melihat laporan keuangan gabungan seluruh portofolio [18].

---

## 2.2 Teori Penunjang

### 2.2.1 Sistem Informasi Manajemen

Sistem Informasi Manajemen (SIM) adalah sistem berbasis komputer yang mengumpulkan, menyimpan, mengolah, dan menyajikan data agar dapat dipakai sebagai dasar pengambilan keputusan dalam sebuah organisasi [1]. Secara sederhana, SIM mengubah data mentah menjadi informasi yang berguna, lalu informasi itu dipakai untuk perencanaan, pengendalian, dan evaluasi kinerja.

Pada industri properti sewa, SIM menjalankan tiga fungsi yang saling terkait. Pertama, mencatat kondisi fisik properti seperti unit kamar, fasilitas, dan barang di dalamnya. Kedua, merekam seluruh transaksi sewa dari awal kontrak sampai pembayaran terakhir. Ketiga, menyusun laporan keuangan yang bisa dipercaya pemilik sebagai dasar mengambil keputusan.

PA ini memakai konsep SIM sebagai kerangka dasar karena ketiga fungsi tersebut tercakup di dalam sistem yang dibangun. Yang membedakan sistem ini dari sistem lama adalah letak otomasi. Pada sistem lama, laporan okupansi dan tunggakan harus dihimpun manual dengan membuka beberapa menu satu per satu. Pada sistem yang dirancang, data sudah tersusun begitu masuk sehingga laporan terbentuk otomatis dan tidak perlu diketik ulang.

> **Gambar 2.1 — Dimensi Fungsional SIM pada Sistem Manajemen Rumah Kost:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.2 Arsitektur Modular Monolithic

Arsitektur modular monolithic membangun aplikasi sebagai satu kesatuan utuh, tetapi membaginya ke dalam modul-modul yang masing-masing punya tanggung jawab dan tidak saling bergantung langsung [9]. Bedanya dengan monolitik konvensional terletak pada pemisahan antar modul. Pada monolitik biasa, pemisahan hanya berupa struktur folder, sehingga service di satu bagian tetap bisa memanggil bagian lain tanpa batasan. Pada modular monolithic, pemisahan antar modul ditegakkan dan komunikasi antar modul harus lewat kontrak yang disepakati.

Prinsip batas tersebut diambil dari konsep *bounded context* dalam Domain-Driven Design, yang dipakai untuk menentukan di mana sebuah modul harus berakhir [10]. Setiap modul diperlakukan sebagai satu bagian bisnis dengan aturan main sendiri. Modul keuangan misalnya punya aturan penghitungannya sendiri, dan modul kamar punya aturan tentang ketersediaan unit. Keduanya tidak boleh saling membaca data secara langsung, melainkan berkomunikasi lewat kontrak yang telah ditentukan.

PA ini memakai pendekatan ini karena alasan utamanya adalah kemudahan waktu depan. Ketika bisnis berkembang dan muncul kebutuhan baru, misalnya perlu menambah modul laporan keuangan atau modul pengarsipan dokumen, penambahan tersebut cukup dilakukan dengan membuat modul terpisah dan mendaftarkannya, tanpa mengubah modul yang sudah berjalan. Sebaliknya, ketika ada modul yang tidak lagi dibutuhkan, modul itu bisa dihapus beserta seluruh isinya tanpa meninggalkan jejak di modul lain.

Kemudahan inilah yang tidak dimiliki sistem lama. Folder modulnya memang ada, tetapi karena batasnya tidak ditegakkan, modul keuangan tetap bisa membaca tabel modul kamar. Akibatnya tidak ada satu pun bagian yang bisa dilepas atau diuji sendiri tanpa menarik bagian lain ikutcampur. Batas yang benar-benar dipaksakan oleh kerangka kerja membuat penambahan dan penghapusan modul menjadi pekerjaan yang biasa, bukan proses yang perlu dikhawatirkan.

> **Gambar 2.2 — Hirarki Modul 3-Tier pada Modular Monolithic:** `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/hierarki_3_tier_modulith.mmd` / `.png`

---

### 2.2.3 NestJS

NestJS adalah kerangka kerja backend berbasis Node.js dan TypeScript yang dirancang untuk membangun aplikasi server dengan struktur modular [13]. Berbeda dari framework konvensional yang mengharuskan pengembang membuat struktur folder sendiri, NestJS menyediakan pemisahan antar modul sebagai bagian dari kerangka kerjanya. Setiap unit kerja dibungkus dekorator `@Module()` yang menentukan layanan mana yang boleh diekspor ke modul lain dan mana yang disembunyikan di dalam modul tersebut.

Dua mekanisme membuat hal itu bekerja. Pertama, *encapsulation*. Layanan yang tidak didaftarkan pada daftar `exports` tidak akan pernah bisa disuntik oleh modul lain, meskipun keduanya berada di repositori yang sama. Kedua, *dependency injection*. Setiap kelas menerima dependensinya dari wadah aplikasi, bukan membuatnya sendiri, sehingga mudah diganti dengan tiruan saat pengujian. Selain itu, NestJS dibangun di atas Node.js yang bekerja dengan model I/O non-blocking, sehingga permintaan yang menunggu jawaban dari layanan luar tidak menahan proses lain.

PA ini memilih NestJS karena pemisahan antar modul ditegakkan oleh kerangka kerjanya sendiri, bukan oleh disiplin tim. Ketika modul keuangan mencoba menulis kueri ke tabel milik modul kamar, kode itu akan gagal sejak tahap build, bukan baru ketahuan saat pengujian. Pengalaman sistem lama menunjukkan bahwa pemisahan yang hanya dijaga lewat aturan tertulis akan cepat dilanggar ketika waktu pengembangan sedang menekan. Dengan NestJS, pelanggaran aturan menjadi kesalahan teknis, bukan pilihan penyusun kode.

> **Gambar 2.3 — Pemisahan Antar Modul dan Mekanisme Dependency Injection pada NestJS:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.4 Flutter

Flutter adalah kerangka kerja antarmuka lintas platform yang dikembangkan oleh Google dengan bahasa pemrograman Dart [15]. Semua tampilan pada aplikasi disusun dari komponen yang namanya *widget*. Satu basis kode yang sama dapat dikompilasi menjadi aplikasi web, aplikasi Android, maupun aplikasi iOS, tanpa menulis ulang lapisan tampilannya. Karena itu Flutter disebut multi-platform, sebab satu proyek dapat dipakai untuk beberapa perangkat sekaligus.

PA ini memakai Flutter dengan target utama berupa aplikasi web. Alasan memilih lingkungan web adalah lingkup penggunaan sistem: pengoperasian harian dilakukan dari komputer atau tablet di ruang pengelola, sehingga tampilan lebar lebih sesuai. Arsitektur yang dipakai juga memperjelas alasan itu. Karena logika bisnis disimpan di lapisan domain yang murni Dart tanpa bergantung pada sistem operasi maupun peramban, lapisan tersebut tetap bisa dipakai ulang ketika aplikasi dikompilasi untuk perangkat mobile di kemudian hari. Jadi kesiapan ekspansi ke mobile muncul sebagai hasil dari struktur kode, bukan sebagai target tambahan yang harus dirancang terpisah.

> **Gambar 2.4 — Lapisan Clean Architecture pada Flutter:** `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/clean_architecture_frontend.mmd` / `.png`

---

### 2.2.5 Clean Architecture

Clean Architecture adalah pola arsitektur yang memisahkan program menjadi lapisan-lapisan dengan aturan ketergantungan satu arah [16]. Lapisan paling dalam berisi entitas dan aturan bisnis yang murni, lapisan tengah berisi use case, dan lapisan luar menangani presentasi serta akses data. Aturan utamanya sederhana: lapisan dalam tidak boleh mengenal keberadaan lapisan luar.

Pada aplikasi Flutter, pemisahan ini menjawab satu masalah yang sering muncul. Kode pada lapisan tampilan biasanya mengambil data langsung dari repository, sehingga logika bisnis ikut bercampur dengan komponen antarmuka. Akibatnya, menguji sebuah aturan bisnis berarti menyalakan seluruh tampilan beserta koneksi jaringan. Dengan Clean Architecture, aturan bisnis berdiri sendiri tanpa framework apa pun, sehingga bisa diuji dalam hitungan milidetik.

PA ini memakai Clean Architecture pada sisi antarmuka karena pemisahan tersebut memudahkan dua hal. Pertama, pengujian: setiap lapisan punya fokus yang jelas, sehingga aturan bisnis dapat diuji tanpa lapisan lain, dan pengujian antarmuka cukup memeriksa pemetaan state ke tampilan. Kedua, perubahan pada bagian tertentu tidak menimpa bagian lain. Contohnya, apabila format jawaban API berubah, cukup ubah lapisan data; lapisan domain dan lapisan presentasi tidak perlu disentuh karena keduanya tidak tahu bentuk data mentah.

> **Gambar 2.5 — Pembagian Lapisan pada Clean Architecture:** `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/clean_architecture_frontend.mmd` / `.png`

---

### 2.2.6 BLoC (Business Logic Component)

BLoC adalah pola pengelolaan *state* pada Flutter yang memisahkan pemicu perubahan state dari proses perubahannya [15]. Alurnya sederhana: widget mengirim *event*, *bloc* yang menerima event itu memanggil use case, lalu *bloc* memancarkan *state* baru dalam bentuk objek yang tidak bisa diubah setelah dibuat.

Pola ini membuat aliran data pada antarmuka berjalan satu arah dan mudah dilacak.urutannya bisa dibaca langsung dari kode: dari widget, ke event, ke use case, ke state, lalu kembali ke widget. Berbeda dengan pemanggilan `setState` yang menyatukan pemicu dan perubahan di dalam satu widget, BLoC memisahkannya sehingga transisi state bisa diuji tanpa menampilkan antarmuka sama sekali.

PA ini memakai BLoC karena pola ini sebenarnya memaksa struktur kode menjadi tertata. BLoC hanya bekerja jika logika bisnis berada di use case terpisah dari widget yang memunculkannya. Umumnya, pengembang yang langsung memuat data dan memprosesnya di dalam widget akan membuat pola ini mustahil diterapkan. Dengan BLoC, pemisahan antara logika bisnis dan tampilan bukan lagi pilihan disiplin, melainkan syarat agar pola tersebut berjalan.

> **Gambar 2.6 — Alur Data pada Pola BLoC:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.7 PostgreSQL

PostgreSQL adalah sistem manajemen basis data relasional *open-source* yang dikenal konsisten dengan standar SQL, mendukung transaksi dengan integritas tinggi, dan menyediakan penanganan konkurensi yang matang [17]. Yang membedakannya dari basis data relasional lain terletak pada tiga hal yang dipakai langsung pada sistem ini.

Pertama, tipe numerik `NUMERIC` dipakai untuk seluruh nilai uang. Tipe ini menyimpan angka desimal secara tepat, sehingga penjumlahan tagihan tidak pernah menghasilkan selisih satu rupiah akibat pembulatan. Kedua, tipe `JSONB` dipakai untuk menyimpan payload *event* dan parameter *tool* MCP, sekaligus memudahkan pencarian di dalam struktur tersebut. Ketiga, PostgreSQL menyediakan penguncian baris dengan `SELECT ... FOR UPDATE`, yaitu mengunci baris yang sedang dibaca selama transaksi masih berjalan.

Mekanisme penguncian itulah yang dipakai untuk mencegah dua orang memesan kamar yang sama pada saat bersamaan. Saat permintaan sewa masuk, baris kamar dikunci lebih dulu, lalu diperiksa apakah sudah ada kontrak aktif di periode tersebut. Kalau belum ada, kontrak disimpan di dalam transaksi yang sama; kalau sudah ada, transaksi dibatalkan dan permintaan kedua ditolak. Selama penguncian masih aktif, permintaan lain untuk kamar yang sama harus mengantre. Inilah yang membuat pemesanan ganda tidak mungkin terjadi meski beberapa orang menekan tombol sewa pada milidetik yang sama.

> **Gambar 2.7 — Mekanisme Penguncian Baris untuk Pencegahan Pemesanan Ganda:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.8 Multi-Tenancy dengan Row-Level Scoping

Multi-tenancy adalah pola arsitektur yang membuat satu instalasi aplikasi melayani banyak unit bisnis independen dengan jaminan pemisahan data [18]. Pada sistem properti sewa, unit bisnisnya adalah gedung. Artinya, data kamar gedung A tidak boleh bisa dibaca atau diubah oleh pengelola gedung B.

Tiga model yang lazim adalah *database per tenant*, *schema per tenant*, dan *shared database dengan row-level scoping*. Model pertama memberi isolasi paling kuat tetapi membutuhkan server khusus untuk setiap gedung. Model kedua mengurangi jumlah server, tetapi pemeliharaan strukturnya menambah pekerjaan setiap kali ada gedung baru. Model ketiga menyimpan seluruh data di satu basis data dan menambahkan kolom `building_id` pada setiap tabel sebagai penanda.

PA ini memilih model ketiga karena tiga alasannya. Migrasi skema cukup dijalankan satu kali untuk seluruh gedung, bukan diulang tiap kali ada properti baru. Biaya server tidak bertambah seiring jumlah gedung. Dan yang paling penting, laporan gabungan seluruh portofolio bisa disusun dengan satu kueri, sedangkan pada model terpisah data harus digabungkan lebih dahulu. Keterbatasan model ini juga diketahui: pemisahan data harus dijaga di lapisan aplikasi, bukan oleh basis data, sehingga setiap kueri wajib menyertakan `building_id`.

> **Gambar 2.8 — Isolasi Data Antar Gedung pada Row-Level Scoping:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.9 Single Sign-On, OpenID Connect, dan Keycloak

Single Sign-On (SSO) adalah mekanisme yang memungkinkan pengguna cukup sekali masuk untuk mengakses beberapa aplikasi sekaligus, tanpa mengulang kredensial di setiap aplikasi [19]. Pada sistem yang punya banyak modul atau banyak aplikasi terpisah, mekanisme ini menghemat waktu pengguna sekaligus mengurangi jumlah kata sandi yang harus dikelola.

OpenID Connect (OIDC) adalah standar yang mengatur lapisan identitas di atas OAuth 2.0. Bedanya, OAuth 2.0 hanya mengatur pendelegasian hak akses, sedangkan OIDC menambahkan identitas: setelah pengguna berhasil masuk, aplikasi menerima *token* berisi informasi siapa penggunanya. Token tersebut berbentuk JWT dan ditandatangani secara digital, sehingga pihak lain bisa memastikan token itu benar berasal dari penyedia identitas dan belum kedaluwarsa. Karena tanda tangannya dapat diperiksa tanpa menghubungi server pengeluar token, proses verifikasi bisa dijalankan secara lokal dan cepat.

Keycloak adalah *identity and access management* open-source yang mendukung OIDC, SSO, dan pengelolaan peran [20]. Yang sering tidak dikerjakan sendiri oleh aplikasi adalah justru hal-hal standar ini: verifikasi email saat pendaftaran, pemulihan kata sandi ketika pengguna lupa, masa berlaku sesi, dan pencatatan aktivitas login. Pada sistem lama seluruh itu harus dibuat satu per satu, dan bagian yang paling sering tertinggal justru yang paling penting, yaitu pemulihan akun.

PA ini memakai Keycloak karena tiga alasan. Pertama, fitur keamanan yang dibutuhkan sudah tersedia sehingga waktu pengembangan bisa dipakai untuk aturan bisnis sewa. Kedua, peran pengguna seperti pemilik, pengelola, dan penghuni cukup diatur di satu tempat, lalu diteruskan ke backend lewat isi token. Ketiga, backend cukup memverifikasi tanda tangan token tanpa perlu menghubungi Keycloak pada setiap permintaan, sehingga waktu tanggap tidak bertambah. Perlu dicatat bahwa Keycloak menambah satu layanan yang harus dijalankan dan dipelihara, dan pembagian peran harus disusun di Keycloak dengan cermat supaya tetap sinkron dengan aturan pada sistem.

> **Gambar 2.9 — Alur Verifikasi Token OIDC dengan JWKS:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.10 Docker dan Docker Compose

Docker adalah platform *containerization* yang membungkus aplikasi beserta seluruh dependensinya ke dalam satu unit bernama *image* [23]. Image ini berisi semua yang diperlukan untuk menjalankan aplikasi: kode, pustaka, konfigurasi, sampai sistem operasi dasar. Karena isinya lengkap dan tidak bergantung pada isi mesin, aplikasi yang berjalan di laptop pengembang akan berjalan sama persis di server.

Perbedaan utama Docker dengan cara lama adalah pemisahan antara apa yang ada di kode dan apa yang ada di komputer. Pada pendekatan lama, setiap orang memasang PostgreSQL dan Keycloak dengan versi masing-masing, dan versi yang berbeda sering menyebabkan program berjalan di satu komputer tetapi gagal di komputer lain. Dengan Docker, versi PostgreSQL dan Keycloak dituliskan di satu berkas konfigurasi, lalu dijalankan apa adanya di mana saja.

Docker Compose adalah kelanjutannya. Compose membaca satu berkas yang menjelaskan beberapa container sekaligus, lalu menjalankan semuanya dengan satu perintah. PA ini punya tiga komponen yang harus jalan bersamaan: backend NestJS, basis data PostgreSQL, dan Keycloak. Compose dipakai agar ketiganya bisa dijalankan, dihentikan, dan dibuild ulang tanpa langkah manual yang berbeda-beda [41].

> **Gambar 2.10 — Komposisi Container pada Sistem Manajemen Rumah Kost:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.11 Midtrans SNAP

Midtrans adalah penyedia layanan gerbang pembayaran yang menghubungkan aplikasi dengan jaringan pembayaran bank dan dompet digital. Midtrans SNAP merupakan layanan andalannya: SNAP menyediakan antarmuka pembayaran siap pakai dalam bentuk *pop-up*, sehingga penghuni tidak perlu meninggalkan aplikasi untuk menyelesaikan transaksi [25]. SNAP mendukung kanal Virtual Account, QRIS, dan dompet digital.

Integrasi berjalan dua arah. Dari sisi sistem, backend meminta token pembayaran lalu meneruskannya ke antarmuka SNAP, dan penghuni menyelesaikan pembayaran di sana. Dari sisi Midtrans, setiap kali status pembayaran berubah, Midtrans mengirim *webhook* ke alamat yang didaftarkan. Di sinilah bagian yang perlu diperhatikan berada: *webhook* adalah permintaan yang masuk dari luar, sehingga harus diperiksa sebelum dipercayai.

Ada dua perlindungan yang dipakai pada sistem ini. Yang pertama, penomoran pesanan. Setiap permintaan pembayaran diberi nomor unik, sehingga ketika jaringan membuatkan permintaan terkirim ulang, Midtrans mengenali bahwa itu transaksi yang sama dan tidak membuat tagihan ganda. Yang kedua, verifikasi tanda tangan. Setiap *webhook* disertai tanda tangan yang dihitung dari nomor pesanan, kode status, jumlah pembayaran, dan kunci rahasia. Backend menghitung ulang tanda tangan itu; kalau tidak cocok, permintaan ditolak dan status tagihan tidak diubah. Tanpa dua perlindungan ini, siapa pun yang mengetahui alamat *webhook* bisa memalsukan pembayaran.

> **Gambar 2.11 — Alur Pembayaran dan Verifikasi Webhook:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.12 Standar Kontrak Input-Output REST API

REST API adalah gaya komunikasi yang paling umum dipakai antar aplikasi web. Yang dikirim berupa permintaan HTTP, dan jawabannya berupa *response* dengan kode status yang menyatakan berhasil atau gagal. Kelemahannya, setiap pengembang bebas membuat format jawabannya sendiri, sehingga satu endpoint bisa berbeda dengan endpoint lain. Pengembang yang membuat program harusnya mengelola semua kemungkinan format itu.

Standar yang dipakai pada sistem ini mengatasi masalah tersebut: setiap *endpoint* mengembalikan *response* dengan lima kunci yang selalu sama. Kunci `status` menyatakan berhasil atau gagal, `message` berisi keterangan yang bisa dibaca manusia, `data` berisi isi jawaban, `meta` berisi informasi tambahan seperti penomoran halaman, dan `errors` berisi rincian kesalahan validasi. Format kesalahan mengikuti kebiasaan *Problem Details* [36]. Contoh jawaban berhasil:

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

Contoh jawaban gagal karena masukan tidak sesuai:

```json
{
  "status": false,
  "message": "Validasi masukan gagal",
  "errors": {
    "duration_months": ["Durasi sewa minimal untuk gedung ini adalah 3 bulan."],
    "room_id": ["Kamar sudah sedang disewa pada periode tersebut."]
  }
}
```

Kode status yang dipakai mengikuti ketetapan umum HTTP. Kode 200 dan 201 berarti permintaan berhasil diproses atau data baru dibuat. Kode 400 berarti permintaan tidak sesuai format. Kode 401 berarti token tidak ada atau sudah kedaluwarsa. Kode 403 berarti pengguna tidak berhak mengakses data gedung tersebut. Kode 404 berarti data tidak ditemukan. Kode 422 berarti masukan melanggar aturan bisnis, misalnya durasi sewa di bawah minimal. Dengan seluruh kemungkinan kesalahan mengikuti pola yang sama, sisi antarmuka cukup menulis satu fungsi untuk menangani semuanya.

> **Gambar 2.12 — Bentuk Standar Respons API:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.13 Pengujian Perangkat Lunak Otomatis

Pengujian program adalah proses menjalankan program dengan masukan khusus untuk memeriksa apakah hasilnya sesuai dengan yang diharapkan [22]. Dalam metode *black-box*, pengujian hanya melihat hasil dari luar, sehingga program bisa menghasilkan jawaban yang benar tetapi salah cara.

Pola pengujian yang umum adalah *testing pyramid* [22]. Di bagian paling bawah ada pengujian unit, yaitu menguji satu aturan bisnis tanpa jaringan, tanpa basis data, dan tanpa antarmuka. Di atasnya ada pengujian kontrak, yang memeriksa apakah setiap endpoint mengembalikan bentuk jawaban sesuai kesepakatan. Di bagian paling atas ada pengujian integrasi, yang menyalakan beberapa bagian sekaligus untuk memeriksa alur keseluruhan.

Jumlah pengujian berbanding terbalik dengan tingginya. Makin ke atas, makin sedikit pengujiannya, makin lama waktunya, dan makin sulit melacak kesalahan. Inilah alasan pengujian unit ditulis paling banyak: cepat dijalankan dan kesalahannya mudah ditemukan.

PA ini memakai susunan itu dengan target cakupan kode minimal 80 persen. Ada satu jenis pengujian yang khas untuk sistem ini, yaitu uji isolasi gedung. Tujuannya membuktikan bahwa pengelola gedung satu tidak dapat membaca data gedung lain, termasuk ketika keduanya mencoba mengakses pada saat bersamaan.

> **Gambar 2.13 — Piramida Pengujian beserta Komposisinya:** belum tersedia. Diagram ini masih perlu dibuat.

---

### 2.2.14 Model Context Protocol

Model Context Protocol (MCP) adalah standar terbuka yang menghubungkan model kecerdasan buatan dengan sumber data dan fungsi di luar model tersebut [21]. Sebagian besar pertanyaan operasional membutuhkan data nyata yang tidak ada di dalam model, sehingga tanpa akses ke data itu model hanya bisa menebak.

MCP menjawab dengan memisahkan tiga peran. *Host* adalah aplikasi yang berinteraksi dengan pengguna, misalnya kolom tanya-jawab pada dasbor. *Client* adalah konektor di dalam host yang meneruskan permintaan ke server. *Server* adalah layanan yang menyediakan data dan fungsi. Ketiganya berkomunikasi memakai pesan JSON-RPC 2.0, yaitu format pertukaran pesan yang sudah disepakati dan tersedia di banyak bahasa pemrograman.

Server MCP mengekspos tiga jenis kemampuan. *Resources* berisi data yang bisa dibaca, misalnya data gedung. *Prompts* berisi templat instruksi, misalnya cara menulis jawaban sebagai analis properti. *Tools* berisi fungsi yang dijalankan model ketika dibutuhkan, misalnya menghitung tingkat keterisian kamar. Karena sebuah *tool* adalah kode yang benar-benar dijalankan, komponen ini harus diperlakukan dengan hati-hati.

Oleh karena itu, pada sistem ini semua *tools* yang diekspos hanya berfungsi membaca. Tidak ada satu pun fungsi yang mengubah data. Dengan begitu, jawaban yang muncul di kolom tanya-jawab pasti berdasarkan angka yang benar-benar ada di basis data, dan keputusan penting tetap diambil manusia.

> **Gambar 2.14 — Alur Jawaban Cepat lewat Asisten Artificial Intelligence dan MCP:** `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.mmd` (sumber notasi Mermaid, hasil render `.png`)

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

*Sumber: Tabel 2.1 Penelitian terkait*

| Judul Penelitian | Tahun | Penulis | Tujuan | Metode | Hasil |
|---|---|---|---|---|---|
| Prototype Sistem Informasi Reservasi Kos (Studi Kasus: Kos Wisma Cirebon Bandung) | 2019 | Abdussamad, N. dan Hasugian, L. P. | Membangun sistem prototype reservasi kos | Deskriptif, OOP, UML, Prototyping | Sistem hanya mendukung proses reservasi tanpa fitur maintenance |
| Perancangan Aplikasi Manajemen Indekos Berbasis Mobile dengan Metode Microservice | 2021 | Nofianto, R. | Merancang aplikasi manajemen indekos mobile | Microservice | Berbasis mobile saja, belum mendukung pengelolaan operasional |
| Aplikasi AturKost Berbasis Web untuk Pengelola dan Penghuni Kost (Studi Kasus: Kost Jura) | 2021 | Steven dan Christianto | Membantu pengelolaan dan interaksi penghuni | SDLC Waterfall | Menyediakan fitur pengelolaan umum, belum fokus pada maintenance operasional |
| Sistem Informasi Pengelolaan Data Kos Annisa Menggunakan Framework Codeigniter 4 | 2022 | Azizah, dkk. | Membangun sistem informasi kos berbasis web untuk pemasaran, pembayaran, ketersediaan kamar | CodeIgniter 4, Waterfall | Fokus pemasaran dan ketersediaan kamar, belum mengelola maintenance dan inventaris |
| e-Kos sebagai Sistem Informasi Pengelolaan Kos pada Mazaki's House | 2022 | Rahmatya, M. D., dkk. | Membangun e-kos untuk booking kamar, pembayaran bulanan, dan pencatatan pengeluaran pemeliharaan | OOP, Waterfall | e-Kos untuk booking, pembayaran, dan pencatatan biaya pemeliharaan |
| Sistem Informasi Manajemen Kost Putra Trisula Berbasis Web (Studi Kasus: Asrama Putra Trisula) | 2023 | Darlin, W., dkk. | Mengatasi pencatatan manual penyewa, pembayaran, dan keluhan fasilitas rusak | Prototyping, MVC, Codeigniter | Menangani keluhan, belum fokus pada penjadwalan dan manajemen inventaris |
| Sistem Informasi Manajemen Rumah Kos Damara Putri Jember Berbasis Web | 2024 | Diana, W. N. | Mengembangkan sistem informasi manajemen rumah kos berbasis web | Tidak dijelaskan | Hanya mencakup manajemen umum, belum mencakup fitur maintenance mendalam |
| Perancangan Aplikasi Manajemen Proyek Sistem Informasi dalam Pengelolaan Kosan D2 Berbasis Web | 2024 | Andini, N. R. dan Yahfizham | Manajemen penyewaan dan pemeliharaan inventaris | Kualitatif, Waterfall, UML | Belum secara eksplisit menangani penjadwalan perawatan atau pelacakan detail inventaris |
| Implementasi Sistem Informasi Pengelolaan Kos-Kosan untuk Peningkatan Efisiensi Operasional di Sekitar UNS | 2024 | Ramadhan, A. A. | Meningkatkan efisiensi pengelolaan data penyewa, kamar, dan fasilitas | Waterfall | Belum memiliki modul khusus untuk operasional proaktif seperti penjadwalan perawatan rutin serta absensinya integrasi antara pelaporan kerusakan fasilitas dengan pelacakan inventaris |
| Pengembangan Sistem Manajemen Penghuni dan Tamu | 2025 | Rasyidatur | Mencatat data penghuni, tamu, dan riwayat sewa | Scrum, modular semu | Modul tersusun atas domain Penghuni dan Tamu, tetapi pemisahan antar modul tidak ditegakkan |
| Pengembangan Sistem Manajemen Kamar dan Reservasi | 2025 | Roihanah | Mengelola kamar dan reservasi | Scrum, modular semu | Modul tersusun atas domain Kamar dan Reservasi, tetapi pemanggilan antar modul tanpa perantara |
| Pengembangan Sistem Keuangan dan Transaksi | 2025 | Rizal | Mengelola tagihan dan transaksi sewa | Scrum, modular semu | Modul keuangan membaca tabel modul kamar secara langsung, pembayaran masih di lingkungan uji coba |
| Pengembangan Sistem Operasional dan Pemeliharaan | 2025 | Bagus | Mengelola keluhan kerusakan dan inventaris | Scrum, modular semu | Modul operasional terpisah tetapi tidak terhubung dengan modul lain |
| Pengembangan Sistem Informasi Manajemen Rumah Kost (Penelitian Ini) | 2026 | Peneliti | Menyatukan operasional sewa multi-gedung dalam satu sistem | Scrum, Modular Monolithic NestJS, Flutter Web, PostgreSQL, Docker | Pemisahan antar modul ditegakkan kerangka kerja, autentikasi standar Keycloak OIDC, asisten Artificial Intelligence lewat MCP read-only |

---

## 2.4 Sintesis dan Gap Statement

Berdasarkan telaah atas penelitian terkait pada §2.3 dan evaluasi terhadap empat proposal *previous work*, ditemukan lima kesenjangan yang belum diselesaikan oleh penelitian terdahulu.

**1. Modular Monolithic yang Belum Diterapkan dengan Benar**

Hampir semua penelitian yang memakai istilah *modular monolithic* pada tabel §2.3 membaginya hanya pada level struktur folder. Modul keuangan tetap bisa membaca tabel modul kamar secara langsung. Relasi *Foreign Key* juga dipasang melintasi batas domain. Akibatnya, tidak ada bagian yang bisa diuji atau dilepas tanpa menarik bagian lain. Empat *previous work* mengalami hal yang sama [5] sampai [8].

Masalahnya bukan pada istilah yang dipakai, melainkan pada cara penerapannya. Pemisahan antar modul yang hanya berupa kesepakatan tertulis akan dilanggar ketika waktu pengembangan sedang menekan. Pada penelitian kost, pemisahan yang dipaksakan oleh kerangka kerja belum pernah dipakai.

**2. Hanya Mendukung Satu Gedung**

Tiga dari enam penelitian eksternal pada tabel §2.3 menghasilkan sistem untuk satu gedung fisik. Ketika pemilik menambah properti, satu-satunya pilihan adalah memasang instalasi dan basis data terpisah untuk setiap gedung [2] [3] [28]. Akibatnya, laporan gabungan seluruh portofolio tidak bisa disusun tanpa menggabungkan data dari beberapa tempat.

**3. Autentikasi Masih Bersifat Primitif**

Semua penelitian pada tabel §2.3 mengelola kredensial pengguna secara mandiri di dalam basis data. Tidak satu pun menyediakan verifikasi email, pemulihan kata sandi, dan manajemen sesi yang terstandarisasi. Akibatnya, risiko kebocoran akun tinggi, dan waktu pengembangan tersedot untuk membangun fitur keamanan yang seharusnya tersedia siap pakai [5] sampai [8].

**4. Model Sewa Terlalu Bercabang**

Kelola Kosku, misalnya, menangani tagihan bulanan otomatis, denda keterlambatan, dan uang jaminan sekaligus [26]. Fitur itu dibuat sangat lengkap, sementara fitur lain pada sistem yang sama masih sederhana. Justru kedalaman satu fitur inilah yang menjadi masalah. Model bisnis yang bercabang memaksa skema basis data ikut bercabang.

Pada *previous work*, hal ini terlihat paling jelas. Sistem harus melayani satuan sewa harian, bulanan, dan tahunan sekaligus, sampai basis data tumbuh menjadi empat puluh satu tabel dengan banyak kolom yang sudah tidak dipakai [5] sampai [8]. Kekesenjangan ini bukan pada jumlah fiturnya, melainkan pada cara aturan bisnisnya ditata. Aturan yang berbeda antar gedung lebih tepat disimpan sebagai konfigurasi.

**5. Belum Tersedia Jawaban Cepat lewat Asisten *Artificial Intelligence***

Pemilik kost sering butuh jawaban cepat: berapa tingkat keterisian kamar bulan ini, atau siapa yang sedang menunggak. Pada penelitian terdahulu, jawaban itu harus dihimpun dengan membuka beberapa halaman satu per satu. Belum ada penelitian sistem manajemen kost yang menyediakan akses baca lewat protokol standar yang menghubungkan model *Artificial Intelligence* dengan data operasional.

*Model Context Protocol* menyediakan jalan keluar. Protokol ini memungkinkan model *Artificial Intelligence* memanggil fungsi baca pada data operasional. Batasannya jelas: fungsi yang diekspos hanya membaca dan tidak mengubah apa pun. Dengan begitu, jawaban yang muncul selalu berdasarkan angka yang benar-benar ada.

Proyek Akhir ini menjawab kelima kesenjangan tersebut melalui perancangan **Sistem Informasi Manajemen Rumah Kost Berbasis Arsitektur Modular Monolithic**. Pemisahan antar modul ditegakkan oleh kerangka NestJS sehingga tiap bagian bisa diuji terpisah. Sistem dirancang untuk beberapa gedung, bukan satu gedung. Autentikasi memakai standar industri agar pemulihan kata sandi dan verifikasi email tidak dibangun dari nol. Model bisnis disederhanakan menjadi sewa bulanan dengan aturan per gedung. Jawaban cepat disediakan lewat *Model Context Protocol* dengan model *Artificial Intelligence* yang hanya bisa membaca data.

---
