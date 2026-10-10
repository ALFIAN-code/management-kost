# Konvensi Penulisan Naskah

**Terakhir diupdate:** 2025-09-19

## Bahasa & Format

- Docs `PA/docs/`: Indonesia. Draft BAB: Indonesia formal.
- File: `bab1-latar-belakang.md` snake-case. Gambar ref: `Gambar 3.x`.
- Tabel di markdown pakai pipe, header wajib.

## Sitasi & Referensi

- Body: `[1]`. Daftar: IEEE. Lihat PANDUAN_PENULISAN §3.
- Draft boleh pakai `[CITATION NEEDED]` sementara, tapi wajib resolved sebelum docx.

## Diagram

- **✅ Ratified (2026-10-10, preferensi user):** Setiap generate diagram (DFD, ERD, BPMN, arsitektur, dll) **WAJIB dibuat dulu dalam bentuk `.html` mandiri** di `PA/docs/System design/<jenis>/`, berisi SVG yang di-generate dari array data (layout otomatis, label tidak tertimpa garis, tanpa garis bersilangan) + tombol **Download SVG** & **Download PNG (2x)**. Mermaid `.mmd` hanya pendamping opsional.
- Final docx: export PNG dari HTML + caption.
- Setiap diagram wajib ada paragraf penjelasan sebelum/sesudah ("Gambar 3.x menunjukkan...").

## Trace Kode

- Format: `(lihat Project/backend-wismaamalgorontalo/Modules/Room/Http/Controllers/...)` atau `[CODE EVIDENCE NEEDED]` jika belum ada.
