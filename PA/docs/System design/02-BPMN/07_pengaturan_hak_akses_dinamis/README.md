# Alur 07: Pengaturan Hak Akses Dinamis (Dynamic RBAC Builder)

> Modul Terkait: **Modul Core (User & Access Control)**  
> Sifat: **Wajib Aktif di Seluruh Skenario Gedung**

---

## 1. Deskripsi Alur
Alur ini memberikan keleluasaan penuh bagi Pemilik/Super Admin untuk mengatur pembagian tugas staf secara dinamis (*Dynamic Role-Based Access Control*). Sistem tidak membatasi peran pada label kaku (*Owner/Admin/Resident*), melainkan memungkinkan pembuatan peran kustom tanpa perlu mengubah kode sumber aplikasi.

## 2. Struktur Izin Granular (*Permission Sets*)
Sistem menyediakan izin granular per domain:
* `room:read`, `room:write`, `room:delete`
* `occupancy:read`, `occupancy:assign`, `occupancy:checkout`
* `finance:view_invoice`, `finance:record_expense`, `finance:report`
* `maintenance:view_ticket`, `maintenance:update_ticket`
* `guest:log_entry`, `guest:checkout`

## 3. Alur Pembuatan Peran Kustom
1. Pemilik menginput nama peran baru (contoh: *"Petugas Keamanan"*, *"Teknisi Listrik"*, *"Wali Kamar Asrama"*).
2. Pemilik mencentang izin-izin relevan yang dibutuhkan.
3. Sistem menyimpan kombinasi peran tersebut dan mengikatkannya ke akun pengguna yang ditunjuk.
4. UI frontend dan API backend secara otomatis memfilter menu dan akses rute sesuai izin aktif pengguna tersebut.
