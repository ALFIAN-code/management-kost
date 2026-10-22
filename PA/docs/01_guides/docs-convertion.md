# Panduan Konversi Markdown ke DOCX dan PDF dengan Pandoc

Pandoc mem-parse Markdown menjadi AST, lalu menulisnya ulang ke format target. Ini yang membuat hasilnya lebih akurat dibanding konverter yang hanya mengganti tag.

## 1. Instalasi

```bash
# macOS
brew install pandoc

# Arch / CachyOS
sudo pacman -S pandoc

# Ubuntu / Debian
sudo apt install pandoc
```

Cek versi:

```bash
pandoc --version
```

## 2. Konversi Dasar

```bash
# Markdown -> Word
pandoc input.md -o output.docx

# Markdown -> PDF
pandoc input.md -o output.pdf
```

## 3. Atur Gaya dengan `reference.docx`

Pandoc memakai style dari dokumen referensi (font, heading, margin, tabel).

1. Ambil template bawaan:

   ```bash
   pandoc -o reference.docx --print-default-data-file reference.docx
   ```

2. Buka `reference.docx` di Word, lalu edit **style**-nya (bukan isinya): Normal, Heading 1-3, Table, Caption, dst. Atur juga margin dan ukuran kertas.
3. Simpan, lalu pakai saat konversi:

   ```bash
   pandoc input.md -o output.docx --reference-doc=reference.docx
   ```

## 4. Opsi yang Sering Dipakai

| Opsi | Fungsi |
|---|---|
| `--toc` | Daftar isi otomatis |
| `--toc-depth=3` | Kedalaman daftar isi |
| `--number-sections` | Penomoran bab otomatis |
| `--citeproc --bibliography=refs.bib` | Sitasi dari file BibTeX |
| `--csl=apa.csl` | Gaya sitasi (APA, IEEE, dll.) |
| `--resource-path=.` | Lokasi pencarian gambar relatif |
| `-f markdown+footnotes+tex_math_dollars` | Aktifkan ekstensi Markdown |
| `--metadata title="Judul"` | Isi metadata dokumen |

Contoh gabungan:

```bash
pandoc input.md -o output.docx \
  --reference-doc=reference.docx \
  --toc --number-sections \
  --resource-path=.
```

## 5. Output PDF

Pandoc membuat PDF lewat engine eksternal.

```bash
# LaTeX (hasil paling rapi untuk dokumen akademik)
pandoc input.md -o output.pdf --pdf-engine=xelatex

# Typst (lebih ringan dan cepat)
pandoc input.md -o output.pdf --pdf-engine=typst
```

Untuk mengganti font dan margin pada XeLaTeX:

```bash
pandoc input.md -o output.pdf --pdf-engine=xelatex \
  -V mainfont="Times New Roman" \
  -V fontsize=12pt \
  -V geometry:margin=2.5cm
```

## 6. Pakai YAML Front Matter

Letakkan di bagian paling atas file Markdown:

```yaml
---
title: "Judul Dokumen"
author: "Nama Penulis"
date: "2026-10-21"
toc: true
number-sections: true
---
```

Dengan ini opsi `--toc` dan `--number-sections` tidak perlu diketik lagi di command line.

## 7. Diagram Mermaid

Pandoc tidak merender Mermaid secara otomatis. Render dulu ke gambar, lalu sisipkan.

1. Install mermaid-cli:

   ```bash
   npm install -g @mermaid-js/mermaid-cli
   ```

2. Render diagram:

   ```bash
   mmdc -i diagram.mmd -o diagram.png -s 3
   ```

3. Sisipkan di Markdown:

   ```markdown
   ![Alur sistem](diagram.png)
   ```

Alternatif: pakai filter `mermaid-filter` agar blok ` ```mermaid ` dirender otomatis saat konversi.

## 8. Masalah Umum dan Solusinya

| Masalah | Solusi |
|---|---|
| Tabel terpotong di Word | Gunakan pipe table dan atur lebar kolom lewat jumlah tanda `-` pada baris pemisah |
| Gambar tidak muncul | Tambahkan `--resource-path=.` atau pakai path relatif yang benar |
| Font tidak sesuai | Ubah style di `reference.docx`, bukan di file Markdown |
| Footnote / math tidak tampil | Aktifkan ekstensi dengan `-f markdown+footnotes+tex_math_dollars` |
| Halaman judul tidak sesuai format kampus | Buat cover manual di Word, atau pakai `reference.docx` yang sudah memuat cover |
| PDF gagal dibuat | Pastikan engine (XeLaTeX / Typst) sudah terinstal |

## 9. Alur Kerja yang Disarankan

1. Tulis konten dalam satu atau beberapa file `.md`.
2. Siapkan `reference.docx` sekali saja sesuai format yang dibutuhkan.
3. Simpan perintah konversi di `Makefile` atau script supaya bisa diulang:

   ```makefile
   build:
   	pandoc front.md bab1.md bab2.md -o laporan.docx \
   	  --reference-doc=reference.docx \
   	  --toc --number-sections \
   	  --resource-path=.
   ```

4. Jalankan `make build`, lalu rapikan detail akhir di Word jika perlu (cover, nomor halaman, daftar gambar).

## 10. Alternatif untuk Situs Dokumentasi

Jika yang dibutuhkan situs dokumentasi (bukan file Word/PDF):

- **MkDocs Material**: sederhana, konfigurasi YAML
- **Docusaurus**: berbasis React, cocok untuk dokumentasi besar
- **VitePress**: ringan dan cepat, berbasis Vue