# BAB 1 — Pendahuluan

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[19]` terurut sesuai kemunculan pertama pada teks.

**Judul Proyek Akhir:**
*Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum*
(Studi Kasus: Wisma Amal Gorontalo)

---

## 1.1 Latar Belakang Masalah

### 1.1.1 Urgensi Transformasi Digital Manajemen Kost dan Profil Wisma Amal Gorontalo

Pertumbuhan urbanisasi, mobilitas pendidikan tinggi, dan ekspansi pusat kegiatan ekonomi di berbagai wilayah Indonesia telah mendorong peningkatan kebutuhan terhadap hunian sewa sementara berjangka pendek hingga menengah, seperti rumah kost dan wisma komersial [1]. Berdasarkan laporan dan kajian sektor ekonomi riil, industri penyewaan properti hunian mikro, kecil, dan menengah (UMKM) memberikan kontribusi signifikan terhadap perekonomian lokal [1]. Namun, mayoritas tata kelola operasional bisnis kost saat ini masih dikelola secara konvensional atau semi-manual dengan mengandalkan buku pencatatan fisik, aplikasi pesan instan, dan lembar kerja spreadsheet yang tidak terintegrasi [1][2].

Pengelolaan manual pada skala properti yang berkembang menimbulkan berbagai friksi dan kerentanan operasional yang berulang:
1. **Kesalahan Pencatatan dan Asimetri Data:** Ketiadaan basis data relasional terpusat mengakibatkan inkonsistensi pencatatan identitas penghuni, riwayat masa sewa yang tercecer, dan hilangnya riwayat mutasi pembayaran [2].
2. **Konflik Alokasi dan Penjadwalan Kamar (*Double Booking*):** Proses reservasi yang dilakukan secara lisan atau melalui obrolan pesan tanpa mekanisme penguncian konkurensi sering memicu terjadinya pemesanan ganda pada satu unit kamar fisik dalam rentang waktu yang sama [3].
3. **Inkontinuitas Penagihan dan Rekonsiliasi Keuangan:** Ketiadaan sistem otomasi penagihan dan rekonsiliasi manual bukti transfer bank meningkatkan risiko keterlambatan pembayaran sewa (*arrears*), kesulitan identifikasi tagihan tertunggak, serta ketiadaan laporan arus kas (*cash flow*) yang akurat dan transparan bagi pemilik properti [4].
4. **Tata Kelola Pemeliharaan Fasilitas yang Reaktif:** Keluhan kerusakan fasilitas kamar dari penghuni tidak terdokumentasi dalam sistem tiket terstruktur, mengakibatkan lambatnya tindak lanjut penanganan (*Service Level Agreement* tidak terukur) dan mempercepat depresiasi aset fisik [4].

Wisma Amal Gorontalo merupakan salah satu penyedia hunian kost komersial terkemuka di Kota Gorontalo yang melayani segmen mahasiswa dan pekerja profesional. Dalam perkembangannya, pemilik Wisma Amal merencanakan ekspansi portofolio bisnis dengan mengelola beberapa gedung kost (*multi-building properties*) di lokasi berbeda. Pengelolaan multi-gedung secara manual meningkatkan beban kognitif pengelola secara eksponensial. Pemilik kesulitan memantau persentase okupansi agregat, performa keuangan lintas properti, dan status operasional harian secara cepat. Kondisi empiris ini menuntut adanya Sistem Informasi Manajemen (SIM) terintegrasi berbasis web dan mobile yang mampu menangani isolasi data multi-gedung, menyediakan otomasi alur transaksi, serta dilengkapi asisten cerdas untuk memfasilitasi penarikan wawasan operasional secara instan [2][4].

---

### 1.1.2 Telaah Kritis dan Dekonstruksi 4 Proposal Previous Work (Juni 2025)

Sebagai upaya awal digitalisasi pengelolaan Wisma Amal Gorontalo, pada bulan Juni 2025 telah dilakukan inisiasi perancangan sistem oleh empat mahasiswa melalui empat proposal proyek akhir yang terpisah [10][11][12][13]:

| No | Proposal / Domain | Peneliti & NRP | Metodologi & Arsitektur | Fokus Utama & Luaran Fungsional |
|---|---|---|---|---|
| 1 | **Manajemen Penghuni & Tamu** | Rasyidatur (3123500039) | Scrum, Modular Monolith | Modul profil penghuni, pencatatan tamu berkunjung, riwayat sewa kamar, dan dashboard monitoring aktivitas [10]. |
| 2 | **Kamar & Reservasi** | Roihanah (3123500005) | Scrum, Modular Monolith | CRUD master data kamar, status ketersediaan real-time, mekanisme validasi bentrok reservasi, dan antrean waktu [11]. |
| 3 | **Keuangan & Transaksi** | Rizal (3123500060) | Scrum, Modular Monolith | Otomasi penerbitan tagihan berkala, integrasi payment gateway Midtrans SNAP, pencatatan pengeluaran, dan visualisasi grafik keuangan [12]. |
| 4 | **Operasional & Maintenance** | Bagus (3123500031) | Scrum, Modular Monolith | Tiket pelaporan kerusakan fasilitas berlampiran multi-foto, inventaris kamar, pengajuan pembelian barang, dan jadwal kebersihan [13]. |

Meskipun keempat proposal di atas mengklaim penggunaan arsitektur Modular Monolith dan metodologi Scrum, hasil telaah mendalam terhadap artefak desain dan basis kode awal mengungkap sejumlah kelemahan struktural, inkonsistensi arsitektur, dan *technical debt* yang signifikan:

1. **Fragmentasi Sistem dan Ketiadaan Dukungan Multi-Gedung (*Multi-Tenancy*):**
   Keempat proposal dirancang sebagai entitas perangkat lunak yang terisolasi tanpa adanya *single source of truth*. Tidak ada skema arsitektur terpadu yang mampu menyatukan domain Kamar, Penghuni, Keuangan, dan Pemeliharaan dalam satu *deployment unit* yang utuh [10][11][12][13]. Selain itu, seluruh rancangan basis data diasumsikan hanya untuk satu gedung fisik tunggal, sehingga tidak memungkinkan perluasan bisnis pemilik ke properti multi-gedung tanpa menduplikasi instalasi server.

2. **Modular Monolith Semu dan Kopling Erat Antar-Modul (*Tight Coupling*):**
   Secara fisik, kode backend dibagi ke dalam direktori modul, namun secara teknis terjadi kopling erat yang merusak prinsip modularitas. Komunikasi antar-modul dilakukan melalui pemanggilan service langsung (*direct synchronous service call*) dan injeksi repository lintas modul tanpa perantara interface abstraksi (*Dependency Inversion* dilanggar) [11]. Modul Keuangan mengakses tabel basis data Kamar secara langsung [12], dan relasi *Foreign Key* fisik dipasang melintasi batas modul domain. Akibatnya, modul tidak dapat diaktifkan atau dinonaktifkan secara mandiri (*toggleable*) tanpa memicu *fatal error* pada modul lain.

3. **Inkonsistensi Format Kontrak Input dan Output API:**
   Tidak adanya standarisasi pembungkus respons JSON (*JSON envelope*) dan format validasi masukan antar-modul menyebabkan perbedaan skema data (misalnya inkonsistensi penamaan atribut status boolean, representasi paginasi, dan struktur pemetaan kesalahan HTTP 422). Hal ini memicu kerapuhan (*brittleness*) pada layer konsumsi data di sisi antarmuka klien.

4. **Implementasi Frontend yang Semi-Clean:**
   Pada sisi frontend Flutter, struktur kode mengklaim penerapan *Clean Architecture*, namun pada praktiknya lapisan BLoC bergantung langsung pada implementasi konkret Repository tanpa abstraksi UseCase dan Repository Interface [14]. Pelanggaran *The Dependency Rule* ini mengakibatkan logika bisnis bercampur dengan framework UI, menyulitkan proses pengujian unit terisolasi [15].

5. **Ketiadaan Asisten Cerdas untuk Pengambilan Keputusan (*AI Assistance Gap*):**
   Pemilik dan pengelola properti dituntut untuk membuka berbagai menu dashboard secara manual guna merekapitulasi data okupansi, memeriksa tagihan tertunggak, atau meninjau komplain yang belum selesai. Tidak tersedia antarmuka cerdas berbasis bahasa alami (*natural language query*) yang mampu mengagregasi wawasan operasional secara instan dan aman.

6. **Kerapuhan Pengujian dan Dokumentasi Statis:**
   Pengujian pada *previous work* hanya mengandalkan *black-box testing* berbasis skenario manual fungsional dasar tanpa adanya *automated unit test*, *API contract test*, maupun *integration test* [10][11][12][13]. Selain itu, dokumen arsitektur seperti `KNOWLEDGE_BASE.md` tidak tersinkronisasi secara otomatis dengan kode sumber (*documentation rot*) [14].

7. **Integrasi Pembayaran yang Belum Siap Produksi (*Sandbox-Only Payment*):**
   Implementasi Midtrans hanya berjalan pada tahap *sandbox* tanpa dilengkapi penanganan *idempotency key*, verifikasi tanda tangan kriptografis webhook (*signature verification*), kebijakan *retry handling*, dan pencatatan audit transaksi (*audit trail*) yang memenuhi standar industri [12][16].

8. **Kerapuhan Sistem Otentikasi dan Ketiadaan Single Sign-On (SSO):**
   Pengelolaan kredensial pengguna pada sistem lama dilakukan secara mandiri di dalam basis data lokal tanpa dukungan *Enterprise Identity and Access Management* (IAM) atau *Single Sign-On* (SSO). Hal ini meningkatkan risiko kerentanan manajemen password, ketiadaan perlindungan *Multi-Factor Authentication* (MFA), serta mengharuskan pengguna melakukan registrasi akun manual berulang kali [10][11].

---

### 1.1.3 Urgensi dan Rasionalisasi Pilar Refactoring Sistem

Berdasarkan analisis kritis terhadap kegagalan arsitektural *previous work* serta tinjauan literatur terkini (2022–2026), proyek akhir ini memposisikan diri bukan sebagai pembangunan sistem baru dari nol (*greenfield*), melainkan **proses refaktorisasi arsitektur komprehensif (*architectural refactoring*)** untuk menyatukan dan menyempurnakan 4 domain legacy menjadi satu platform enterprise yang siap produksi (*production-ready*).

Refaktorisasi ini ditegakkan di atas **Pilar-Pilar Arsitektural Utama**:

```
┌─────────────────────────────────────────────────────────────────────────┐
│              PILAR REFACTORING SISTEM MANAJEMEN WISMA                   │
├─────────────────────────────────────────────────────────────────────────┤
│ 1. Modular Monolith Architecture (3-Tier Hierarchy & Event-Driven)      │
│    • Infrastructure, Core (Room & Schedule), Business Modules           │
│    • Komunikasi Tulis via Event Bus & Komunikasi Baca via Gateway       │
├─────────────────────────────────────────────────────────────────────────┤
│ 2. Clean Architecture di Frontend Flutter                               │
│    • Presentation (BLoC) → Domain (UseCase/Entity) ← Data (DataSource) │
│    • Single Codebase Web Dashboard & Mobile Application                 │
├─────────────────────────────────────────────────────────────────────────┤
│ 3. Multi-Tenant System (Multi-Gedung Row-Level Scoping)                 │
│    • Entitas 'buildings', TenantResolverMiddleware, Header X-Building-ID│
│    • Tenant-Aware RBAC (Owner multi-gedung vs Pengelola gedung binaan)  │
├─────────────────────────────────────────────────────────────────────────┤
│ 4. Standarisasi Kontrak Input-Output API & Living Documentation         │
│    • Envelope JSON baku: {status, message, data, meta, errors}          │
│    • Strict FormRequest Validation & DTO Serialization via Scramble     │
├─────────────────────────────────────────────────────────────────────────┤
│ 5. Model Context Protocol (MCP) with Built-in AI Assistance             │
│    • JSON-RPC Tools Server untuk analitik okupansi, finansial & komplain│
│    • Deterministic Grounding anti-halusinasi & Tenant Boundary Guardrail│
├─────────────────────────────────────────────────────────────────────────┤
│ 6. Federated Identity & Single Sign-On (SSO) Berbasis Keycloak OIDC     │
│    • OpenID Connect Identity Provider, Token Verification via JWKS      │
│    • Just-In-Time (JIT) Provisioning & Spatie RBAC Authorization Mapping│
└─────────────────────────────────────────────────────────────────────────┘
```

1. **Modular Monolith Architecture (Backend):**
   Menerapkan arsitektur monolitik modular dengan hirarki 3 lapis (*3-Tier Hierarchy*): *Infrastructure Tier* (`Auth`, `Setting`), *Core Tier* (`Room`, `Schedule`), dan *Business Modules Tier* (`Finance`, `Maintenance`, `Guest`, `Inventory`, `Notification`, `Mcp`) [5][6][8]. Komunikasi mutasi data antar-modul diselesaikan secara asinkron via *Internal Event Bus*, sedangkan komunikasi baca lintas domain diagregasi via *Module Gateway Layer* dengan proteksi `ModuleGate::isActive()` untuk memastikan sistem tetap beroperasi normal saat modul bisnis tertentu dimatikan (*graceful degradation*) [7][11].

2. **Clean Architecture di Frontend Flutter:**
   Menerapkan pemisahan tiga lapisan murni (*Presentation*, *Domain*, dan *Data*) dengan pola *Unidirectional Data Flow* berbasis BLoC pada satu basis kode (*single codebase*) Flutter Web dan Mobile [15][17]. Penggunaan *Repository Interface* dan *UseCase* menjamin bahwa logika bisnis aplikasi sepenuhnya terisolasi dari framework antarmuka dan mudah diuji secara otomatis.

3. **Multi-Tenant System (Multi-Gedung):**
   Menerapkan arsitektur *Shared Database with Row-Level Scoping* melalui penambahan entitas `buildings` dan kolom diskriminator `building_id`. Mekanisme isolasi dijalankan otomatis oleh `TenantResolverMiddleware` dan *Global Query Scope* pada ORM, didukung oleh *Tenant-Aware RBAC* untuk membatasi ruang lingkup kerja pengelola gedung tanpa mengorbankan visibilitas global pemilik properti [8].

4. **Standarisasi Kontrak Input-Output API:**
   Menerapkan format envelope respons seragam `{status, message, data, meta, errors}` pada seluruh endpoint REST, didukung oleh validasi ketat *FormRequest* pada layer HTTP dan *Resource Transformers (DTO)*. Dokumentasi API diekstraksi secara langsung dari basis kode (*Living Documentation* via Scramble OpenAPI) untuk mencegah disonansi kontrak data antara frontend, backend, dan modul MCP.

5. **Model Context Protocol (MCP) with Built-in AI Assistance:**
   Menyediakan antarmuka terstandarisasi berbasis *Model Context Protocol* (MCP) yang mengekspos sekumpulan tool komputasi read-only (`get_building_occupancy`, `get_financial_summary`, `get_damage_reports`, `get_guest_activity`). Protokol ini memungkinkan model AI (LLM) berinteraksi secara deterministik dengan basis data operasional, memberikan wawasan analitik instan tanpa risiko halusinasi data dan tetap patuh pada batasan hak akses tenant [8].

6. **Federated Identity & Single Sign-On (SSO) Berbasis Keycloak OIDC:**
   Mendelegasikan proses otentikasi kredensial pengguna ke server *Identity and Access Management* (IAM) terpusat Keycloak melalui protokol OpenID Connect (OIDC). Backend Laravel melakukan validasi stateless token JWT via *JSON Web Key Set* (JWKS) dan menjalankan *Just-In-Time (JIT) User Provisioning* untuk menyinkronkan data pengguna lokal dengan penugasan Spatie RBAC dan tenant gedung yang relevan.

7. **Integrasi Pembayaran Production-Ready & Strategi Pengujian Berlapis:**
   Menyempurnakan integrasi Midtrans SNAP dengan *Idempotency-Key* (UUIDv4) untuk mencegah transaksi ganda, verifikasi tanda tangan kriptografis SHA-512 pada webhook, serta menerapkan strategi piramida pengujian (*Unit*, *Contract*, *Tenant Isolation*, dan *Integration Testing*) dengan target cakupan kode minimal 80% [12][16][18].

---

## 1.2 Rumusan Masalah

Berdasarkan pemaparan latar belakang, identifikasi kegagalan *previous work*, dan urgensi perancangan sistem terpadu, rumusan masalah dalam Proyek Akhir ini didefinisikan sebagai berikut:

1. Bagaimana merancang dan mengimplementasikan **arsitektur Modular Monolith backend yang konsisten** dengan hirarki 3 lapis (*3-Tier Hierarchy*), komunikasi mutasi berbasis *Internal Event Bus*, dan kueri lintas domain via *Module Gateway Layer*?
2. Bagaimana menerapkan **Clean Architecture pada Frontend Flutter** (BLoC → UseCase → RepositoryInterface) dalam satu basis kode (*single codebase*) terpadu untuk Flutter Web Dashboard dan Flutter Mobile App?
3. Bagaimana merancang dan menerapkan **sistem Multi-Tenant multi-gedung** menggunakan pola *Row-Level Scoping* dan *TenantResolverMiddleware* guna memastikan isolasi data yang aman dan penegakan *Tenant-Aware RBAC*?
4. Bagaimana membangun **standarisasi kontrak input-output API** (JSON Envelope baku, FormRequest, DTO) yang terintegrasi dengan automasi *living documentation* OpenAPI?
5. Bagaimana merancang dan mengintegrasikan modul **MCP Server dengan built-in AI** untuk menyediakan layanan kueri wawasan analitik properti berbasis bahasa alami dengan prinsip *deterministic grounding* dan pengamanan *tenant boundary*?
6. Bagaimana mengintegrasikan **Single Sign-On (SSO) berbasis Keycloak OpenID Connect (OIDC)** dengan verifikasi stateless JWKS dan *Just-In-Time Provisioning* pada modul otentikasi backend?
7. Bagaimana mengimplementasikan integrasi payment gateway **Midtrans tingkat produksi (*production-ready*)** serta mengevaluasi kualitas sistem melalui **strategi pengujian berlapis (Unit, Contract, Tenant Isolation, dan Integration Test)**?

---

## 1.3 Tujuan Penelitian

Tujuan yang ingin dicapai melalui pelaksanaan Proyek Akhir ini adalah:

1. Menghasilkan arsitektur backend **Modular Monolith yang terstruktur dan decoupled**, di mana setiap modul bisnis dapat diaktifkan atau dinonaktifkan secara mandiri tanpa memicu kegagalan sistem (*graceful degradation*).
2. Mengembangkan antarmuka pengguna berbasis **Clean Architecture pada Flutter** yang memisahkan logika bisnis dari lapisan presentasi serta mendukung penggunaan kembali komponen pada Web Dashboard dan Mobile App secara optimal.
3. Mewujudkan fitur **Multi-Tenant multi-gedung** yang memungkinkan pengelolaan terpusat atas portofolio properti kost dengan isolasi data yang ketat antar gedung binaan.
4. Menerapkan **kontrak data REST API yang seragam dan type-safe** yang terhubung langsung dengan dokumentasi hidup sistem (*living documentation*) guna mengeliminasi kesalahan parsing data.
5. Menyediakan modul **asisten cerdas terintegrasi berbasis Model Context Protocol (MCP)** yang memfasilitasi pemilik dan pengelola dalam memperoleh laporan okupansi, keuangan, dan operasional secara instan dan akurat.
6. Mengimplementasikan sistem **Single Sign-On (SSO) berbasis Keycloak OpenID Connect** guna menyediakan otentikasi terpusat yang aman, terstandarisasi, dan terintegrasi dengan Spatie RBAC.
7. Menerapkan integrasi pembayaran digital **Midtrans yang aman dan idempoten** serta membuktikan keandalan sistem melalui pencapaian cakupan pengujian perangkat lunak minimal 80%.

---

## 1.4 Batasan Masalah

Guna menjaga fokus penelitian dan ketercapaian target luaran Proyek Akhir pada lingkup Diploma Tiga (D3) Teknik Informatika, ditetapkan batasan-batasan masalah berikut beserta justifikasi teknisnya:

1. **Lingkup Domain Bisnis:**
   Domain sistem mencakup *Infrastructure Tier* (`Auth/Keycloak SSO`, `Setting`), *Core Tier* (`Tenant/Building`, `Room`, `Schedule`), serta *Business Modules Tier* (`Finance/Midtrans`, `Maintenance`, `Guest`, `Inventory`, `Notification`, dan `Mcp Server`).
2. **Peran Pengguna (*User Roles*):**
   Sistem memfasilitasi tiga tingkatan aktor: Pemilik (*Owner* multi-gedung), Pengelola (*Admin* tertugaskan pada gedung tertentu), dan Penghuni/Calon Penghuni.
3. **Platform Antarmuka:**
   Aplikasi Web Dashboard (Flutter Web) ditujukan untuk seluruh peran (Pemilik, Pengelola, dan Penghuni), sedangkan Aplikasi Mobile (Flutter Mobile) ditujukan khusus bagi kemudahan mobilitas Penghuni (dibangun di atas basis kode tunggal).
4. **Model Multi-Tenancy:**
   Isolasi data multi-gedung diimplementasikan menggunakan pendekatan *Shared Database with Row-Level Scoping* (`building_id`), bukan *Separate Database per Tenant*, guna meminimalkan biaya operasional infrastruktur dan memfasilitasi agregasi laporan analitik pemilik.
5. **Otentikasi & Identity Provider (IdP):**
   Sistem otentikasi terpusat mengandalkan server Keycloak mandiri berbasis protokol OpenID Connect (OIDC). Fungsionalitas pengiriman email notifikasi dan verifikasi pada Keycloak dialirkan melalui relay SMTP eksternal.
6. **Batasan Fungsional Asisten AI (MCP):**
   Modul MCP Server difokuskan pada penyediaan operasi komputasi dan analisis data baca (*read-only tool calls*) guna menjamin integritas data transaksi dan menghindari eksekusi mutasi data kritis secara otonom oleh AI tanpa pengawasan manusia (*human-in-the-loop*).
7. **Kanal Integrasi Eksternal:**
   Pembayaran digital difasilitasi melalui Midtrans SNAP API (Virtual Account, QRIS, E-Wallet), sedangkan notifikasi otomatis disalurkan melalui WhatsApp Gateway (Fonnte/Open-WA) dan layanan in-app notification.
8. **Metodologi Pengembangan:**
   Pengembangan sistem dilaksanakan menggunakan kerangka kerja Scrum dalam 4 siklus *sprint* (durasi total 8 minggu).

---

## 1.5 Manfaat Penelitian

Hasil penelitian dan pengembangan sistem ini diharapkan dapat memberikan kontribusi nyata bagi berbagai pihak:

### 1.5.1 Manfaat Bagi Pemilik dan Pengelola Properti (Wisma Amal)
- **Efisiensi Pengelolaan Portofolio:** Memberikan kemudahan bagi pemilik dalam memantau dan mengelola banyak gedung kost sekaligus dalam satu portal dashboard terpadu.
- **Akurasi dan Kecepatan Pengambilan Keputusan:** Memfasilitasi perolehan wawasan bisnis (tingkat okupansi, proyeksi pendapatan, tunggakan sewa, dan beban pemeliharaan) secara instan melalui asisten AI berbasis MCP.
- **Otomasi Finansial & Minimalisasi Kerugian:** Menghilangkan pencatatan manual bukti transfer bank melalui sistem verifikasi pembayaran otomatis Midtrans dan penagihan berkala otomatis.

### 1.5.2 Manfaat Bagi Penghuni dan Calon Penghuni
- **Kemudahan Transaksi & Transparansi:** Memberikan kemudahan dalam memilih unit kamar, melakukan reservasi anti-bentrok, memantau rincian tagihan digital, dan melakukan pembayaran instan melalui kanal digital resmi.
- **Kemudahan Penyampaian Layanan:** Memfasilitasi pelaporan kerusakan fasilitas kamar secara terstruktur berlampiran foto serta memantau status penanganannya secara transparan.

### 1.5.3 Manfaat Bagi Penulis dan Akademisi (Institusi PENS)
- **Penguasaan Praktik Rekayasa Perangkat Lunak Modern:** Memberikan pembuktian kompetensi penerapan arsitektur *Modular Monolith*, *Clean Architecture*, *Multi-Tenancy*, dan *Model Context Protocol (MCP)* pada aplikasi berskala produksi.
- **Kontribusi Referensi Akademis:** Menjadi rujukan studi empiris mengenai metodologi refaktorisasi arsitektur perangkat lunak dari sistem monolitik terfragmentasi menjadi sistem monolitik modular yang teruji dan terstandarisasi.

---

## 1.6 Sistematika Penulisan

Laporan Proyek Akhir ini disusun secara sistematis ke dalam lima bab utama dengan urutan pembahasan logis sebagai berikut:

- **BAB 1 PENDAHULUAN:**
  Memuat latar belakang permasalahan operasional kost, dekonstruksi kritis atas 4 proposal *previous work*, justifikasi 5 pilar refaktorisasi arsitektur, rumusan masalah, tujuan penelitian, batasan masalah, manfaat penelitian, dan sistematika penulisan laporan.

- **BAB 2 KAJIAN PUSTAKA:**
  Menyajikan landasan teoretis komprehensif yang mendukung penelitian, meliputi Sistem Informasi Manajemen Properti, Evolusi Arsitektur Monolith menuju Modular Monolith (3-Tier & Event-Driven), Standarisasi Kontrak RESTful API & DTO, Arsitektur Multi-Tenancy Row-Level Scoping, Protokol MCP dan Integrasi LLM Tool-Use, Clean Architecture Frontend Flutter, Karakteristik Basis Data MySQL ACID/MVCC, Pola Integrasi Midtrans Production-Ready, Strategi Pengujian Perangkat Lunak (Testing Pyramid), dan Living Documentation. Bab ini juga memuat tinjauan 14 penelitian terkait beserta positioning kontribusi penelitian dan sintesis *gap statement*.

- **BAB 3 METODOLOGI DAN PERANCANGAN SISTEM:**
  Menguraikan metodologi pengembangan perangkat lunak berbasis kerangka kerja Scrum (peran, artefak, dan pembagian 4 sprint) serta memaparkan rancangan sistem secara mendalam (*Software Design Document*), meliputi diagram arsitektur sistem Clean-Modulith + MCP, pemodelan proses bisnis (BPMN & Activity Diagram), pemodelan fungsional (Diagram Use Case, Use Case Specifications, DFD Level 0 dan Level 1 disertai Kamus Data), perancangan basis data relasional (ERD Multi-Tenant dan Kamus Data Basis Data lengkap), perancangan antarmuka pengguna (UI/UX Mockups), spesifikasi teknis tool MCP dan kontrak API, serta matriks skenario pengujian verifikatif.

- **BAB 4 IMPLEMENTASI DAN EVALUASI:**
  Mendokumentasikan tahapan implementasi modul backend dan frontend, konfigurasi multi-tenancy dan MCP server, integrasi payment gateway, serta memaparkan hasil pengujian sistem (Unit Testing, Contract Testing, Tenant Isolation Testing, Integration Testing, dan evaluasi akurasi jawaban AI) disertai analisis ketercapaian tujuan penelitian.

- **BAB 5 PENUTUP:**
  Menyajikan kesimpulan menyeluruh yang menjawab seluruh rumusan masalah dan tujuan penelitian pada BAB 1, serta memberikan saran-saran pengembangan strategis untuk penyempurnaan sistem pada masa mendatang.
