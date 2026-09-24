# Template Baseline — Hasil Parse Template Kampus

> Baseline format docx (dari `PA/old-files/PROPOSAL PROYEK AKHIR _ A4.docx.pdf` + 3 PDF lain). Dipakai sebagai acuan `python-docx` generate + `validate_thesis_docx.py`.

**Terakhir diupdate:** 2025-09-19
**Sumber:** 4 PDF proposal (A4)

## Kertas & Layout (asumsi dari PDF A4)

| Elemen | Nilai | Catatan |
|---|---|---|
| Kertas | A4 (21 x 29.7 cm) | Dari nama file `A4.docx.pdf` |
| Font body | Times New Roman 12 (asumsi — verifikasi dari docx asli) |  |
| Spasi | 1.5 (asumsi) |  |
| Heading BAB | Caps, bold, center: `BAB 1 PENDAHULUAN` |  |
| Sub-heading | `1.1 Latar Belakang` bold |  |
| Nomor halaman | Bawah, Daftar Isi romawi (i, ii...), BAB arab (1, 2...) |  |

> TODO: parse docx asli jika ada (bukan PDF) via `parse_docx_template.py` untuk font/margin pasti. Saat ini baseline dari PDF.

## Style Heading untuk TOC

| Style | Level | Masuk TOC? |
|---|---|---|
| `BAB x JUDUL` | Heading 1 | Ya |
| `x.y Judul` | Heading 2 | Ya |
| `x.y.z Judul` | Heading 3 | Tidak (no-outline, cegah bocor) |

## Sitasi & Referensi

- Body: superscript? Tidak — proposal pakai inline `[1]`. Pertahankan inline numeric.
- Daftar Pustaka: auto-numbered `[1]..[n]`, urut kemunculan.

## Cover Fields

```
PROPOSAL LAPORAN AKHIR / PROPOSAL PROYEK AKHIR
Judul (caps) + Sub Judul
Nama
NRP
Dosen Pembimbing: Nama, gelar + NIP
PROGRAM STUDI DIPLOMA TIGA TEKNIK INFORMATIKA
DEPARTEMEN TEKNIK INFORMATIKA DAN KOMPUTER
POLITEKNIK ELEKTRONIKA NEGERI SURABAYA
Tahun
```

## Validation Scripts (dari 1-pluto1)

```bash
# Cek urutan sitasi di markdown
python scripts/validate_citation_order.py PA/docs/modules --references PA/docs/02_reference/DAFTAR_PUSTAKA.md --order bab1 bab2 bab3 bab4 bab5
# Cek docx final
python scripts/validate_thesis_docx.py PA/ProyekAkhir.docx --refs-auto-numbered --toc-must-contain 'BAB,1,1.1,2' --toc-must-not-contain '1.1.1' --no-outline-style 'Heading 3'
```
