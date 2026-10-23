# Alur 10 — Pemesanan DP (Two-Phase Invoicing) & Refund Pembatalan Sewa

> **Status:** Resmi Disepakati (ADR-013)  
> **Tipe Notasi:** BPMN 2.0 Collaboration Diagram (Pool & Lane)  
> **Modul Terlibat:** `Lease`, `Finance`, `Building`, `Notification`  
> **Fokus Utama:** Panduan Alur Kerja Engineering & Referensi Pengujian Sistem  

---

## 1. Ringkasan Proses Bisnis

Diagram ini memodelkan dua siklus penting pada sistem manajemen kost general multi-gedung:
1. **Fase 1: Pemesanan Kamar & Uang Muka (Two-Phase Invoicing):**
   - Calon penghuni memilih kamar dan mengajukan reservasi.
   - Sistem mengunci ketersediaan unit kamar (`SELECT FOR UPDATE`).
   - Sistem memeriksa kebijakan pemesanan properti (`booking_fee_mode` di `building_settings`):
     - Jika gedung mengaktifkan uang tanda jadi (`FIXED_DP`), diterbitkan **Invoice #1: DP Tanda Jadi** dengan batas bayar 24 jam.
     - Calon penghuni membayar via Midtrans SNAP $\rightarrow$ Webhook callback memverifikasi tanda tangan kriptografis SHA-512.
     - Status sewa berubah menjadi `Reserved` (kamar terkunci aman dan tidak bisa dipesan orang lain).
     - Menjelang tanggal mulai sewa (H-3), cron job scheduler otomatis menerbitkan **Invoice #2: Pelunasan** ($\text{Harga Sewa} - \text{DP}$).
     - Calon penghuni melunasi tagihan pelunasan $\rightarrow$ status sewa menjadi `Active` (Check-in aktif).
2. **Fase 2: Pembatalan Sewa & Pengembalian Dana (Refund Semi-Manual):**
   - Sebelum tanggal mulai sewa, penghuni mengajukan permohonan pembatalan digital melalui portal web dengan mengunggah nomor rekening bank tujuan.
   - Sistem memeriksa jendela batas waktu pembatalan gedung (`cancellation_grace_days`, misal $\ge 14$ hari):
     - **Jika melewati batas:** Notifikasi diterbitkan bahwa uang DP hangus sesuai kebijakan gedung $\rightarrow$ kamar otomatis kembali menjadi `available`.
     - **Jika memenuhi syarat:** Tiket pembatalan masuk ke menu **Refund Requests** dan pengelola menerima notifikasi penugasan.
   - Pengelola meninjau rincian rekening tujuan dan memotong biaya pembatalan/denda jika berlaku.
   - Pengelola mengeksekusi transfer bank secara mandiri (m-banking).
   - Pengelola mengunggah foto struk/bukti transfer resmi (`refund_proof_url`) dan menekan tombol **"Selesaikan Refund"**.
   - Sistem otomatis mengubah status sewa menjadi `cancelled`, melepaskan unit kamar kembali ke publik menjadi `available`, dan mengirim kuitansi pembatalan berlampiran struk transfer ke nomor WhatsApp penghuni.

---

## 2. Berkas Diagram

1. **[`alur_pembatalan_dan_refund.html`](alur_pembatalan_dan_refund.html):** Diagram interaktif mandiri berbasis SVG murni dengan tombol unduh.
2. **[`alur_pembatalan_dan_refund.svg`](alur_pembatalan_dan_refund.svg):** Berkas vektor resolusi tanpa batas.
3. **[`alur_pembatalan_dan_refund.png`](alur_pembatalan_dan_refund.png):** Berkas raster resolusi tinggi (1340x730 px).

---

## 3. Kamus Data & Transisi Status (State Machine)

| Aktor | Aksi / Tugas | Kondisi Input | Status Output |
|---|---|---|---|
| **Penghuni** | Pengajuan Sewa | Kamar `available` | Sewa `pending_payment` |
| **Sistem** | Terbitkan Invoice DP | Mode `FIXED_DP` | Invoice DP `unpaid` |
| **Payment GW** | Settlement Webhook | Pembayaran sukses | Invoice DP `paid`, Sewa `reserved` |
| **Sistem (Cron)** | Trigger Pelunasan H-3 | $T_{\text{checkin}} - \text{today} \le 3$ hari | Invoice Pelunasan `unpaid` |
| **Penghuni** | Bayar Pelunasan | Invoice Pelunasan `unpaid` | Invoice Pelunasan `paid`, Sewa `active` |
| **Penghuni** | Ajukan Pembatalan | Sewa `reserved` | Tiket Refund `submitted` |
| **Pengelola** | Transfer & Upload Struk | Tiket Refund `submitted` | Tiket Refund `completed`, Sewa `cancelled`, Kamar `available` |
