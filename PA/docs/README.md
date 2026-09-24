# Dokumentasi Skripsi — PA Wisma Amal Gorontalo

Folder `PA/docs/` adalah **DOCS SKRIPSI** — single source of truth untuk penulisan Proyek Akhir.

> **Untuk AI:** Kamu sampai sini via `Docs/00_overview/ARCHITECTURE.md` (hub global). Baca `AGENTS.md:1` urutan: `03_logs/PROGRESS_LOG.md` (PA) → `00_overview/STATE.md` → `00_overview/ARCHITECTURE.md` → `01_guides/PANDUAN_PENULISAN.md` → `02_reference/*`.

## Peta

```
PA/docs/
├── README.md                    ← kamu di sini
├── 00_overview/
│   ├── ARCHITECTURE.md          # struktur naskah BAB1-5
│   ├── STATE.md                 # status BAB (mana WIP, revisi dosen)
│   └── STACK.md                 # aturan penulisan kampus (hasil parse template)
├── 01_guides/
│   ├── PANDUAN_PENULISAN.md     # aturan resmi kampus (wajib dipatuhi)
│   ├── GLOSSARY.md              # istilah TI + Wisma (sinkron dengan Docs/)
│   └── CONVENTIONS.md           # konvensi tulis sitasi, tabel, gambar
├── 02_reference/
│   ├── TEMPLATE_BASELINE.md     # hasil parse template docx kampus
│   ├── DAFTAR_PUSTAKA.md        # database sitasi terkurasi (DOI)
│   ├── TABEL_JURNAL.md          # matriks literature review
│   ├── ERD_GLOBAL.md            # ERD gabungan 4 proposal
│   └── SKILL_BLOCKERS.md        # aturan hybrid skills (blocker AI)
├── 03_logs/
│   ├── PROGRESS_LOG.md          # log bimbingan & revisi (append-only)
│   ├── DECISIONS.md             # alasan pilih judul/metode/rumusan
│   └── CHANGELOG.md             # versi docx
└── modules/
    ├── bab1/ (pendahuluan)
    ├── bab2/ (kajian pustaka)
    ├── bab3/ (desain sistem)
    ├── bab4/ (eksperimen & analisis)
    └── bab5/ (penutup)
```

## Sumber Knowledge

- `PA/old-files/` — 4 PDF proposal (struktur + isi awal, tidak 100% sama dengan final):
  - `Revisi Sempro 1.pdf` — Penghuni & Tamu (Rasyidatur 3123500039)
  - `Final Proposal PA.pdf` — Kamar & Reservasi (Roihanah 3123500005)
  - `Proposal Proyek Akhir.pdf` — Keuangan (Rizal 3123500060)
  - `PROPOSAL PROYEK AKHIR _ A4.docx.pdf` — Operasional & Maintenance (Bagus 3123500031)

## Aturan Blocker

1. **Source-first:** klaim teknis BAB3/4 wajib trace ke `Project/backend-wismaamalgorontalo/Modules/*` atau `Project/fe_wisma_amal_gorontalo/lib/*`. Tanpa bukti → `[CODE EVIDENCE NEEDED]`.
2. **Sitasi verifikabel:** setiap sitasi wajib ada di `02_reference/DAFTAR_PUSTAKA.md` dengan DOI/URL. Dilarang fabrikasi (cek via Semantic Scholar/Crossref).
3. **Template compliance:** sebelum generate docx, cek `02_reference/TEMPLATE_BASELINE.md` + jalankan checklist `SKILL_BLOCKERS.md`.
