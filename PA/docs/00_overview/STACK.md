# Stack Penulisan — Aturan Kampus PENS

> Hasil parse 4 PDF proposal `PA/old-files/`. Ini aturan yang diturunkan dari praktik aktual (bukan buku panduan resmi — jika ada PDF panduan resmi, merge ke sini).

**Program:** D3 Teknik Informatika, Departemen Teknik Informatika & Komputer, PENS
**Tahun:** 2025
**Bahasa:** Indonesia (abstrak Inggris opsional)

## Format Naskah (dari observasi template)

| Elemen | Aturan | Contoh |
|---|---|---|
| Cover | Judul + sub-judul, nama, NRP, dosen pembimbing + NIP, prodi, departemen, PENS, tahun | Lihat `Revisi Sempro 1.pdf` hal 1 |
| BAB | `BAB 1 PENDAHULUAN` (caps), sub `1.1 Latar Belakang` | 5 BAB |
| Sitasi | Numeric `[1]` urut kemunculan di body, daftar di akhir | `[1][2]` di latar belakang |
| Daftar Pustaka | IEEE-like: `[n] Author, "Title," Journal, vol, pp, date, doi/url` | 22 refs (sempro), 10-17 (lainnya) |
| Tabel | `Tabel 2.1 Judul` + kolom Judul/Tahun/Penulis/Tujuan/Metode/Hasil (penelitian terkait) | Tabel perbandingan wajib di BAB2 |
| Gambar | `Gambar 3.x Judul` — BPMN, Use Case, DFD, Activity, ERD, mockup, timeline | 12-26 gambar di BAB3 |
| Skenario uji | Tabel Subyek/Obyek(Data)/Skenario/Hasil diharapkan + kuesioner skala Likert | Black-box testing |

## Sistematika Wajib (5 BAB)

1. **BAB 1 Pendahuluan:** Latar Belakang → Rumusan/Identifikasi Masalah → Tujuan → Batasan → Manfaat → Sistematika Penulisan
2. **BAB 2 Kajian Pustaka:** Deskripsi Permasalahan → Teori Penunjang → Penelitian Terkait + Tabel perbandingan + gap statement
3. **BAB 3 Desain Sistem:** Deskripsi Solusi → Scrum (peran, artefak, sprint, backlog, user story) → Desain (BPMN, Use Case/Mindmap, DFD, Activity, ERD, mockup, skenario, jadwal)
4. **BAB 4 Eksperimen & Analisis:** Implementasi + hasil uji + analisis ketercapaian tujuan
5. **BAB 5 Penutup:** Kesimpulan + saran

## Teori Penunjang Standar (dari 4 proposal)

Wajib ada (sesuaikan sub-judul): SIM, Modular Monolith/Modulith (+ DDD), Laravel, Flutter, MySQL (+ relasional), + spesifik modul (Midtrans/payment gateway, notifikasi Open-WA).

## Kebutuhan Dokumen PA

| Kategori | File | Wajib? |
|---|---|---|
| 00_overview | ARCHITECTURE, STATE, STACK | Ya |
| 01_guides | PANDUAN_PENULISAN, GLOSSARY, CONVENTIONS | Ya |
| 02_reference | TEMPLATE_BASELINE, DAFTAR_PUSTAKA, TABEL_JURNAL, ERD_GLOBAL, SKILL_BLOCKERS | Ya |
| 03_logs | PROGRESS_LOG, DECISIONS, CHANGELOG | Ya |
| modules | bab1..bab5 | Ya |
