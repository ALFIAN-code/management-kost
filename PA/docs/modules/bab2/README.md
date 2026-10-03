# BAB 2 — Kajian Pustaka

> Dokumen Resmi Naskah Proyek Akhir — Departemen Teknik Informatika dan Komputer, PENS.
> Format sitasi mengacu pada IEEE numeric `[1]`-`[22]` terurut sesuai kemunculan pertama pada teks.

---

## 2.1 Deskripsi Permasalahan Empiris dan Teknis

Tata kelola hunian komersial sewa (rumah kost dan wisma) menuntut integrasi yang harmonis antara manajemen aset fisik, siklus waktu hunian, penagihan keuangan berkala, serta layanan purnajual [1][2]. Pada implementasi konvensional, proses operasional yang terfragmentasi menimbulkan inefisiensi yang signifikan:

1. **Fragmentasi Data dan Ketidakakuratan Pencatatan:**
   Pencatatan data penghuni dan riwayat transaksi yang terpisah-pisah pada lembar kerja spreadsheet atau pembukuan manual menimbulkan asimetri informasi [2]. Tidak adanya relasi data terstruktur mengakibatkan sulitnya penelusuran riwayat pembayaran sewa (*audit trail*), hilangnya data perbaikan fasilitas, dan lambatnya rekonsiliasi arus kas masuk dan keluar [4].

2. **Kerentanan Konflik Penjadwalan (*Double Booking*):**
   Manajemen ketersediaan kamar yang tidak terotomasi secara real-time rentan terhadap bentrok pemesanan (*double booking*), khususnya ketika proses reservasi dilakukan bersamaan melalui berbagai kanal komunikasi tanpa mekanisme penguncian konkurensi data (*concurrency locking*) [3].

3. **Kompleksitas Pengelolaan Portofolio Multi-Gedung (*Multi-Building Tenancy*):**
   Ketika skala usaha kost berkembang dari satu properti menjadi beberapa gedung fisik, pendekatan sistem monolitik tradisional tanpa isolasi *tenant* mengharuskan pengembang menduplikasi instalasi aplikasi untuk setiap gedung baru. Hal ini meningkatkan beban pemeliharaan infrastruktur secara eksponensial dan menghalangi pemilik (*owner*) untuk memperoleh gambaran kinerja bisnis secara konsolidasi [8].

4. **Keterbatasan Arsitektur Perangkat Lunak Legacy:**
   Pengembangan sistem sebelumnya yang memecah domain ke dalam 4 proposal terpisah (Penghuni & Tamu, Kamar & Reservasi, Keuangan, Operasional & Maintenance) mengalami kegagalan integrasi akibat kopling ketat (*tight coupling*) antar modul, pemanggilan service langsung tanpa abstraksi interface, serta pelanggaran batasan dependensi arsitektur [10][11][12][13].

---

## 2.2 Teori Penunjang

### 2.2.1 Sistem Informasi Manajemen (SIM) dan Transformasi Digital Properti Hunian

Sistem Informasi Manajemen (SIM) didefinisikan sebagai sistem sosio-teknikal terpadu yang mengombinasikan sumber daya manusia (*brainware*), perangkat keras (*hardware*), perangkat lunak (*software*), jaringan komunikasi, basis data (*database*), dan prosedur operasional standar (SOP) untuk mentransformasikan data mentah menjadi informasi bernilai guna mendukung fungsi perencanaan, pengorganisasian, pengendalian, dan pengambilan keputusan manajerial dalam suatu organisasi [2]. Dalam konteks modern, peranan SIM telah bergeser dari sekadar alat otomasi klerikal menjadi instrumen keunggulan kompetitif (*strategic competitive advantage*) [4].

Pada industri properti sewa hunian berskala mikro hingga menengah, digitalisasi proses bisnis melalui SIM mencakup empat pilar fungsional utama:

```
┌────────────────────────────────────────────────────────────────────────┐
│               DIMENSI FUNGSIONAL SISTEM INFORMASI WISMA                │
├───────────────────┬────────────────────┬───────────────────────────────┤
│ 1. Manajemen Aset │ 2. Siklus Sewa     │ 3. Keuangan & Penagihan       │
│ • Kamar Fisik     │ • Reservasi Kamar  │ • Invoice Generator Otomatis  │
│ • Fasilitas Unit  │ • Profil Penghuni  │ • Payment Gateway (Midtrans)  │
│ • Jadwal Servis   │ • Log Tamu Harian  │ • Rekonsiliasi & Arus Kas     │
├───────────────────┴────────────────────┴───────────────────────────────┤
│ 4. Operasional & Pemeliharaan                                          │
│ • Tiket Komplain Kerusakan Fasilitas                                   │
│ • Inventaris Barang Per Kamar & Approval Pembelian                     │
└────────────────────────────────────────────────────────────────────────┘
```

1. **Manajemen Aset Fisik & Ruang:** Mengelola data master kamar (nomor, tipe, kapasitas, fasilitas, tarif dasar), inventaris barang di dalam unit, serta jadwal pemeliharaan preventif.
2. **Manajemen Siklus Hidup Sewa (Tenancy Lifecycle):** Memfasilitasi pendaftaran calon penghuni, verifikasi identitas (KTP/kontak), alokasi kamar, kontrak sewa berkala (harian, bulanan, tahunan), mutasi kamar, hingga prosedur *check-out* dan pengembalian deposit.
3. **Akuntansi & Penagihan Sewa (Rent Accounting & Billing):** Otomasi penerbitan tagihan berkala (*recurring invoice*), integrasi kanal pembayaran digital terverifikasi (*payment gateway*), denda keterlambatan, manajemen uang jaminan (*security deposit*), serta penyusunan laporan laba rugi dan arus kas.
4. **Manajemen Layanan & Pemeliharaan (Helpdesk & Maintenance):** Sistem tiket penanganan komplain kerusakan fasilitas berbasis multi-foto, penugasan teknisi/petugas kebersihan, pemantauan waktu penyelesaian (*Service Level Agreement* / SLA), dan pencatatan riwayat depresiasi fasilitas aset [4][19].

Penerapan SIM terbukti mereduksi beban administratif hingga 70%, meminimalkan kesalahan manusia dalam pembukuan, mencegah kerugian pendapatan akibat kelalaian penagihan, serta meningkatkan kepuasan dan retensi penghuni [1][4][20].

---

### 2.2.2 Evolusi Arsitektur Perangkat Lunak: Monolith, Microservices, dan Modular Monolith (Modulith)

Arsitektur perangkat lunak merupakan cetak biru fundamental yang mendefinisikan komponen-komponen penyusun sistem, hubungan struktural dan perilaku antar komponen, serta prinsip perancangan yang memandu evolusi sistem [3][5]. Dalam rekayasa perangkat lunak enterprise, pemilihan arsitektur backend merupakan penentu utama skalabilitas, kemudahan pemeliharaan (*maintainability*), dan efisiensi operasional [5][7].

```
┌─────────────────────────────────────────────────────────────────────────┐
│               ARSITEKTUR MODULAR MONOLITH (MODULITH)                    │
│                                                                         │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │                     INFRASTRUCTURE TIER                         │   │
│   │        • Auth (Sanctum + RBAC)        • Setting & System Config │   │
│   └────────────────────────────────┬────────────────────────────────┘   │
│                                    │                                    │
│   ┌────────────────────────────────▼────────────────────────────────┐   │
│   │                          CORE TIER                              │   │
│   │        • Tenant / Building Entity     • Room Management         │   │
│   │        • Schedule Core (Sewa, Perawatan, Pemblokiran Kamar)     │   │
│   └────────────────────────────────┬────────────────────────────────┘   │
│                                    │                                    │
│   ┌────────────────────────────────▼────────────────────────────────┐   │
│   │                   BUSINESS MODULES TIER                         │   │
│   │  ┌───────────┐ ┌─────────────┐ ┌──────────────┐ ┌─────────────┐ │   │
│   │  │  Finance  │ │ Maintenance │ │ Guest & Inv  │ │ Notification│ │   │
│   │  └─────┬─────┘ └──────┬──────┘ └──────┬───────┘ └──────┬──────┘ │   │
│   │        │              │               │                │        │   │
│   │        └──────────────┴───────┬───────┴────────────────┘        │   │
│   │                               ▼                                 │   │
│   │                     ★ MCP SERVER (AI API) ★                     │   │
│   └───────────────────────────────┬─────────────────────────────────┘   │
│                                   │                                     │
│   ┌───────────────────────────────▼─────────────────────────────────┐   │
│   │      COMMUNICATION LAYER: EVENT BUS (WRITE) & GATEWAY (READ)    │   │
│   └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Analisis Komparatif Paradigma Arsitektur
- **Monolith Tradisional (Layered Architecture):** Seluruh kode bisnis dikompilasi dan dideploy sebagai satu kesatuan (*single binary/artifact*). Meskipun sederhana dalam proses deployment dan bebas dari latensi jaringan antar fungsi, arsitektur ini rentan terhadap degradasi struktur (*architectural erosion*), di mana batas-batas domain menjadi kabur, memicu kopling ketat (*tight coupling*) dan mempersulit pengujian unit secara terisolasi [3][5].
- **Microservices Architecture:** Memecah aplikasi menjadi kumpulan layanan independen yang terdistribusi di atas jaringan, masing-masing dengan basis data sendiri. Walaupun memungkinkan penskalaan independen, microservices menimbulkan biaya operasional yang sangat tinggi (*high operational overhead*), latensi jaringan antar layanan (*network latency*), konsistensi data eventual yang kompleks (*distributed transaction / Saga pattern*), serta rentan terhadap *Fallacies of Distributed Computing* (asumsi bahwa jaringan selalu andal, latensi nol, dan bandwidth tak terbatas) [3][7][9].
- **Modular Monolith (Modulith):** Merupakan pendekatan hibrida modern yang mengadopsi prinsip modularitas logis microservices dengan tetap mempertahankan kesederhanaan deployment monolitik [5][6][8]. Modul-modul bisnis didefinisikan secara tegas di dalam satu basis kode dan dieksekusi di dalam satu proses runtime bersama, memanfaatkan komunikasi in-memory berkecepatan tinggi tanpa latensi jaringan [7][11][13].

#### 2. Prinsip Domain-Driven Design (DDD) sebagai Fondasi Modulith
Modular Monolith mengadopsi prinsip *Domain-Driven Design (DDD)* untuk menetapkan batas-batas modul yang kohesif (*bounded contexts*) [8]:
- **Bounded Context:** Setiap modul (Room, Schedule, Finance, Maintenance, Guest, Inventory, Notification, Mcp) merepresentasikan ruang lingkup bisnis tertentu dengan model data dan aturan bisnis yang terisolasi [6][8].
- **Explicit Boundaries & Information Hiding:** Detail implementasi internal modul (seperti query Eloquent mentah dan model internal) disembunyikan dari modul lain. Interaksi hanya diizinkan melalui kontrak publik yang telah ditetapkan [5][8].
- **Shared Kernel Minimal:** Hanya komponen fundamental bersama (seperti identitas pengguna, penanganan error, dan otorisasi RBAC) yang ditempatkan pada shared kernel guna mencegah ketergantungan silang yang tidak terkontrol [6].

#### 3. Hirarki Modul 3-Lapis (3-Tier Hierarchy)
Untuk menjamin keteraturan dependensi searah (*acyclic dependency*), sistem menstrukturkan modul ke dalam 3 tingkatan [11][12]:
1. **Infrastructure Tier (Selalu Aktif):** Modul fundamental sistem, yaitu `Auth` (manajemen pengguna, token Sanctum, dan Spatie RBAC) serta `Setting` (konfigurasi sistem dan feature toggles).
2. **Core Tier (Selalu Aktif):** Modul entitas inti yang merepresentasikan fisik dan jadwal properti:
   - `Room`: Aset fisik kamar (nomor, tipe, harga dasar, foto, fasilitas).
   - `Schedule`: Entitas temporal yang mencatat semua pemanfaatan kamar (sewa penghuni, perbaikan teknis, kebersihan berkala, atau pemblokiran). Modul ini menggantikan entitas `Rental` dan `Resident` legacy.
3. **Business Modules Tier (Independen & Toggleable):** Modul proses bisnis spesifik yang dapat diaktifkan atau dinonaktifkan per properti (`Finance`, `Maintenance`, `Guest`, `Inventory`, `Notification`, dan `Mcp Server`).

#### 4. Pola Komunikasi Decoupled: Event Bus (Write) vs Module Gateway (Read)
Kunci modularitas sejati terletak pada penghapusan pemanggilan service langsung antar modul [5][6]:
- **Operasi Tulis (Mutasi Data) Berbasis Internal Event Bus:** Ketika terjadi mutasi data pada Core Tier (misalnya jadwal sewa baru dibuat), modul `Schedule` memancarkan domain event global `JadwalDibuat`. Modul `Finance` yang bertindak sebagai listener akan menangkap event tersebut dan menerbitkan invoice secara asinkron tanpa modul `Schedule` perlu mengetahui keberadaan modul `Finance`. Jika modul `Finance` dinonaktifkan via `modules_statuses.json`, event tetap dipancarkan tanpa memicu kegagalan sistem (*graceful degradation*).
- **Operasi Baca (Query Aggregation) Berbasis Module Gateway Layer:** Untuk kebutuhan pembacaan data lintas modul (misalnya dashboard agregasi atau laporan analitik AI), modul bisnis memanggil kontrak publik pada *Module Gateway Layer*. Pemanggilan ini diproteksi oleh pengecekan runtime `ModuleGate::isActive('ModuleName')` guna mengembalikan data fallback aman apabila modul yang dituju sedang nonaktif.

> **Gambar 2.1 — Arsitektur Sistem Terpadu (C4 Container, FINAL):** `PA/docs/diagrams/01_arsitektur_sistem_terpadu/c4_level2_container_wisma_amal.svg` — relasi Flutter App, Laravel 11 API, Keycloak OIDC, Midtrans, Fonnte, dan MySQL 8.x.
>
> **Gambar 2.2 — Dekomposisi Modulith 3-Tier (Component, FINAL):** `PA/docs/diagrams/02_hierarki_3_tier_modulith/component_diagram_modular_monolith_3_tier.svg` — Tier Infrastruktur/Core/Bisnis, Query Gateway, Event Bus, Module Registry, dan Tenant Scope. File `.mmd`/`.png` lama di folder tersebut dinyatakan disupersede.

---

### 2.2.3 Standarisasi Kontrak Input-Output API, Serialisasi DTO, dan Living Documentation

Komunikasi data antara antarmuka klien multi-platform (Flutter Web dan Mobile), backend Laravel, serta modul integrasi eksternal (Midtrans, WhatsApp Gateway, dan MCP AI) memerlukan kontrak data yang terstruktur, konsisten, dan *type-safe* [8][18].

```
┌────────────────────────────────────────────────────────────────────────┐
│                  ANATOMI KONTRAK DATA INPUT-OUTPUT                     │
├───────────────────────────────────┬────────────────────────────────────┤
│ INPUT (HTTP Request)              │ OUTPUT (HTTP Response Envelope)    │
│ • JSON Payload / Multipart        │ • status: boolean (true/false)     │
│ • Header X-Building-ID (Tenant)   │ • message: string deskriptif       │
│ • FormRequest Strict Validation   │ • data: object / array terenkapsulasi│
│ • Boundary Sanitization           │ • meta: pagination / audit info    │
│ • RFC-7807 Error Code Mapping     │ • errors: key-value validasi (422) │
└───────────────────────────────────┴────────────────────────────────────┘
```

#### 1. Spesifikasi Baku JSON Response Envelope
Seluruh endpoint REST API diwajibkan mengembalikan struktur envelope standar menggunakan trait `ApiResponse`:
- **Format Respons Sukses (HTTP 200 / 201):**
  ```json
  {
    "status": true,
    "message": "Data daftar kamar berhasil diambil",
    "data": [
      {
        "id": 101,
        "building_id": 1,
        "nomor_kamar": "A-01",
        "tipe": "eksekutif",
        "harga_bulanan": 1500000,
        "status": "kosong"
      }
    ],
    "meta": {
      "current_page": 1,
      "per_page": 10,
      "total": 45,
      "last_page": 5
    }
  }
  ```
- **Format Respons Kegagalan Validasi (HTTP 422 Unprocessable Entity):**
  ```json
  {
    "status": false,
    "message": "Validasi input formulir gagal",
    "errors": {
      "building_id": ["Gedung wajib dipilih dan harus valid."],
      "nomor_kamar": ["Nomor kamar sudah terdaftar pada gedung terpilih."]
    }
  }
  ```

#### 2. Validasi Berlapis (Layered Validation) via FormRequest
Validasi parameter masukan dilakukan pada gerbang terluar HTTP menggunakan kelas *FormRequest* terdedikasi per modul sebelum dialirkan ke domain service. Pemetaan kode status HTTP merujuk pada standar IETF (RFC 7231 & RFC 7807):
- `200 OK`: Permintaan berhasil diproses.
- `201 Created`: Sumber daya baru berhasil disimpan ke basis data.
- `400 Bad Request`: Permintaan tidak memenuhi format sintaksis dasar.
- `401 Unauthorized`: Ketiadaan atau ketidakvalidan token otentikasi Bearer Sanctum.
- `403 Forbidden`: Pengguna tidak memiliki hak akses (*Forbidden*) berdasarkan aturan Spatie RBAC atau pembatasan *tenant boundary*.
- `404 Not Found`: Entitas data tidak ditemukan pada lingkup gedung aktif.
- `422 Unprocessable Entity`: Data masukan melanggar aturan validasi bisnis/skema.
- `500 Internal Server Error`: Kesalahan fatal internal pada server yang dicatat ke dalam log sistem.

#### 3. Data Transfer Objects (DTO) dan Resource Transformers
Penggunaan Laravel API Resources bertindak sebagai DTO (*Data Transfer Object*) yang memetakan model entitas internal Eloquent menjadi skema JSON publik. Pola ini mencegah terjadinya kebocoran skema basis data (*information leakage* seperti hash password, kunci token internal, atau kolom sistem), mengeliminasi masalah *over-fetching/under-fetching*, serta menjamin tipe data yang konsisten (misalnya konversi harga ke tipe numeric/integer dan tanggal ke format ISO-8601 `YYYY-MM-DD`).

#### 4. Living Documentation via Scramble OpenAPI
Guna mencegah dokumentasi menjadi artefak yang usang (*documentation rot*), spesifikasi OpenAPI 3.1 diekstraksi secara otomatis dari basis kode menggunakan pustaka Scramble. Dokumentasi diperbarui secara real-time berdasarkan *type-hints PHP 8.2*, *DocBlocks*, dan kelas *FormRequest/Resource* tanpa memerlukan pemeliharaan file YAML manual. OpenAPI spec ini menjadi acuan tunggal (*single source of truth*) bagi pengembangan datasource di Flutter dan definisi tool schema pada server MCP.

---

### 2.2.4 Arsitektur Multi-Tenancy (Pola Row-Level Scoping Multi-Gedung)

Multi-tenancy merupakan arsitektur perangkat lunak yang memungkinkan satu instansi aplikasi melayani banyak kelompok pengguna atau unit bisnis independen (*tenants*) dengan jaminan isolasi data yang ketat [8]. Dalam konteks Wisma Amal, multi-tenancy diimplementasikan untuk mendukung pengelolaan portofolio **multi-gedung kost** dalam satu platform terpusat.

```
┌────────────────────────────────────────────────────────────────────────┐
│                 POLA ISOLASI DATA MULTI-TENANT                         │
├───────────────────────────────────┬────────────────────────────────────┤
│ Model Multi-Tenancy               │ Karakteristik & Evaluasi           │
├───────────────────────────────────┼────────────────────────────────────┤
│ 1. Database-per-Tenant            │ • Isolasi fisik mutlak             │
│    (Tiap gedung punya 1 DB fisik) │ • Biaya tinggi, migrasi rumit      │
├───────────────────────────────────┼────────────────────────────────────┤
│ 2. Schema-per-Tenant              │ • Isolasi schema logis             │
│    (1 DB, tabel dipisah schema)   │ • Maintenance DDL overhead         │
├───────────────────────────────────┼────────────────────────────────────┤
│ 3. Shared Database with           │ • Isolasi baris data (building_id) │
│    Row-Level Scoping ★ (Dipilih)  │ • Hemat resource, agregasi mudah,  │
│                                   │   query cepat via composite index  │
└───────────────────────────────────┴────────────────────────────────────┘
```

#### 1. Evaluasi Model Isolasi Multi-Tenant
Terdapat 3 model isolasi data multi-tenant dalam rekayasa basis data [8]:
1. **Database-per-Tenant:** Setiap gedung memiliki basis data fisik terpisah. Menawarkan isolasi mutlak, namun memerlukan biaya infrastruktur yang tinggi dan mempersulit pemeliharaan migrasi skema massal.
2. **Schema-per-Tenant:** Satu basis data bersama dengan skema terpisah per gedung. Mengurangi beban server namun tetap menimbulkan overhead manajemen DDL yang tinggi.
3. **Shared Database with Row-Level Scoping (Pilihan PA Ini):** Seluruh data gedung disimpan dalam satu basis data bersama dengan penambahan kolom diskriminator `building_id` pada setiap tabel domain (`rooms`, `schedules`, `invoices`, `damage_reports`, `inventories`, `guests`). Model ini dipilih karena efisiensi sumber daya server komputasi, kemudahan eksekusi migrasi skema terpusat, serta kemudahan penyusunan laporan analitik konsolidasi bagi pemilik properti (*cross-building analytics*).

#### 2. Pipeline Resolusi Tenant & Global Scope Middleware
Proses isolasi data dijalankan secara otomatis melalui tahapan pipeline middleware:
1. **Resolusi Tenant (`TenantResolverMiddleware`):** Setiap request HTTP memeriksa keberadaan header `X-Building-ID` atau parameter rute. Middleware memverifikasi keabsahan ID gedung dan memastikan pengguna yang terautentikasi memiliki relasi penugasan yang sah terhadap gedung tersebut.
2. **Injeksi Global Query Scope Eloquent:** ORM Eloquent secara otomatis menyematkan klausa `WHERE building_id = :current_tenant_id` pada seluruh kueri operasi `SELECT`, `UPDATE`, dan `DELETE`. Hal ini mengeliminasi risiko kelalaian pengembang dalam menuliskan filter gedung secara manual, sehingga mencegah kebocoran data antar-gedung (*cross-tenant data leakage*).

#### 3. Tenant-Aware Role-Based Access Control (RBAC)
Matriks otorisasi Spatie RBAC diperluas dengan dimensi kepemilikan gedung:
- **Owner (Pemilik Properti):** Memiliki hak akses penuh atas $N$ gedung miliknya, dapat berpindah konteks gedung secara dinamis (*building switcher*), dan mengakses ringkasan keuangan gabungan.
- **Admin / Pengelola Gedung:** Dibatasi secara mutlak hanya pada 1 atau beberapa gedung penugasan spesifik. Usaha akses terhadap data gedung lain akan ditolak oleh sistem dengan respons HTTP 403 Forbidden.
- **Penghuni:** Hak akses dibatasi pada entitas data jadwal kamar, tagihan, dan komplain miliknya sendiri pada gedung yang ditempati.

---

### 2.2.5 Model Context Protocol (MCP) dan Rekayasa Asisten Cerdas (Built-in AI Assistant)

*Model Context Protocol* (MCP) merupakan standar terbuka yang dirancang untuk mengintegrasikan model kecerdasan buatan (*Large Language Models* / LLM) dengan sumber data kontekstual dan fungsi komputasi perangkat lunak eksternal secara terstruktur dan aman [8].

```
┌─────────────────────────────────────────────────────────────────────────┐
│               ALUR KERJA ASISTEN AI BERBASIS PROTOKOL MCP               │
│                                                                         │
│   Pengguna (Owner/Admin)                                                │
│   "Berapa total pendapatan Gedung Melati bulan ini?"                    │
│             │                                                           │
│             ▼                                                           │
│   ┌───────────────────────────┐    1. Analisis Niat & Pemilihan Tool    │
│   │ LLM Engine (Claude/Gemini)│ ────────────────────────────────────┐   │
│   └───────────────────────────┘                                     │   │
│             ▲                                                       ▼   │
│             │ 4. Sintesis Jawaban Terstruktur          ┌────────────────┐
│             │    Berdasarkan Data Faktual              │ MCP Client     │
│             │                                          └───────┬────────┘
│             │                                                  │ 2. JSON-RPC
│             │                                                  ▼
│   ┌─────────┴─────────────────┐    3. Return Data      ┌────────────────┐
│   │ Response UI (Teks+Tabel)  │ <───────────────────── │ MCP Server (BE)│
│   └───────────────────────────┘       JSON Terverifikasi└────────────────┘
│                                                         • Auth & Tenant 
│                                                         • Module Gateway
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Arsitektur Komponen Protokol MCP
Interaksi AI pada sistem Wisma Amal diatur melalui modul `Mcp` yang bertindak sebagai **MCP Server JSON-RPC 2.0**:
- **MCP Client (Frontend / Gateway AI):** Menerima masukan pertanyaan bahasa alami dari pengguna, meneruskannya ke LLM, dan mengeksekusi *tool request* yang diminta oleh model.
- **MCP Server (Backend Laravel Modul Mcp):** Mengekspos katalog fungsionalitas sistem yang terdokumentasi dalam format JSON Schema:
  - *Resources:* Skema metadata properti statis.
  - *Prompts:* Panduan instruksi sistem (*system prompt*) yang mengarahkan model untuk bertindak sebagai analis bisnis properti profesional.
  - *Tools:* Fungsi komputasi deterministik yang dapat dipanggil oleh model untuk mengambil data riil dari basis data MySQL.

#### 2. Katalog Tool Analitik SIM Wisma
Modul `Mcp` mengekspos empat tool komputasi read-only utama:
1. `get_building_occupancy(building_id: int, date: string)`: Menghasilkan persentase okupansi, jumlah kamar terisi, kosong, dan dalam perbaikan pada gedung terpilih.
2. `get_financial_summary(building_id: int, start_date: string, end_date: string)`: Menghasilkan rekapitulasi total tagihan terbit, total pembayaran terverifikasi, piutang sewa tertunggak, dan rincian pengeluaran operasional.
3. `get_damage_reports(building_id: int, status: string)`: Mengambil daftar tiket kerusakan aktif beserta tingkat keparahan dan estimasi biaya penanganan.
4. `get_guest_activity(building_id: int, date_range: string)`: Mengagregasi data kunjungan tamu dan mendeteksi anomali durasi menginap.

#### 3. Deterministic Grounding, Mitigasi Halusinasi, dan Guardrail Keamanan
- **Deterministic Data Grounding:** Model AI tidak diizinkan membuat inferensi angka secara spekulatif. Seluruh pernyataan kuantitatif wajib bersumber dari payload JSON yang dikembalikan oleh tool MCP melalui kueri basis data riil via *Module Gateway*.
- **Tenant Boundary Enforcement:** Sebelum tool dieksekusi, server MCP memverifikasi token pengguna dan memastikan bahwa parameter `building_id` berada dalam lingkup hak akses pengguna tersebut.
- **Audit Logging:** Setiap interaksi tool-use oleh AI dicatat ke dalam tabel basis data `mcp_tool_logs` (merekam ID pengguna, nama tool, parameter yang dikirimkan, durasi eksekusi, dan timestamp) untuk pemantauan integritas dan audit keamanan sistem.

---

### 2.2.6 Single Sign-On (SSO), OpenID Connect (OIDC), dan Arsitektur Keycloak IAM

*Single Sign-On* (SSO) adalah mekanisme otentikasi terpusat yang memungkinkan pengguna mengakses berbagai aplikasi dan layanan independen hanya dengan satu set kredensial otentikasi [8]. Dalam sistem berskala enterprise modern, pemisahan fungsi antara *Identity Provider* (IdP) dan *Resource Server / Service Provider* (SP) merupakan praktik standar untuk meningkatkan postur keamanan dan menyederhanakan tata kelola identitas.

```
┌─────────────────────────────────────────────────────────────────────────┐
│              ARSITEKTUR OTENTIKASI KEYCLOAK OIDC TERPUSAT               │
│                                                                         │
│   Pengguna (Flutter Web / Mobile)                                       │
│   [ Tombol: "Masuk via SSO Wisma Amal" ]                                │
│             │                                                           │
│             ▼                                                           │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │ KEYCLOAK IAM SERVER (Realm: wisma-amal-realm)                   │   │
│   │ • User Credential & MFA Management                              │   │
│   │ • Identity Brokering (Google OAuth2 / Social Login)             │   │
│   │ • OIDC Token Issuer (RS256 Private Key Signing)                 │   │
│   └────────────────────────────────┬────────────────────────────────┘   │
│                                    │ Menerbitkan ID Token & Access Token│
│                                    ▼ (JWT)                              │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │ FLUTTER CLIENT APPLICATION (OIDC Client)                        │   │
│   └────────────────────────────────┬────────────────────────────────┘   │
│                                    │ Kirim Token via Header             │
│                                    ▼ POST /api/auth/sso/keycloak        │
│   ┌─────────────────────────────────────────────────────────────────┐   │
│   │ BACKEND LARAVEL MODULITH (Modul Auth)                           │   │
│   │ 1. Unduh Public Key via Keycloak JWKS Endpoint (/certs)         │   │
│   │ 2. Validasi Stateless Signature & Claims (sub, email, exp)      │   │
│   │ 3. Just-In-Time (JIT) Provisioning pada tabel lokal 'users'     │   │
│   │ 4. Pemetaan Role Spatie RBAC & Injeksi Tenant Scope Gedung      │   │
│   │ 5. Terbitkan Token Sesi Internal Laravel Sanctum                │   │
│   └─────────────────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Protokol OpenID Connect (OIDC) dan OAuth 2.0
OpenID Connect (OIDC) merupakan lapisan identitas (*identity layer*) yang dibangun di atas kerangka kerja otorisasi OAuth 2.0 (RFC 6749):
- **OAuth 2.0:** Bertanggung jawab atas pendelegasian otorisasi (*authorization*) dengan menerbitkan *Access Token*.
- **OpenID Connect (OIDC):** Menambahkan profil identitas pengguna terstandarisasi dalam bentuk *ID Token* berformat JSON Web Token (JWT) yang ditandatangani secara kriptografis (*signed JWT*).

#### 2. Arsitektur Keycloak Identity and Access Management (IAM)
Keycloak dipilih sebagai server IdP open-source enterprise dengan karakteristik:
- **Realm-Based Isolation:** Seluruh konfigurasi pengguna, klien aplikasi (Flutter Web dan Mobile), serta peran sistem dikelola di dalam satu realm terisolasi (`wisma-amal-realm`).
- **Identity Brokering:** Keycloak bertindak sebagai broker identitas yang memungkinkan pengguna masuk menggunakan akun eksternal (seperti Google Sign-In) tanpa perlu mengonfigurasi kredensial Google OAuth secara terpisah di backend Laravel dan frontend Flutter.
- **Token Exchange & Stateless Verification via JWKS:** Backend Laravel tidak perlu melakukan koneksi basis data langsung ke Keycloak. Validasi token dilakukan secara *stateless* menggunakan algoritma asimetris RS256 dengan memverifikasi tanda tangan publik token terhadap kunci publik yang diekspos melalui endpoint *JSON Web Key Set* (JWKS) Keycloak (`/realms/wisma-amal-realm/protocol/openid-connect/certs`).

#### 3. Just-In-Time (JIT) User Provisioning dan RBAC Synchronization
Ketika pengguna berhasil melakukan otentikasi via Keycloak dan mengirimkan ID Token ke backend:
- Backend mengekstraksi klaim identitas (`sub` sebagai `keycloak_id`, `email`, dan `name`).
- Jika akun belum terdaftar di basis data lokal MySQL, sistem secara otomatis mengeksekusi *Just-In-Time (JIT) Provisioning* untuk membuat baris pengguna baru.
- Sistem menyematkan default role Spatie (misalnya role `resident` atau `guest`) dan mengikatkan konteks gedung binaan/sewa, kemudian menerbitkan token *Laravel Sanctum* untuk komunikasi API transaksi selanjutnya.

---

### 2.2.7 Clean Architecture di Frontend Flutter (Mobile + Web Single Codebase)

Clean Architecture memisahkan kode program ke dalam lapisan-lapisan konsentris dengan aturan ketergantungan yang kaku (*The Dependency Rule*), di mana lapisan dalam tidak boleh mengetahui keberadaan lapisan luar [14][15][16]. Pada frontend Flutter, Clean Architecture memungkinkan 100% domain logic dan state management digunakan bersama (*reused*) antara antarmuka Web Dashboard dan Mobile App dalam satu basis kode tunggal (*single codebase*) [15].

```
┌─────────────────────────────────────────────────────────────────────────┐
│              CLEAN ARCHITECTURE FRONTEND FLUTTER (3 LAYER)              │
├─────────────────────────────────────────────────────────────────────────┤
│                                                                         │
│   PRESENTATION LAYER                                                    │
│   • UI Widgets (Web Dashboard & Mobile Screens)                         │
│   • State Management (BLoC / Cubit Pattern)                             │
│   • Responsive Layout Builders & Navigation (AutoRoute)                 │
│                                │                                        │
│                                ▼ (Memanggil UseCase)                    │
│   DOMAIN LAYER (Pure Dart - No External Dependencies)                   │
│   • Entities (Struktur data bisnis murni)                               │
│   • UseCases (Logika interaksi bisnis spesifik: GetRooms, PayInvoice)   │
│   • Repository Interfaces (Abstraksi kontrak akses data)                │
│                                ▲                                        │
│                                │ (Mengimplementasi Interface)           │
│   DATA LAYER                                                            │
│   • Repository Implementations (Pengambil keputusan cache/network)      │
│   • DataSources (Remote API Dio Client & Local Secure Storage)          │
│   • Models / DTO (JSON Serializer & Mapper to Domain Entity)            │
│                                                                         │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Pembagian 3 Lapisan Arsitektural
1. **Domain Layer (Lapisan Pusat - Pure Dart):**
   Merupakan lapisan paling dalam yang bebas dari dependensi pustaka luar, Flutter SDK, maupun database:
   - *Entities:* Struktur data bisnis inti (contoh: `RoomEntity`, `InvoiceEntity`).
   - *UseCases:* Kelas yang mengenkapsulasi satu aturan bisnis spesifik (contoh: `GetBuildingOccupancyUseCase`, `PayInvoiceUseCase`).
   - *Repository Interfaces:* Kontrak abstraksi data murni (contoh: `abstract class RoomRepository`).
2. **Data Layer (Lapisan Data):**
   Bertanggung jawab atas penyediaan data mentah ke domain layer:
   - *DataSources:* Menangani komunikasi jaringan remote via Dio HTTP Client (dilengkapi interceptor token Sanctum dan penyematan header `X-Building-ID`) serta penyimpanan lokal via *Flutter Secure Storage*.
   - *Models (DTO):* Representasi data yang mengimplementasikan serialisasi JSON (`fromJson`, `toJson`) dan pemetaan ke domain entity (`toEntity()`).
   - *Repository Implementations:* Mengimplementasikan kontrak domain repository, mengelola strategi pengambilan data (remote/cache), serta membungkus hasil dalam tipe fungsional `Either<Failure, Success>` (*dartz*).
3. **Presentation Layer (Lapisan Tampilan):**
   - *State Management (BLoC / Business Logic Component):* Menerapkan aliran data satu arah (*Unidirectional Data Flow*). Menerima *Event* dari UI, mengeksekusi *UseCase*, dan memancarkan *State* baru yang tidak dapat diubah (*immutable State*).
   - *Pages & Widgets:* Komponen antarmuka responsif yang me-render data sesuai state BLoC terkini.

#### 2. Manajemen Dependensi dengan Service Locator (GetIt)
Objek dependensi didaftarkan secara terpusat pada *Service Locator* GetIt:
- `DataSource`: Didaftarkan sebagai `LazySingleton` untuk efisiensi koneksi HTTP.
- `Repository`: Didaftarkan sebagai `LazySingleton`.
- `UseCase`: Didaftarkan sebagai `Factory` untuk menjamin independensi eksekusi.
- `BLoC`: Didaftarkan sebagai `Factory` dan diikat ke widget tree menggunakan `BlocProvider.value` (mencegah penutupan state stream yang tidak disengaja).

---

### 2.2.8 Basis Data Relasional MySQL: Integritas ACID, MVCC, dan Optimasi Indexing Multi-Tenant

MySQL 8.x dengan mesin penyimpanan InnoDB menyediakan fondasi basis data relasional yang andal dengan kepatuhan penuh terhadap prinsip ACID (Atomicity, Consistency, Isolation, Durability) [8].

```
┌────────────────────────────────────────────────────────────────────────┐
│               MEKANISME PENCEGAHAN DOUBLE BOOKING (MVCC)               │
├────────────────────────────────────────────────────────────────────────┤
│ Permintaan Sewa Masuk (Kamar 101, Tanggal: 2026-10-01 s/d 2026-10-31)  │
│                                │                                       │
│                                ▼                                       │
│ Transaksi DB Dimulai: DB::beginTransaction()                           │
│ SELECT * FROM schedules                                                │
│ WHERE room_id = 101 AND building_id = 1                                │
│   AND status IN ('active', 'reserved')                                 │
│   AND (start_date <= '2026-10-31' AND end_date >= '2026-10-01')        │
│ FOR UPDATE;  <── [Pessimistic Row Lock: Mencegah Transaksi Konkuren]   │
│                                │                                       │
│         ┌──────────────────────┴──────────────────────┐                │
│         ▼ (Ada Jadwal Bentrok)                        ▼ (Jadwal Kosong)│
│  Rollback & Lempar DomainException             Insert Jadwal Baru &    │
│  (HTTP 422: "Kamar sudah dipesan")             DB::commit()            │
└────────────────────────────────────────────────────────────────────────┘
```

#### 1. Integritas Transaksi & Penguncian Pesimistik Anti-Double Booking
Dalam reservasi kamar sewa, bentrok jadwal akibat transaksi konkuren pada waktu yang bersamaan diatasi menggunakan mekanisme *Multi-Version Concurrency Control* (MVCC) dan *Pessimistic Row-Level Locking*:
- Pengecekan ketersediaan kamar dieksekusi di dalam blok transaksi `DB::transaction()` menggunakan kueri `SELECT ... FOR UPDATE`.
- Baris jadwal kamar terkunci secara eksklusif hingga transaksi selesai (*commit* atau *rollback*), memaksa transaksi konkuren lain untuk mengantre sehingga mencegah terjadinya anomali *Write-Skew* dan *Double Booking*.

#### 2. Strategi Composite Indexing Multi-Tenant
Pada basis data bersama (*shared database*), volume data tabel domain bertumbuh seiring bertambahnya jumlah gedung. Untuk menjaga performa kueri tetap konstan ($O(\log N)$):
- Diterapkan *Composite Index* `(building_id, status, created_at)` pada tabel `rooms` dan `schedules`.
- Diterapkan *Composite Index* `(building_id, user_id, status)` pada tabel `invoices`.
- Strategi indeks komposit memastikan *Query Optimizer* MySQL mengeksekusi *Index Range Scan* alih-alih *Full Table Scan*, menjaga latensi kueri basis data di bawah 50 milidetik.

#### 3. Tingkatan Pemisahan Basis Data pada Modular Monolith
Salah satu pertanyaan fundamental dalam arsitektur Modular Monolith adalah: *"Jika sistem mengklaim modular, mengapa databasenya masih satu? Apa bedanya dengan monolith biasa?"* Literatur membedakan tiga tingkatan pemisahan basis data [5][6][8]:

```
┌────────────────────────────────────────────────────────────────────────┐
│            3 TINGKATAN PEMISAHAN BASIS DATA MODULAR MONOLITH            │
├───────────────────────────────────┬────────────────────────────────────┤
│ Tingkat Pemisahan                 │ Karakteristik & Evaluasi           │
├───────────────────────────────────┼────────────────────────────────────┤
│ Level 1. Physical Database-       │ Tiap modul punya server DB sendiri │
│ per-Module (Microservices murni)  │ Biaya mahal, transaksi Saga rumit, │
│                                   │ overkill untuk skala UMKM kost     │
├───────────────────────────────────┼────────────────────────────────────┤
│ Level 2. Schema-per-Module        │ 1 instance DB, namespace schema    │
│ (1 DB, namespace terpisah)        │ terpisah per modul (misal          │
│                                   │ auth.users, finance.invoices)      │
├───────────────────────────────────┼────────────────────────────────────┤
│ Level 3. Logical Schema Ownership │ 1 database fisik bersama, namun    │
│ & Shared Database ★ (Pilihan PA)  │ kepemilikan tabel dipisah tegas    │
│                                   │ per modul + larangan FK lintas     │
│                                   │ batas domain bisnis                │
└───────────────────────────────────┴────────────────────────────────────┘
```

Sistem Wisma Amal menerapkan **Level 3 — Logical Schema Ownership**: seluruh tabel berada dalam satu database fisik MySQL, namun setiap modul memiliki folder migrasi sendiri (`Modules/<Nama>/database/migrations/`), hanya berhak memodifikasi tabel miliknya, dan **dilarang memasang Foreign Key constraint fisik lintas batas domain bisnis**. Referensi antar modul diwujudkan sebagai *soft-reference* (kolom ID logis tanpa constraint) yang dihubungkan melalui Event Bus dan Module Gateway. Pendekatan ini mempertahankan efisiensi biaya infrastruktur dan transaksi ACID lokal, sekaligus menjaga independensi modul (*toggleability*) dan membuka jalur evolusi menuju microservices tanpa refactoring skema (*evolutionary architecture*) [7][9][11].

---

### 2.2.9 Integrasi Payment Gateway Modern (Midtrans Production-Ready Patterns)

Integrasi Midtrans SNAP API memfasilitasi penerimaan pembayaran digital otomatis (Virtual Account, QRIS, E-Wallet) dengan arsitektur yang aman dan berstandar industri perbankan [16][18][22].

```
┌─────────────────────────────────────────────────────────────────────────┐
│               ALUR PEMBAYARAN MIDTRANS PRODUCTION-READY                 │
│                                                                         │
│   Penghuni / Klien                   Backend SIM           Midtrans     │
│          │                                │                    │        │
│          │ 1. Request SNAP Token          │                    │        │
│          │ ─────────────────────────────> │ 2. Create Charge   │        │
│          │                                │    + Idempotency   │        │
│          │                                │ ─────────────────> │        │
│          │                                │ <───────────────── │        │
│          │ <───────────────────────────── │    Return Token    │        │
│          │    Return SNAP URL & Token     │                    │        │
│          │                                │                    │        │
│          │ 3. Bayar via VA / QRIS         │                    │        │
│          │ ──────────────────────────────────────────────────> │        │
│          │                                │                    │        │
│          │                                │ 4. Webhook Notif   │        │
│          │                                │ <───────────────── │        │
│          │                                │    (SHA-512 Sign)  │        │
│          │                                │ 5. Verifikasi Sign │        │
│          │                                │ 6. Update Status   │        │
│          │                                │ 7. Emit Event      │        │
│          │                                │ 8. HTTP 200 OK     │        │
│          │                                │ ─────────────────> │        │
└─────────────────────────────────────────────────────────────────────────┘
```

#### 1. Pola Idempotensi (Idempotency Pattern)
Untuk mengantisipasi kegagalan jaringan saat pengiriman permintaan pembuatan charge, backend mengirimkan header `Idempotency-Key` (UUIDv4 unik per transaksi sewa). Server Midtrans mengenali kunci ini untuk menjamin bahwa permintaan yang terulang tidak akan menghasilkan transaksi penagihan ganda [16][22].

#### 2. Verifikasi Tanda Tangan Kriptografis Webhook (Signature Verification)
Setiap notifikasi webhook callback dari Midtrans divalidasi keasliannya menggunakan algoritma hash SHA-512 sebelum memproses pembaruan data:
$$\text{Signature} = \text{SHA-512}(\text{order\_id} + \text{status\_code} + \text{gross\_amount} + \text{ServerKey})$$
Jika tanda tangan tidak cocok, sistem menolak payload dengan respons HTTP 403 Forbidden, melindungi sistem dari pemalsuan notifikasi (*fake webhook callback*).

#### 3. State Machine Pembayaran & Webhook Retry Handling
Status transaksi dikelola menggunakan *Finite State Machine* (FSM): `pending` $\rightarrow$ `settlement` (pembayaran sukses, memancarkan event `PembayaranDiterima` untuk mengaktifkan status kamar sewa) atau `expire`/`cancel` (pembayaran kedaluwarsa/batal, memancarkan event `JadwalBatal` untuk membebaskan jadwal kamar). Endpoint webhook bersifat idempoten dan selalu merespons HTTP 200 dalam waktu $<5$ detik guna mencegah siklus *retry policy* berulang dari server Midtrans.

---

### 2.2.10 Strategi Pengujian Perangkat Lunak (Software Quality Assurance & Testing Pyramid)

Penjaminan mutu perangkat lunak dilakukan dengan menerapkan piramida pengujian (*Testing Pyramid*) bertingkat untuk memverifikasi kebenaran logika, keamanan data, dan performa arsitektur [12][18]:

```
                     ┌───────────────┐
                     │   E2E Tests   │  (Simulasi Alur Penuh Pengguna)
                     │  (Web & Mob)  │
                     └───────┬───────┘
                     ┌───────┴───────┐
                     │  Integration  │  (Event Bus, DB, API Contracts,
                     │  & Isolation  │   Tenant Row Scoping Tests)
                     └───────┬───────┘
             ┌───────────────┴───────────────┐
             │         Unit Testing          │  (Service, UseCase, Entities,
             │  (Pest PHP & Flutter Test)    │   State Machine, Transformers)
             └───────────────────────────────┘
```

1. **Unit Testing:** Menguji logika bisnis terkecil secara terisolasi menggunakan Pest PHP (Backend) dan `flutter_test` + `mocktail` (Frontend). Menguji fungsionalitas UseCase, transisi state BLoC, kalkulasi durasi dan tarif sewa, serta DTO serializer.
2. **API Contract Testing:** Menguji kesesuaian response JSON envelope terhadap spesifikasi skema pada status kode sukses (200/201) dan kesalahan validasi (422).
3. **Tenant Isolation Testing:** Pengujian penetrasi keamanan basis data untuk membuktikan bahwa kueri dari token Pengelola Gedung A tidak dapat membaca atau memodifikasi data Gedung B.
4. **Integration & Event-Driven Testing:** Menguji alur bisnis end-to-end (Pemesanan Jadwal $\rightarrow$ Pemancaran Event $\rightarrow$ Penerbitan Tagihan $\rightarrow$ Callback Midtrans $\rightarrow$ Notifikasi WhatsApp).
5. **Cakupan Pengujian (Code Coverage):** Pengujian dijalankan otomatis pada pipeline CI/CD dengan target *code coverage* minimal 80%.

---

### 2.2.11 Living Documentation dan Evolusi Arsitektur Sistem

Dokumentasi sistem dikelola menggunakan paradigma *Living Documentation* yang terintegrasi langsung dengan repositori kode sumber [6][8]:
- **Architecture Decision Records (ADR):** Seluruh keputusan arsitektur penting (seperti penentuan Modular Monolith, model multi-tenancy, integrasi Keycloak SSO, dan integrasi MCP) dicatat kronologis pada file `DECISIONS.md` dengan struktur: *Context*, *Decision*, *Alternatives*, dan *Consequences*.
- **Katalog Pengetahuan Hidup (`KNOWLEDGE_BASE.md`):** Mendokumentasikan struktur modul, katalog event global, dan aturan dependensi sebagai panduan tunggal pengembang.
- **Automasi Validasi Arsitektur:** Menjalankan kakas statis `deptrac analyse` pada backend untuk mencegah pelanggaran dependensi antar-tier modul dan `flutter analyze` pada frontend sebelum kode digabungkan ke cabang utama.

---

## 2.3 Penelitian Terkait

Berikut telaah mendalam terhadap penelitian-penelitian terdahulu yang relevan dalam domain sistem manajemen kost, arsitektur modular monolith, clean architecture, SSO IAM, dan otomasi pembayaran:

```
┌────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                TABEL 2.3 KOMPARASI PENELITIAN TERKAIT & POSITIONING SISTEM                             │
├────┬─────────────────────────────┬───────────┬──────────────────────────┬─────────────────────────────┬────────────────┤
│ No │ Peneliti & Tahun            │ Metode    │ Teknologi / Arsitektur   │ Fitur & Kelemahan           │ Positioning PA │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 1  │ I Gede et al. (2025) [1]    │ Waterfall │ Laravel, MySQL           │ Fitur kamar & sewa; monolith│ Modulith +     │
│    │ (SIM Kost Pondok 91)        │           │ tradisional              │ konvensional, no multi-bldg │ Multi-Tenant   │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 2  │ I Putu et al. (2025) [2]    │ Waterfall │ Laravel, Node.js Bot     │ Bot WA terpisah; tight      │ Event-Driven + │
│    │ (Optimasi Kost + WA Bot)    │           │                          │ coupling, no clean arch     │ Open-WA Modul  │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 3  │ Albert et al. (2024) [3]    │ Spiral    │ CodeIgniter, MySQL       │ Sistem web sederhana; stack │ Laravel 11 +   │
│    │ (Kost Putri Hana)           │           │                          │ usang, tidak modular        │ 3-Tier Modulith│
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 4  │ Hidayat et al. (2023) [4]   │ Prototype │ Native PHP, MySQL        │ Dashboard kamar; no testing,│ Clean-Modulith │
│    │ (SIM Kamar Ikebana)         │           │                          │ raw SQL, rentan bentrok     │ + Unit Testing │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 5  │ JATI Vol. 9 No. 3 (2025)[14]│ Prototype │ Flutter, Laravel         │ Mobile app kost; no web,    │ Clean Flutter  │
│    │ (Kos SidoRame12)            │           │                          │ no multi-tenancy, semi-clean│ Single Codebase│
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 6  │ Ayyubi (2024) [15]          │ Waterfall │ Flutter, Midtrans SNAP   │ Pembayaran digital; sandbox │ Midtrans Prod  │
│    │ (SIM Bayar Kost WS Barokah) │           │                          │ only, no idempotency key    │ + Idempotency  │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 7  │ JSCR (2025) [16]            │ MVVM      │ Flutter, Supabase        │ Akuntansi kost; no SQL ACID │ Modulith MySQL │
│    │ (Kelola Kosku)              │           │                          │ relational, no AI analytics │ + MCP AI Tools │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 8  │ JITET (2026) [17]           │ Scrum     │ Laravel, Midtrans        │ Notifikasi sewa; single bldg│ Multi-Tenant + │
│    │ (Transformasi Digital Kost) │           │                          │ no MCP tool integration     │ MCP Assistant  │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 9  │ INTECOMS (2026) [18]        │ Waterfall │ Laravel 12, Fonnte WA    │ Web Blade kost; no mobile,  │ Clean FE +     │
│    │ (SIM Kost Web)              │           │                          │ no decoupled event bus      │ Event Bus      │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 10 │ Rasyidatur (2025) [10]      │ Scrum     │ Modulith Semu            │ Penghuni & Tamu; direct call│ Event-Driven + │
│    │ (Previous Work 1)           │           │                          │ repo, no test, single bldg  │ Multi-Tenant   │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 11 │ Roihanah (2025) [11]        │ Scrum     │ Modulith Semu            │ Kamar & Reservasi; no inter-│ Schedule Core+ │
│    │ (Previous Work 2)           │           │                          │ face contract, tight couple │ PessimisticLock│
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 12 │ Rizal (2025) [12]           │ Scrum     │ Modulith Semu            │ Keuangan; query langsung ke │ Finance Modul  │
│    │ (Previous Work 3)           │           │                          │ tabel Room, sandbox Midtrans│ + Gateway Read │
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 13 │ Bagus (2025) [13]           │ Scrum     │ Modulith Semu            │ Maintenance; no web UI,     │ Full Clean FE  │
│    │ (Previous Work 4)           │           │                          │ semi-clean flutter, no test │ + Web Dashboard│
├────┼─────────────────────────────┼───────────┼──────────────────────────┼─────────────────────────────┼────────────────┤
│ 14 │ SISTEM PROYEK AKHIR INI     │ Scrum     │ Laravel 11 Modulith,     │ Modulith Event-Bus, Clean FE│ Solusi Terpadu │
│    │ (Wisma Amal Gorontalo)      │           │ Flutter Clean Arch, MCP  │ Multi-Tenant, API Standard, │ Enterprise     │
│    │                             │           │ AI, Keycloak OIDC, Midtr │ Keycloak SSO, MCP AI Assist │ Production     │
└────┴─────────────────────────────┴───────────┴──────────────────────────┴─────────────────────────────┴────────────────┘
```

---

## 2.4 Sintesis dan Gap Statement

Berdasarkan tinjauan kritis terhadap 13 penelitian terkait dan evaluasi mendalam atas 4 proposal *previous work*, ditemukan **kesenjangan ilmiah dan teknis (research gap)** yang belum diselesaikan oleh penelitian-penelitian terdahulu:

1. **Ketiadaan Integrasi Modular Monolith Sejati Berbasis Event:**
   Mayoritas penelitian terdahulu masih terjebak pada arsitektur monolitik konvensional atau monolitik modular semu yang mengandalkan pemanggilan service langsung dan kopling basis data fisik antar modul, sehingga modul tidak dapat di-toggle secara independen [1][10][11][12].
2. **Ketiadaan Dukungan Multi-Gedung (*Multi-Tenancy*) dengan Isolasi Data Tingkat Baris:**
   Seluruh sistem manajemen kost yang diteliti hanya dirancang untuk satu gedung tunggal tanpa mekanisme partisi data multi-properti dan *Tenant-Aware RBAC* [1][14][17][18].
3. **Inkonsistensi Kontrak Data API dan Arsitektur Frontend:**
   Penerapan Clean Architecture pada frontend sering kali tidak tuntas (*semi-clean*), tidak memisahkan UseCase dari implementasi konkret, serta tidak didukung kontrak JSON envelope API yang baku [10][14].
4. **Ketiadaan Antarmuka Asisten Cerdas Berbasis Protokol Terstandarisasi (MCP):**
   Belum ada penelitian sistem informasi manajemen kost yang mengintegrasikan LLM dengan basis data operasional melalui *Model Context Protocol* untuk menyediakan layanan analitik bisnis berbasis bahasa alami dengan jaminan *deterministic grounding* dan keamanan tenant [1][10][16][17].
5. **Ketiadaan Otentikasi Terfederasi Single Sign-On (SSO):**
   Sistem-sistem terdahulu masih mengandalkan penyimpanan kredensial password lokal tanpa integrasi *Identity Provider* (IdP) terstandarisasi OpenID Connect yang aman dan mendukung *Identity Brokering* [10][11].
6. **Kelemahan Strategi Pengujian dan Dokumentasi Hidup:**
   Penelitian terdahulu umumnya mengabaikan pengujian terotomasi (*Unit*, *Contract*, dan *Integration Testing*) serta membiarkan dokumentasi teknis terpisah dari basis kode [4][10][11][12][13].

Proyek Akhir ini mengisi seluruh kesenjangan tersebut melalui perancangan dan implementasi **Sistem Informasi Manajemen Wisma Amal Gorontalo Berbasis Arsitektur Terpadu**: Modular Monolith 3-Tier Event-Driven, Clean Architecture Frontend Flutter (Single Codebase), Multi-Tenant Row-Level Scoping Multi-Gedung, Standarisasi Kontrak Input-Output API, Single Sign-On (SSO) berbasis Keycloak OIDC, serta Asisten AI Terintegrasi berbasis Model Context Protocol (MCP).
