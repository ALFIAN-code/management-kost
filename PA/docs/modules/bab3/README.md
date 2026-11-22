# BAB 3 — DESAIN SISTEM

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.

---

## 3.1 Deskripsi Solusi

Berdasarkan permasalahan yang diuraikan pada BAB 1, solusi yang diusulkan adalah membangun ulang sistem manajemen rumah kost menjadi satu aplikasi web yang dapat melayani banyak gedung sekaligus. Sistem lama berasal dari empat proposal terpisah yang masing-masing menangani satu bagian, yaitu penghuni dan tamu, kamar dan reservasi, keuangan, serta operasional. Keempatnya tidak punya aturan bersama dan hanya dapat dipakai untuk satu gedung. Pada proyek akhir ini, keempat bagian tersebut disatukan ke dalam satu backend dengan batas modul yang jelas, satu basis data, dan satu aplikasi antarmuka untuk tiga peran pengguna: pemilik, pengelola, dan penghuni.

Solusi ini menjawab permasalahan pada BAB 1 melalui enam hal berikut.

1. **Satu sistem untuk banyak gedung.** Pemilik dapat mendaftarkan beberapa gedung pada satu instalasi sistem. Setiap baris data operasional diberi penanda gedung (`building_id`), sehingga pengelola hanya melihat data gedung yang ditugaskan kepadanya, sedangkan pemilik dapat melihat ringkasan seluruh gedung miliknya. Pemilik tidak perlu memasang server atau basis data baru setiap kali membuka cabang.

2. **Backend dibagi menjadi sembilan modul yang terpisah tegas.** Backend dibangun dengan NestJS dan dibagi menjadi modul Auth, Building, Room, Lease, Finance, Maintenance, Guest, Inventory, dan Notification. Setiap modul hanya mengelola tabel miliknya sendiri. Jika satu modul perlu memicu perubahan di modul lain, misalnya kontrak sewa baru yang harus menghasilkan tagihan, modul tersebut mengirim *event* dan tidak mengakses tabel modul lain secara langsung. Dengan cara ini, kesalahan pada satu modul tidak merembet ke modul lain, dan setiap modul dapat diuji sendiri.

3. **Sewa bulanan dengan aturan per gedung.** Sistem hanya melayani sewa dalam satuan bulan penuh. Durasi minimum sewa diatur oleh masing-masing gedung, bukan ditanam di kode, sehingga gedung yang mewajibkan sewa minimal tiga bulan dan gedung yang mengizinkan sewa satu bulan dapat berjalan di sistem yang sama. Sistem juga mengakomodasi kebijakan pemesanan fleksibel (bayar penuh bulan pertama atau uang tanda jadi/DP flat) per gedung melalui pola *Two-Phase Invoicing* tanpa menambah tabel cicilan baru. Untuk mencegah pemesanan ganda, kamar dikunci selama proses pemesanan berlangsung, sehingga dua penghuni tidak dapat menyewa kamar yang sama pada periode yang sama.

4. **Tagihan dan pembayaran berjalan otomatis.** Begitu kontrak sewa tercatat, sistem menerbitkan tagihan, dan penghuni dapat membayar melalui Midtrans dengan Virtual Account atau QRIS. Status pembayaran diperbarui otomatis setelah notifikasi dari Midtrans diverifikasi. Pesan tagihan, pengingat jatuh tempo, dan bukti lunas dikirim lewat WhatsApp, serta dilengkapi tombol aksi kirim pengingat manual bagi pengelola. Bagi calon penghuni yang membatalkan pemesanan sebelum tanggal mulai sewa, sistem memfasilitasi pengajuan pengembalian dana (*refund*) semi-manual yang diselesaikan via transfer m-banking pengelola berlampiran bukti transfer resmi.

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
| F04 | Kebijakan Konfigurasi Gedung (Durasi, Mode DP & Refund) | Building | Core |
| F05 | Master Kamar dan Kapasitas | Room | Core |
| F06 | Alokasi dan Penempatan Hunian | Lease | Core |
| F07 | Dasbor Monitoring Hunian | Lease dan Room | Core |
| F08 | Penagihan Sewa Berkala & DP (Two-Phase Invoicing) | Finance | Opsional |
| F09 | Pembayaran Digital, Kasir & Refund Semi-Manual | Finance | Opsional |
| F10 | Denda Keterlambatan | Finance | Opsional |
| F11 | Pengeluaran Operasional | Finance | Opsional |
| F12 | Tiket Kerusakan Fasilitas | Maintenance | Opsional |
| F13 | Pemeliharaan Rutin Berkala | Maintenance | Opsional |
| F14 | Inventarisasi dan Audit Aset | Inventory | Opsional |
| F15 | Pengawasan Buku Tamu | Guest | Opsional |
| F16 | Notifikasi Pesan Otomatis | Notification | Opsional |
| F17 | Asisten Analitik | MCP | Ekstensi AI |

Rancangan untuk fitur-fitur di atas dijelaskan pada subbab berikutnya, yaitu desain sistem (3.2), alur proses bisnis (3.3), use case diagram (3.4), data flow diagram (3.5), rancangan basis data (3.6), dan rancangan antarmuka (3.7).

---

## 3.2 Desain Sistem

Sebagai solusi langsung atas permasalahan arsitektur sistem lama (*before*) yang telah diuraikan pada Subbab 2.1.2 (lihat Gambar 2.1 di Bab II), sistem baru (*after*) ini dirancang menggunakan pendekatan arsitektur *modular monolithic* pada sisi *backend*, dipadukan dengan *Clean Architecture* pada sisi antarmuka web, serta penyimpanan data relasional terpusat. Pendekatan ini menyatukan seluruh layanan operasional dalam satu kesatuan kode aplikasi dan satu basis data, namun tetap menjaga isolasi logika bisnis di setiap modul domain secara ketat — menggantikan struktur 12 modul Laravel pada sistem lama yang sebelumnya hanya terpisah di level folder.

> **Gambar 3.1 — Arsitektur Sistem Keseluruhan:** `PA/docs/System design/01-Gambaran-umum/01_arsitektur_keseluruhan/arsitektur_terpadu.png`

1. **Lapisan Antarmuka (Flutter Web).** Lapisan ini menyajikan antarmuka pengguna berbasis peramban (*web browser*) untuk tiga peran: Dasbor Pemilik untuk melihat ringkasan portofolio lintas gedung, Dasbor Pengelola untuk operasional harian satu gedung binaan, dan Portal Penghuni untuk memilih kamar, membayar tagihan, serta menyampaikan keluhan. Pada dasbor pemilik dan pengelola juga tersedia Tab Asisten AI untuk mengajukan pertanyaan analitik operasional.
2. **Lapisan Adapter, Identitas, dan Protokol AI.** Lapisan ini menjembatani lalu lintas data dari luar menuju modul internal:
   - **Keycloak OIDC:** Menangani autentikasi identitas terpusat dan menerbitkan token akses JWT. Backend NestJS memverifikasi keabsahan token tersebut secara *stateless* menggunakan kunci publik JWKS tanpa perlu menghubungi server Keycloak pada setiap permintaan.
   - **REST API NestJS:** Menyediakan antarmuka komunikasi data HTTP yang terstandarisasi dengan amplop JSON seragam, validasi ketat DTO (*Data Transfer Object*), dan dokumentasi interaktif Swagger.
   - **MCP Server & Klien MCP:** Menjalankan protokol *Model Context Protocol* (MCP) berbasis format JSON-RPC 2.0. Klien AI (model bahasa besar/LLM) mengirimkan permintaan pemanggilan alat (*tool call*), lalu modul MCP mengeksekusi kueri agregasi baca secara terukur dan mengembalikan data faktual operasional.
3. **Lapisan Backend Modular Monolith.** Inti pemrosesan sistem dibangun dengan kerangka kerja NestJS yang membagi fungsi bisnis ke dalam sembilan modul terenkapsulasi. Antar-modul berkomunikasi melalui *event bus* untuk aksi mutasi data dan melalui *query gateway* untuk pembacaan lintas domain, tanpa relasi fisik antar-tabel. Di bagian luar, backend terhubung ke penyedia gerbang pembayaran Midtrans melalui `MidtransAdapter` dan ke penyedia WhatsApp Gateway melalui `WhatsAppAdapter`.
4. **Lapisan Data (PostgreSQL).** Berupa basis data relasional tunggal (*shared database*). Seluruh data operasional diisolasi per gedung menggunakan *row-level scoping* berbasis kolom `building_id`.

---

### 3.2.1 Klasifikasi Modul: Core dan Opsional

Sistem dibangun dengan arsitektur Modular Monolith menggunakan NestJS. Setiap modul terenkapsulasi dan tidak saling terikat melalui Foreign Key fisik lintas modul. Komunikasi antar modul dilakukan melalui *event bus* untuk aksi mutasi dan *module gateway* untuk pembacaan lintas domain.

**Tabel 3.5 Klasifikasi Modul Core dan Opsional**

| Klasifikasi | Modul (Istilah Teknis) | Nama Fungsi Awam | Tabel Utama | Karakteristik |
|-------------|------------------------|------------------|-------------|---------------|
| **Core (Wajib Aktif)** | User & Access Control | Pengguna & Akses | `users`, `user_profiles`, `roles`, `permissions`, `role_permissions` | Konteks identitas dan peran pengguna. Harus selalu aktif. |
| | Property & Building | Gedung | `buildings`, `building_settings` | Master gedung dan konfigurasi kebijakan per gedung. |
| | Room Management | Kamar | `rooms` | Data fisik unit kamar. |
| | Occupancy & Schedule | Sewa & Penempatan | `leases` | Kontrak sewa dan alokasi hunian. |
| | Occupancy Dashboard | Pantau Kamar | — (tanpa tabel fisik) | Visualisasi denah dan ketersediaan kamar. |
| **Opsional (Plug & Play)** | Finance & Billing | Keuangan & Tagihan | `invoices`, `payments`, `fines`, `expenses` | Aktif untuk properti berbayar; bisa dinonaktifkan pada asrama/mes gratis. |
| | Maintenance & Facility | Perawatan | `damage_reports`, `maintenance_schedules` | Aktif jika gedung butuh tiket kerusakan dan jadwal perawatan. |
| | Asset & Inventory | Inventaris | `inventories`, `room_inventories` | Aktif jika gedung memiliki inventaris perabot. |
| | Guest Logging | Buku Tamu | `guests` | Aktif jika properti mencatat tamu. |
| | Notification Service | Notifikasi | `notification_logs` | Aktif jika terhubung ke gateway pesan. |

**Aturan utama:** Lima modul inti (*core*) wajib aktif di semua kombinasi skenario. Modul tambahan (*opsional*) dapat diaktifkan atau dinonaktifkan per gedung tanpa memutus modul lain.

Untuk memudahkan pemahaman bagi orang awam maupun penguji, konsep modularitas ini diilustrasikan dengan analogi susunan balok Lego pada Gambar 3.19.

> **Gambar 3.19 — Arsitektur Modular Monolith:** `PA/docs/System design/04-ERD/diagram_klasifikasi_modul.png`

Berdasarkan Gambar 3.19, cara kerja modularitas sistem dapat dianalogikan sebagai berikut:
1. **Module Gateway sebagai Papan Alas (*Baseplate* ungu):** Bertindak sebagai penghubung komunikasi pusat. Semua modul hanya menancap pada alas ini dan tidak saling mengikat secara langsung antar-balok.
2. **Modul Inti sebagai Balok Pondasi (Balok biru di bawah):** Lima modul inti terpasang permanen pada papan alas. Tanpa kelima balok ini, struktur sistem tidak dapat berdiri.
3. **Modul Tambahan sebagai Balok Bongkar-Pasang (Balok hijau di atas):** Lima modul bisnis dapat dipasang (*ON*) atau dicabut (*OFF*) secara fleksibel sesuai profil operasional masing-masing gedung.
4. **Independensi saat Modul Dilepas:** Balok *Keuangan & Tagihan* digambarkan terangkat dari posisinya untuk mencontohkan kondisi asrama mahasiswa atau mes karyawan gratis yang tidak memungut biaya sewa. Ketika balok keuangan dilepas, papan alas dan balok lainnya tetap kokoh berdiri tanpa memicu kesalahan (*crash* atau galat basis data).

#### Konteks Data Antar-Modul (Tanpa FK Fisik)

Seluruh modul berbagi satu basis data PostgreSQL dengan isolasi baris (*row-level scoping*) melalui kolom `building_id`. Modul yang membutuhkan konteks gedung atau pengguna **tidak mengakses tabel modul lain secara langsung**, melainkan memperolehnya dari klaim token akses JWT yang divalidasi oleh backend.

Contoh:
- Modul Keuangan mengetahui `building_id` dari klaim token, bukan dengan *join* langsung ke tabel `buildings`.
- Modul Kamar menerima `building_id` dari parameter permintaan yang telah divalidasi terhadap klaim token, bukan melalui relasi FK fisik ke tabel `buildings`.

Dengan pola ini, menonaktifkan satu modul opsional tidak memicu kesalahan integritas data pada modul lain.

---

### 3.2.2 Arsitektur Backend

Berbeda dengan arsitektur sebelum *rewrite* pada Gambar 2.10 yang mengizinkan pemanggilan langsung antar-*service* lintas domain, pada rancangan baru ini *backend* NestJS dipecah ke dalam sembilan modul yang dikelompokkan ke dalam tiga tingkatan (*tier*) logis, sebagaimana ditunjukkan pada Gambar 3.2. Pengelompokan ini bertujuan menjaga keteraturan arah ketergantungan agar modul tingkat dasar tidak bergantung pada modul tingkat bisnis, serta mewajibkan seluruh komunikasi lintas modul melewati *Module Gateway*.

> **Gambar 3.2 — Dekomposisi Modul Backend NestJS:** `PA/docs/System design/01-Gambaran-umum/02_arsitektur_backend/arsitektur_backend_modulith.png`

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

### 3.2.3 Arsitektur Antarmuka Pengguna (Clean Architecture pada Flutter Web)

Antarmuka web dikembangkan menggunakan Flutter Web dengan menerapkan pola *Clean Architecture*. Kode aplikasi dipisahkan secara tegas antara komponen tampilan dan aturan logika bisnis, sehingga antarmuka mudah dirawat dan siap diuji secara mandiri.

> **Gambar 3.3 — Arsitektur Antarmuka Flutter Web berbasis Clean Architecture:** `PA/docs/System design/01-Gambaran-umum/03_arsitektur_frontend/c4_level3_flutter_clean_architecture.png`

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

Bagian ini memodelkan seluruh proses operasional utama sistem menggunakan diagram aktivitas lintas lajur (*swimlane activity diagram*). Notasi ini dipilih agar urutan aktivitas dan pertukaran data antar-aktor, sistem kost (antarmuka Flutter Web, modul backend NestJS, dan *event bus*), serta layanan eksternal (Midtrans, WhatsApp Gateway, Keycloak, dan LLM) dapat ditelusuri langkah demi langkah.

### 3.3.1 Alur Alokasi dan Penempatan Hunian

Alur ini mengatur proses pemilihan kamar oleh penghuni, validasi batas minimum sewa gedung, pencegahan pemesanan ganda melalui penguncian baris basis data, hingga penerbitan kontrak sewa.

> **Gambar 3.4 — Activity Diagram Alokasi dan Penempatan Hunian:** `PA/docs/System design/02-BPMN/01_alokasi_penempatan_hunian/alur_alokasi_penempatan.png`

Tahapan proses pada Gambar 3.4 berjalan sebagai berikut:
1. Penghuni membuka katalog kamar pada antarmuka Flutter Web dengan memilih gedung yang dituju.
2. Sistem memanggil modul Building dan modul Room menggunakan penyaring `building_id` dari token sesi untuk menampilkan kamar berstatus kosong beserta tarif bulanannya.
3. Penghuni memilih nomor unit kamar dan durasi sewa dalam satuan bulan, lalu menekan tombol pengajuan sewa.
4. Modul Lease membaca konfigurasi `min_rental_months` pada tabel `building_settings` via modul Building. Jika durasi yang diminta kurang dari batas minimum gedung, sistem langsung menolak dengan kode HTTP 422.
5. Jika durasi memenuhi syarat, modul Lease membuka transaksi basis data dan mengunci baris kamar terkait menggunakan perintah `SELECT ... FOR UPDATE` guna memeriksa apakah ada kontrak aktif yang tumpang tindih. Jika kamar sedang diproses transaksi lain, sistem mengembalikan galat HTTP 422.
6. Jika kamar kosong dan valid, modul Lease menyimpan data kontrak dengan status awal `pending_payment` dan menerbitkan kejadian `LeaseCreated` ke *event bus*.
7. Pada properti komersial (modul Finance aktif), modul Finance menangkap kejadian tersebut, menerbitkan invoice periode pertama, meminta token transaksi SNAP ke Midtrans, dan mengembalikannya ke antarmuka untuk dibayar. Setelah notifikasi pelunasan diterima dari Midtrans via webhook, modul Lease mengubah status kontrak menjadi `confirmed` dan status kamar menjadi terisi.
8. Mekanisme penagihan menerapkan skema Dua Fase (*Two-Phase Invoicing*): Fase 1 menerbitkan invoice DP/*booking fee* (atau pembayaran sewa bulan/periode pertama) untuk mengonfirmasi reservasi, dan Fase 2 menerbitkan invoice pelunasan atau sewa berkala berikutnya sebelum tanggal jatuh tempo huni.
9. Pada properti non-komersial seperti asrama (modul Finance nonaktif), kontrak langsung berstatus `confirmed` tanpa menunggu pembayaran.

---

### 3.3.2 Alur Penagihan Sewa dan Pembayaran Digital

Alur ini mengatur penerbitan tagihan berkala, opsi pembayaran otomatis melalui gerbang pembayaran Midtrans maupun manual melalui pengelola, penanganan denda keterlambatan, serta pengiriman bukti bayar otomatis via WhatsApp.

> **Gambar 3.5 — Diagram Alur Proses Penagihan Sewa dan Pembayaran Digital:** `PA/docs/System design/02-BPMN/02_penagihan_pembayaran/alur_penagihan_pembayaran.png`

Tahapan proses pada Gambar 3.5 meliputi:
1. Modul Finance menangkap kejadian `LeaseCreated` dari *event bus*, menghitung total kewajiban sewa (harga bulanan dikalikan durasi periode berjalan), lalu menerbitkan invoice baru berstatus `unpaid` dengan tenggat jatuh tempo tertentu.
2. Modul Finance menerbitkan event `InvoiceIssued`, yang ditangkap oleh modul Notification untuk mengirimkan tautan rincian tagihan ke nomor WhatsApp penghuni.
3. Penghuni dapat menyelesaikan pembayaran melalui dua jalur:
   - **Jalur Digital (Midtrans):** Penghuni memilih pembayaran online pada portal web. Modul Finance meminta token SNAP ke Midtrans. Penghuni menyelesaikan transaksi melalui Virtual Account atau QRIS. Server Midtrans mengirimkan notifikasi *webhook callback* bersertifikat tanda tangan SHA-512 ke backend NestJS. Backend memvalidasi tanda tangan tersebut, memperbarui status invoice menjadi `paid`, dan memancarkan event `PaymentSettled`.
   - **Jalur Manual:** Penghuni menyerahkan uang tunai atau bukti transfer manual kepada pengelola. Pengelola menekan tombol verifikasi manual (`POST /api/invoices/{id}/pay-manual`), sehingga status invoice diperbarui menjadi `paid` dan memancarkan event `PaymentSettled`.
4. Event `PaymentSettled` memicu modul Lease membuka blokir sewa dan modul Notification mengirim kuitansi pembayaran lunas resmi ke nomor WhatsApp penghuni.
5. Pengajuan pengembalian dana (*refund*) akibat pembatalan sewa diproses secara semi-manual: penghuni mengajukan permohonan *refund* melalui portal web, pengelola meninjau dan menyetujui rincian perhitungan *refund*, lalu pembayaran fisik *refund* ditransfer manual oleh pengelola sebelum status invoice/kontrak diperbarui di sistem.
6. Jika tagihan melewati tanggal jatuh tempo ditambah masa toleransi (*grace period*), proses terjadwal harian secara otomatis membubuhkan denda keterlambatan flat ke tagihan serta memancarkan event `InvoiceOverdue` untuk mengirimkan pesan peringatan.

---

### 3.3.3 Alur Penanganan Tiket Kerusakan Fasilitas

Alur ini memfasilitasi pelaporan kerusakan perabot atau fasilitas kamar oleh penghuni secara digital, penugasan teknisi oleh pengelola, hingga perbaikan tuntas dilaporkan.

> **Gambar 3.6 — Diagram Alur Proses Penanganan Tiket Kerusakan Fasilitas:** `PA/docs/System design/02-BPMN/03_laporan_kerusakan_fasilitas/alur_laporan_kerusakan.png`

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

> **Gambar 3.7 — Diagram Alur Proses Pemeliharaan Rutin Berkala:** `PA/docs/System design/02-BPMN/04_pemeliharaan_rutin_berkala/alur_pemeliharaan_rutin.png`

Tahapan proses pada Gambar 3.7 meliputi:
1. Pengelola mendaftarkan jadwal servis preventif pada kalender operasional dengan menetapkan jenis fasilitas, periode interval (misalnya setiap 3 bulan), dan tanggal jatuh tempo perawatan berikutnya.
2. Penjadwal latar belakang memeriksa kalender secara harian. Saat waktu memasuki H-7 sebelum jadwal jatuh tempo, sistem memicu pengingat otomatis di dasbor pengelola dan mengirimkan pesan WhatsApp ke teknisi penanggung jawab.
3. Teknisi melaksanakan servis fisik pada tanggal yang ditentukan.
4. Setelah pekerjaan selesai, pengelola mencatat realisasi servis pada sistem, memasukkan biaya riil yang timbul, dan menandai status perawatan menjadi `completed`.
5. Modul Maintenance menerbitkan event `MaintenanceServiceCompleted` ke modul Finance agar total biaya perawatan dapat dibukukan sebagai pengeluaran operasional gedung.

---

### 3.3.5 Alur Pencatatan Pengeluaran Operasional

Alur ini mengatur tata kelola pengeluaran kas operasional gedung demi menjamin akuntabilitas pembukuan keuangan dan menghasilkan kalkulasi laba bersih secara riil.

> **Gambar 3.8 — Diagram Alur Proses Pencatatan Pengeluaran Operasional:** `PA/docs/System design/02-BPMN/05_pengeluaran_operasional/alur_pengeluaran_operasional.png`

Tahapan proses pada Gambar 3.8 meliputi:
1. Pengelola mengeluarkan kas untuk kebutuhan gedung (seperti pembayaran listrik PLN, tagihan air PDAM, langganan internet, pembelian perlengkapan kebersihan, atau upah teknisi).
2. Pengelola membuka menu pengeluaran pada dasbor web, memilih kategori biaya, mengisi nominal, serta mengunggah foto nota fisik atau kuitansi pembayaran.
3. Modul Finance memvalidasi kelengkapan data dan menyimpan rekaman transaksi kas keluar.
4. Sistem secara otomatis menghitung laba bersih (*Net Operating Income*) gedung dengan mengurangkan total pengeluaran operasional dari seluruh penerimaan sewa dan denda pada periode berjalan.
5. Laporan arus kas dan grafik rekapitulasi laba bersih langsung tersaji pada Dasbor Pemilik secara *real-time*.

---

### 3.3.6 Alur Pengawasan Buku Tamu

Alur ini memfasilitasi pencatatan kunjungan tamu dari luar demi menjaga ketertiban lingkungan gedung kost, mencakup pra-registrasi, konfirmasi kedatangan (*check-in*), kepulangan (*check-out*), serta pengenaan biaya inap jika berlaku.

> **Gambar 3.9 — Diagram Alur Proses Pengawasan Buku Tamu:** `PA/docs/System design/02-BPMN/06_pengawasan_buku_tamu/alur_pengawasan_buku_tamu.png`

Tahapan proses pada Gambar 3.9 meliputi:
1. Penghuni mendaftarkan tamu yang akan datang berkunjung melalui portal web (`POST /api/guests`), mengisi nama tamu, kontak, dan perkiraan waktu berkunjung.
2. Saat tamu tiba di lokasi gedung, pengelola atau petugas keamanan memverifikasi identitas fisik tamu dan menekan tombol konfirmasi kehadiran (*check-in*).
3. Ketika tamu selesai berkunjung dan meninggalkan lokasi, petugas mencatat waktu kepulangan fisik (*check-out*). Modul Guest memperbarui status kunjungan menjadi `checked_out` dan memancarkan event `GuestCheckedOut`.
4. Jika tamu menginap melewati batas jam malam dan gedung menerapkan kebijakan tarif tamu menginap (`guest_fee_enabled = true`), modul Guest menghitung jumlah malam menginap dan meneruskan data biaya tersebut ke modul Finance untuk dimasukkan ke dalam invoice tagihan berkala penghuni yang bersangkutan.

---

### 3.3.7 Alur Pengaturan Hak Akses Dinamis (Dynamic RBAC)

Alur ini memungkinkan Pemilik untuk menyusun peran kerja staf (*custom roles*) secara mandiri dengan mencentang kumpulan izin modular (*granular permissions*) tanpa perlu melakukan perubahan kode sumber aplikasi.

> **Gambar 3.10 — Diagram Alur Proses Pengaturan Hak Akses Dinamis:** `PA/docs/System design/02-BPMN/07_pengaturan_hak_akses_dinamis/alur_hak_akses_dinamis.png`

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

> **Gambar 3.11 — Diagram Alur Proses Pendataan dan Audit Inventaris Aset:** `PA/docs/System design/02-BPMN/08_pendataan_inventaris_aset/alur_inventaris_aset.png`

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

> **Gambar 3.12 — Diagram Alur Proses Konsultasi AI melalui MCP:** `PA/docs/System design/02-BPMN/09_konsultasi_ai_mcp/bpmn_konsultasi_ai_mcp.png`

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

> **Gambar 3.13 — Use Case Diagram Sistem Manajemen Rumah Kost:** `PA/docs/System design/05-Use-Case/use_case_global.png`

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

> **Gambar 3.14 — Data Flow Diagram (DFD) Level 0 / Diagram Konteks:** `PA/docs/System design/03-DFD/dfd_level_0_context.png`

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

> **Gambar 3.15 — Data Flow Diagram (DFD) Level 1:** `PA/docs/System design/03-DFD/dfd_level_1_dekomposisi.png`

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

## 3.6 Rancangan Basis Data

Sistem menggunakan sistem manajemen basis data relasional (*Relational Database Management System* / RDBMS) PostgreSQL. Seluruh modul backend berbagi satu basis data bersama (*shared database*). Isolasi data antar-gedung ditegakkan di level baris (*row-level scoping*) menggunakan kolom penanda `building_id`, sehingga seluruh kueri operasional terisolasi per properti secara aman dan efisien.

### 3.6.1 Entity Relationship Diagram

Rancangan basis data baru (*after*) ini merupakan hasil penyederhanaan dan *refactoring* menyeluruh terhadap ERD sistem sebelum *rewrite* pada Subbab 2.1.2 (lihat Gambar 2.2 di Bab II) yang sebelumnya membengkak hingga 41 tabel akibat percabangan masa sewa dan duplikasi tabel penampung. Pada sistem baru ini, model data dirancang dengan menegakkan batas modul (*modular boundaries*) melalui penyederhanaan aturan sewa menjadi bulanan murni dan penerapan pola *Two-Phase Invoicing*. Untuk menjaga agar modul backend tetap independen dan tidak saling terikat kaku di level skema fisik seperti pada sistem lama, ketergantungan relasi *Foreign Key* (FK) fisik hanya diizinkan di dalam modul yang sama (intra-modul). Hubungan lintas domain dikelola sepenuhnya melalui referensi logis (*soft reference*) yang diperkuat oleh indeks kolom dan penyaringan `building_id`, sebagaimana ditunjukkan pada Gambar 3.18.

> **Gambar 3.18 — Entity Relationship Diagram:** `PA/docs/System design/04-ERD/erd_sistem_dinamis.png`

Gambar 3.18 mengelompokkan tabel domain ke dalam sembilan modul pemiliknya:

1. **M1 · User & Access Control (Core):**
   - `users`: Identitas utama pengguna yang terhubung ke Keycloak (`keycloak_sub`), surel, nama, status aktif, dan batas gedung bawaan (`assigned_building_id`).
   - `user_profiles`: Profil biodata pengguna mencakup NIK KTP, jenis kelamin, alamat, nomor darurat, dan foto identitas (relasi *1-to-1* dengan `users`).
   - `roles`, `permissions`, `user_roles`, `role_permissions`: Pengaturan peran kustom dan hak akses granular berbasis sistem RBAC dinamis.

2. **M2 · Property & Building (Core):**
   - `buildings`: Master data fisik gedung properti (kode unik, nama, alamat, total unit kamar).
   - `building_settings`: Konfigurasi kebijakan per gedung seperti kebijakan pemesanan (`booking_policy`), durasi sewa minimal (`min_rental_months`), sakelar fitur modul opsional, jam malam, dan tarif denda.

3. **M3 · Room Management (Core):**
   - `room_types`: Tipe/kategori kamar beserta daftar fasilitas pendukung dalam format JSON.
   - `rooms`: Unit fisik kamar mencakup nomor unit, lantai, kapasitas, tarif dasar bulanan, dan status fisik (`physical_status`).
   - `room_images`: Galeri foto unit kamar beserta urutan tampilan dan penanda foto utama.

4. **M4 · Occupancy & Schedule (Core):**
   - `occupancies`: Transaksi kontrak huni dan alokasi sewa bulanan, mencakup penghuni utama, rentang tanggal sewa, kesepakatan harga, serta status kontrak.
   - `occupancy_members`: Daftar anggota/penghuni tambahan yang menempati unit kamar terkait beserta riwayat *check-in*/*check-out*.

5. **O1 · Finance & Billing (Opsional):**
   - `invoices`: Lembar tagihan sewa berkala per periode sewa beserta status pembayaran dan tenggat jatuh tempo.
   - `payments`: Catatan transaksi pembayaran digital (Midtrans SNAP) atau kasir manual berlampiran bukti transfer.
   - `fines`: Catatan denda keterlambatan pembayaran tagihan.
   - `expenses`: Catatan pengeluaran kas operasional gedung berlampiran foto nota bukti pengeluaran.

6. **O2 · Maintenance (Opsional):**
   - `damage_reports` & `damage_report_logs`: Tiket laporan kerusakan fasilitas dari penghuni berlampiran foto serta rekam jejak perubahan status perbaikan.
   - `maintenance_schedules`: Agenda pemeliharaan rutin preventif untuk fasilitas gedung.

7. **O3 · Asset & Inventory (Opsional):**
   - `inventories` & `room_inventories`: Master data inventaris aset gedung serta pemetaan perabot per kamar beserta kondisi dan tanggal audit terakhir.

8. **O4 · Guest Logging (Opsional):**
   - `guests`: Buku tamu digital untuk mencatat riwayat kunjungan, jam masuk/keluar, status menginap, dan pembebanan biaya inap tambahan.

9. **O5 · Notification (Opsional):**
   - `notification_logs`: Log riwayat pengiriman notifikasi otomatis (WhatsApp/Email) mencakup nama event, muatan pesan, dan status pengiriman.

---

### 3.6.2 Skenario Pengujian Kombinasi Modul

Untuk membuktikan keandalan dan sifat modularitas terisolasi (nol *Foreign Key* fisik antar-domain), sistem diuji menggunakan empat skenario kombinasi modul pada gedung yang berbeda. Hasil pengujian menunjukkan bahwa setiap modul dapat diaktifkan atau dinonaktifkan secara independen tanpa menimbulkan *error* kaskade pada lapisan basis data maupun aplikasi.

**Tabel 3.6 Hasil Pengujian Kombinasi Modul Lego**

| Skenario | Kombinasi Modul Aktif | Modul Dinonaktifkan | Hasil Uji Integrasi & Status |
|---|---|---|---|
| Skenario A | Core + Finance + Maintenance + Inventory + Guest + Notification | Tidak Ada (Penuh) | LULUS (100%). Seluruh fitur otomatisasi penagihan, tiket, audit, dan WhatsApp berjalan sempurna. |
| Skenario B | Core + Maintenance + Inventory + Guest | Finance, Notification | LULUS (100%). Kontrak huni dikonfirmasi otomatis tanpa invoice & pembayaran digital. |
| Skenario C | Core + Finance + Notification | Maintenance, Inventory, Guest | LULUS (100%). Sistem berfokus pada sewa & transaksi tanpa menu operasional lapangan. |
| Skenario D | Core Saja (Auth, Building, Room, Lease) | Seluruh Modul Opsional | LULUS (100%). Berfungsi murni sebagai sistem pencatatan master kamar & alokasi hunian murni. |

Berdasarkan hasil pengujian kombinasi di atas, disimpulkan bahwa arsitektur Modular Monolith berbasis pola Lego terbukti berhasil memisahkan tanggung jawab antar-domain secara sempurna, memberikan fleksibilitas tinggi bagi pengelola properti untuk menyesuaikan layanan sesuai karakteristik tiap gedung.
