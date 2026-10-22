# BAB 3 — DESAIN SISTEM

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.

---

## 3.1 Deskripsi Solusi

Berdasarkan permasalahan yang diuraikan pada BAB 1, solusi yang diusulkan adalah membangun ulang sistem manajemen rumah kost menjadi satu aplikasi web yang dapat melayani banyak gedung sekaligus. Sistem lama berasal dari empat proposal terpisah yang masing-masing menangani satu bagian, yaitu penghuni dan tamu, kamar dan reservasi, keuangan, serta operasional. Keempatnya tidak punya aturan bersama dan hanya dapat dipakai untuk satu gedung. Pada proyek akhir ini, keempat bagian tersebut disatukan ke dalam satu backend dengan batas modul yang jelas, satu basis data, dan satu aplikasi antarmuka untuk tiga peran pengguna: pemilik, pengelola, dan penghuni.

Solusi ini menjawab permasalahan pada BAB 1 melalui enam hal berikut.

1. **Satu sistem untuk banyak gedung.** Pemilik dapat mendaftarkan beberapa gedung pada satu instalasi sistem. Setiap baris data operasional diberi penanda gedung (`building_id`), sehingga pengelola hanya melihat data gedung yang ditugaskan kepadanya, sedangkan pemilik dapat melihat ringkasan seluruh gedung miliknya. Pemilik tidak perlu memasang server atau basis data baru setiap kali membuka cabang.

2. **Backend dibagi menjadi sembilan modul yang terpisah tegas.** Backend dibangun dengan NestJS dan dibagi menjadi modul Auth, Building, Room, Lease, Finance, Maintenance, Guest, Inventory, dan Notification. Setiap modul hanya mengelola tabel miliknya sendiri. Jika satu modul perlu memicu perubahan di modul lain, misalnya kontrak sewa baru yang harus menghasilkan tagihan, modul tersebut mengirim *event* dan tidak mengakses tabel modul lain secara langsung. Dengan cara ini, kesalahan pada satu modul tidak merembet ke modul lain, dan setiap modul dapat diuji sendiri.

3. **Sewa bulanan dengan aturan per gedung.** Sistem hanya melayani sewa dalam satuan bulan penuh. Durasi minimum sewa diatur oleh masing-masing gedung, bukan ditanam di kode, sehingga gedung yang mewajibkan sewa minimal tiga bulan dan gedung yang mengizinkan sewa satu bulan dapat berjalan di sistem yang sama. Penyederhanaan ini memangkas skema basis data dari 41 tabel menjadi 13 tabel. Untuk mencegah pemesanan ganda, kamar dikunci selama proses pemesanan berlangsung, sehingga dua penghuni tidak dapat menyewa kamar yang sama pada periode yang sama.

4. **Tagihan dan pembayaran berjalan otomatis.** Begitu kontrak sewa tercatat, sistem menerbitkan tagihan, dan penghuni dapat membayar melalui Midtrans dengan Virtual Account atau QRIS. Status pembayaran diperbarui otomatis setelah notifikasi dari Midtrans diverifikasi. Pesan tagihan, pengingat jatuh tempo, dan bukti lunas dikirim lewat WhatsApp, sehingga pengelola tidak perlu lagi memeriksa bukti transfer satu per satu.

5. **Operasional gedung tercatat di satu tempat.** Penghuni melaporkan kerusakan lewat formulir yang disertai foto, lalu pengelola memverifikasi laporan dan menugaskan teknisi sampai laporan ditutup. Pengelola juga mencatat inventaris tiap kamar, jadwal perawatan rutin, pengeluaran operasional, dan tamu yang berkunjung. Fitur-fitur ini bersifat opsional dan dapat diaktifkan atau dimatikan sesuai kebutuhan masing-masing gedung.

6. **Login terpusat dan asisten analitik.** Autentikasi ditangani Keycloak, termasuk verifikasi email dan lupa kata sandi, sehingga backend cukup memeriksa token yang dibawa setiap permintaan. Di atas seluruh modul disediakan asisten analitik berbasis *Model Context Protocol* (MCP) yang dapat menjawab pertanyaan seperti "berapa kamar kosong di Gedung A bulan ini" dengan membaca data operasional. Asisten ini hanya dapat membaca data dan tetap dibatasi oleh hak akses gedung milik penanya.

Antarmuka dibangun dengan Flutter Web dan menerapkan Clean Architecture. Setiap peran mendapat dasbor sendiri: pemilik memantau seluruh gedung, pengelola menangani operasional harian satu gedung, dan penghuni mengurus kamar, tagihan, serta laporan kerusakannya.

Seluruh kemampuan sistem dirangkum menjadi tujuh belas fitur pada Tabel 3.1. Fitur *core* selalu aktif di setiap gedung karena menopang operasi dasar. Fitur opsional dapat dinyalakan per gedung. Contohnya, fitur penagihan dapat dimatikan pada asrama yang tidak memungut biaya sewa. Asisten analitik ditempatkan sebagai lapisan tambahan di atas modul bisnis dan tidak menambah tabel baru.

**Tabel 3.1 Daftar Fitur Sistem**

| Kode | Nama Fitur | Modul | Sifat |
|---|---|---|---|
| F01 | Autentikasi Pengguna dan Profil | Auth | Core |
| F02 | Pengaturan Hak Akses Dinamis | Auth | Core |
| F03 | Manajemen Multi-Gedung | Building | Core |
| F04 | Kebijakan Konfigurasi Gedung | Building | Core |
| F05 | Master Kamar dan Kapasitas | Room | Core |
| F06 | Alokasi dan Penempatan Hunian | Lease | Core |
| F07 | Dasbor Monitoring Hunian | Lease dan Room | Core |
| F08 | Penagihan Sewa Berkala | Finance | Opsional |
| F09 | Pembayaran Digital dan Kasir | Finance | Opsional |
| F10 | Denda Keterlambatan | Finance | Opsional |
| F11 | Pengeluaran Operasional | Finance | Opsional |
| F12 | Tiket Kerusakan Fasilitas | Maintenance | Opsional |
| F13 | Pemeliharaan Rutin Berkala | Maintenance | Opsional |
| F14 | Inventarisasi dan Audit Aset | Inventory | Opsional |
| F15 | Pengawasan Buku Tamu | Guest | Opsional |
| F16 | Notifikasi Pesan Otomatis | Notification | Opsional |
| F17 | Asisten Analitik | MCP | Ekstensi AI |

Rancangan untuk fitur-fitur di atas dijelaskan pada subbab berikutnya, yaitu desain sistem (3.2), alur proses bisnis (3.3), use case diagram (3.4), data flow diagram (3.5), activity diagram (3.6), rancangan basis data (3.7), dan rancangan antarmuka (3.8).

---

## 3.2 Desain Sistem

Sistem dirancang menggunakan pendekatan arsitektur *modular monolithic* pada sisi backend, dipadukan dengan *Clean Architecture* pada sisi antarmuka web, serta penyimpanan data relasional terpusat. Pendekatan ini menyatukan seluruh layanan operasional dalam satu kesatuan kode aplikasi dan satu basis data, namun tetap menjaga isolasi logika bisnis di setiap modul domain secara ketat.

Arsitektur keseluruhan terbagi ke dalam empat lapisan utama, yaitu lapisan antarmuka pengguna, lapisan adapter dan integrasi, lapisan backend modular monolith, serta lapisan basis data relasional.

> **Gambar 3.1 — Arsitektur Sistem Terpadu (Modular Monolith NestJS, 9 Modul):** `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.html` (diagram HTML).

Gambar 3.1 memperlihatkan hubungan kerja antara keempat lapisan tersebut:

1. **Lapisan Antarmuka (Flutter Web).** Lapisan ini menyajikan antarmuka pengguna berbasis peramban (*web browser*) untuk tiga peran: Dasbor Pemilik untuk melihat ringkasan portofolio lintas gedung, Dasbor Pengelola untuk operasional harian satu gedung binaan, dan Portal Penghuni untuk memilih kamar, membayar tagihan, serta menyampaikan keluhan. Pada dasbor pemilik dan pengelola juga tersedia Tab Asisten AI untuk mengajukan pertanyaan analitik operasional.
2. **Lapisan Adapter, Identitas, dan Protokol AI.** Lapisan ini menjembatani lalu lintas data dari luar menuju modul internal:
   - **Keycloak OIDC:** Menangani autentikasi identitas terpusat dan menerbitkan token akses JWT. Backend NestJS memverifikasi keabsahan token tersebut secara *stateless* menggunakan kunci publik JWKS tanpa perlu menghubungi server Keycloak pada setiap permintaan.
   - **REST API NestJS:** Menyediakan antarmuka komunikasi data HTTP yang terstandarisasi dengan amplop JSON seragam, validasi ketat DTO (*Data Transfer Object*), dan dokumentasi interaktif Swagger.
   - **MCP Server & Klien MCP:** Menjalankan protokol *Model Context Protocol* (MCP) berbasis format JSON-RPC 2.0. Klien AI (model bahasa besar/LLM) mengirimkan permintaan pemanggilan alat (*tool call*), lalu modul MCP mengeksekusi kueri agregasi baca secara terukur dan mengembalikan data faktual operasional.
3. **Lapisan Backend Modular Monolith.** Inti pemrosesan sistem dibangun dengan kerangka kerja NestJS yang membagi fungsi bisnis ke dalam sembilan modul terenkapsulasi. Antar-modul berkomunikasi melalui *event bus* untuk aksi mutasi data dan melalui *query gateway* untuk pembacaan lintas domain, tanpa relasi fisik antar-tabel. Di bagian luar, backend terhubung ke penyedia gerbang pembayaran Midtrans melalui `MidtransAdapter` dan ke penyedia WhatsApp Gateway melalui `WhatsAppAdapter`.
4. **Lapisan Data (PostgreSQL).** Berupa basis data relasional tunggal (*shared database*) yang menyimpan 13 tabel domain. Seluruh data operasional diisolasi per gedung menggunakan penyaring baris (*row-level scoping*) berbasis kolom `building_id`.

---

### 3.2.1 Dekomposisi Modul Backend

Backend NestJS dipecah ke dalam sembilan modul yang dikelompokkan ke dalam tiga tingkatan (*tier*) logis, sebagaimana ditunjukkan pada Gambar 3.2. Pengelompokan ini bertujuan menjaga keteraturan arah ketergantungan agar modul tingkat dasar tidak bergantung pada modul tingkat bisnis.

> **Gambar 3.2 — Dekomposisi Modulith 3-Tier (Sembilan Modul):** `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.html` (diagram HTML).

Struktur tiga tingkatan modul backend tersebut meliputi:

1. **Tier 1 — Modul Inti (*Core Modules*).** Modul-modul ini wajib aktif di semua skenario implementasi karena menopang operasional dasar:
   - **M1 (Auth):** Mengelola otorisasi pengguna, pemetaan peran Keycloak (`owner`, `admin`, `resident`), dan profil biodata pada tabel `users` serta `user_profiles`.
   - **M2 (Building):** Mengelola master data gedung properti pada tabel `buildings`, serta aturan kebijakan huni pada tabel `building_settings`.
   - **M3 (Room):** Mengelola data fisik unit kamar, nomor, tipe, tarif sewa, dan status kesiapan unit (`kosong`, `terisi`, `maintenance`) pada tabel `rooms`.
   - **M4 (Lease):** Mengelola siklus kontrak sewa bulanan dan penempatan kamar pada tabel `leases`, dilengkapi penguncian baris (*row locking*) untuk mencegah bentrok jadwal sewa.

2. **Tier 2 — Modul Bisnis Opsional (*Optional Business Modules*).** Modul penunjang yang dapat diaktifkan atau dinonaktifkan sesuai kebutuhan masing-masing gedung:
   - **O1 (Finance):** Mengelola siklus penagihan berkala pada tabel `invoices`, pencatatan pembayaran digital Midtrans pada tabel `payments`, serta denda keterlambatan flat pada tabel `fines`.
   - **O2 (Maintenance):** Mengelola penerimaan dan tindak lanjut laporan kerusakan fasilitas dari penghuni pada tabel `damage_reports`.
   - **O3 (Guest):** Mengelola pencatatan tamu yang berkunjung atau menginap pada tabel `guests`.
   - **O4 (Inventory):** Mengelola inventaris aset perabot kamar dan kondisinya pada tabel `inventories`.
   - **O5 (Notification):** Mengelola pencatatan riwayat pesan pengingat tagihan dan informasi operasional yang dikirim ke nomor WhatsApp penghuni pada tabel `notification_logs`.

3. **Tier 3 — Module Gateway dan Layanan Bersama.**
   - **Query Gateway:** Menyediakan fungsi agregasi baca lintas modul sehingga satu modul tidak perlu melakukan kueri langsung ke tabel milik modul lain.
   - **Event Bus:** Menyediakan jalur pengiriman pesan kejadian asinkron (*domain events*). Sebagai contoh, saat kontrak sewa baru terbentuk di modul Lease, event `LeaseCreated` dikirimkan ke modul Finance untuk menerbitkan invoice pertama dan ke modul Notification untuk mengirimkan pemberitahuan.
   - **Module Registry:** Memeriksa status fitur modul per gedung berdasarkan konfigurasi `building_settings`.
   - **Tenant Scope:** Memastikan setiap kueri basis data menyertakan klaim `building_id` milik pengguna yang aktif.

---

### 3.2.2 Arsitektur Antarmuka Pengguna (Clean Architecture pada Flutter Web)

Antarmuka web dikembangkan menggunakan Flutter Web dengan menerapkan pola *Clean Architecture*. Kode aplikasi dipisahkan secara tegas antara komponen tampilan dan aturan logika bisnis, sehingga antarmuka mudah dirawat dan siap diuji secara mandiri.

> **Gambar 3.3 — Arsitektur Frontend Flutter Web (Clean Architecture):** `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/c4_level3_flutter_clean_architecture.svg` (diagram C4 Level 3).

Gambar 3.3 memperlihatkan tiga lapisan utama pada aplikasi Flutter Web beserta komponen penunjangnya:

1. **Lapisan Presentasi (*Presentation Layer*).** Lapisan terluar yang berhubungan langsung dengan pengguna. Terdiri dari *Pages and Widgets* yang bertugas merender tampilan visual halaman serta menangkap aksi masukan pengguna, dan komponen *BLoC / Cubit* (*Business Logic Component*) yang mengelola *state* fitur. BLoC menerima masukan berupa *event*, memprosesnya ke lapisan domain, lalu memancarkan status perubahan (*loading*, *sukses*, *error*) ke antarmuka.
2. **Lapisan Domain (*Domain Layer*).** Inti dari aplikasi yang ditulis menggunakan bahasa Dart murni tanpa ketergantungan pada pustaka antarmuka Flutter maupun pustaka pihak ketiga. Lapisan ini memuat:
   - **Entity:** Objek representasi data bisnis murni (misalnya `Room`, `Lease`, `DamageReport`).
   - **Use Case:** Komponen yang mengeksekusi satu aksi bisnis spesifik (seperti alokasi kamar sewa, pelaporan kerusakan, atau penarikan tagihan).
   - **Repository (Interface):** Kontrak abstrak yang mendefinisikan kebutuhan operasi data tanpa terikat pada bagaimana data tersebut diambil.
3. **Lapisan Data (*Data Layer*).** Lapisan yang bertanggung jawab mengimplementasikan kontrak repositori yang didefinisikan oleh lapisan domain. Terdiri dari:
   - **Remote Data Source:** Bertugas melakukan panggilan jaringan HTTP ke backend NestJS menggunakan pustaka Dio dengan menyertakan *Bearer token* JWT.
   - **Model / DTO:** Menangani serialisasi dan deserialisasi JSON (`fromJson`) serta memetakan data respons API ke entitas domain (`toEntity`).
   - **Repository Implementation:** Mengoordinasikan pengambilan data dari *data source* dan mengubahnya menjadi format domain sebelum diteruskan ke *use case*.
4. **Lapisan Core dan Dependency Injection.** Fondasi teknis yang digunakan bersama di seluruh lapisan, meliputi penanganan galat terpusat (*Failure* dan *Exception*), *interceptor* Dio untuk menyematkan token autentikasi secara otomatis pada setiap *header* permintaan, serta pengaturan injeksi dependensi menggunakan *service locator* `get_it`.

---


## 3.3 Alur Proses Bisnis

Bagian ini memodelkan seluruh proses operasional utama sistem menggunakan diagram alur interaksi berurutan (*sequence diagram*) dan bagan alir proses. Notasi ini dipilih agar pertukaran pesan antar-aktor, antarmuka Flutter Web, modul backend NestJS, *event bus*, serta layanan eksternal (Midtrans, WhatsApp Gateway, Keycloak, dan LLM) dapat ditelusuri langkah demi langkah.

Terdapat sembilan alur proses bisnis yang mencakup seluruh fitur fungsional sistem, sebagaimana dirangkum pada Tabel 3.2.

**Tabel 3.2 Daftar Diagram Alur Proses Bisnis**

| No | Nama Alur Proses | Fitur yang Dicakup | Modul Utama yang Terlibat |
|---|---|---|---|
| 1 | Alokasi dan Penempatan Hunian | F04, F06 | Building, Room, Lease, Finance |
| 2 | Penagihan Sewa dan Pembayaran Digital | F08, F09, F10 | Finance, Lease, Notification, Midtrans |
| 3 | Penanganan Tiket Kerusakan Fasilitas | F12 | Maintenance, Room, Notification |
| 4 | Pemeliharaan Rutin Berkala | F13 | Maintenance, Notification, Finance |
| 5 | Pencatatan Pengeluaran Operasional | F11 | Finance |
| 6 | Pengawasan Buku Tamu | F15 | Guest, Finance |
| 7 | Pengaturan Hak Akses Dinamis | F02 | Auth |
| 8 | Pendataan dan Audit Inventaris Aset | F14 | Inventory, Room, Maintenance, Finance |
| 9 | Konsultasi AI melalui MCP | F17 | MCP, Auth, Module Gateway |

---

### 3.3.1 Alur Alokasi dan Penempatan Hunian

Alur ini mengatur proses pemilihan kamar oleh penghuni, validasi batas minimum sewa gedung, pencegahan pemesanan ganda melalui penguncian baris basis data, hingga penerbitan kontrak sewa.

> **Gambar 3.4 — Diagram Alur Proses Alokasi dan Penempatan Hunian:** `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.4 berjalan sebagai berikut:
1. Penghuni membuka katalog kamar pada antarmuka Flutter Web dengan memilih gedung yang dituju.
2. Sistem memanggil modul Building (`GET /api/buildings`) dan modul Room (`GET /api/rooms`) menggunakan penyaring `building_id` dari token sesi untuk menampilkan kamar berstatus kosong beserta tarif bulanannya.
3. Penghuni memilih nomor unit kamar dan durasi sewa dalam satuan bulan, lalu menekan tombol pengajuan sewa (`POST /api/leases`).
4. Modul Lease membaca konfigurasi `min_rental_months` pada tabel `building_settings` via modul Building. Jika durasi yang diminta kurang dari batas minimum gedung, sistem langsung menolak dengan kode HTTP 422.
5. Jika durasi memenuhi syarat, modul Lease membuka transaksi basis data dan mengunci baris kamar terkait menggunakan perintah `SELECT ... FOR UPDATE` guna memeriksa apakah ada kontrak aktif yang tumpang tindih. Jika kamar sedang diproses transaksi lain, sistem mengembalikan galat HTTP 422.
6. Jika kamar kosong dan valid, modul Lease menyimpan data kontrak dengan status awal `pending_payment` dan menerbitkan kejadian `LeaseCreated` ke *event bus*.
7. Pada properti komersial (modul Finance aktif), modul Finance menangkap kejadian tersebut, menerbitkan invoice periode pertama, meminta token transaksi SNAP ke Midtrans, dan mengembalikannya ke antarmuka untuk dibayar. Setelah notifikasi pelunasan diterima dari Midtrans via webhook, modul Lease mengubah status kontrak menjadi `confirmed` dan status kamar menjadi `terisi`.
8. Pada properti non-komersial seperti asrama (modul Finance nonaktif), kontrak langsung berstatus `confirmed` tanpa menunggu pembayaran.

---

### 3.3.2 Alur Penagihan Sewa dan Pembayaran Digital

Alur ini mengatur penerbitan tagihan berkala, opsi pembayaran otomatis melalui gerbang pembayaran Midtrans maupun manual melalui pengelola, penanganan denda keterlambatan, serta pengiriman bukti bayar otomatis via WhatsApp.

> **Gambar 3.5 — Diagram Alur Proses Penagihan dan Pembayaran Digital:** `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.5 meliputi:
1. Modul Finance menangkap kejadian `LeaseCreated` dari *event bus*, menghitung total kewajiban sewa (harga bulanan dikalikan durasi periode berjalan), lalu menerbitkan invoice baru berstatus `unpaid` dengan tenggat jatuh tempo tertentu.
2. Modul Finance menerbitkan event `InvoiceIssued`, yang ditangkap oleh modul Notification untuk mengirimkan tautan rincian tagihan ke nomor WhatsApp penghuni.
3. Penghuni dapat menyelesaikan pembayaran melalui dua jalur:
   - **Jalur Digital (Midtrans):** Penghuni memilih pembayaran online pada portal web. Modul Finance meminta token SNAP ke Midtrans. Penghuni menyelesaikan transaksi melalui Virtual Account atau QRIS. Server Midtrans mengirimkan notifikasi *webhook callback* bersertifikat tanda tangan SHA-512 ke backend NestJS. Backend memvalidasi tanda tangan tersebut, memperbarui status invoice menjadi `paid`, dan memancarkan event `PaymentSettled`.
   - **Jalur Manual:** Penghuni menyerahkan uang tunai atau bukti transfer manual kepada pengelola. Pengelola menekan tombol verifikasi manual (`POST /api/invoices/{id}/pay-manual`), sehingga status invoice diperbarui menjadi `paid` dan memancarkan event `PaymentSettled`.
4. Event `PaymentSettled` memicu modul Lease membuka blokir sewa dan modul Notification mengirim kuitansi pembayaran lunas resmi ke nomor WhatsApp penghuni.
5. Jika tagihan melewati tanggal jatuh tempo ditambah masa toleransi (*grace period*), proses terjadwal harian secara otomatis membubuhkan denda keterlambatan flat ke tagihan serta memancarkan event `InvoiceOverdue` untuk mengirimkan pesan peringatan.

---

### 3.3.3 Alur Penanganan Tiket Kerusakan Fasilitas

Alur ini memfasilitasi pelaporan kerusakan perabot atau fasilitas kamar oleh penghuni secara digital, penugasan teknisi oleh pengelola, hingga perbaikan tuntas dilaporkan.

> **Gambar 3.6 — Diagram Alur Proses Penanganan Tiket Kerusakan Fasilitas:** `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.6 meliputi:
1. Penghuni mengisi formulir komplain pada portal web, melampirkan deskripsi masalah dan foto bukti kerusakan (`POST /api/damage-reports`).
2. Modul Maintenance menyimpan laporan pada tabel `damage_reports` dengan status `open` dan memancarkan event `RoomDamaged`.
3. Jika kerusakan tergolong fatal dan unit tidak layak huni sementara waktu, modul Room memperbarui status kamar menjadi `maintenance` agar terkunci dari alokasi baru.
4. Pengelola menerima daftar tiket baru pada dasbor operasional, meninjau foto bukti, lalu menugaskan teknisi dengan mengubah status tiket menjadi `in_progress`.
5. Teknisi melakukan perbaikan fisik di lokasi. Setelah selesai, pengelola atau teknisi menutup tiket (`POST /api/damage-reports/{id}/resolve`) dengan melampirkan foto hasil perbaikan dan catatan teknis.
6. Modul Maintenance memancarkan event `RoomRepaired`. Modul Room mengembalikan status kamar menjadi `kosong` (atau tetap `terisi` jika penghuni masih menghuni), dan modul Notification mengirim pemberitahuan penyelesaian perbaikan kepada penghuni.

---

### 3.3.4 Alur Pemeliharaan Rutin Berkala

Alur ini mencakup agenda perawatan preventif fasilitas umum gedung (misalnya servis AC rutin, pembersihan tandon air, atau penyemprotan hama) yang dijalankan berdasarkan jadwal kalender.

> **Gambar 3.7 — Diagram Alur Proses Pemeliharaan Rutin Berkala:** `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.7 meliputi:
1. Pengelola mendaftarkan jadwal servis preventif pada kalender operasional dengan menetapkan jenis fasilitas, periode interval (misalnya setiap 3 bulan), dan tanggal jatuh tempo perawatan berikutnya.
2. Penjadwal latar belakang memeriksa kalender secara harian. Saat waktu memasuki H-7 sebelum jadwal jatuh tempo, sistem memicu pengingat otomatis di dasbor pengelola dan mengirimkan pesan WhatsApp ke teknisi penanggung jawab.
3. Teknisi melaksanakan servis fisik pada tanggal yang ditentukan.
4. Setelah pekerjaan selesai, pengelola mencatat realisasi servis pada sistem, memasukkan biaya riil yang timbul, dan menandai status perawatan menjadi `completed`.
5. Modul Maintenance menerbitkan event `MaintenanceServiceCompleted` ke modul Finance agar total biaya perawatan dapat dibukukan sebagai pengeluaran operasional gedung.

---

### 3.3.5 Alur Pencatatan Pengeluaran Operasional

Alur ini mengatur tata kelola pengeluaran kas operasional gedung demi menjamin akuntabilitas pembukuan keuangan dan menghasilkan kalkulasi laba bersih secara riil.

> **Gambar 3.8 — Diagram Alur Proses Pencatatan Pengeluaran Operasional:** `PA/docs/System design/02-BPMN/05_pengeluaran_operasional/alur_pengeluaran_operasional.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.8 meliputi:
1. Pengelola mengeluarkan kas untuk kebutuhan gedung (seperti pembayaran listrik PLN, tagihan air PDAM, langganan internet, pembelian perlengkapan kebersihan, atau upah teknisi).
2. Pengelola membuka menu pengeluaran pada dasbor web (`POST /api/expenses`), memilih kategori biaya, mengisi nominal, serta mengunggah foto nota fisik atau kuitansi pembayaran.
3. Modul Finance memvalidasi kelengkapan data dan menyimpan rekaman transaksi kas keluar.
4. Sistem secara otomatis menghitung laba bersih (*Net Operating Income*) gedung dengan mengurangkan total pengeluaran operasional dari seluruh penerimaan sewa dan denda pada periode berjalan.
5. Laporan arus kas dan grafik rekapitulasi laba bersih langsung tersaji pada Dasbor Pemilik secara *real-time*.

---

### 3.3.6 Alur Pengawasan Buku Tamu

Alur ini memfasilitasi pencatatan kunjungan tamu dari luar demi menjaga ketertiban lingkungan gedung kost, mencakup pra-registrasi, konfirmasi kedatangan (*check-in*), kepulangan (*check-out*), serta pengenaan biaya inap jika berlaku.

> **Gambar 3.9 — Diagram Alur Proses Pengawasan Buku Tamu:** `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.9 meliputi:
1. Penghuni mendaftarkan tamu yang akan datang berkunjung melalui portal web (`POST /api/guests`), mengisi nama tamu, kontak, dan perkiraan waktu berkunjung.
2. Saat tamu tiba di lokasi gedung, pengelola atau petugas keamanan memverifikasi identitas fisik tamu dan menekan tombol konfirmasi kehadiran (*check-in*).
3. Ketika tamu selesai berkunjung dan meninggalkan lokasi, petugas mencatat waktu kepulangan fisik (*check-out*). Modul Guest memperbarui status kunjungan menjadi `checked_out` dan memancarkan event `GuestCheckedOut`.
4. Jika tamu menginap melewati batas jam malam dan gedung menerapkan kebijakan tarif tamu menginap (`guest_fee_enabled = true`), modul Guest menghitung jumlah malam menginap dan meneruskan data biaya tersebut ke modul Finance untuk dimasukkan ke dalam invoice tagihan berkala penghuni yang bersangkutan.

---

### 3.3.7 Alur Pengaturan Hak Akses Dinamis (Dynamic RBAC)

Alur ini memungkinkan Pemilik untuk menyusun peran kerja staf (*custom roles*) secara mandiri dengan mencentang kumpulan izin modular (*granular permissions*) tanpa perlu melakukan perubahan kode sumber aplikasi.

> **Gambar 3.10 — Diagram Alur Proses Pengaturan Hak Akses Dinamis:** `PA/docs/System design/02-BPMN/07_pengaturan_hak_akses_dinamis/alur_hak_akses_dinamis.mmd` (bagan alir proses).

Tahapan proses pada Gambar 3.10 meliputi:
1. Pemilik membuka menu pengaturan peran dan izin pada dasbor web.
2. Sistem menyajikan daftar hak akses granular yang tersedia di setiap modul (seperti `room:read`, `room:write`, `finance:view_invoice`, `maintenance:update_ticket`).
3. Pemilik dapat memilih antara memakai peran standar bawaan (`owner`, `admin`, `resident`) atau membuat peran baru.
4. Jika membuat peran baru, Pemilik memasukkan nama jabatan (contoh: *"Wali Asrama"* atau *"Petugas Keamanan"*), mencentang hak akses yang ingin diberikan, lalu menyimpannya ke basis data.
5. Pemilik menautkan peran kustom tersebut ke akun pengguna staf yang ditunjuk.
6. Guard API backend dan menu antarmuka Flutter Web secara otomatis menyesuaikan tampilan dan membatasi rute akses sesuai izin yang aktif pada pengguna tersebut.

---

### 3.3.8 Alur Pendataan dan Audit Inventaris Aset

Alur ini mengatur inventarisasi perabotan dan barang fasilitas di dalam kamar, pelaksanaan audit fisik saat serah terima kunci, serta penanganan otomatis jika ditemukan barang rusak atau hilang.

> **Gambar 3.11 — Diagram Alur Proses Pendataan dan Audit Inventaris Aset:** `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.11 meliputi:
1. **Pendaftaran Aset:** Pengelola mendaftarkan barang aset ke modul Inventory (seperti kasur springbed, unit AC, lemari pakaian, meja belajar) lengkap dengan kode inventaris dan kondisi awal (*baik*). Modul memvalidasi keberadaan unit kamar sebelum menyimpan rekaman aset.
2. **Inspeksi Fisik (*Check-in / Check-out*):** Saat terjadi serah terima kamar dengan penghuni, pengelola membuka lembar checklist inventaris pada aplikasi dan memeriksa kondisi barang bersama penghuni.
3. **Hasil Verifikasi:**
   - Jika seluruh barang dalam kondisi lengkap dan baik, pengelola menandai audit sebagai *verified*.
   - Jika ditemukan barang yang rusak berat atau hilang, pengelola memperbarui kondisi aset menjadi `damaged` atau `lost`, lalu modul Inventory menerbitkan kejadian `AssetDamagedOrLost`.
4. **Penanganan Insiden:**
   - Kejadian tersebut memicu modul Maintenance untuk menerbitkan tiket perbaikan fasilitas secara otomatis.
   - Jika kerusakan disebabkan oleh kelalaian penghuni, modul Finance dapat menerbitkan tagihan penggantian kerugian aset ke dalam invoice penghuni yang bersangkutan.

---

### 3.3.9 Alur Konsultasi AI melalui Model Context Protocol (MCP)

Alur ini mengatur bagaimana model kecerdasan buatan (LLM) dapat menjawab pertanyaan manajerial dari pemilik atau pengelola menggunakan data operasional yang faktual secara aman melalui protokol MCP.

> **Gambar 3.12 — Diagram Alur Proses Konsultasi AI melalui Model Context Protocol:** `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.mmd` (diagram interaksi berurutan).

Tahapan proses pada Gambar 3.12 meliputi:
1. Pemilik atau pengelola menuliskan pertanyaan bahasa alami pada Tab Chat AI di antarmuka web (misalnya: *"Berapa total pendapatan Gedung Melati bulan ini?"*).
2. Klien antarmuka meneruskan pertanyaan tersebut beserta spesifikasi perkakas (*tool schema*) ke mesin LLM.
3. LLM menganalisis maksud pertanyaan dan menentukan alat baca yang tepat untuk dipanggil (misalnya `get_financial_summary`). LLM membalas ke antarmuka dengan permintaan eksekusi alat melalui protokol JSON-RPC 2.0.
4. Antarmuka web memanggil endpoint MCP Server di backend (`POST /mcp/tools/call`).
5. Modul MCP memverifikasi token pengguna dan memastikan bahwa pengguna memiliki hak akses sah terhadap properti yang ditanyakan (`building_id`). Permintaan lintas tenant yang tidak berhak akan langsung ditolak.
6. Modul MCP mengeksekusi kueri agregasi baca melalui *Module Gateway* ke basis data PostgreSQL. Basis data mengembalikan data angka faktual murni.
7. Modul MCP mencatat rekam jejak pemanggilan alat pada log audit aplikasi, lalu mengirimkan hasil JSON data faktual kembali ke LLM melalui antarmuka web.
8. LLM merangkum data angka faktual tersebut menjadi jawaban bahasa alami yang jelas, terstruktur, dan bebas dari halusinasi (*grounded data*). Antarmuka web menampilkan teks penjelasan beserta tabel ringkasan ke hadapan pengguna.

---


## 3.4 Use Case Diagram

*Use Case Diagram* memodelkan interaksi antara para pengguna sistem (*aktor*) dengan fungsionalitas yang disediakan oleh sistem aplikasi manajemen rumah kost terpadu. Pemodelan ini mempertegas batasan kewenangan (*role boundary*) antar-aktor sehingga setiap pengguna hanya dapat menjalankan fitur yang sesuai dengan peran dan cakupan propertinya.

Sistem melayani tiga kategori aktor manusia utama serta empat entitas sistem eksternal:
1. **Pemilik (*Owner*):** Memiliki wewenang tertinggi untuk mendaftarkan gedung properti baru, mengatur kebijakan tarif huni, membuat peran staf kustom melalui *Role Builder*, memantau dasbor performa portofolio bisnis seluruh gedung, serta mengajukan kueri analitik ke asisten AI.
2. **Pengelola (*Admin Gedung*):** Bertanggung jawab atas pengelolaan operasional harian pada satu gedung tertentu yang ditugaskan kepadanya. Pengelola mengelola ketersediaan unit kamar, memverifikasi permohonan sewa, menindaklanjuti tiket kerusakan fasilitas, mencatat pengeluaran kas operasional, mencatat buku tamu, serta melakukan audit inventaris kamar.
3. **Penghuni (*Resident*):** Menikmati layanan hunian mandiri (*self-service*) melalui portal web, mencakup pencarian dan reservasi kamar, pembayaran tagihan sewa digital melalui Midtrans, pelaporan keluhan kerusakan fasilitas berlampiran foto, pendaftaran tamu berkunjung, serta verifikasi kelengkapan inventaris kamar.
4. **Sistem Eksternal:** Terdiri dari Keycloak OIDC (autentikasi dan penerbit token JWT), Midtrans (pemrosesan pembayaran digital), WhatsApp Gateway (pengiriman pesan notifikasi otomatis), dan Mesin LLM (pemrosesan bahasa alami untuk kueri MCP).

> **Gambar 3.13 — Use Case Diagram Sistem Manajemen Rumah Kost:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Diagram Visual Use Case]`

Deskripsi hubungan penggunaan (*use case*) dirangkum ke dalam lima kelompok fungsi utama pada Tabel 3.3.

**Tabel 3.3 Ringkasan Spesifikasi Use Case Sistem**

| ID | Nama Use Case | Aktor Utama | Modul Domain | Lingkup Aksi Utama |
|---|---|---|---|---|
| UC-01 | Pengelolaan Gedung dan Kamar | Pemilik, Pengelola | Building, Room | Registrasi gedung baru, pengaturan `min_rental_months`, penambahan unit kamar, dan pengubahan status fisik unit. |
| UC-02 | Reservasi Kamar dan Pembayaran Digital | Penghuni | Lease, Finance | Pemilihan unit kamar, penguncian baris jadwal anti-bentrok, penerbitan tagihan otomatis, dan transaksi via Midtrans SNAP. |
| UC-03 | Pengajuan dan Penanganan Tiket Kerusakan | Penghuni, Pengelola, Teknisi | Maintenance, Room | Unggah foto keluhan kerusakan, isolasi status kamar jika fatal, penugasan teknisi, dan konfirmasi perbaikan selesai. |
| UC-04 | Konsultasi Wawasan Bisnis berbasis AI | Pemilik, Pengelola | MCP, Module Gateway | Eksekusi pemanggilan perkakas baca analitik (okupansi, kas masuk, piutang, dan tiket) secara deterministik tanpa halusinasi. |
| UC-05 | Inventarisasi Aset dan Buku Tamu | Pengelola, Penghuni | Inventory, Guest | Checklist fisik perabot kamar saat serah terima huni, pencatatan jam tamu masuk/keluar, dan pembebanan biaya inap. |

---

## 3.5 Data Flow Diagram (DFD)

*Data Flow Diagram* (DFD) memodelkan aliran pertukaran data secara terstruktur, mulai dari sumber data eksternal (*terminator*), tahapan proses komputasi di dalam sistem, hingga penyimpanan data (*data store*) yang terisolasi. Pemodelan DFD disusun mengikuti standar DeMarco dan Yourdon, yang membagi aliran data ke dalam dua tingkatan: Diagram Konteks (Level 0) dan Diagram Dekomposisi Fungsional (Level 1).

### 3.5.1 DFD Level 0 (Diagram Konteks)

Diagram Konteks mendefinisikan batas sistem (*system boundary*) secara menyeluruh. Seluruh fungsionalitas aplikasi diwakili oleh satu lingkaran proses utama (Proses 0.0) yang berinteraksi dengan tujuh entitas luar, tanpa menampilkan komponen penyimpanan data internal.

> **Gambar 3.14 — DFD Level 0 (Context Diagram):** `PA/docs/System design/03-DFD/dfd_level_0_context.html` (diagram HTML).

Berdasarkan Gambar 3.14, pertukaran data antara Proses 0.0 dengan ketujuh entitas luar meliputi:
1. **Pemilik Properti (*Owner*):** Mengirimkan data input berupa registrasi akun, pendaftaran gedung baru, pengaturan tarif dan durasi sewa, serta konfigurasi izin peran kustom. Sistem mengembalikan data keluaran berupa dasbor okupansi seluruh gedung, laporan laba rugi kas riil, dan rekapitulasi audit pengguna.
2. **Pengelola Gedung (*Admin*):** Memasukkan data unit kamar, penugasan teknisi tiket komplain, pencatatan nota kas keluar operasional, checklist kondisi aset kamar, dan konfirmasi kedatangan tamu. Sistem memberikan data keluaran berupa daftar kamar gedung binaan, tiket komplain masuk, jadwal jatuh tempo servis fasilitas H-7, serta rekapitulasi buku tamu aktif.
3. **Penghuni (*Resident*):** Memasukkan data permohonan reservasi kamar, konfirmasi pembayaran tagihan, tiket aduan kerusakan fasilitas berfoto, dan pra-registrasi identitas tamu. Sistem memberikan konfirmasi penempatan sewa, lembar invoice tagihan, tautan pembayaran online, serta notifikasi progres penanganan perbaikan.
4. **Keycloak (Identity Provider OIDC):** Menerima kredensial masuk dari pengguna dan mengembalikan token akses JWT yang memuat klaim peran serta batasan properti.
5. **Midtrans (Payment Gateway):** Menerima permintaan token transaksi SNAP (nomor order dan nominal tagihan), lalu mengirimkan notifikasi *webhook callback* mengenai status penyelesaian pembayaran secara *real-time*.
6. **WhatsApp Gateway:** Menerima muatan pesan teks otomatis (rincian invoice, pengingat jatuh tempo, kuitansi pelunasan) beserta nomor telepon tujuan, dan mengembalikan status konfirmasi pengiriman pesan.
7. **Model Bahasa AI (MCP Host / LLM):** Mengirimkan perintah pemanggilan perkakas analitik berbasis format JSON-RPC 2.0 dan menerima hasil ekstraksi data faktual JSON yang teragregasi secara aman.

---

### 3.5.2 DFD Level 1 (Dekomposisi Fungsional)

DFD Level 1 mendekomposisi Proses 0.0 menjadi sepuluh proses fungsional mandiri yang mencerminkan pembagian sembilan modul bisnis backend NestJS serta satu lapisan modul analitik MCP. Masing-masing proses bertanggung jawab penuh atas penyimpanan data (*data store*) yang dimilikinya, sebagaimana disajikan pada Gambar 3.15.

> **Gambar 3.15 — DFD Level 1 (Dekomposisi Fungsional):** `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.html` (diagram HTML).

Sepuluh proses fungsional beserta keterkaitannya dengan 13 *data store* (D1 sampai D13) dijelaskan pada Tabel 3.4.

**Tabel 3.4 Pemetaan Proses Fungsional, Fitur, dan Data Store pada DFD Level 1**

| No. Proses | Nama Proses Fungsional | Fitur yang Terkait | Data Store yang Dikelola | Keterangan Aliran Data |
|---|---|---|---|---|
| 1.0 | Kelola Akun dan Hak Akses | F01, F02 | D1 `users`, D2 `user_profiles` | Menyimpan kredensial akun, mengikat peran Keycloak, dan mengelola biodata pengguna. |
| 2.0 | Kelola Gedung dan Kebijakan | F03, F04 | D3 `buildings`, D4 `building_settings` | Menyimpan profil fisik gedung dan konfigurasi parameter operasional (durasi minimal sewa, tarif denda, toleransi tamu). |
| 3.0 | Kelola Kamar dan Kapasitas | F05 | D5 `rooms` | Mengelola data kamar, tipe, dan harga bulanan. Menerima instruksi penguncian status kamar dari proses pemeliharaan. |
| 4.0 | Kelola Alokasi Hunian | F06, F07 | D6 `leases` (membaca D4 dan D5) | Memvalidasi durasi sewa terhadap aturan gedung, mengunci kamar, menyimpan kontrak aktif, dan menyajikan dasbor okupansi. |
| 5.0 | Kelola Keuangan dan Transaksi | F08, F09, F10, F11 | D7 `invoices`, D8 `payments`, D9 `fines` | Menerbitkan tagihan sewa, memproses token SNAP Midtrans, mencatat pembayaran manual/digital, dan menghitung laba bersih operasional. |
| 6.0 | Kelola Pemeliharaan dan Tiket | F12, F13 | D10 `damage_reports` (memperbarui D5) | Menerima komplain kerusakan berlampiran foto dari penghuni, menugaskan teknisi, dan menjadwalkan servis rutin preventif. |
| 7.0 | Kelola Inventaris Aset | F14 | D11 `inventories` (membaca D5) | Mencatat daftar inventaris perabot unit kamar dan menyimpan hasil verifikasi checklist fisik saat serah terima. |
| 8.0 | Kelola Buku Tamu | F15 | D12 `guests` (meneruskan biaya ke D7) | Mencatat log kunjungan tamu dan meneruskan biaya inap tambahan ke modul keuangan jika tamu melewati batas jam malam. |
| 9.0 | Kirim Notifikasi Otomatis | F16 | D13 `notification_logs` | Menangkap kejadian transaksi dari *event bus* dan mengirim pesan pengingat tagihan/kuitansi ke WhatsApp Gateway. |
| 10.0 | Layani Asisten Analitik | F17 | Operasi baca murni dari D5, D6, D7, dan D10 | Mengagregasi data statistik ketersediaan kamar, keuangan, dan tiket kerusakan untuk disajikan kembali ke antarmuka AI. |

Aturan isolasi data ditegakkan secara ketat pada DFD Level 1: tidak ada proses yang diperkenankan menulis (*write*) langsung ke *data store* milik proses lain. Seluruh koordinasi lintas proses dilakukan secara asinkron melalui pertukaran kejadian domain (*event bus*) atau secara sinkron melalui antarmuka *Module Gateway*.

---


## 3.6 Activity Diagram

*Activity Diagram* memodelkan aspek dinamis dari sistem dengan menggambarkan logika prosedural, aliran aktivitas bisnis, dan titik percabangan keputusan dari sudut pandang alur kerja pengguna. Pemodelan ini memperjelas transisi status data operasional dari kondisi awal hingga kondisi akhir.

Pada sistem ini, aktivitas operasional difokuskan pada dua alur kerja utama yang paling krusial: alur alokasi kamar sewa beserta pembayaran digital, serta alur pelaporan kerusakan fasilitas hingga perbaikan selesai.

### 3.6.1 Alur Aktivitas Alokasi Kamar dan Pembayaran Digital

Aktivitas ini melibatkan calon penghuni, sistem antarmuka Flutter Web, dan modul backend. Proses dimulai saat penghuni memilih unit kamar dan durasi sewa, sistem memvalidasi batas minimum durasi gedung, mengunci ketersediaan kamar, menerbitkan invoice otomatis, memfasilitasi transaksi via Midtrans, hingga kamar berstatus terisi dan kuitansi dikirimkan.

> **Gambar 3.16 — Activity Diagram Alokasi Kamar dan Pembayaran Digital:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Diagram Visual Activity Diagram]`

### 3.6.2 Alur Aktivitas Pelaporan dan Penyelesaian Kerusakan Fasilitas

Aktivitas ini melibatkan penghuni, pengelola gedung, dan teknisi fisik. Alur dimulai dari pengisian komplain dan unggah bukti foto oleh penghuni, verifikasi urgensi kerusakan oleh pengelola (dengan opsi penguncian kamar ke status *maintenance* jika kerusakan parah), penugasan teknisi perbaikan, pelaksanaan servis fisik, penutupan tiket perbaikan berfoto, hingga pembaruan status kamar kembali normal.

> **Gambar 3.17 — Activity Diagram Pelaporan dan Penanganan Kerusakan Fasilitas:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Diagram Visual Activity Diagram]`

---

## 3.7 Rancangan Basis Data

Sistem menggunakan sistem manajemen basis data relasional (*Relational Database Management System* / RDBMS) PostgreSQL. Seluruh modul backend berbagi satu basis data bersama (*shared database*) yang telah disederhanakan menjadi 13 tabel domain utama. Isolasi data antar-gedung ditegakkan di level baris (*row-level scoping*) menggunakan kolom penanda `building_id`, sehingga seluruh kueri operasional terisolasi per properti secara aman dan efisien.

### 3.7.1 Entity Relationship Diagram (ERD 13 Tabel)

Model data dirancang dengan menegakkan batas modul (*modular boundaries*). Untuk menjaga agar modul backend tetap independen dan tidak saling terikat kaku di level skema fisik, ketergantungan relasi *Foreign Key* (FK) fisik antar-tabel dibatasi seminimal mungkin. Hubungan lintas domain dikelola melalui referensi logis (*soft reference*) yang diperkuat oleh indeks kolom.

> **Gambar 3.18 — Entity Relationship Diagram 13 Tabel (ADR-007):** `PA/docs/System design/04-ERD/erd_13_tabel.html` (diagram HTML).

Gambar 3.18 mengelompokkan 13 tabel domain ke dalam sembilan modul pemiliknya:
1. **Modul Auth (Identitas Pengguna):**
   - Tabel `users`: Menyimpan identitas akun pengguna, peran Keycloak (`owner`, `admin`, `resident`), surel, dan penanda gedung binaan bagi pengelola.
   - Tabel `user_profiles`: Menyimpan biodata tambahan pengguna (nomor KTP/identitas, telepon, dan alamat asal). Memiliki relasi fisik *One-to-One* ke tabel `users`.
2. **Modul Building (Master Properti & Kebijakan):**
   - Tabel `buildings`: Menyimpan data induk properti gedung (nama, alamat, kontak). Terhubung ke tabel `users` via relasi kepemilikan pemilik properti (`owner_id`).
   - Tabel `building_settings`: Menyimpan pasangan kunci-nilai konfigurasi dinamis per gedung, seperti durasi minimal sewa (`min_rental_months`), aturan denda keterlambatan (`fine_flat_amount`), dan kebijakan biaya tamu menginap (`guest_fee_enabled`).
3. **Modul Room (Fisik Kamar):**
   - Tabel `rooms`: Menyimpan data unit fisik kamar (nomor unit, lantai, tipe, kapasitas ranjang/orang, harga dasar bulanan, dan status fisik: `kosong`, `terisi`, `maintenance`).
4. **Modul Lease (Kontrak Huni):**
   - Tabel `leases`: Menyimpan transaksi kontrak sewa bulanan, tanggal mulai, durasi sewa, salinan harga bulanan saat transaksi (*price snapshot*), serta status sewa (`pending_payment`, `confirmed`, `active`, `completed`).
5. **Modul Finance (Keuangan & Pembayaran):**
   - Tabel `invoices`: Menyimpan lembar tagihan berkala yang diterbitkan untuk setiap periode kontrak sewa.
   - Tabel `payments`: Menyimpan catatan transaksi pelunasan, kanal bayar, token SNAP Midtrans, dan nomor referensi transaksi. Memiliki relasi fisik *Foreign Key* ke tabel `invoices`.
   - Tabel `fines`: Menyimpan data denda keterlambatan pembayaran sewa yang dikenakan secara otomatis.
6. **Modul Maintenance (Tiket Fasilitas):**
   - Tabel `damage_reports`: Menyimpan tiket keluhan kerusakan fasilitas kamar, keterangan masalah, tautan foto bukti, penugasan teknisi, dan status penyelesaian.
7. **Modul Guest (Buku Tamu):**
   - Tabel `guests`: Menyimpan riwayat tamu berkunjung pada suatu kontrak huni, waktu masuk riil, waktu kepulangan, serta tanda pembebanan biaya menginap.
8. **Modul Inventory (Inventaris Barang):**
   - Tabel `inventories`: Menyimpan daftar aset perabot kamar (nama barang, kode inventaris, jumlah unit, dan kondisi fisik barang: *baik*, *rusak ringan*, *rusak berat*, *hilang*).
9. **Modul Notification (Log Pesan):**
   - Tabel `notification_logs`: Menyimpan riwayat pengiriman notifikasi transaksi otomatis (jenis notifikasi, nomor WhatsApp tujuan, muatan pesan, status terkirim).

---

### 3.7.2 Kamus Data Sistem (Data Dictionary)

Spesifikasi struktur kolom, tipe data, serta aturan batasan (*constraints*) untuk ketiga belas tabel domain dirangkum pada Tabel 3.5.

**Tabel 3.5 Kamus Data 13 Tabel Domain Sistem**

| Nama Tabel | Nama Kolom | Tipe Data | Keterangan & Batasan Integritas |
|---|---|---|---|
| `users` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `email` | VARCHAR(150) | Alamat surel unik (*Unique*). |
| | `name` | VARCHAR(100) | Nama lengkap pengguna. |
| | `role` | VARCHAR(20) | Peran pengguna (`owner`, `admin`, `resident`). |
| | `assigned_building_id` | UUID (Nullable) | Gedung penugasan khusus peran pengelola (*soft reference*). |
| `user_profiles` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `user_id` | UUID | FK fisik menuju `users.id` (*One-to-One*). |
| | `id_card` | VARCHAR(50) | Nomor identitas KTP/SIM. |
| | `phone` | VARCHAR(25) | Nomor kontak aktif / WhatsApp. |
| `buildings` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `name` | VARCHAR(100) | Nama gedung properti kost. |
| | `address` | TEXT | Alamat fisik lengkap gedung. |
| | `owner_id` | UUID | FK fisik menuju `users.id` (pemilik properti). |
| `building_settings` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `key` | VARCHAR(50) | Kunci konfigurasi (kombinasi `building_id` + `key` bersifat unik). |
| | `value` | TEXT | Nilai konfigurasi parameter huni. |
| `rooms` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `room_number` | VARCHAR(20) | Nomor kamar (unik dalam satu gedung: `UQ(building_id, room_number)`). |
| | `monthly_price` | NUMERIC(12,2) | Tarif sewa bulanan unit kamar. |
| | `status` | VARCHAR(20) | Status kesiapan unit (`kosong`, `terisi`, `maintenance`). |
| `leases` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `room_id` | UUID | Kamar yang dihuni (*soft reference*). |
| | `user_id` | UUID | Penghuni terdaftar (*soft reference*). |
| | `start_month` | DATE | Tanggal mulai periode huni sewa. |
| | `duration_months` | INTEGER | Jumlah bulan masa sewa (wajib $\ge$ `min_rental_months`). |
| | `status` | VARCHAR(20) | Status kontrak (`pending_payment`, `confirmed`, `active`, `completed`). |
| `invoices` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `lease_id` | UUID | Kontrak sewa terkait (*soft reference*). |
| | `invoice_number` | VARCHAR(50) | Nomor referensi invoice resmi (*Unique*). |
| | `amount` | NUMERIC(12,2) | Total nilai kewajiban pembayaran. |
| | `due_date` | DATE | Tanggal batas akhir pembayaran (*jatuh tempo*). |
| | `status` | VARCHAR(20) | Status pelunasan (`unpaid`, `paid`, `overdue`, `cancelled`). |
| `payments` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `invoice_id` | UUID | FK fisik menuju `invoices.id`. |
| | `payment_method` | VARCHAR(30) | Kanal pembayaran (Virtual Account, QRIS, Tunai). |
| | `snap_token` | VARCHAR(100) | Token transaksi dari Midtrans SNAP. |
| | `amount` | NUMERIC(12,2) | Jumlah uang yang disetorkan. |
| | `status` | VARCHAR(20) | Status transaksi (`pending`, `settlement`, `failed`). |
| `fines` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `lease_id` | UUID | Kontrak sewa yang dikenai denda (*soft reference*). |
| | `amount` | NUMERIC(12,2) | Nominal denda keterlambatan flat. |
| | `reason` | VARCHAR(100) | Keterangan alasan penalti. |
| `damage_reports` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `room_id` | UUID | Unit kamar yang mengalami kerusakan (*soft reference*). |
| | `description` | TEXT | Uraian detail keluhan fasilitas. |
| | `photo_url` | VARCHAR(255) | Tautan foto bukti fisik kerusakan. |
| | `status` | VARCHAR(20) | Status penanganan (`open`, `in_progress`, `resolved`). |
| `inventories` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `building_id` | UUID | Penanda gedung (*soft reference*). |
| | `room_id` | UUID | Kamar lokasi aset berada (*soft reference*). |
| | `item_name` | VARCHAR(100) | Nama barang perabot fasilitas. |
| | `quantity` | INTEGER | Jumlah unit barang di dalam kamar. |
| | `condition` | VARCHAR(20) | Kondisi fisik (`good`, `minor_damage`, `heavy_damage`, `lost`). |
| `guests` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `lease_id` | UUID | Kontrak penghuni yang dikunjungi (*soft reference*). |
| | `guest_name` | VARCHAR(100) | Nama lengkap tamu berkunjung. |
| | `check_in_at` | TIMESTAMP | Waktu kedatangan tamu. |
| | `check_out_at` | TIMESTAMP (Nullable) | Waktu kepulangan fisik tamu. |
| `notification_logs` | `id` | UUID | Kunci utama (*Primary Key*). |
| | `event_type` | VARCHAR(50) | Jenis kejadian (`LeaseCreated`, `InvoiceIssued`, `PaymentSettled`). |
| | `recipient_phone` | VARCHAR(25) | Nomor WhatsApp tujuan. |
| | `message_payload` | TEXT | Teks pesan otomatis yang dikirimkan. |
| | `status` | VARCHAR(20) | Status pengiriman (`sent`, `delivered`, `failed`). |

---

### 3.7.3 Aturan Integritas dan Validasi Data

Untuk menjamin konsistensi dan keamanan data pada basis data bersama (*shared database*), sistem menerapkan sembilan aturan validasi ketat pada lapisan aplikasi dan basis data:
1. **Isolasi Data Gedung (*Row-Level Scoping*):** Setiap kueri pencarian, pembacaan, dan mutasi pada tabel operasional wajib menyertakan parameter `building_id` yang divalidasi dari klaim token akses JWT pengguna.
2. **Pencegahan Pemesanan Ganda (*Anti-Double Booking*):** Transaksi reservasi kamar wajib mengeksekusi penguncian baris (`SELECT ... FOR UPDATE`) pada tabel `rooms` dan memeriksa ketiadaan irisan tanggal sewa aktif pada tabel `leases` dalam satu blok transaksi basis data.
3. **Pemberlakuan Batas Minimum Durasi Sewa:** Masa sewa yang diajukan pada modul Lease wajib memenuhi nilai ambang batas minimal yang tersimpan pada `building_settings.min_rental_months` gedung bersangkutan.
4. **Keunikan Identitas Kamar:** Pasangan kolom `(building_id, room_number)` diwajibkan unik melalui indeks *unique constraint* pada tabel `rooms`, sehingga tidak dimungkinkan adanya nomor kamar kembar di satu gedung yang sama.
5. **Keunikan Referensi Invoice:** Kolom `invoice_number` pada tabel `invoices` wajib bersifat unik di seluruh sistem untuk mencegah tumpang-tindih pencatatan penagihan.
6. **Idempotensi Transaksi Pembayaran:** Webhook callback dari Midtrans diperiksa keabsahan tanda tangan SHA-512 miliknya dan diproses secara idempoten guna mencegah pencatatan pelunasan ganda atas satu transaksi yang sama.
7. **Presisi Finansial:** Kolom nilai uang pada tabel `rooms`, `leases`, `invoices`, `payments`, dan `fines` menggunakan tipe data `NUMERIC(12,2)` demi mencegah terjadinya galat pembulatan (*rounding errors*) pada angka desimal.
8. **Integritas Referensi Logis (*Soft Reference*):** Pengecekan keberadaan entitas lintas modul dilakukan pada lapisan logika aplikasi melalui *Module Gateway* sebelum operasi penyimpanan dieksekusi.
9. **Kemandirian Skema Modul:** Penghapusan atau penambahan modul opsional (seperti Maintenance atau Guest) tidak akan merusak struktur integritas fisik basis data modul core (Room dan Lease).

---

## 3.8 Rancangan Antarmuka Pengguna

Antarmuka pengguna dikembangkan berbasis web responsif menggunakan Flutter Web untuk memberikan pengalaman visual yang konsisten bagi seluruh kategori pengguna di peramban desktop dan tablet. Rancangan tata letak antarmuka dibagi menjadi tiga dasbor utama yang disesuaikan dengan kebutuhan peran masing-masing.

### 3.8.1 Dasbor Peran Pemilik (Owner Dashboard)

Halaman ini dirancang khusus bagi pemilik properti untuk menyajikan ikhtisar manajerial seluruh gedung kost yang dimiliki dalam satu tampilan terpadu.

> **Gambar 3.19 — Mockup Dasbor Peran Pemilik:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Gambar Mockup Dasbor Pemilik]`

Fitur unggulan pada antarmuka Pemilik meliputi:
- **Komponen Pemilih Gedung (*Building Switcher*):** Tombol pemilih gedung yang memungkinkan pemilik melihat statistik satu properti tertentu atau melihat rekapitulasi gabungan seluruh properti secara serentak.
- **Kartu Ringkasan Indikator Kinerja Utama (KPI Cards):** Menampilkan metrik keterisian kamar (*occupancy rate*), total pendapatan kas masuk, estimasi piutang tagihan tertunggak, serta laba bersih operasional gedung bulan berjalan.
- **Panel Konsultasi Asisten AI:** Kolom percakapan interaktif berbasis MCP yang memfasilitasi pemilik mengajukan pertanyaan manajerial dalam bahasa alami dan menerima ringkasan data analitik secara instan.

### 3.8.2 Dasbor Peran Pengelola (Admin Dashboard)

Halaman operasional harian yang dirancang bagi staf pengelola untuk memantau aktivitas satu gedung binaan yang ditugaskan kepadanya.

> **Gambar 3.20 — Mockup Dasbor Peran Pengelola:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Gambar Mockup Dasbor Pengelola]`

Fitur unggulan pada antarmuka Pengelola meliputi:
- **Matriks Denah Kamar (*Room Grid Status*):** Tampilan visual denah kamar per lantai dengan penanda warna status yang jelas: hijau (*kosong*), biru (*terisi*), dan kuning (*dalam perbaikan/maintenance*).
- **Papan Manajemen Tiket Komplain (*Maintenance Kanban / List*):** Daftar tiket laporan kerusakan fasilitas dari penghuni lengkap dengan foto kondisi fisik, tombol penugasan teknisi, serta tombol penutupan tiket perbaikan.
- **Menu Operasional Bersama:** Formulir pencatatan kas keluar operasional berlampiran foto nota, pencatatan check-in/check-out buku tamu, serta lembar checklist serah terima inventaris kamar.

### 3.8.3 Portal Peran Penghuni (Resident Portal)

Halaman mandiri (*self-service portal*) yang memberikan kenyamanan bagi penghuni dalam mengakses seluruh layanan hunian kost.

> **Gambar 3.21 — Mockup Portal Peran Penghuni:** `[GAMBAR BELUM ADA — Menunggu Penyusunan Gambar Mockup Portal Penghuni]`

Fitur unggulan pada antarmuka Penghuni meliputi:
- **Katalog Pemilihan Kamar:** Tampilan foto unit kamar, spesifikasi fasilitas, tarif bulanan, dan kalender ketersediaan kamar.
- **Halaman Riwayat Tagihan & Pembayaran Digital:** Tampilan invoice tagihan sewa berkala yang terintegrasi langsung dengan jendela pop-up pembayaran digital Midtrans SNAP (Virtual Account bank dan QRIS).
- **Formulir Tiket Komplain Fasilitas:** Formulir pelaporan kerusakan kamar yang memungkinkan penghuni mengambil atau mengunggah foto bukti fisik kerusakan secara langsung dari peramban serta memantau progres perbaikannya hingga tuntas.

---
