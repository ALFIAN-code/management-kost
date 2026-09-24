# BAB 2 — Kajian Pustaka (Draft Baru — Teori + Kritik Previous Work + Penelitian Terkait)

> Status: **DRAFT BARU 15%** — TABEL_JURNAL.md terisi 19 jurnal, siap dipakai untuk 2.2 & 2.3.

## Struktur BAB 2 (Sesuai PANDUAN_PENULISAN)

### 2.1 Deskripsi Permasalahan
Sintesis dari analisis previous work (4 proposal) + teori + jurnal terbaru:
1. **Previous work fragmentasi**: 4 proposal terpisah tanpa sistem terintegrasi utuh
2. **Arsitektur tidak konsisten**: klaim Modular Monolith/DDD tapi FE semi-clean (no interface), BE direct service call
3. **Test & dokumentasi lemah**: hanya black-box scenario, no unit test, docs tidak sinkron
4. **Frontend web hilang**: proposal menyebut React tapi implementasi hanya Flutter mobile
5. **Payment integration belum production**: Midtrans sandbox only, no idempotency/retry/audit

### 2.2 Teori Penunjang (Dari Jurnal 2022-2026 + Buku Dasar)
> **WAJIB sitasi dari TABEL_JURNAL.md (No 5-13)** — jangan copy teori dari previous proposal tanpa verifikasi jurnal terbaru.

| Sub-bab | Topik | Sumber (TABEL_JURNAL No) |
|---|---|---|
| 2.2.1 | Sistem Informasi Manajemen (SIM) — definisi, peran, keuntungan | [2] buku + [14,16] jurnal |
| 2.2.2 | Arsitektur Modular Monolith / Modulith + DDD bounded context | [5,6,7,8,9,10] |
| 2.2.3 | Clean Architecture (Uncle Bob) — dependency rule, UseCase, Repository Interface | [11,12,13] |
| 2.2.4 | Laravel Modular (nwidart/laravel-modules) — Repository-Service pattern, feature toggle | [7,8] + docs resmi |
| 2.2.5 | Flutter Clean Architecture — BLoC → UseCase → RepositoryInterface, GetIt DI | [11,12,13] |
| 2.2.6 | MySQL/Relational DB untuk DDD — ACID, MVCC, migration per modul | [8] + buku |
| 2.2.7 | Payment Gateway Integration Patterns — Midtrans, idempotency, webhook handling | [19] official docs |
| 2.2.8 | Software Testing Strategy — Unit, Integration, E2E untuk modular monolith | [12] + jurnal testing |
| 2.2.9 | Living Documentation — ADR, KNOWLEDGE_BASE, sync with code | [6,8] + praktik industri |

### 2.3 Penelitian Terkait + Tabel Perbandingan (WAJIB untuk BAB 2.3)

> **Tabel wajib kolom: Judul/Tahun/Penulis/Tujuan/Metode/Hasil + Perbandingan & Positioning + Baris PA Kita**

| No | Judul | Tahun | Penulis | Tujuan | Metode | Hasil | **Perbandingan & Positioning PA Kita** |
|---|---|---|---|---|---|---|---|
| 1 | Sistem Informasi Manajemen Rumah Kos Laravel (Pondok 91) | 2025 | I Gede et al. | Fitur kamar/penyewa/fasilitas/pembayaran | Waterfall, Laravel+MySQL | Fitur lengkap tapi monolith | **Kita: Scrum + Modular Monolith** — Waterfall tidak cocok untuk dev paralel 4 domain; kita pakai sprint iteratif |
| 2 | Optimasi Manajemen Kost + Bot WhatsApp | 2025 | I Putu et al. | Efisiensi + notif WA | Waterfall, Laravel+Node | Efisiensi + notif WA berjalan | **Kita: Scrum + Open-WA (Node) terintegrasi di modul Notification** — tidak terpisah bot |
| 3 | Perancangan Rumah Kost Putri Hana (CodeIgniter) | 2024 | Albert et al. | Website pengelolaan | Spiral, CI+MySQL | Website pengelolaan | **Kita: Laravel 11 Modular** — CI deprecated, Laravel modern + modular boundaries |
| 4 | Pengembangan Sistem Manajemen Kamar Kost (Ikebana Palembang) | 2023 | Hidayat et al. | Dashboard kamar/penghuni | Prototyping, PHP+MySQL | Dashboard kamar/penghuni | **Kita: Modular Monolith (Room/Resident/Finance/Maintenance)** — bukan monolith polos |
| 5 | **Pengembangan Sistem Manajemen Kos Mobile (Kos SidoRame12)** | **2025** | **JATI Vol.9** | **Mobile app kos, manual→digital** | **Prototype, Flutter+Laravel** | **Mobile app, payment reminder** | **Kita: Scrum (bukan prototype) + FE full Clean Arch + BE Modular Monolith + Web Dashboard** — prototype cepat tapi tidak scalable; kita production-ready |
| 6 | **Rancang Bangun Sistem Informasi Pembayaran Kost + Midtrans SNAP** | **2024** | **Ayyubi (UDBS)** | **Payment gateway integration** | **Waterfall, Flutter+Laravel+Midtrans** | **Payment integration, efficiency** | **Kita: Scrum + Midtrans production (idempotency, retry, audit trail, refund automation)** — Waterfall tidak iteratif; Midtrans kita hardened |
| 7 | **Kelola Kosku: SIA Mobile + Anniversary Billing + Auto-Penalty + Security Deposit + Depresiasi PMK 72** | **2025** | **JSCR** | **SIA lengkap kos** | **MVVM, Flutter+Supabase+Firebase** | **Anniversary billing, auto-penalty, PMK 72** | **Kita: Clean Arch (bukan MVVM) + Laravel MySQL (bukan Supabase) + PMK compliance via Finance module** — MVVM vs Clean Arch trade-off; kita pakai Laravel untuk relational integrity |
| 8 | **Transformasi Digital Pengelolaan Kos: Laravel + Midtrans + Scrum + WhatsApp** | **2026** | **JITET** | **Digital transformation kos** | **Scrum, Laravel, Midtrans, Twilio** | **Auto billing notif, ticket complaint, room binding** | **Kita: Scrum + Open-WA (bukan Twilio, cost-effective) + Feature Toggle per properti** — Twilio mahal; Open-WA self-hosted |
| 9 | **Sistem Manajemen Kos Web Laravel 12 + WhatsApp Gateway Fonnte** | **2026** | **INTECOMS** | **Web-based kos management** | **Waterfall, Laravel 12, MySQL, Fonnte** | **Real-time room, auto billing, room binding** | **Kita: Scrum + Laravel 11 Modular + React Web Dashboard (bukan Blade only)** — Waterfall vs Scrum; kita multi-frontend (Web + Mobile) |
| 10 | **Previous Work: Penghuni & Tamu (Rasyidatur 3123500039)** | **2025** | **Proposal** | **Manajemen penghuni & tamu** | **Scrum, Modular Monolith** | **Guest logging, resident profile** | **Kita: Perbaikan — FE full Clean Arch, Interface-based BE, test coverage, docs sync** |
| 11 | **Previous Work: Kamar & Reservasi (Roihanah 3123500005)** | **2025** | **Proposal** | **Kamar & reservasi real-time** | **Scrum, Modular Monolith** | **Room schedule, anti-bentrok, queue waktu** | **Kita: Perbaikan — konsisten Clean Arch, integration test, web dashboard** |
| 12 | **Previous Work: Keuangan (Rizal 3123500060)** | **2025** | **Proposal** | **Manajemen keuangan + Midtrans** | **Scrum, Modular Monolith** | **Tagihan otomatis, Midtrans, laporan** | **Kita: Perbaikan — Midtrans production (idempotency, retry, audit), refund automation** |
| 13 | **Previous Work: Operasional & Maintenance (Bagus 3123500031)** | **2025** | **Proposal** | **Maintenance + inventory** | **Scrum, Modular Monolith** | **Laporan kerusakan multi-foto, inventory** | **Kita: Perbaikan — interface-based modular comm, living docs, web dashboard** |
| **14** | **PA Kita (2025) — Sistem Terintegrasi Wisma Amal** | **2025** | **Kita** | **Sistem utuh + koreksi arsitektur + test + docs** | **Scrum 4 sprint, Modular Monolith, Clean Arch, Unit+Integration Test ≥80%** | **Target: sistem utuh production-ready** | **Baseline perbaikan sistematis previous work** |

### 2.4 Gap Statement (Penutup BAB 2)

> Dari **12 penelitian terkait kost (1-13)** + **4 previous work (10-13)** + **5 jurnal teori modulith/clean arch (TABEL_JURNAL 5-13)**: **tidak ada yang mengintegrasikan** (a) Modular Monolith konsisten Clean Architecture (FE full Clean via UseCase+RepoInterface + BE Interface-based), (b) Test coverage ≥80% (unit + integration), (c) Living documentation sync dengan kode, (d) Frontend web (React) + mobile (Flutter) terintegrasi, (e) Midtrans production-ready (idempotency, retry, audit trail, refund automation) — **dalam satu sistem utuh**. PA ini mengisi gap tersebut dengan **perbaikan sistematis previous work**.

---

## Rencana Isi (Next)
1. Isi 2.1-2.2 dengan sitasi dari TABEL_JURNAL (minimal 1 sitasi per paragraf)
2. Tabel 2.3 di atas sudah lengkap 14 baris (12 terkait + 2 baseline) — tulis narasi per baris
3. Gap statement eksplisit merujuk ke kesalahan previous work (BAB 1)