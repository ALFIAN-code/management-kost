# Changelog — PA

## [2026-10-21] ProyekAkhir_BAB1_BAB2_v0.4.docx
- Digenerate dari `modules/bab1/README.md` + `modules/bab2/README.md` memakai Pandoc 3.12.1.
- Format: A4, margin 4-4-3-3 cm, Times New Roman 12 pt, spasi 1,5, Heading 1 kapital di tengah dan mulai halaman baru.
- Cover + Daftar Isi otomatis (field TOC), nomor halaman romawi (front matter) dan arab (isi).
- Gambar 2.2, 2.4, 2.5 disisipkan dari `System design/`; 11 gambar lain ditandai "(belum tersedia)".
- Daftar Pustaka memakai `modules/referensi/DAFTAR_PUSTAKA_LENGKAP.md` (28 entri).
- Blocker: urutan sitasi belum mulai dari `[1]`; `[36]` dan `[41]` dipakai di BAB 2 tetapi belum ada di daftar pustaka.
- Perbaikan 12:37: relasi `rIdFtr2` (footer halaman pertama) sempat tidak tertulis di `document.xml.rels` sehingga paket ditolak Pages/Google Docs. Sudah ditambahkan, urutan elemen `w:shd` dibetulkan, dan paket divalidasi ulang (0 masalah). Terbukti terbuka di Pages 14.4.

## [2025-09-19] Init PA/docs
- Struktur + baseline + pustaka awal + skill blockers

---
