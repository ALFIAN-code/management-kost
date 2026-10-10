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
- Apabila pengelola ingin berganti dari Midtrans ke Xendit, atau dari Fonnte ke Wablas, cukup membuat *Adapter* baru dan mengganti injeksinya (biasanya melalui `.env` atau *Service Provider*), tanpa risiko merusak stabilitas perhitungan keuangan.
- Diagram arsitektur akan diperbarui nantinya untuk menampilkan entitas "3rd-Party Integration Adapters".
