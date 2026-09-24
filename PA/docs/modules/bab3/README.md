# BAB 3 — Desain Sistem (Outline Baru — Desain Sistem Perbaikan)

> Status: **OUTLINE 0%** — desain sistem BARU dengan koreksi previous work. Trace ke `Project/` untuk validasi feasibility, BUKAN copy previous.

## Struktur BAB 3 (Sesuai PANDUAN_PENULISAN)

### 3.1 Deskripsi Solusi (Baru — Perbaikan Sistematik)
Sistem terintegrasi Wisma Amal dengan **5 perbaikan utama dari previous work**:
1. **Arsitektur Konsisten**: FE Full Clean (BLoC→UseCase→RepoInterface) + BE Interface-based Modular Communication
2. **Integrasi Modul Via Interface**: Service Interface + Dependency Inversion (no direct DB/service call antar modul)
3. **Test Strategy**: Unit Test (Repository, UseCase, Service) + Integration Test (API, Modul Communication) ≥80% coverage
4. **Frontend Web Dashboard**: React/Next.js untuk Pemilik/Pengelola (terpisah dari Flutter mobile Penghuni)
5. **Production-Ready Payment**: Midtrans idempotency, retry, webhook verification, audit trail, refund automation

### 3.2 Metodologi Scrum (Perbaikan: 4 Sprint dengan Definition of Done ketat)
- **Peran**: PO (Wisma Owner), SM, Dev Team (Backend + Frontend Web + Frontend Mobile)
- **Artefak**: Product Backlog (integrasi utuh), Sprint Backlog, Increment (demo-able per sprint)
- **Sprint 1 (Minggu 1-2)**: Foundation — Core Module (Auth, RBAC, Feature Toggle), CI/CD, Test Infrastructure, Documentation Sync
- **Sprint 2 (Minggu 3-4)**: Domain Modules — Room/Reservation + Resident (interface-based, unit test)
- **Sprint 3 (Minggu 5-6)**: Finance + Operational — Midtrans production, Maintenance/Inventory, Notification
- **Sprint 4 (Minggu 7-8)**: Frontend Web (React) + Integration Test + E2E + Documentation Final + UAT

> **Perbaikan dari previous**: previous work sprint hanya 4 minggu tanpa test infra, web frontend, integration test.

### 3.3 Desain Sistem (Trace ke Project/ untuk Feasibility)

#### 3.3.1 Arsitektur Sistem (Diagram 3 lapis + Sequence)
```
Frontend Web (React)          Frontend Mobile (Flutter)
        │                            │
        └──────────────┬─────────────┘
                       ▼
            API Gateway / Laravel Modular Monolith
            ┌─────────────────────────────────────┐
            │ Core: Auth, RBAC, Toggle, Notif    │
            ├─────────────────────────────────────┤
            │ Room ←interface→ Resident          │
            │ Finance ←interface→ Rental         │
            │ Maintenance ←interface→ Inventory  │
            └─────────────────────────────────────┘
                       │
                       ▼
              MySQL (per modul schema) + Midtrans
```

#### 3.3.2 BPMN (Swimlane: Pemilik, Pengelola, Penghuni, System) — **Baru, konsisten**
#### 3.3.3 Use Case Diagram (3 aktor + system) + Mindmap fitur terintegrasi
#### 3.3.4 DFD Level 0 (Context) + Level 1 (4 domain + core) — **Data store per modul**
#### 3.3.5 Activity Diagram (min 3: Reservasi+Payment, Maintenance Flow, Dashboard Analytics)
#### 3.3.6 ERD Global → `02_reference/ERD_GLOBAL.md` (versi perbaikan: FK konsisten, audit columns, pivot tables)
#### 3.3.7 Mockup per Peran:
- **Pemilik (Web)**: Dashboard KPI, Approve Pengajuan, Master Data, Audit Log
- **Pengelola (Web)**: Kelola Kamar/Penghuni, Verifikasi Bayar, Jadwal Maintenance, Laporan
- **Penghuni (Flutter Mobile)**: Daftar Kamar, Reservasi, Tagihan+Bayar, Laporan Kerusakan, Riwayat

#### 3.3.8 Tabel Skenario Aplikasi (Black-box + Integration)
| No | Subyek | Obyek/Data | Skenario | Hasil Diharapkan | Modul Terkait | Test Type |
|---|---|---|---|---|---|---|
| 1 | Penghuni | Reservasi | Pilih kamar kosong → reservasi → bayar Midtrans | Status kamar: kosong→dipesan→terisi | Room, Rental, Finance | Integration |
| 2 | Pengelola | Maintenance | Terima laporan → jadwalkan → selesai | Status: pending→in_progress→completed | Maintenance, Notification | Integration |
| 3 | Pemilik | Approve | Lihat pengajuan beli → approve → inventory update | Inventory + audit log | Inventory, Core | Integration |
| ... | ... | ... | ... | ... | ... | Unit/Integration |

#### 3.3.9 Tabel Skenario Evaluasi (Kuesioner Likert 1-5 — Usability, Performance, Reliability)
#### 3.3.10 Jadwal Proyek (Gantt 8 minggu dengan milestone)

### 3.4 Trace Mapping ke Project/ (Validasi Feasibility — Read Only, No Code Change)
| Desain Baru | Project/Backend Feasibility | Project/Frontend Feasibility | Catatan |
|---|---|---|---|
| Room/Resident Interface-based | `Modules/Room/Repositories/Contracts/` exists ✓ | `lib/domain/repository/` needs interface ✓ | FE perlu refactor |
| Finance Midtrans Production | `Modules/Finance/Services/` has MidtransService ✓ | `lib/data/datasource/` needs payment datasource | Perlu hardening |
| Frontend Web React | N/A (belum ada) | N/A (belum ada) | **New development** |
| Test Infrastructure | `php artisan test` (Pest) ✓ | `flutter test` ✓ | Perlu config coverage |
| Living Docs Sync | `KNOWLEDGE_BASE.md` living ✓ | `CLEAN_ARCHITECTURE_GUIDELINE.md` ✓ | Perlu update otomatis |

---

## Catatan Penting
- **JANGAN copy desain dari 4 proposal previous** — mereka terpisah, tidak konsisten, tidak lengkap
- **Setiap klaim desain wajib trace ke Project/** untuk validasi feasibility (read-only)
- **Kode existing sebagai baseline**, bukan target — kita desain perbaikan, lalu implementasi di sprint
- **Frontend Web React = NEW DEVELOPMENT** (previous tidak ada)

---

## Next Steps (Setelah Literature Review Selesai)
1. Detail setiap diagram (BPMN, DFD, Activity, ERD) di markdown → export PNG untuk docx
2. Lengkapi tabel skenario aplikasi (target 20+ skenario: unit + integration)
3. Finalisasi mockup (bisa pakai wireframe tool, export PNG)
4. Validasi semua trace ke Project/ → update mapping table