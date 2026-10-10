# Alur 03: Penanganan Tiket Kerusakan Fasilitas (Damage Reports)

> Modul Terkait: **Modul Opsional (Maintenance & Facility)**  
> Sifat: **Aktif jika Pengelola Menggunakan Manajemen Komplain Digital**

---

## 1. Deskripsi Alur
Alur ini mengelola pengaduan kerusakan fasilitas di dalam unit kamar maupun area bersama oleh penghuni, penugasan teknisi, isolasi status ketersediaan fisik kamar, hingga verifikasi penyelesaian perbaikan.

## 2. Aktor yang Terlibat
* **Penghuni:** Pihak yang menemukan kerusakan fasilitas dan mengunggah foto bukti.
* **Pengelola:** Pihak yang memvalidasi tingkat kerusakan, menugaskan teknisi, dan menutup tiket.
* **Teknisi:** Pihak pelaksana perbaikan fisik.

## 3. Isolasi Status Fisik Kamar (*Decoupled Room State*)
Jika kerusakan tergolong fatal (misal: kebocoran parah, korsleting listrik, atau sanitasi rusak total), pengelola menandai status unit fisik kamar di Modul Room menjadi `under_maintenance`. Hal ini secara otomatis mencegah Modul Schedule mengalokasikan kamar tersebut kepada calon penghuni baru tanpa mengganggu jadwal penghuni lama.

## 4. Transisi Status Tiket Komplain
$$\text{Open (Menunggu Konfirmasi)} \longrightarrow \text{In Progress (Sedang Dikerjakan)} \longrightarrow \text{Resolved (Selesai)}$$
*(Atau $\rightarrow \text{Rejected}$ jika komplain tidak valid / di luar tanggungan gedung)*
