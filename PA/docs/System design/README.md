# System Design — Sumber Kebenaran Tunggal (Single Source of Truth)

> Folder ini adalah **pusat kebenaran tunggal (*Single Source of Truth*)** untuk seluruh spesifikasi desain sistem, daftar fitur, alur proses bisnis (BPMN), diagram aliran data (DFD), model data (ERD), dan arsitektur sistem PA-Management-kost.
> 
> **Aturan Wajib:** Seluruh hasil perancangan dan keputusan yang disepakati bersama user **WAJIB langsung dicatat dan diperbarui secara otomatis di folder ini pada sesi yang sama**, untuk mencegah fragmentasi dokumen dan multi-tafsir.

---

## 1. Dokumen Inti Perancangan Sistem (Current Single Source of Truth)

1. **[Daftar Kebutuhan & Fitur Resmi (F01–F17)](DAFTAR_FITUR.md):**
   * Spesifikasi 17 fitur terperinci yang membagi sistem menjadi **Fitur Core (M1–M5)**, **Fitur Opsional Plug & Play (O1–O5)**, dan **Lapisan Adaptor AI (MCP)**.
2. **[Koleksi 10 Alur Proses Bisnis Lengkap (`02-BPMN/`)](02-BPMN/README.md):**
   * Alur proses bisnis kolaboratif BPMN 2.0 (HTML/SVG/PNG 2x) per fitur:
     - `01_alokasi_penempatan_hunian/` (Core: Alokasi, Kuota, Booking Policy)
     - `02_penagihan_pembayaran/` (Opsional: Tagihan, SNAP Midtrans, Denda)
     - `03_laporan_kerusakan_fasilitas/` (Opsional: Tiket Aduan Kerusakan)
     - `04_pemeliharaan_rutin_berkala/` (Opsional: Agenda Servis Preventif H-7)
     - `05_pengeluaran_operasional/` (Opsional: Kas Keluar Riil & Nota)
     - `06_pengawasan_buku_tamu/` (Opsional: Check-in/out Tamu & Biaya Inap)
     - `07_pengaturan_hak_akses_dinamis/` (Core: Dynamic RBAC & Role Builder)
     - `08_pendataan_inventaris_aset/` (Opsional: Pendataan & Audit Fisik)
     - `09_konsultasi_ai_mcp/` (Adaptor: Asisten AI & Konteks Data)
     - `10_pembatalan_sewa_dan_refund/` (ADR-013: Pemesanan DP Two-Phase Invoicing & Refund Semi-Manual)
3. **[Diagram Aliran Data Sistem (`03-DFD/`)](03-DFD/README.md):**
   * Diagram Konteks Level 0 (`dfd_level_0_context.html`) dan Diagram Dekomposisi Fungsional Level 1 (`dfd_level_1_dekomposisi.html`) membagi 10 proses domain dan 13 data store terisolasi.
4. **[Model Data Terpadu & Kamus Data (`04-ERD/`)](04-ERD/README.md):**
   * Diagram Entity-Relationship terpadu 13 tabel domain sewa bulanan murni (`erd_13_tabel.html`) dan ERD sistem dinamis (`erd_sistem_dinamis.html`).
5. **[UML 2.5 Use Case Diagram (`05-Use-Case/`)](05-Use-Case/README.md):**
   * Pemodelan batasan fungsionalitas aktor manusia (*Default Seed Roles* & *Dynamic RBAC*) dan sistem eksternal (Keycloak, Midtrans, WhatsApp, AI MCP). Tersedia dalam HTML interaktif, SVG, dan PNG 2x resolusi cetak.
6. **[Diagram Teori Penunjang BAB 2 (`06-Teori-Penunjang/`)](06-Teori-Penunjang/README.md):**
   * Diagram konseptual penunjang materi kajian pustaka BAB 2:
     - `gambar_2_3_nestjs_modul_di`: Pemisahan Modul & Dependency Injection pada NestJS
     - `gambar_2_8_row_level_scoping`: Isolasi Data Antar Gedung pada Row-Level Scoping Multi-Tenancy
     - `gambar_2_9_oidc_jwks`: Alur Verifikasi Token OIDC dengan Kunci Publik JWKS
     - `gambar_2_11_midtrans_webhook`: Alur Pembayaran SNAP & Verifikasi Notifikasi Webhook
     - `gambar_2_13_piramida_pengujian`: Piramida Pengujian Perangkat Lunak beserta Komposisinya
     - `gambar_2_14_mcp`: Alur Konsultasi Data Asisten AI via Model Context Protocol (MCP)
     Tersedia dalam format HTML interaktif mandiri, vektor SVG, dan raster PNG 2x resolusi cetak.

---

## 2. Koleksi Diagram Arsitektur Dasar

1. **`01_arsitektur_sistem_terpadu/`** (`c4_level2_container_wisma_amal.svg`): C4 Container Arsitektur Sistem Terpadu.
2. **`02_hierarki_3_tier_modulith/`** (`component_diagram_modular_monolith_3_tier.svg`): Aturan Dependensi 3-Tier (Infrastructure, Core, Business).
3. **`03_clean_architecture_frontend/`** (`clean_architecture_frontend.mmd`): Clean Architecture Frontend Flutter Single Codebase.

---

## 3. Arsip Draft Desain Lama (Obsolete / Superseded)

Seluruh subfolder pada direktori **`draft/`** (04 s/d 16: `04_bpmn_...`, `08_dfd_...`, `12_erd_...`, dll.) merupakan artefak rancangan lama sebelum keputusan **Full Rewrite (ADR-007 & ADR-008)**. Dokumen pada folder tersebut **tidak digunakan lagi** dalam implementasi aktif maupun naskah terkini, dan diarsipkan sebagai jejak sejarah.

---

## Petunjuk Ekspor dan Re-render

Jika Anda ingin mengubah kode sumber diagram `.mmd`, Anda dapat me-render ulang seluruh file `.png` secara otomatis menggunakan perintah berikut:

```bash
cd "PA/docs/System design"
for file in */*.mmd; do
    out="${file%.mmd}.png"
    echo "Rendering $file -> $out"
    npx @mermaid-js/mermaid-cli -i "$file" -o "$out" -s 2 -b white
done
```
