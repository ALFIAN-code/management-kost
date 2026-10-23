# Koleksi Diagram Teori Penunjang BAB 2

> Folder ini memuat diagram konseptual untuk menunjang penjelasan pada **BAB 2 (Kajian Pustaka)**.
> Diagram dirancang ringkas, mudah dipahami, tidak berlebihan secara teknis, dan berlandaskan teori/standar resmi yang dapat dipertanggungjawabkan.
> 
> Setiap diagram tersedia dalam tiga format:
> 1. **`.html`** — Antarmuka mandiri interaktif dengan tombol ekspor SVG & PNG (2x resolusi cetak).
> 2. **`.svg`** — Vektor murni tajam tanpa pecah saat di-zoom.
> 3. **`.png`** — Raster resolusi tinggi siap sisip ke naskah dokumen proposal/skripsi.

---

## Daftar Diagram Teori Penunjang

| No | Nama Diagram & Sub-bab BAB 2 | Berkas HTML | Berkas Gambar | Dasar Teori / Standar Rujukan |
|---|---|---|---|---|
| **Gambar 2.3** | **Pemisahan Modul & DI pada NestJS**<br>*(§2.2.3 NestJS)* | [`gambar_2_3_nestjs_modul_di.html`](gambar_2_3_nestjs_modul_di.html) | [`gambar_2_3_nestjs_modul_di.png`](gambar_2_3_nestjs_modul_di.png)<br>[`gambar_2_3_nestjs_modul_di.svg`](gambar_2_3_nestjs_modul_di.svg) | Dokumentasi Resmi NestJS (*Fundamentals: Modules, Providers, & IoC Container*) |
| **Gambar 2.8** | **Isolasi Data pada Row-Level Scoping**<br>*(§2.2.8 Multi-Tenancy)* | [`gambar_2_8_row_level_scoping.html`](gambar_2_8_row_level_scoping.html) | [`gambar_2_8_row_level_scoping.png`](gambar_2_8_row_level_scoping.png)<br>[`gambar_2_8_row_level_scoping.svg`](gambar_2_8_row_level_scoping.svg) | Microsoft Azure Architecture Center (*Multitenant Database Tenancy Patterns*) |
| **Gambar 2.9** | **Verifikasi Token OIDC dengan JWKS**<br>*(§2.2.9 SSO, OIDC, Keycloak)* | [`gambar_2_9_oidc_jwks.html`](gambar_2_9_oidc_jwks.html) | [`gambar_2_9_oidc_jwks.png`](gambar_2_9_oidc_jwks.png)<br>[`gambar_2_9_oidc_jwks.svg`](gambar_2_9_oidc_jwks.svg) | Spesifikasi OpenID Connect Core 1.0 (§3.1) & RFC 7517 (*JSON Web Key Set*) |
| **Gambar 2.11** | **Alur Pembayaran & Verifikasi Webhook**<br>*(§2.2.11 Midtrans SNAP)* | [`gambar_2_11_midtrans_webhook.html`](gambar_2_11_midtrans_webhook.html) | [`gambar_2_11_midtrans_webhook.png`](gambar_2_11_midtrans_webhook.png)<br>[`gambar_2_11_midtrans_webhook.svg`](gambar_2_11_midtrans_webhook.svg) | Dokumentasi Resmi Midtrans (*SNAP Guide & HTTP Notification Webhook*) |
| **Gambar 2.13** | **Piramida Pengujian & Komposisinya**<br>*(§2.2.13 Pengujian Otomatis)* | [`gambar_2_13_piramida_pengujian.html`](gambar_2_13_piramida_pengujian.html) | [`gambar_2_13_piramida_pengujian.png`](gambar_2_13_piramida_pengujian.png)<br>[`gambar_2_13_piramida_pengujian.svg`](gambar_2_13_piramida_pengujian.svg) | Mike Cohn (2009), Martin Fowler (2012), & Google Testing Guide |
| **Gambar 2.14** | **Alur Konsultasi AI via Protokol MCP**<br>*(§2.2.14 Model Context Protocol)* | [`gambar_2_14_mcp.html`](gambar_2_14_mcp.html) | [`gambar_2_14_mcp.png`](gambar_2_14_mcp.png)<br>[`gambar_2_14_mcp.svg`](gambar_2_14_mcp.svg) | Anthropic (*Model Context Protocol Specification Revision 2024-11-05*) |

---

## Ringkasan Konsep Masing-Masing Diagram

### 1. Gambar 2.3 — Pemisahan Modul & Dependency Injection (NestJS)
* **Konsep:** Mengilustrasikan batas isolasi modul. Di dalam `Module A`, hanya service yang diekspor (`Public Service A`) yang dapat diinjeksi ke modul lain (`Module B`). Service internal (`Internal Service X`) tetap privat dan tidak dapat disuntikkan secara sembarangan, mencegah pelanggaran batas modularitas.

### 2. Gambar 2.8 — Row-Level Scoping (Multi-Tenancy)
* **Konsep:** Mengilustrasikan konsep multi-tenancy di mana seluruh data disimpan dalam satu tabel bersama (*shared table*). Isolasi data antar-gedung ditegakkan di level baris data melalui kolom penanda `building_id`, di mana kueri aplikasi secara otomatis menyaring data sesuai konteks pengelola gedung yang sedang aktif.

### 3. Gambar 2.9 — Alur Verifikasi Token OIDC dengan JWKS
* **Konsep:** Menunjukkan bagaimana pengguna melakukan login ke *Identity Provider* (Keycloak) untuk memperoleh token JWT, dan bagaimana Backend API memverifikasi keaslian token tersebut secara mandiri dan cepat menggunakan Kunci Publik (JWKS) tanpa harus melakukan panggilan balik ke Keycloak pada setiap request.

### 4. Gambar 2.11 — Alur Pembayaran dan Verifikasi Webhook (Midtrans SNAP)
* **Konsep:** Membagi proses menjadi dua tahap jelas: (1) Pelanggan meminta Snap token dan melakukan pembayaran via pop-up SNAP, serta (2) Midtrans mengirimkan notifikasi asinkron (webhook) yang diverifikasi keasliannya oleh backend menggunakan kalkulasi tanda tangan SHA512 sebelum mengubah status transaksi menjadi lunas.

### 5. Gambar 2.13 — Piramida Pengujian beserta Komposisinya
* **Konsep:** Menjelaskan strategi pengujian otomatis perangkat lunak berlapis: *Unit Tests* sebagai fondasi terbesar (~70%), *Integration Tests* di lapisan tengah (~20%), dan *UI/E2E Tests* di puncak paling tipis (~10%), disertai indikator komparasi biaya dan durasi eksekusi.

### 6. Gambar 2.14 — Alur Jawaban Cepat Asisten AI via Model Context Protocol (MCP)
* **Konsep:** Menunjukkan alur kerja 4 komponen: Pengguna bertanya lewat chat $\rightarrow$ Asisten AI (LLM Host) menganalisis dan memanggil fungsi tool $\rightarrow$ MCP Server (Read-Only) mengeksekusi kueri aman ke basis data operasional $\rightarrow$ Data faktual dikembalikan ke LLM untuk menyusun jawaban akurat dan faktual bagi pengguna.
