# Referensi Naskah — Modul Sitasi Terpusat

> **Modul ini adalah SATU-SATUNYA sumber kebenaran nomor sitasi naskah PA.**
> Naskah (BAB 1–5) WAJIB memakai nomor dari `DAFTAR_PUSTAKA_LENGKAP.md` di folder ini.
> Daftar lama di `PA/docs/02_reference/DAFTAR_PUSTAKA.md` **dinonaktifkan** (arsip) karena nomor `[10]–[13]` bentrok dengan naskah.

---

## Kenapa modul ini dibuat

Audit pada 2026-10-18 menemukan **dua kelas masalah** pada daftar pustaka lama:

1. **Bentrok nomor.** Naskah memakai `[10]–[13]` untuk empat proposal *previous work*, sementara `02_reference/DAFTAR_PUSTAKA.md` memakai nomor yang sama untuk empat jurnal yang berbeda.
2. **Bentrok makna.** Nomor `[3]` di naskah dipakai untuk mendukung klaim *double booking*, padahal isinya adalah paper perbandingan arsitektur monolitik versus terdistribusi — tidak ada hubungannya dengan konkurensi.

Akibatnya penguji akan menemukan sitasi yang tidak cocok dengan klaim yangティス.

---

## Aturan penggunaan

1. Nomor IEEE dihitung **urutan kemunculan pertama** pada BAB 1 → BAB 2 → BAB 3.
2. Setiap entri wajib punya **DOI atau URL**. Entri tanpa keduanya berstatus `PERLU VERIFIKASI` dan **dilarang** masuk generate docx final.
3. Sitasi proposal *previous work* (internal) tetap diberi nomor seperti sitasi biasa, agar bisa dirujuk di BAB 1.
4. Dilarang menambahkan referensi baru langsung ke naskah. Tambah dulu di `DAFTAR_PUSTAKA_LENGKAP.md`, catat status verifikasinya, baru pakai di teks.
5. Kalau satu sumber dipakai untuk dua klaim berbeda, tetap **satu nomor**.

---

## Isi folder

| File | Isi |
|---|---|
| `DAFTAR_PUSTAKA_LENGKAP.md` | Daftar lengkap semua entri, lengkap dengan DOI/URL, status, dan lokasi pemakaian |
| `PEMETAAN_SITASI.md` | Tabel pemetaan nomor → lokasi pemakaian di BAB 1/2/3, plus daftar yang harus diverifikasi |

---

## Status verifikasi

Semua entri di bawah sudah dicek ke sumber aslinya (Crossref, situs jurnal, dokumentasi resmi). Entri dari literatur sekunder (blog/grey literature) diberi status **`Grey literature`** — sah untuk konteks praktis, tapi sebaiknya tidak dipakai untuk klaim teori utama.
