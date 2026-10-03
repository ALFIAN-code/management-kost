# Panduan Penulisan PA — PENS D3 TI

> Aturan resmi penulisan (hasil ekstraksi 4 proposal + adaptasi umum PENS). Prioritas tertinggi untuk AI saat menulis. Jika ada buku panduan resmi kampus (PDF), merge ke sini dan catat di DECISIONS.

**Terakhir diupdate:** 2025-09-19

## 1. Struktur Front Matter

1. Cover: `LAPORAN PROYEK AKHIR` / **Refactoring Sistem Manajemen Rumah Kost dengan Arsitektur Modular Monolithic Berbasis Kerangka Kerja Scrum** (Studi Kasus: Wisma Amal Gorontalo), nama, NRP, dosen pembimbing (nama + NIP), prodi, departemen, PENS, tahun
2. Daftar Isi, Daftar Gambar, Daftar Tabel (dengan nomor halaman titik-titik)

## 2. Gaya Bahasa

- Bahasa Indonesia formal, kalimat pasif untuk prosedur ("dilakukan", "dirancang"), aktif untuk tujuan ("bertujuan")
- Konsisten: `penghuni` (bukan penyewa berganti-ganti), `pengelola` vs `pemilik`, `kamar` (bukan room di narasi)
- Hindari typo khas proposal: `permaslahan`, `manajamen`, `peginap`, `Bussiness` → proofread wajib
- Setiap klaim masalah di BAB1 harus didukung sitasi `[n]` atau data Wisma (jangan opini kosong)

## 3. Sitasi Numeric (Blocker)

- Format: `[1]`, `[1][2]` berurutan kemunculan pertama di body. Sitasi pertama di BAB1 harus `[1]`.
- Daftar Pustaka format IEEE:
  ```
  [1] A. Author, "Title," Journal, vol. x, no. y, pp. zz, Mon. Year, doi:xxx
  ```
- Setiap entry wajib punya DOI/URL verifikabel. Dilarang sitasi halusinasi — cek via Semantic Scholar/Crossref.
- Urutan di Daftar Pustaka = urutan kemunculan, bukan abjad.

## 4. Tabel & Gambar

- Tabel: `Tabel 2.1 Judul` di atas tabel. Kolom penelitian terkait: Judul/Tahun/Penulis/Tujuan/Metode/Hasil + baris peneliti sendiri di akhir.
- Gambar: `Gambar 3.x Judul` di bawah gambar. Wajib dirujuk di teks ("pada Gambar 3.2...").
- BAB3 wajib: BPMN, Use Case, DFD Level 0 + Level 1, minimal 2 Activity Diagram, ERD, mockup per peran, Tabel Skenario Aplikasi, Tabel Kuesioner, Timeline/Jadwal.

## 5. Scrum Documentation (khusus PA ini)

BAB3 wajib ada: Peran (PO/SM/Dev), Artefak (Product/Sprint Backlog, Increment), Perencanaan Sprint (tabel 4 sprint), Sprint Backlog + contoh User Story (tabel No/User Story/Task Teknis/Status + tabel Elemen/Deskripsi + Kriteria Penerimaan).

## 6. Larangan (dari skill 1-pluto1 + Imbad0202)

- Jangan overclaim: "sistem modular dengan fitur lengkap" hanya jika modul tersebut ada di `modules_statuses.json` = true dan ada file-nya.
- Jangan tulis hasil uji di BAB3 (itu BAB4). BAB3 hanya rencana/skenario.
- Jangan tambah referensi yang tidak disitasi di body, dan sebaliknya.
- Parafrase, bukan copy-paste jurnal. Tiap paragraf BAB2 minimal 1 sitasi.

## 7. Checklist Sebelum Generate DOCX

- [ ] Sitasi urut `[1]` dari BAB1, tidak ada lompat
- [ ] Semua gambar/tabel dirujuk di teks
- [ ] TOC hanya Heading 1-2 (BAB + 1 level), tidak bocor Heading 3
- [ ] Daftar Pustaka auto-numbered, semua ada DOI/URL
- [ ] Cover + pengesahan + NIP pembimbing benar
