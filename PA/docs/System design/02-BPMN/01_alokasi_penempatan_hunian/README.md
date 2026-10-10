# Alur 01: Alokasi & Penempatan Hunian (Occupancy & Placement)

> Modul Terkait: **Modul Core (Occupancy & Schedule + Room Management)**  
> Sifat: **Wajib Aktif di Seluruh Skenario Gedung**

---

## 1. Deskripsi Alur
Alur ini mengatur siklus hidup penempatan seseorang ke dalam unit kamar fisik berdasarkan dimensi waktu (dari tanggal mulai hingga tanggal selesai). Alur ini bersifat independen dari urusan pembayaran uang.

## 2. Aktor yang Terlibat
* **Calon Penghuni / Staf:** Pengguna yang membutuhkan tempat tinggal.
* **Pengelola / Pengawas Gedung:** Pihak yang memvalidasi permohonan atau menugaskan kamar secara langsung.
* **Sistem (Modul Schedule & Room):** Melakukan kalkulasi kuota fisik kamar dan validasi anti-bentrok jadwal secara otomatis.

## 3. Kebijakan Pemilihan Kamar (`building_settings.booking_policy`)
Sistem mendukung 3 mode kebijakan yang dapat disesuaikan per gedung:
1. `ADMIN_ASSIGN_ONLY`: Pengelola langsung menempatkan penghuni (tanpa pemilihan mandiri oleh pengguna). Cocok untuk mes tertutup / santri baru.
2. `SELF_SERVICE_APPROVAL`: Pengguna memilih kamar, masuk ke antrean `pending_approval`, dan wajib disetujui pengelola.
3. `SELF_SERVICE_INSTANT`: Pengguna memilih kamar dan langsung terkonfirmasi (jika kuota tersedia).

## 4. Hubungan dengan Modul Finance (*Payment Barrier Gate*)
* **Jika Modul Finance AKTIF:** Alokasi masuk ke status penahanan `pending_payment`. Uang masuk (settlement) adalah syarat validator pembuka kunci ke status `confirmed`.
* **Jika Modul Finance NONAKTIF:** Barrier pembayaran dilewati (*bypassed*), alokasi langsung menuju `confirmed` (atau `pending_approval` jika butuh verifikasi admin).

## 5. Transisi Status Alokasi (*State Lifecycle*)
$$\text{Pending (Approval/Payment)} \longrightarrow \text{Confirmed/Upcoming} \xrightarrow{\text{Check-in}} \text{Active} \xrightarrow{\text{Check-out}} \text{Completed}$$
*(Status Pembatalan: $\rightarrow \text{Cancelled}$)*
