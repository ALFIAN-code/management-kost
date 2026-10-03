# Tabel Jurnal — Matriks Literature Review

> Screening 20-30 → pilih 10-15 untuk BAB2. Sumber: Semantic Scholar API + SINTA/Garuda + Google Scholar + Crossref verify.

**Terakhir diupdate:** 2025-09-20 02:00
**Filter default:** 2022-2026, Computer Science / Information Systems, openAccessPdf優先, minCitationCount opsional

## Cara Search (SOP dari Imbad0202 lite)

```bash
# Bulk search Semantic Scholar
curl "https://api.semanticscholar.org/graph/v1/paper/search/bulk?query=kost+management+information+system&year=2022-2026&fields=title,url,publicationTypes,publicationDate,openAccessPdf,authors,year,citationCount,abstract&sort=citationCount:desc&limit=100"
# Cek sitasi exist
curl "https://api.crossref.org/works/{doi}"
```

## Matriks (19 jurnal terpilih — 5 teori + 14 penelitian terkait untuk tabel perbandingan)

| No | Judul | Penulis/Tahun | Metode | Hasil | DOI/URL | Relevansi ke BAB | **Perbandingan & Positioning PA Kita** |
|---|---|---|---|---|---|---|---|
| 1 | Sistem Informasi Manajemen Rumah Kos Menggunakan Framework Laravel (Pondok 91) | I Gede et al., 2025 | Waterfall, Laravel+MySQL | Fitur kamar/penyewa/fasilitas/pembayaran | (dari proposal) | BAB2 terkait | **Kita: Scrum + Modular Monolith** — Waterfall tidak cocok untuk dev paralel 4 domain; kita pakai sprint iteratif |
| 2 | Optimasi Manajemen Kost + Bot WhatsApp | I Putu et al., 2025 | Waterfall, Laravel+Node | Efisiensi + notif WA | (dari proposal) | BAB2 terkait | **Kita: Scrum + Open-WA (Node) terintegrasi di modul Notification** — tidak terpisah bot |
| 3 | Perancangan Rumah Kost Putri Hana (CodeIgniter) | Albert et al., 2024 | Spiral, CI+MySQL | Website pengelolaan | (dari proposal) | BAB2 terkait | **Kita: Laravel 11 Modular** — CI deprecated, Laravel modern + modular boundaries |
| 4 | Pengembangan Sistem Manajemen Kamar Kost (Ikebana Palembang) | Hidayat et al., 2023 | Prototyping, PHP+MySQL | Dashboard kamar/penghuni | (dari proposal) | BAB2 terkait | **Kita: Modular Monolith (Room/Resident/Finance/Maintenance)** — bukan monolith polos |
| 5 | Modular Monolith as a Microservices Precursor | Shablii & Tytenko, 2023 | Conceptual + case study | Modulith sebagai precursor ke microservices, hexagonal architecture | 10.30890/2567-5273.2023-29-01-038 | BAB2 teori | **Dasar teori arsitektur kita** — hexagonal boundaries = modul Laravel |
| 6 | Towards a Progressive Scalability for Modular Monolith Applications | Carvalho et al., 2025 | Guidelines proposal (SciTePress WEBIST) | Guidelines untuk scalable modular monolith, modular boundaries, deployment | 10.5220/0013786800003985 | BAB2 teori | **Guideline modular boundaries & scalability** — diterapkan di feature toggle per properti |
| 7 | Architectural Trade-Offs in Modulith Architecture: A Case Study | Prakash, 2025 | Case study (rewards system) | Modulith untuk high-dependency system, reduced complexity vs microservices | 10.5120/ijca2025924504 | BAB2 teori | **Bukti empirik modulith > microservices untuk high dependency** — cocok kos (room↔finance↔resident) |
| 8 | Modular Monolith Architecture in Cloud Environments: A Systematic Literature Review | Al-Qora'n & Ahmad, 2025 | SLR (Kitchenham, 6 libraries, 2020-2025) | 15 primary studies, DDD/modular boundaries/containerised, performance advantage | 10.3390/fi17110496 | BAB2 teori | **SLR evidence: MMA performance advantage** — validasi arsitektur kita |
| 9 | Automated Microservice Identification in Modular Monolith Architectures | Dejonckheere, 2024 | Master thesis (Univ. Turku) | 4-step automated modularization, cohesion/coupling metrics | http://urn.fi/URN:ISBN:978-951-29-9528-8 | BAB2 teori | **Metrik cohesion/coupling** — acuan evaluasi modular boundaries kita |
| 10 | Modular Monolith: Is This the Trend in Software Architecture? | Su & Li, 2024 | Grey literature review (64 studies) | 3 frameworks (Service Weaver, Spring Modulith, Light-hybrid-4j), 4 cases (Shopify, Appsmith, Gusto, PlayTech) | arXiv:2401.11867 | BAB2 teori | **Industry adoption: Shopify/Appsmith pakai MMA** — validasi trend industri |
| 11 | Flutter Clean Architecture: Complete Guide with Example | Saed, 2025 | Tutorial + production guide | Domain/Data/Presentation layers, UseCase, Repository Interface, GetIt DI, dartz Either | https://bnsaed.com/flutter/guides/clean-architecture/ | BAB2 teori | **Pattern Clean Arch FE kita** — UseCase + RepoInterface + GetIt DI |
| 12 | Flutter BLoC + Clean Architecture: A Practical Guide with Patterns and Code | ASOasis, 2026 | End-to-end feature (Weather Search) | Feature-first folder, UseCase → Repository → BLoC, testing strategy | https://asoasis.tech/articles/2026-03-11-2053-flutter-bloc-pattern-clean-architecture/ | BAB2 teori | **Testing strategy & DI wiring** — acuan unit test FE ≥80% |
| 13 | Flutter Clean Architecture: The Complete Guide to Scalable App Design (2026) | Shakil, 2026 | Full product-catalog feature | Folder-by-feature, dependency injection (get_it+injectable), migration Firebase→Supabase | https://flutterstudio.dev/blog/flutter-clean-architecture.html | BAB2 teori | **Folder-by-feature + injectable** — struktur FE kita (features/ bukan lib/modules/) |
| 14 | **Pengembangan Sistem Manajemen Kos Berbasis Mobile (Kos SidoRame12)** | JATI Vol.9 No.3, 2025 | Prototype, Flutter+Laravel, Black-box+UAT | Mobile app kos, manual→digital, payment reminder | https://ejournal.itn.ac.id/index.php/jati/article/download/13708/7704/ | BAB2 penelitian terkait | **Kita: Scrum (bukan prototype) + FE full Clean Arch + BE Modular Monolith + Web Dashboard** — prototype cepat tapi tidak scalable; kita production-ready |
| 15 | **Rancang Bangun Sistem Informasi Pembayaran Kost + Midtrans SNAP** | Ayyubi, 2024 | Waterfall, Flutter+Laravel+Midtrans SNAP | Payment gateway integration, efficiency improvement | https://eprints.udb.ac.id/id/eprint/2731/ | BAB2 penelitian terkait | **Kita: Scrum + Midtrans production (idempotency, retry, audit trail, refund automation)** — Waterfall tidak iteratif; Midtrans kita hardened |
| 16 | **Kelola Kosku: SIA Mobile + Anniversary Billing + Auto-Penalty + Security Deposit + Depresiasi PMK 72/2023** | JSCR, 2025 | MVVM, Flutter+Supabase+Firebase, Black-box+UAT | SIA lengkap: anniversary billing, auto-penalty, security deposit, asset depreciation PMK 72 | https://ojs.widyakartika.ac.id/index.php/jscr/article/download/948/809/ | BAB2 penelitian terkait | **Kita: Clean Arch (bukan MVVM) + Laravel MySQL (bukan Supabase) + PMK compliance via Finance module** — MVVM vs Clean Arch trade-off; kita pakai Laravel untuk relational integrity |
| 17 | **Transformasi Digital Pengelolaan Kos: Laravel + Midtrans + Scrum + WhatsApp** | JITET, 2026 | Scrum, Laravel, Midtrans, Twilio WhatsApp | Digital transformation, auto billing notif, ticket-based complaint, room binding | https://journal.eng.unila.ac.id/index.php/jitet/article/view/8261/ | BAB2 penelitian terkait | **Kita: Scrum + Open-WA (bukan Twilio, cost-effective) + Feature Toggle per properti** — Twilio mahal; Open-WA self-hosted |
| 18 | **Sistem Manajemen Kos Web Laravel 12 + WhatsApp Gateway Fonnte** | INTECOMS, 2026 | Waterfall, Laravel 12, MySQL, WhatsApp Gateway | Real-time room availability, auto billing notif, ticket-based complaint, room binding | https://journal.ipm2kpe.or.id/index.php/INTECOM/article/view/20278/ | BAB2 penelitian terkait | **Kita: Scrum + Laravel 11 Modular + Flutter Web (bukan Blade only)** — Waterfall vs Scrum; kita single codebase Flutter Web + Mobile |
| 19 | **Midtrans Official Documentation: HTTP(S) Notification/Webhooks, Idempotency-Key, Payment Notification API, Core API SNAP, E-Wallet, QRIS** | Midtrans, 2022-2025 | Official technical docs | Webhook handling, idempotency, signature verification, retry policy, SNAP BI-SNAP | https://docs.midtrans.com/ | BAB3 implementasi | **Referensi implementasi production-ready** — idempotency key, signature verification, retry policy, refund automation |

## Gap Statement (untuk BAB2 penutup)

> Dari **12 penelitian terkait kost (5-18)** + **4 previous work** + **5 jurnal teori modulith/clean arch (5-13)**: **tidak ada yang mengintegrasikan** (a) **Modular Monolith konsisten (Backend: Service Interface + Dependency Inversion) + Clean Architecture (Frontend: BLoC→UseCase→RepoInterface)**, (b) Test coverage ≥80% (unit + integration), (c) Living documentation sync dengan kode, (d) Frontend web (Flutter Web) + mobile (Flutter) terintegrasi single codebase, (e) Midtrans production-ready (idempotency, retry, audit trail, refund automation) — **dalam satu sistem utuh**. PA ini mengisi gap tersebut dengan **refactoring sistematis previous work ke Modular Monolith konsisten**.

## Log Search

| Tanggal | Keyword | Sumber | Hasil | Dipilih |
|---|---|---|---|---|
| 2025-09-19 | (init — dari proposal) | PA/old-files | 12 | 4 |
| 2025-09-20 | modular monolith architecture 2023-2025 | Semantic Scholar + Web | 10 | 5 (5-9) |
| 2025-09-20 | flutter clean architecture bloc 2025-2026 | Web + Dev blogs | 8 | 4 (11-14) |
| 2025-09-20 | kost management system indonesia 2022-2025 | SINTA/Garuda + Scholar | 12 | 6 (14-18) |
| 2025-09-20 | midtrans payment integration production | Midtrans docs + Web | 5 | 1 (19) |