# Dokumentasi Federated — PA Management Kost

Folder `Docs/` ini adalah **GLOBAL HUB** — single source of truth untuk AI & manusia di root `PA-Management-kost/`.

> **Untuk AI:** Baca `AGENTS.md` di root dulu. File ini hanya peta federasi.

## Federasi Docs

```
PA-Management-kost/
├── AGENTS.md               <- routing keputusan L1
├── Docs/                   <- KAMU DI SINI (hub global)
│   ├── 00_overview/        ★ dibaca tiap sesi
│   ├── 01_guides/          ○ onboarding
│   ├── 02_reference/       ◇ pointer teknis
│   ├── 03_logs/            ● history gabungan
│   └── modules/            ◆ pointer modul high-level
│
├── PA/
│   ├── old-files/*.pdf     <- sumber knowledge (4 proposal)
│   └── docs/               <- DOCS SKRIPSI (komprehensif BAB1-5, panduan kampus, jurnal)
│
└── Project/
    ├── docs/               <- DOCS PROJECT HUB (pointer backend+frontend)
    ├── backend-wismaamalgorontalo/
    │   ├── KNOWLEDGE_BASE.md <- akan di-adopt
    │   └── docs/           <- DOCS BACKEND (Laravel modular)
    └── fe_wisma_amal_gorontalo/
        ├── CLEAN_ARCHITECTURE_GUIDELINE.md <- akan di-adopt
        └── docs/           <- DOCS FRONTEND (Flutter BLoC)
```

## Cara Pakai untuk AI (Blocker Routing)

| Task | Wajib baca dulu | Baru boleh |
|---|---|---|
| **Review/ubah PA (naskah)** | `Docs/00_overview/ARCHITECTURE.md` → `PA/docs/00_overview/*` + `PA/docs/02_reference/*` | Edit `PA/docs/modules/bab*/` |
| **Review/ubah Project** | `Docs/00_overview/ARCHITECTURE.md` → `Project/docs/00_overview/*` → `backend/docs` atau `fe/docs` | Edit `Project/**` + update modul docs |

**Aturan L1:** Jangan loncat hub. Jika `Docs/00_overview/STATE.md` bilang `PA BAB2 WIP`, maka AI tidak boleh asumsi selesai.

## Kapan buka apa?

| Kategori | Isi | Kapan |
|---|---|---|
| `00_overview/` | `ARCHITECTURE.md` hub federasi, `STATE.md` ringkasan 1 halaman, `STACK.md` fullstack | Tiap sesi |
| `01_guides/` | `GLOSSARY.md` istilah Wisma Amal, `CONVENTIONS.md` aturan tulis, `WORKFLOW.md` sprint Scrum | Onboarding |
| `02_reference/` | Pointer ke `PA/docs/02_reference/*` dan `Project/docs/02_reference/*` | Butuh detail teknis |
| `03_logs/` | `PROGRESS_LOG.md` gabungan, `DECISIONS.md` ADR global, `CHANGELOG.md` | Tiap sesi & cari histori |
| `modules/` | Pointer high-level: `wisma-core`, `room-reservation`, `finance`, `operational` | Saat kerjakan fitur lintas stack |

Bahasa docs: Indonesia. Kode: Inggris.
