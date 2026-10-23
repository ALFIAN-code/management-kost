# Architecture Decision Records — Federated

> Append-only. Jika keputusan berubah, buat entry baru dan tandai lama sebagai Superseded.

---

## ADR-001: Federated Docs (Global Hub → PA/docs + Project/docs)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Proyek PA-Management-kost punya 2 concerns: skripsi (PA) dan sistem (Project). 1 docs raksasa akan basi dan membingungkan AI (campur aturan Laravel vs aturan tulis kampus). User minta Docs global sebagai pointer + komprehensif di masing-masing scope.
**Keputusan:** Struktur federated 3 hub: `Docs/` (global hub) → `PA/docs/` (skripsi BAB1-5, panduan kampus, jurnal) → `Project/docs/` (hub kode) → `backend/docs` & `fe/docs`. `Docs/00_overview/ARCHITECTURE.md` jadi index pointer, bukan detail.
**Alternatif:**
- 1 docs di root saja — ditolak, karena PA dan Project punya siklus & stakeholder beda (dosen vs user Wisma)
- Docs per modul saja tanpa hub — ditolak, AI butuh entry point tunggal tiap sesi (AGENTS.md:1)
**Konsekuensi:** AI wajib baca hub dulu baru routing ke sub-docs. Update `STATE.md` di 3 level. Tradeoff: sedikit overhead, tapi mencegah campur context.

---

## ADR-002: Hybrid Skill sebagai Blocker (Primary: 1-pluto1 thesis-writing)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** User butuh AI bisa menulis PA dengan disiplin (sitasi, template docx, klaim trace ke kode) + search jurnal awal. 6 skill dievaluasi: David-Saeteros, 1-pluto1, Imbad0202 (48k stars), Composio docx, O0000 index, AlessandroCaforio.
**Keputusan:** Primary blocker = `1-pluto1/thesis-writing-en` (code-backed thesis, citation order, source-first, validate_docx), Engine = `Composio docx` (docx-js/ooxml), Rigor = subset `Imbad0202` (deep-research + Stage 2.5 integrity gate), Arsitektur = `AlessandroCaforio` (CLAUDE.md brain + 8 rules always-on).
**Alternatif:**
- Imbad0202 full pipeline — ditolak, overkill untuk D3 (butuh ~$4-6 & hooks)
- David-Saeteros saja — ditolak, tidak cek citation numeric & code evidence
**Konsekuensi:** Aturan blocker ditanam di `PA/docs/02_reference/*` dan `Docs/00_overview/STACK.md` sebagai SOP, bukan sekadar skill install.

---

## ADR-003: Modular Monolith, bukan Microservice

**Tanggal:** 2025-09-19
**Status:** Accepted (dari proposal, dipertahankan)
**Konteks:** Wisma Amal butuh 4 domain terpisah tapi sharing data (reservasi → tagihan → notif) dan tim kecil (4 mahasiswa PA). Microservice menambah kompleksitas jaringan & deployment.
**Keputusan:** `nwidart/laravel-modules` — 1 deployment, modul loosely-coupled highly-cohesive, toggle via `modules_statuses.json`, komunikasi via ServiceInterface.
**Alternatif:** Microservice — ditolak (proposal Nofianto 2021 pakai microservice tapi hanya mobile, tidak modular; overhead tidak sebanding).
**Konsekuensi:** Scaling vertikal dulu, миграция ke microservice bisa stepwise jika properti >1 (lihat Faustino et al. 2024 di proposal).

---

## ADR-004: Flutter BLoC Semi-Clean → Full Clean untuk Fitur Baru

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Repo `fe_wisma_amal_gorontalo` saat ini semi-clean (no interface, repo concrete) untuk kecepatan. Guideline `CLEAN_ARCHITECTURE_GUIDELINE.md` menuntut full Clean (UseCase + Repository Interface).
**Keputusan:** Fitur baru wajib full Clean (BLoC → UseCase → RepositoryInterface → Impl). Fitur lama boleh stay semi-clean, refactor bertahap.
**Konsekuensi:** Konsistensi meningkat, boilerplate bertambah — acceptable untuk PA yang akan di-review dosen.

---

## ADR-005: 5 Pilar Konseptual PA (Standar I/O, Multi-Tenant Gedung, MCP AI, Clean-Modulith)

**Tanggal:** 2026-10-03
**Status:** Accepted
**Konteks:** Naskah PA perlu penguatan bobot substansi teknis dan relevansi industri modern tanpa mengubah judul skripsi yang sudah terdaftar. 4 previous work memiliki kelemahan pada fragmentasi, isolasi data gedung, ketiadaan asisten cerdas, serta format API yang inkonsisten.
**Keputusan:** Mengadopsi 5 pilar konseptual terpadu:
1. **Standar Input-Output:** Format envelope API konsisten `{status, message, data, meta, errors}` dengan FormRequest input validation dan Resource DTO serialization.
2. **Multi-Tenant System (Multi-Gedung):** Logical data isolation berbasis `building_id` dan `TenantResolverMiddleware` untuk mendukung pengelolaan multi-properti oleh satu pemilik/pengelola.
3. **Model Context Protocol (MCP) with Built-in AI:** Modul MCP Server terisolasi yang menyediakan tool-use read-only untuk asisten AI (analitik keuangan, okupansi, laporan kerusakan) dengan ground data ketat dan tenant scoping.
4. **Modular Monolith Architecture (Backend):** 3-tier module hierarchy (Infrastructure, Core, Business) dengan komunikasi tulis event-driven dan pembacaan lintas modul via Module Gateway terkontrol `ModuleGate::isActive()`.
5. **Clean Architecture (Frontend Flutter):** Pemisahan 3 layer (Presentation BLoC, Domain UseCase/Entity/Interface, Data DataSource/Model/RepoImpl) pada single codebase Flutter Web + Mobile.
**Alternatif:**
- Separate database per tenant (ditolak, overhead operasional dan sumber daya terlalu besar untuk skala wisma/kost).
- Autonomous AI agent dengan write permission (ditolak untuk fase 1 demi keamanan transaksi dan integritas data).
**Konsekuensi:** Perubahan ERD global mencakup entitas `buildings`, pembaruan BAB 1, 2, 3 naskah PA, dan perancangan skenario evaluasi multi-tenant serta AI grounding di BAB 4.

---

## ADR-006: Single Sign-On (SSO) IAM Berbasis Keycloak OpenID Connect (OIDC)

**Tanggal:** 2026-10-03
**Status:** Accepted
**Konteks:** Sistem membutuhkan mekanisme otentikasi enterprise yang aman, terpusat, dan terstandarisasi industri tanpa perlu membangun sistem credential management dan MFA dari awal. Pengguna (Pemilik, Pengelola, Penghuni) membutuhkan kemudahan akses melalui Single Sign-On (SSO) dan Social Identity Brokering (Google Login via Keycloak).
**Keputusan:** Mengadopsi **Keycloak** sebagai *Identity Provider (IdP) & Authorization Server* eksternal berbasis protokol **OpenID Connect (OIDC) / OAuth 2.0**:
1. Keycloak mengelola Realm `wisma-amal-realm`, registrasi pengguna, kredensial password, MFA, dan *Identity Brokering* (Google OAuth).
2. Frontend Flutter melakukan otentikasi ke Keycloak OIDC $\rightarrow$ menerima ID Token & Access Token JWT.
3. Backend Laravel (Modul `Auth`) memverifikasi keaslian token OIDC via *JWKS (JSON Web Key Set)* endpoint Keycloak secara stateless.
4. Backend melakukan *Just-In-Time (JIT) Provisioning* pada tabel lokal `users` (sinkronisasi `keycloak_id`, email, nama) dan mengikatkan role Spatie RBAC serta tenant scope gedung, kemudian menerbitkan token sesi internal Laravel Sanctum.
**Alternatif:**
- Otentikasi username/password manual di Laravel saja (ditolak, beban keamanan tinggi, rentan brute-force, dan tidak mendukung federated SSO).
- Firebase Auth (disebut di proposal 2025, namun digantikan oleh Keycloak karena Keycloak sepenuhnya open-source, self-hostable, dan standar enterprise OIDC/SAML2).
**Konsekuensi:** Penambahan entitas `keycloak_id` pada tabel `users`, penambahan sub-bab teori protokol OIDC/JWKS di BAB 2, pemodelan alur SSO di BAB 3, dan penambahan diagram sequence otentikasi Keycloak. Masalah ketiadaan SMTP bawaan pada Keycloak diselesaikan melalui SMTP relay / mail catcher di level server.

---

## ADR-007: Full Rewrite Sistem Kost Bulanan (13 Tabel, Modular Monolith Sejak Hari Pertama)

**Tanggal:** 2026-10-07
**Status:** Accepted
**Konteks:** Audit migration membuktikan sistem lama 41 tabel dengan duplikasi (dua stack tagihan, dua cache snapshot, dua mekanisme blokir kamar, skema DP, kolom legacy modul mati) dan jejak sewa harian yang mayoritas kode mati. Dosen pembimbing menilai desain ERD terlalu ribet dan salah untuk domain kost, serta beschlossen sewa bulanan dengan minimal durasi configurable per gedung tidak cukup waktu jika ditempel ke arsitektur lama.
**Keputusan:** Rewrite penuh di folder/repo baru tanpa mengacu kode lama, dengan desain baru: sewa bulanan penuh (tanpa tarif harian), minimal durasi configurable per gedung via `building_settings`, 13 tabel, dan aturan modular monolith ditegakkan sejak hari pertama (nol FK lintas modul, komunikasi via Event Bus + Module Gateway).
**Alternatif:**
- Refactor bertahap sistem lama (ditolak — duplikasi dan legacy menempel di skema inti, biaya refactor ≈ rewrite).
- Pertahankan sewa harian (ditolak — kolom `price_daily` dan cabang durasi adalah kompleksitas tanpa pemakai).
**Konsekuensi:** Pekerjaan sebelumnya (migration 2026-10-03, 16 diagram, BAB 1–3 80%) menjadi arsip referensi; BAB 1–3 direvisi total mengikuti desain baru (Fase 1); implementasi folder baru (Fase 2–5).

---

## ADR-008: Arsitektur Hunian Dinamis Multi-Kondisi (Core Minimalis & Decoupling Modul Opsional)

**Tanggal:** 2026-10-10
**Status:** Accepted
**Konteks:** Sistem dirancang agar seawet dan sedinamis mungkin (*as dynamic as possible*) tanpa terikat pada satu use case kaku (hanya rumah kost berbayar), melainkan mampu mendukung berbagai kondisi hunian bersama: asrama mahasiswa/pondok pesantren gratis, mes karyawan, rusunawa, hingga rumah kost komersial. Pada properti non-komersial, fungsi penagihan/keuangan tidak relevan. Selain itu, manajemen hak akses membutuhkan fleksibilitas tinggi di mana pemilik/pengelola dapat mendefinisikan peran kustom (*custom roles*) dari sekumpulan izin (*permission sets*) yang disediakan.
**Keputusan:**
1. **Pemisahan Tegas Aset Fisik vs Alokasi Waktu & Orang:**
   - Modul `Room Management` murni menangani inventaris fisik unit kamar (gedung, lantai, nomor unit, tipe, dan kapasitas maksimal unit).
   - Modul `Occupancy & Schedule` menangani relasi dinamis waktu & orang (siapa menghuni kamar mana, rentang tanggal huni, status alokasi, dan validasi anti-bentrok kapasitas/jadwal).
2. **Finance & Billing Digeser Menjadi Modul Opsional (Toggleable):**
   - Pada properti berbayar (kost komersial), modul Finance diaktifkan untuk menangani penerbitan tagihan sewa berkala, verifikasi pembayaran, denda, dan pengeluaran operasional (*expenses*).
   - Pada properti non-komersial (mes/asrama/pondok), modul Finance dinonaktifkan sehingga alokasi hunian murni berupa penugasan tempat tinggal tanpa memicu tagihan apa pun.
3. **Dynamic RBAC pada User & Access Control:**
   - Menyediakan izin (*permission sets*) bawaan yang granular lintas modul.
   - Mendukung pembuatan Role baru secara dinamis oleh pengguna dengan memilih izin yang diizinkan.
4. **Klasifikasi Modul Core vs Opsional:**
   - **Core (Wajib Aktif):** User & Access Control (Dynamic RBAC), Property & Building, Room Management, Occupancy & Schedule, Occupancy Dashboard & Monitoring.
   - **Opsional (Plug & Play per Gedung):** Finance & Billing, Maintenance & Facility (tiket komplain & jadwal perawatan berkala), Asset & Inventory, Guest Logging, Notification Service.
**Alternatif:**
- Menggabungkan Room dan Schedule dalam satu modul dengan status kamar statis (ditolak — membatasi pemesanan masa depan, tidak fleksibel untuk kapasitas asrama multi-bed, dan menciptakan ketergantungan ketat ke tagihan).
- Menjadikan Finance sebagai modul inti wajib (ditolak — membuat sistem tidak bisa digunakan untuk asrama/mes tanpa harus membuat data tagihan nol rupiah yang tidak perlu).
**Konsekuensi:**
- Modul core memiliki derajat independensi tertinggi (*zero dependency* ke modul opsional).
- Integrasi antar modul sepenuhnya berbasis event/gateway (misal: event `OccupancyCreated` hanya ditangkap oleh Finance jika modul Finance aktif).
- ERD, DFD, dan kontrak antarmuka akan diturunkan dari arsitektur dinamis ini.

---

## ADR-009: Penempatan Model Context Protocol (MCP) sebagai External AI Adapter Layer

**Tanggal:** 2026-10-10
**Status:** Accepted
**Konteks:** Sistem membutuhkan kemampuan interaksi dengan Large Language Model (LLM) / Asisten AI untuk menjawab pertanyaan analitik pengelola/pemilik (contoh: ketersediaan kamar, ringkasan okupansi, komplain fasilitas, laporan keuangan). Perlu ketegasan arsitektural apakah MCP merupakan bagian dari domain bisnis inti (Core), modul bisnis opsional, atau lapisan luar.
**Keputusan:**
1. **MCP adalah Interface Adapter Layer (AI Gateway):**
   - MCP hidup **di atas** modul-modul domain bisnis, sejajar posisinya dengan REST API Controller yang melayani Frontend UI manusia.
   - MCP berfungsi sebagai *Consumer/Adapter* yang menerjemahkan protokol JSON-RPC AI menjadi panggilan query internal ke *Module Gateway / Services*.
2. **Tidak Masuk ke Dokumen Inti Data (ERD/DFD Bisnis):**
   - Dokumen kebutuhan bisnis, alur proses harian, ERD operasional, dan DFD operasional tetap bersih dari entitas AI/MCP.
   - Sistem properti dapat berjalan 100% sempurna tanpa adanya server MCP (sifatnya murni *pluggable add-on*).
3. **Sifat Akses Read-Only & Tenant/Building Aware:**
   - Alat-alat (*tools*) yang disediakan MCP hanya membaca data (*read-only*) dengan pembatasan hak akses sesuai gedung pengguna.
   - Jika modul opsional tertentu nonaktif (misal: Finance dimatikan pada asrama), tool MCP terkait otomatis tidak merespons atau dinonaktifkan.
**Konsekuensi:**
- Arsitektur sistem tetap menganut *Clean Architecture* dan *Separation of Concerns*.
- Pada naskah akademik/skripsi, MCP dibahas pada sub-bab terpisah sebagai nilai tambah integrasi AI (*AI Extension Layer*), bukan prasyarat sistem operasional.



---

## ADR-010: Pola Integrasi Pihak Ketiga (Ports and Adapters / Gateway Layer)

**Tanggal:** 2026-10-10
**Status:** Accepted
**Konteks:** Sistem membutuhkan integrasi ke layanan eksternal (Payment Gateway seperti Midtrans, dan Notification Gateway seperti Fonnte/SMTP). Terdapat risiko *vendor lock-in* dan tingginya *coupling* jika modul bisnis (seperti `Finance` atau `Notification`) memanggil layanan pihak ketiga tersebut secara langsung (hardcode).
**Keputusan:** 
Sistem akan mengadopsi pola arsitektur **Ports and Adapters (Hexagonal Architecture)** melalui mekanisme *Dependency Inversion* bawaan Laravel:
1. **Untuk Payment:** Modul `Finance` hanya bergantung pada antarmuka (Interface) `PaymentGatewayContract`. Integrasi teknis spesifik ke Midtrans diletakkan pada kelas `MidtransAdapter` (berperan sebagai *Infrastructure Layer*). Hal ini memungkinkan penggantian vendor (misal ke Xendit/Tripay) secara *plug-and-play* hanya melalui pergantian _binding_ di Service Provider.
2. **Untuk Notifikasi:** Sistem akan menggunakan arsitektur bawaan *Laravel Notification Channels*. Modul bisnis hanya mengeksekusi perintah notifikasi abstrak, sementara *Custom Channel Adapter* (misal `FonnteWhatsAppChannel`) yang mengeksekusi request HTTP ke API eksternal.
**Alternatif:**
- Integrasi langsung/hardcode di *Controller/Service* bisnis (ditolak — melanggar prinsip SOLID, susah di-*test*, dan rentan jika vendor berubah).
- Menjadikan layanan pihak ketiga sebagai modul bisnis mandiri (ditolak — layanan eksternal adalah sarana infrastruktur, bukan domain bisnis).
**Konsekuensi:**
- Diagram arsitektur backend akan diperbarui dengan menyisipkan *3rd-Party Integration Adapters* di antara modul opsional dan layanan eksternal.
- Kode implementasi API eksternal wajib diletakkan terpisah dari inti *business logic*.

---

## ADR-010: Integrasi Pihak Ketiga Berbasis Adapter Pattern (Ports and Adapters)

**Tanggal:** 2026-10-10
**Status:** Accepted
**Konteks:** Sistem harus berkomunikasi dengan layanan eksternal (*third-party APIs*) seperti *payment gateway* (Midtrans) dan layanan notifikasi (WhatsApp via Fonnte, Email via SMTP). Terdapat dilema apakah koneksi ke API ini disematkan secara langsung (*hardcoded*) ke dalam modul bisnis (Finance & Notification) atau dipisahkan.
**Keputusan:** 
Mengadopsi pendekatan **Hexagonal Architecture (Ports and Adapters) / Dependency Inversion**:
1. **Tidak Ada Vendor Lock-in di Modul Bisnis:** Modul `Finance` dan `Notification` dilarang memanggil pustaka/HTTP request spesifik vendor secara langsung.
2. **Penggunaan Contracts/Interfaces:** Modul bisnis hanya boleh mengandalkan *Interface* abstrak (misal: `PaymentGatewayInterface`).
3. **Adapter Layer Eksternal:** Layanan Midtrans dan Fonnte akan ditulis sebagai *Adapter Class* terpisah di layer infrastruktur yang mengimplementasikan *interface* tersebut (misal: `MidtransAdapter`).
4. **Notifikasi Berbasis Driver:** Untuk WhatsApp dan Email, sistem akan memaksimalkan arsitektur *Laravel Notification Channels* bawaan. Modul bisnis cukup mengeksekusi perintah `$user->notify(...)`, sementara channel adapter yang mengurus transmisi data.
**Alternatif:**
- *Hardcode request* langsung di dalam controller/service Finance (ditolak — berisiko tinggi jika ada kenaikan harga/perubahan vendor, karena harus memodifikasi core logic keuangan).
- Menjadikan vendor sebagai modul mandiri (ditolak — Midtrans dan Fonnte adalah perangkat infrastruktur, bukan sebuah domain bisnis kos-kosan).
**Konsekuensi:**
- Kemudahan dalam *Unit Testing* karena dependensi eksternal bisa dengan mudah di-mock/dipalsukan.
---

## ADR-011: Generalisasi Domain Kost Multi-Gedung, Backend Rewrite ke NestJS, dan Prioritas Web-First

**Tanggal:** 2026-10-18
**Status:** Accepted
**Konteks:**
1. Keterikatan kaku pada satu objek studi kasus (Wisma Amal Gorontalo) membatasi generalisasi sistem. Pengelolaan kost multi-gedung membutuhkan solusi yang berlaku umum untuk berbagai karakteristik operasional properti hunian sewa.
2. Keputusan rewrite total dari 41 tabel ke skema bersih 13 tabel menuntut penulisan ulang seluruh lapisan persistensi data. Mempertahankan Laravel dengan paket modular pihak ketiga terbukti rentan terhadap kebocoran batas modul domain.
3. Luaran tugas akhir memerlukan batasan deliverable yang teruji tuntas dan realistis. Mengembangkan serta menguji antarmuka web dan mobile fisik secara bersamaan memicu redundansi pengujian UI.
4. Fitur pendukung seperti Keycloak OIDC SSO dan asisten AI berbasis MCP dinilai berlebihan (*overengineered*) untuk lingkup operasional inti sewa bulanan.

**Keputusan:**
1. **Generalisasi Domain:** Sistem dirancang sebagai Sistem Informasi Manajemen Rumah Kost Multi-Gedung secara umum. Seluruh dependensi naskah dan arsitektur yang mengikat secara kaku pada Wisma Amal Gorontalo dieliminasi. Nama properti hanya dapat digunakan sebagai sampel data empiris saat pengujian.
2. **Backend Rewrite Total ke NestJS (TypeScript):** Mengadopsi NestJS sebagai kerangka kerja backend baru untuk menerapkan arsitektur Modular Monolith 9 modul terenkapsulasi secara native (`@Module()`), menegakkan nol FK lintas modul di tingkat kompilasi, memanfaatkan I/O non-blocking asinkron, dan menyatukan validasi kontrak DTO via `class-validator` serta Swagger.
3. **Platform Antarmuka Web-First (Flutter Web):** Target implementasi dan pengujian fungsional difokuskan pada Flutter Web (antarmuka dashboard pemilik, pengelola, dan portal penghuni). Dukungan mobile diposisikan sebagai kesiapan arsitektur multi-platform (*expansion readiness*), bukan kewajiban deliverable pengujian PA ini.
4. **Otentikasi Terpusat Keycloak SSO (OIDC):** Menggunakan Keycloak sebagai Identity and Access Management (IAM) untuk menyelesaikan kelemahan autentikasi primitif pada sistem lama (belum ada lupa kata sandi, validasi email, dan manajemen sesi). Backend NestJS bertindak sebagai *Resource Server* yang memvalidasi token JWT secara *stateless* menggunakan JWKS, memetakan peran pengguna (*Owner*, *Admin*, *Resident*), serta mengikatkan *tenant boundary* `building_id`.
5. **Dashboard Analitik & External AI Adapter (Model Context Protocol / MCP):** Menyediakan endpoint ringkasan operasional serta modul server MCP read-only (selaras dengan ADR-009) yang memungkinkan model AI (LLM) mengeksekusi kueri analitik cepat bagi pemilik dan pengelola tanpa melanggar batasan data (*tenant boundary*).

**Konsekuensi:**
- Judul naskah PA disesuaikan menjadi umum: *Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum* (tanpa sub-judul studi kasus spesifik).
- BAB 1–3 diselaraskan secara konsisten ke arsitektur NestJS, skema 13 tabel bulanan, Keycloak OIDC SSO, server MCP AI read-only, dan Flutter Web.
- Repo/folder backend baru akan diinisiasi berbasis template NestJS modular.

---

## ADR-012: PostgreSQL sebagai Basis Data Utama dan Docker sebagai Wajib Deployment

**Tanggal:** 2026-10-18
**Status:** Accepted
**Konteks:**
1. Rancangan awal rewrite (ADR-007 dan ADR-011) masih menyebut MySQL sebagai basis data utama. Setelah dikaji ulang, PostgreSQL lebih sesuai untuk proyek ini karena tipe data `NUMERIC` untuk nilai uang, dukungan `JSONB` untuk payload event dan parameter tool MCP, serta `partial index` yang memudahkan penyaringan tagihan yang belum lunas.
2. Deployment sistem ini akan melibatkan beberapa komponen terpisah (backend NestJS, basis data, Keycloak IAM, dan MCP server). Tanpa orkestrasi container, instalasi di lingkungan uji menjadi sulit direproduksi.
3. Proyek membutuhkan standar deployment yang seragam untuk menjalankan sistem di desktop, laptop, hingga server.

**Keputusan:**
1. **Basis Data Utama: PostgreSQL** — Seluruh 13 tabel domain memakai PostgreSQL sebagai RDBMS. Semua referensi MySQL pada naskah dan kode harus diganti ke PostgreSQL.
2. **Docker Wajib untuk Deployment** — Seluruh komponen sistem (NestJS, PostgreSQL, Keycloak) dibungkus dalam image Docker dan dijalankan lewat Docker Compose. Konsep *containerization* dan *orchestration* masuk ke dalam ruang lingkup PA dan wajib diuji pada bagian implementasi.

**Alternatif:**
- Tetap memakai MySQL (ditolak — `NUMERIC` dan `JSONB` pada PostgreSQL lebih memadai untuk data keuangan dan payload MCP).
- Deployment manual tanpa Docker (ditolak — sulit direplikasi antar lingkungan).

**Konsekuensi:**
- Bab 2 (Kajian Pustaka) harus memuat teori PostgreSQL, bukan MySQL.
- Bab 3 (Perancangan) harus menampilkan diagram Docker Compose dan spesifikasi `docker-compose.yml`.
- Kode dan migration di folder baru wajib mengikuti dialek SQL PostgreSQL (misalnya `SERIAL`/`IDENTITY` untuk auto-increment dan `TIMESTAMPTZ` untuk kolom waktu).
- Infrastruktur lokal dapat dijalankan dengan satu perintah `docker compose up`.

---

## ADR-013: Kebijakan Booking DP Fleksibel (Two-Phase Invoicing), Alur Refund Semi-Manual Berbukti Transfer, dan Otomasi Penagihan Siklus Ulang Tahun Sewa

**Tanggal:** 2026-10-23  
**Status:** Accepted  
**Konteks:**
1. **Dinamika Operasional Sewa Properti Riil:** Pada sistem manajemen kost general (multi-tenant/SaaS), calon penghuni kerap memesan kamar jauh hari sebelum masa huni (H-1 s/d H-3 bulan). Setiap pemilik properti memiliki segmentasi dan kebijakan bisnis berbeda: sebagian mewajibkan bayar sewa bulan pertama penuh di muka (komitmen tinggi), sebagian memfasilitasi Uang Tanda Jadi / Down Payment (DP) flat agar kamar dapat di-booking oleh mahasiswa, dan sebagian membebaskan biaya pemesanan (bayar saat tiba).
2. **Eliminasi Kerumitan Skema Cicilan:** Pendekatan cicilan atau pembayaran parsial konvensional menuntut pelacakan saldo piutang berjalan (`amount_paid`, `remaining_balance`, `partial_status`) yang rawan inkonsistensi akuntansi dan terbukti menjadi salah satu pemicu membengkaknya basis data lama menjadi 41 tabel.
3. **Realitas Pengembalian Dana (Refund):** Jika calon penghuni membatalkan reservasi berbayar jauh-jauh hari, sistem wajib menyediakan alur penyelesaian yang adil dan transparan. Namun, otomatisasi refund via API payment gateway (Midtrans) mensyaratkan akun korporat berbadan hukum (PT/CV) dengan deposit saldo terpisah yang tidak aplikatif bagi pengelola kost UMKM dan berisiko tinggi untuk lingkup Proyek Akhir.
4. **Siklus Penagihan Berkala & Kontrol Pengelola:** Penagihan bulanan memerlukan otomasi penjadwalan penerbitan tagihan, pemberitahuan dua arah (penghuni dan pengelola), serta mekanisme pengingat manual sewaktu-waktu oleh pengelola.

**Keputusan:**
1. **Konfigurasi Kebijakan Booking Dinamis per Properti (`building_settings`):**  
   Pengelola/pemilik properti dapat mengonfigurasi aturan pemesanan melalui parameter:
   - `booking_fee_mode`: `FULL_MONTH` (wajib lunas sewa bulan ke-1 di muka), `FIXED_DP` (uang tanda jadi flat, misal Rp 250.000), atau `NO_DP` (reservasi manual tanpa bayar di muka).
   - `dp_amount`: besaran nominal uang muka jika mode `FIXED_DP` aktif.
   - `dp_expiry_hours`: batas waktu pembayaran DP (default: 24 jam) sebelum reservasi dibatalkan otomatis oleh scheduler.
   - `settlement_lead_days`: tenggat hari penerbitan tagihan pelunasan sebelum tanggal mulai sewa (default: H-3).
   - `cancellation_grace_days`: batas waktu pembatalan yang masih memenuhi syarat pengembalian dana (default: $\ge$ 14 hari sebelum check-in).
   - `auto_invoice_lead_days`: rentang hari penerbitan tagihan sewa berkala otomatis sebelum jatuh tempo (default: H-7).

2. **Pola Two-Phase Invoicing untuk Penanganan DP (Nol Tabel Baru):**  
   Untuk menjaga kesederhanaan skema basis data, sistem menolak mekanisme cicilan parsial. Satu baris invoice selalu bernilai pasti dan diselesaikan dalam satu kali pembayaran penuh (*1 Invoice = 1 Amount = 1 Full Settlement*).  
   Jika mode `FIXED_DP` aktif, bulan pertama dipecah menjadi dua invoice terpisah berstatus definitif:
   - *Invoice #1 (Tipe `DP`):* Diterbitkan saat booking disetujui. Pembayaran DP mengunci unit kamar ke status `reserved` / `upcoming`.
   - *Invoice #2 (Tipe `SETTLEMENT`):* Diterbitkan otomatis oleh scheduler pada H-3 sebelum tanggal mulai huni dengan nominal matematis pasti:
     $$\text{Nominal Pelunasan} = \text{monthly\_price\_snapshot} - \text{Total DP Lunas}$$
     Aktivasi huni (*check-in*) hanya dapat dieksekusi jika Invoice DP dan Invoice Pelunasan berstatus lunas (`paid`).  
   Bulan ke-2 dan seterusnya diterbitkan normal sebagai tipe `RECURRING` sebesar harga sewa penuh kamar.

3. **Alur Refund Semi-Manual Berbukti Transfer Resmi:**  
   Pengembalian dana akibat pembatalan sewa diselesaikan secara semi-manual:
   - Calon penghuni mengajukan pembatalan secara mandiri melalui aplikasi dengan mengunggah alasan dan rincian rekening bank tujuan.
   - Pengelola meninjau permohonan melalui menu **Refund Requests**, memeriksa kepatuhan jendela waktu pembatalan, dan mengonfirmasi nominal pengembalian (dipotong denda/biaya pembatalan jika ada).
   - Pengelola mengeksekusi transfer bank secara mandiri (m-banking), mengunggah foto struk/bukti transfer (`refund_proof_url`), dan menekan tombol *Selesaikan Refund*.
   - Sistem secara otomatis mengubah status kontrak menjadi `cancelled`, melepaskan unit kamar kembali ke publik menjadi `available`, serta mengirimkan notifikasi resmi kepada penghuni berlampiran bukti transfer.

4. **Penagihan Siklus Ulang Tahun Sewa (*Anniversary Billing Cycle*) & Notifikasi Dua Arah:**  
   - Tanggal jatuh tempo penagihan sewa berkala diselaraskan dengan tanggal mulai sewa penghuni (*anniversary date*).
   - Tagihan di-generate otomatis oleh scheduler NestJS pada H-7 sebelum jatuh tempo.
   - Notifikasi dikirimkan dua arah: H-7 (tagihan terbit ke penghuni), H-1 (pengingat jatuh tempo ke penghuni), Hari H (peringatan jatuh tempo ke penghuni dan rekap tunggakan ke dashboard admin), serta konfirmasi kuitansi lunas instan saat pembayaran terverifikasi.
   - Pada antarmuka penagihan pengelola, disediakan tombol aksi **"Kirim Pengingat" (*Manual Reminder Trigger*)** yang dapat diklik pengelola sewaktu-waktu untuk mengirimkan pesan peringatan sopan via WhatsApp/Notifikasi ke kontak penghuni.

**Alternatif:**
- *Multi-payment partial billing pada 1 invoice* (ditolak — menciptakan kompleksitas saldo gantung dan memicu pembengkakan relasi tabel seperti sistem lama).
- *Automated Refund via Midtrans API* (ditolak — mensyaratkan akun berbadan hukum PT/CV dengan escrow disbursement balance, tidak realistis untuk kost skala UMKM dan pengujian PA).
- *Strict Non-refundable Policy tanpa refund* (ditolak — kurang adil bagi calon penghuni yang membatalkan pemesanan jauh hari pada sistem multi-properti general).

**Konsekuensi:**
- Skema tabel `invoices` diperkaya kolom enum `type` (`DP`, `SETTLEMENT`, `RECURRING`, `FINE`), tanpa memerlukan penambahan tabel transaksi baru.
- Menu antarmuka pengelola *Refund Requests* dan *Fine Management* pada rancangan UI web dipertahankan secara definitif sebagai modul fungsional aktif.
- Dokumentasi kebutuhan fitur (`DAFTAR_FITUR.md`) disinkronkan untuk memperjelas aturan F04, F08, F09, dan F16.



