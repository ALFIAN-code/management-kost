# Alur 02: Siklus Tagihan & Pembayaran (Billing & Payment)

> Modul Terkait: **Modul Opsional (Finance & Billing)**  
> Sifat: **Aktif pada Properti Komersial / Berbayar (Rumah Kost / Rusunawa)**

---

## 1. Deskripsi Alur
Alur ini mengelola pencatatan kewajiban finansial penghuni, mencakup pembuatan tagihan (*invoicing*), penerimaan pembayaran digital (Midtrans SNAP VA/QRIS) maupun manual (tunai/transfer langsung), rekonsiliasi status tagihan, hingga penalti denda keterlambatan.

## 2. Pemicu Penerbitan Invoice
1. **Invoice Pertama (Sewa Baru):** Dipicu oleh event `OccupancyCreated` saat calon penghuni mendaftarkan periode sewa baru.
2. **Invoice Rutin Bulanan:** Dipicu oleh cron job scheduler berkala pada tanggal penagihan gedung (*billing cycle date*).

## 3. Saluran Pembayaran Ganda
* **Otomatis (Digital Gateway):** Penghuni membayar via Virtual Account atau QRIS $\rightarrow$ Webhook callback Midtrans mengubah status tagihan menjadi `paid` secara *real-time*.
* **Manual (Tunai/Transfer):** Penghuni membayar langsung ke pengelola $\rightarrow$ Pengelola memverifikasi bukti bayar dan menandai tagihan menjadi `paid` di sistem.

## 4. Denda Keterlambatan
Jika tagihan belum lunas melewati `due_date + grace_period_days`, dan fitur denda gedung aktif (`fine_enabled = true`), sistem secara otomatis menambahkan denda flat (*nominal tetap*) ke tagihan dan memicu notifikasi peringatan.
