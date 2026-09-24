# BAB 1 — Pendahuluan (Draft Baru — Analisis Previous Work + Proposal Kita)

> Status: **DRAFT BARU 0%** — bukan gabungan 4 proposal. Sumber referensi: `PA/old-files/*.pdf` (previous work 4 mahasiswa lain).

## Struktur BAB 1 (Sesuai PANDUAN_PENULISAN)

### 1.1 Latar Belakang
**BAGIAN A — Konteks Umum (dari jurnal & teori, BUKAN copy previous):**
- Bisnis kost/hunian di Indonesia: potensi, tantangan manual (sitasi jurnal 2022-2026)
- Peran Sistem Informasi Manajemen (SIM) dalam efisiensi operasional
- Arsitektur modern: Modular Monolith/DDD sebagai best practice untuk sistem skala menengah

**BAGIAN B — Analisis Previous Work (4 proposal di old-files):**
- Apa yang sudah dibangun: 4 modul terpisah (Penghuni, Kamar/Reservasi, Keuangan, Operasional) — **bukan terintegrasi**
- State implementasi: backend modular (9 modul), frontend Flutter semi-clean — **ada tapi tidak selesai/terintegrasi**
- **Kekurangan/kesalahan previous work** (kita identifikasi):
  1. 4 proposal terpisah → tidak ada sistem terintegrasi utuh
  2. Arsitektur "modulith" diklaim tapi implementasi belum konsisten (semi-clean FE, no interface repo)
  3. Integrasi antar modul lemah (hard-coded service call, tidak via interface)
  4. Testing hanya black-box skenario, tidak ada unit/integration test
  5. Dokumentasi tidak sinkron dengan kode (KNOWLEDGE_BASE living doc tapi tidak complete)
  6. Frontend web owner/admin belum ada (hanya Flutter mobile)
  7. Midtrans integration belum di-hardening (mock/sandbox only)

**BAGIAN C — Posisi PA Kita (Gap → Proposal Baru):**
- PA ini mengusulkan **sistem terintegrasi lengkap dengan koreksi arsitektur & implementasi**
- Fokus: konsistensi Clean Architecture (FE full Clean via UseCase), interface-based modular communication, test coverage, dokumentasi sinkron, web dashboard owner/admin

### 1.2 Rumusan Masalah (Baru — Berbasis Gap Previous Work)
1. Bagaimana merancang ulang arsitektur Modular Monolith yang **konsisten Clean Architecture** (FE full Clean, BE interface-based) untuk sistem terintegrasi Wisma Amal?
2. Bagaimana mengimplementasikan **integrasi antar modul via Service Interface** (bukan direct DB/service call) dengan feature toggle per properti?
3. Bagaimana membangun **test coverage** (unit + integration) dan **dokumentasi living** yang sinkron dengan kode?
4. Bagaimana melengkapi **frontend web dashboard** (pemilik/pengelola) yang terintegrasi dengan backend modular?
5. Bagaimana memastikan **Midtrans payment production-ready** dengan error handling, retry, audit trail lengkap?

### 1.3 Tujuan (Baru — Spesifik Perbaikan)
1. Menghasilkan sistem informasi Wisma Amal **terintegrasi utuh** (bukan 4 modul terpisah) dengan arsitektur Modular Monolith yang konsisten
2. Menerapkan **Clean Architecture penuh di Frontend** (BLoC → UseCase → RepositoryInterface) dan **Interface-based communication di Backend**
3. Mencapai **test coverage ≥80%** (unit + integration) + dokumentasi living (`KNOWLEDGE_BASE.md` + `CLEAN_ARCHITECTURE_GUIDELINE.md` sinkron)
4. Menyediakan **frontend web (React/Next.js) untuk pemilik/pengelola** + Flutter mobile untuk penghuni
5. **Production-ready Midtrans** dengan idempotency, retry logic, audit trail, refund automation

### 1.4 Batasan Masalah
- Fokus: 4 domain (Room, Resident, Finance, Operational) + Core (Auth, Notification, Setting) + Feature Toggle
- Peran: Pemilik (Owner), Pengelola (Admin), Penghuni/Calon Penghuni
- Platform: Web Dashboard (Owner/Admin) + Mobile/Web (Penghuni via Flutter)
- **Out of scope:** Multi-properti (hotel/villa) — feature toggle siap tapi implementasi 1 properti dulu

### 1.5 Manfaat
- Wisma Amal: sistem utuh, terintegrasi, maintainable, production-ready
- Mahasiswa (kita): bukti kompetensi arsitektur, testing, full-stack, dokumentasi
- Akademik: kontribusi metodologi perbaikan sistem legacy modular monolith

### 1.6 Sistematika Penulisan
BAB1 → BAB5 sesuai `00_overview/ARCHITECTURE.md`.

---

## Referensi Previous Work (untuk dikutip di BAB 1 sebagai "Previous Work Analysis")
| Proposal | Mahasiswa/NRP | Fokus | File |
|---|---|---|---|
| Revisi Sempro 1 | Rasyidatur (3123500039) | Penghuni & Tamu | `PA/old-files/Revisi Sempro 1.pdf` |
| Final Proposal PA | Roihanah (3123500005) | Kamar & Reservasi | `PA/old-files/Final Proposal PA.pdf` |
| Proposal Proyek Akhir | Rizal (3123500060) | Keuangan | `PA/old-files/Proposal Proyek Akhir.pdf` |
| Proposal A4 | Bagus (3123500031) | Operasional & Maintenance | `PA/old-files/PROPOSAL PROYEK AKHIR _ A4.docx.pdf` |