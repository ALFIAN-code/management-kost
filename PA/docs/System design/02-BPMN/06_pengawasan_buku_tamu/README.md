# Alur 06: Pengawasan Buku Tamu (Guest Logging)

> Modul Terkait: **Modul Opsional (Guest Logging)**  
> Sifat: **Aktif pada Properti yang Menerapkan Pengawasan Tamu / Jam Malam**

---

## 1. Deskripsi Alur
Alur ini mengelola pencatatan tamu luar yang berkunjung menemui penghuni demi menjaga keamanan lingkungan hunian bersama. Alur mencakup pra-registrasi oleh penghuni, verifikasi kedatangan fisik (*check-in*), kepulangan (*check-out*), dan kalkulasi biaya inap tambahan.

## 2. Aktor yang Terlibat
* **Penghuni:** Pihak yang mendaftarkan tamu yang akan datang.
* **Tamu:** Pengunjung luar.
* **Petugas / Pengelola:** Pihak yang memverifikasi identitas tamu saat tiba dan keluar.

## 3. Integrasi ke Modul Finance (Biaya Inap)
Jika tamu menginap melewati batas waktu toleransi dan gedung memberlakukan aturan tarif tamu menginap (`guest_fee_enabled = true`), Modul Guest otomatis menerbitkan baris tagihan biaya tamu ke dalam invoice penghuni bersangkutan.
