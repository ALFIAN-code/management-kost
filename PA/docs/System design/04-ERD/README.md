# Spesifikasi Model Data (ERD) — Sistem Manajemen Properti Terpadu

> **Pusat Kebenaran Model Data (*Single Source of Truth*):** Dokumen ini, visualizer interaktif [`erd_sistem_dinamis.html`](erd_sistem_dinamis.html) (✨ *Interactive HTML dengan Mode Ringkas A4 & Export SVG/PNG*), serta diagram [`ERD_SISTEM_DINAMIS.mmd`](ERD_SISTEM_DINAMIS.mmd) mendefinisikan seluruh struktur tabel, kolom, tipe data, indeks, dan batasan relasi sistem hunian dinamis (mendukung kost komersial, asrama, mes karyawan, dan pondok pesantren).

---

## 1. Prinsip Desain Model Data (ADR-007 & ADR-008)

1. **Modular Monolith & Nol FK Fisik Lintas Modul:**
   - Integritas data antar modul diisolasi secara ketat (*Loose Coupling*).
   - **FK Fisik Hanya Diperbolehkan Intra-Modul:** Contoh: `user_profiles.user_id -> users.id`, `payments.invoice_id -> invoices.id`, `occupancy_members.occupancy_id -> occupancies.id`.
   - **Komunikasi Antar Modul Menggunakan Soft Reference:** Kolom foreign ID (misal `building_id`, `room_id`, `user_id`, `occupancy_id`) disimpan sebagai integer/UUID terindeks tanpa constraint `REFERENCES` fisik di tingkat database. Integritas referensial dan kaskade dikelola pada application layer via *Domain Event Handler*.

2. **Pemisahan Tegas Antara Fisik Kamar (*Room*) dan Waktu Huni (*Occupancy/Schedule*):**
   - **`rooms`:** Menyimpan aset fisik unit (nomor kamar, lantai, tipe, kapasitas maksimal kasur/orang, dan status fisik: `available`, `occupied`, `maintenance`, `blocked`).
   - **`occupancies`:** Menyimpan kontrak/alokasi orang dan dimensi waktu (siapa penanggung jawab, tanggal mulai, tanggal selesai, tarif sewa, status alokasi: `pending_payment`, `pending_approval`, `active`, `completed`, `cancelled`).
   - **`occupancy_members`:** Memetakan slot ranjang/anggota huni per kamar. Mendukung kondisi 1 kamar 1 orang (kost privat) maupun 1 kamar banyak orang (asrama mahasiswa, barak mes karyawan, santri pesantren).

3. **Multi-Tenancy Berbasis Row-Level Scoping:**
   - Seluruh tabel domain operasional mengikat `building_id` terindeks. Hal ini memungkinkan satu instalasi sistem mengelola multi-gedung secara terisolasi tanpa kebocoran data (*data leak*).

4. **Decoupling Modul Keuangan (*Payment Barrier Gate*):**
   - Modul Keuangan (`invoices`, `payments`, `fines`, `expenses`) bersifat opsional (*plug & play*).
   - Jika `building_settings.is_finance_active = false` (asrama gratis / mes karyawan), alokasi kamar tidak menerbitkan invoice dan alokasi langsung aktif (`active`) tanpa melewati gatekeeper pembayaran.

5. **Kebijakan Pemilihan Kamar Dinamis (`building_settings.booking_policy`):**
   - `ADMIN_ASSIGN_ONLY`: Pengelola yang memplot kamar secara sepihak (mes karyawan, santri baru).
   - `SELF_SERVICE_APPROVAL`: Penghuni memilih kamar mandiri, namun menunggu konfirmasi pengelola.
   - `SELF_SERVICE_INSTANT`: Penghuni memilih kamar mandiri dan langsung terkonfirmasi (setelah bayar jika modul finance aktif).

---

## 2. Kamus Data Lengkap (Data Dictionary)

### A. Core Module: User & Access Control (M1)

#### 1. Tabel `users`
Menyimpan kredensial identitas pengguna dasar sistem.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik pengguna |
| `name` | VARCHAR(150) | NOT NULL | Nama lengkap pengguna |
| `email` | VARCHAR(191) | NOT NULL, UNIQUE, INDEX | Alamat surel aktif |
| `phone` | VARCHAR(30) | NOT NULL, INDEX | Nomor telepon / WhatsApp aktif |
| `password` | VARCHAR(255) | NOT NULL | Hash kata sandi pengguna |
| `assigned_building_id` | UUID / BIGINT | NULLABLE, INDEX | Soft-ref: gedung binaan (khusus peran Pengelola) |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Status keaktifan akun |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu pendaftaran |
| `updated_at` | TIMESTAMP | ON UPDATE CURRENT_TIMESTAMP | Waktu pembaruan akun |

#### 2. Tabel `user_profiles`
Menyimpan kelengkapan data pribadi pengguna (relasi 1:1 intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik profil |
| `user_id` | UUID / BIGINT | NOT NULL, UNIQUE, FK→users(id) ON DELETE CASCADE | Pemilik profil (FK fisik intra-modul) |
| `nik_ktp` | VARCHAR(30) | NULLABLE | Nomor Induk Kependudukan |
| `gender` | ENUM('L', 'P') | NOT NULL | Jenis kelamin |
| `address` | TEXT | NULLABLE | Alamat domisili asal |
| `emergency_contact_name` | VARCHAR(150) | NULLABLE | Nama kontak darurat |
| `emergency_contact_phone` | VARCHAR(30) | NULLABLE | Telepon kontak darurat |
| `photo_url` | VARCHAR(255) | NULLABLE | URL foto profil pengguna |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 3. Tabel `roles` & `permissions`
Menyimpan metadata hak akses dinamis (*Dynamic RBAC*).
| Tabel | Kolom Utama | Deskripsi |
|---|---|---|
| `roles` | `id`, `name` (UQ), `display_name`, `description`, `is_system` (BOOL) | Definisi peran (Owner, Admin, Resident, custom) |
| `permissions` | `id`, `name` (UQ), `module`, `description` | Daftar izin granular per fitur sistem |
| `user_roles` | `user_id` (PK,FK), `role_id` (PK,FK) | Tabel pivot keterikatan pengguna ke peran |
| `role_permissions` | `role_id` (PK,FK), `permission_id` (PK,FK) | Tabel pivot hak akses per peran |

---

### B. Core Module: Property & Building (M2)

#### 4. Tabel `buildings`
Entitas utama multi-tenancy fisik properti.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik properti/gedung |
| `code` | VARCHAR(30) | NOT NULL, UNIQUE | Kode unik gedung (misal: 'WMA-01') |
| `name` | VARCHAR(150) | NOT NULL | Nama gedung/properti |
| `address` | TEXT | NOT NULL | Alamat lengkap properti |
| `total_rooms` | INT | NOT NULL, DEFAULT 0 | Jumlah total unit kamar |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 5. Tabel `building_settings`
Menyimpan aturan operasional dinamis per gedung (relasi 1:1 intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik pengaturan |
| `building_id` | UUID / BIGINT | NOT NULL, UNIQUE, FK→buildings(id) ON DELETE CASCADE | Gedung pemilik pengaturan |
| `booking_policy` | ENUM('ADMIN_ASSIGN_ONLY', 'SELF_SERVICE_APPROVAL', 'SELF_SERVICE_INSTANT') | NOT NULL, DEFAULT 'ADMIN_ASSIGN_ONLY' | Kebijakan pemilihan kamar |
| `is_finance_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Feature toggle modul keuangan |
| `is_maintenance_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Feature toggle modul perbaikan |
| `is_guest_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Feature toggle modul buku tamu |
| `is_inventory_active` | BOOLEAN | NOT NULL, DEFAULT TRUE | Feature toggle modul inventaris |
| `curfew_time` | TIME | NULLABLE | Jam malam kunjungan tamu (misal: 22:00:00) |
| `fine_daily_rate` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Tarif denda keterlambatan per hari |
| `auto_invoice_lead_days` | INT | NOT NULL, DEFAULT 7 | H-hari terbit invoice sebelum tempo |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### C. Core Module: Physical Room Catalog (M3)

#### 6. Tabel `room_types`
Kategori tipe kamar dan fasilitas per gedung.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal tipe kamar |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung pemilik tipe |
| `name` | VARCHAR(100) | NOT NULL | Nama tipe (misal: 'Standard AC', 'VIP', 'Barak') |
| `facilities` | JSON | NULLABLE | Daftar fasilitas bawaan (AC, Kasur, Kamar Mandi) |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 7. Tabel `rooms`
Aset fisik inventaris kamar hunian.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal fisik unit kamar |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `room_type_id` | UUID / BIGINT | NOT NULL, FK→room_types(id) | Tipe kamar (FK fisik intra-modul) |
| `room_number` | VARCHAR(30) | NOT NULL | Nomor/kode pintu kamar (misal: 'A101') |
| `floor` | INT | NOT NULL, DEFAULT 1 | Posisi lantai gedung |
| `capacity` | INT | NOT NULL, DEFAULT 1 | Kapasitas maksimal orang/ranjang |
| `physical_status` | ENUM('available', 'occupied', 'maintenance', 'blocked') | NOT NULL, DEFAULT 'available' | Status fisik kamar saat ini |
| `base_price` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Tarif sewa patokan dasar per bulan |
| `description` | TEXT | NULLABLE | Keterangan spesifik kamar |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 8. Tabel `room_images`
Foto dokumentasi unit kamar (relasi 1:N intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal foto |
| `room_id` | UUID / BIGINT | NOT NULL, FK→rooms(id) ON DELETE CASCADE | Kamar pemilik foto (FK fisik intra-modul) |
| `image_url` | VARCHAR(255) | NOT NULL | URL berkas gambar |
| `is_primary` | BOOLEAN | NOT NULL, DEFAULT FALSE | Penanda foto sampul utama |
| `sort_order` | INT | NOT NULL, DEFAULT 0 | Urutan tampilan gambar |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### D. Core Module: Occupancy & Scheduling (M4)

#### 9. Tabel `occupancies`
Alokasi dinamis penyewaan/penghunian kamar berdimensi waktu.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik alokasi sewa |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `room_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke kamar yang dihuni |
| `primary_user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke penanggung jawab kontrak |
| `start_date` | DATE | NOT NULL, INDEX | Tanggal mulai masa tinggal |
| `end_date` | DATE | NOT NULL, INDEX | Tanggal berakhir masa tinggal |
| `status` | ENUM('pending_payment', 'pending_approval', 'active', 'completed', 'cancelled') | NOT NULL, DEFAULT 'pending_approval' | Status siklus hidup alokasi |
| `agreed_price` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Tarif sewa disepakati (0 jika mes/gratis) |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 10. Tabel `occupancy_members`
Daftar individu penghuni yang menempati slot ranjang kamar (relasi 1:N intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal keanggotaan huni |
| `occupancy_id` | UUID / BIGINT | NOT NULL, FK→occupancies(id) ON DELETE CASCADE | Induk alokasi sewa (FK fisik intra-modul) |
| `user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke akun pengguna penghuni fisik |
| `slot_number` | INT | NOT NULL, DEFAULT 1 | Nomor kasur / ranjang yang ditempati |
| `check_in_at` | TIMESTAMP | NULLABLE | Waktu aktual masuk kamar |
| `check_out_at` | TIMESTAMP | NULLABLE | Waktu aktual keluar kamar |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### E. Optional Module: Finance & Billing (O1)

#### 11. Tabel `invoices`
Tagihan finansial siklus sewa kamar.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik invoice |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `occupancy_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke kontrak alokasi sewa |
| `invoice_number` | VARCHAR(50) | NOT NULL, UNIQUE, INDEX | Nomor seri resmi (misal: 'INV/2026/10/0001') |
| `amount` | DECIMAL(12,2) | NOT NULL | Total nominal tagihan (pokok + denda) |
| `due_date` | DATE | NOT NULL, INDEX | Tanggal batas akhir pembayaran |
| `issued_date` | DATE | NOT NULL | Tanggal terbit invoice |
| `status` | ENUM('unpaid', 'paid', 'expired', 'cancelled') | NOT NULL, DEFAULT 'unpaid' | Status pembayaran tagihan |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 12. Tabel `payments`
Pencatatan mutasi transaksi pembayaran (relasi 1:N intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik pembayaran |
| `invoice_id` | UUID / BIGINT | NOT NULL, FK→invoices(id) ON DELETE CASCADE | Tagihan yang dibayar (FK fisik intra-modul) |
| `payment_method` | ENUM('midtrans_va', 'midtrans_qris', 'manual_transfer', 'cash') | NOT NULL | Kanal metode pembayaran |
| `amount` | DECIMAL(12,2) | NOT NULL | Nominal dana yang dibayarkan |
| `status` | ENUM('pending', 'settlement', 'deny', 'expire', 'refund') | NOT NULL, DEFAULT 'pending' | Status penyelesaian dana |
| `transaction_time` | TIMESTAMP | NULLABLE | Waktu transaksi dicatat gateway / admin |
| `proof_url` | VARCHAR(255) | NULLABLE | Berkas foto/PDF struk bukti bayar |
| `gateway_reference_id` | VARCHAR(100) | NULLABLE, INDEX | Order ID / Transaction ID dari Midtrans |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 13. Tabel `fines`
Pencatatan sanksi denda keterlambatan atau perusakan properti.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik denda |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `occupancy_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke alokasi sewa terhukum |
| `reason` | ENUM('late_payment', 'damage_penalty', 'violation') | NOT NULL | Dasar penagihan denda |
| `amount` | DECIMAL(12,2) | NOT NULL | Besaran denda yang dikenakan |
| `status` | ENUM('unpaid', 'paid', 'waived') | NOT NULL, DEFAULT 'unpaid' | Status tagihan denda |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 14. Tabel `expenses`
Arus kas keluar operasional gedung secara riil.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal unik pengeluaran |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung terkait |
| `category` | ENUM('listrik_air', 'kebersihan', 'perbaikan', 'operasional') | NOT NULL | Kategori beban pengeluaran |
| `amount` | DECIMAL(12,2) | NOT NULL | Nominal uang yang dikeluarkan |
| `expense_date` | DATE | NOT NULL, INDEX | Tanggal transaksi pengeluaran |
| `description` | TEXT | NOT NULL | Rincian keperluan pengeluaran |
| `receipt_url` | VARCHAR(255) | NULLABLE | Foto nota/bon pembelian fisik |
| `recorded_by_user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke staf/pengelola pencatat |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### F. Optional Module: Facility Maintenance (O2)

#### 15. Tabel `damage_reports`
Tiket aduan kerusakan fasilitas dari penghuni atau staf.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal tiket kerusakan |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `room_id` | UUID / BIGINT | NULLABLE, INDEX | Soft-ref ke kamar (null jika fasilitas umum) |
| `reporter_user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke pelapor aduan |
| `title` | VARCHAR(150) | NOT NULL | Judul keluhan kerusakan |
| `description` | TEXT | NOT NULL | Penjelasan detail kronologi kerusakan |
| `photo_url` | VARCHAR(255) | NULLABLE | Foto bukti fisik kerusakan |
| `priority` | ENUM('low', 'medium', 'high', 'emergency') | NOT NULL, DEFAULT 'medium' | Derajat urgensi penanganan |
| `status` | ENUM('submitted', 'approved', 'in_progress', 'completed', 'rejected') | NOT NULL, DEFAULT 'submitted' | Tahapan penanganan tiket |
| `cost_estimate` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Estimasi biaya perbaikan teknisi |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 16. Tabel `damage_report_logs`
Catatan jejak riwayat proses tiket perbaikan (relasi 1:N intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal log tiket |
| `damage_report_id` | UUID / BIGINT | NOT NULL, FK→damage_reports(id) ON DELETE CASCADE | Tiket induk aduan (FK fisik intra-modul) |
| `actor_user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke pengguna pengubah status |
| `previous_status` | VARCHAR(50) | NOT NULL | Status tiket sebelum diubah |
| `new_status` | VARCHAR(50) | NOT NULL | Status tiket setelah diubah |
| `notes` | TEXT | NULLABLE | Catatan teknis pekerjaan teknisi |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Jejak waktu perubahan |

#### 17. Tabel `maintenance_schedules`
Agenda jadwal pemeliharaan fasilitas berkala (*Preventive Maintenance*).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal agenda pemeliharaan |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `target_type` | ENUM('room', 'building_facility') | NOT NULL | Target objek servis |
| `target_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke ID kamar atau fasilitas |
| `service_name` | VARCHAR(150) | NOT NULL | Nama pekerjaan (misal: 'Servis AC Cuci Rutin') |
| `frequency_days` | INT | NOT NULL, DEFAULT 90 | Interval periode pengulangan hari |
| `last_service_date` | DATE | NULLABLE | Tanggal servis terakhir selesai |
| `next_service_date` | DATE | NOT NULL, INDEX | Jadwal tanggal servis berikutnya |
| `status` | ENUM('scheduled', 'due', 'completed') | NOT NULL, DEFAULT 'scheduled' | Status agenda servis |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### G. Optional Module: Asset & Inventory (O3)

#### 18. Tabel `inventories`
Katalog master barang/aset inventaris milik properti.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal master barang |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung pemilik barang |
| `item_code` | VARCHAR(50) | NOT NULL, UNIQUE, INDEX | Nomor seri/kode barcode barang |
| `item_name` | VARCHAR(150) | NOT NULL | Nama aset barang (misal: 'AC Daikin 1/2 PK') |
| `brand` | VARCHAR(100) | NULLABLE | Merk dagang manufaktur |
| `purchase_date` | DATE | NULLABLE | Tanggal pengadaan pembelian |
| `purchase_price` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Harga beli perolehan unit |
| `total_stock` | INT | NOT NULL, DEFAULT 1 | Total kuantitas barang yang dimiliki |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

#### 19. Tabel `room_inventories`
Penempatan dan kondisi fisik aset barang di dalam kamar (relasi 1:N intra-modul).
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal penempatan aset |
| `inventory_id` | UUID / BIGINT | NOT NULL, FK→inventories(id) ON DELETE CASCADE | Induk master barang (FK fisik intra-modul) |
| `room_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke kamar tempat barang diletakkan |
| `quantity` | INT | NOT NULL, DEFAULT 1 | Jumlah unit barang di dalam kamar |
| `condition` | ENUM('good', 'fair', 'damaged', 'lost') | NOT NULL, DEFAULT 'good' | Kondisi fisik barang hasil audit terakhir |
| `last_audit_date` | DATE | NULLABLE | Tanggal audit pengecekan fisik terakhir |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### H. Optional Module: Guest Logging (O4)

#### 20. Tabel `guests`
Pencatatan buku tamu kunjungan luar gedung.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal kunjungan tamu |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `occupancy_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke kontrak penghuni yang dikunjungi |
| `guest_name` | VARCHAR(150) | NOT NULL | Nama lengkap pengunjung |
| `guest_id_number` | VARCHAR(50) | NOT NULL | Nomor identitas identitas (KTP/SIM/Paspor) |
| `phone` | VARCHAR(30) | NOT NULL | Nomor telepon/kontak pengunjung |
| `check_in_at` | TIMESTAMP | NOT NULL | Jam & tanggal tamu tiba |
| `check_out_at` | TIMESTAMP | NULLABLE | Jam & tanggal tamu keluar meninggalkan gedung |
| `overnight_stay` | BOOLEAN | NOT NULL, DEFAULT FALSE | Menandai apakah tamu menginap |
| `stay_fee` | DECIMAL(12,2) | NOT NULL, DEFAULT 0.00 | Tarif menginap jika disyaratkan aturan |
| `status` | ENUM('checked_in', 'checked_out') | NOT NULL, DEFAULT 'checked_in' | Status kehadiran tamu |
| `created_at` / `updated_at` | TIMESTAMP | STANDARD | Jejak waktu |

---

### I. Optional Module: Notification Service (O5)

#### 21. Tabel `notification_logs`
Riwayat antrean dan pengiriman pesan notifikasi eksternal.
| Kolom | Tipe | Constraint | Deskripsi |
|---|---|---|---|
| `id` | UUID / BIGINT | PK, AUTO_INCREMENT | Pengenal log notifikasi |
| `building_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke gedung |
| `recipient_user_id` | UUID / BIGINT | NOT NULL, INDEX | Soft-ref ke pengguna penerima pesan |
| `channel` | ENUM('whatsapp', 'email', 'in_app') | NOT NULL | Saluran kanal komunikasi |
| `event_name` | VARCHAR(100) | NOT NULL | Nama domain event pemicu notifikasi |
| `message_payload` | TEXT | NOT NULL | Teks atau JSON isi pesan yang dikirimkan |
| `delivery_status` | ENUM('queued', 'sent', 'failed') | NOT NULL, DEFAULT 'queued' | Status keberhasilan pengiriman gateway |
| `sent_at` | TIMESTAMP | NULLABLE | Waktu pesan berhasil dikirim |
| `created_at` | TIMESTAMP | DEFAULT CURRENT_TIMESTAMP | Waktu antrean dibuat |

---

## 3. Matriks Relasi Antar-Modul (Soft Reference vs Intra-Module FK)

| Relasi Sumber | Entitas Target | Tipe Relasi | Penegakan Integritas (*Integrity Enforcement*) |
|---|---|---|---|
| `user_profiles.user_id` | `users.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `user_roles.*` / `role_permissions.*` | `roles` & `permissions` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `building_settings.building_id` | `buildings.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `rooms.room_type_id` | `room_types.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE RESTRICT` |
| `room_images.room_id` | `rooms.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `occupancy_members.occupancy_id` | `occupancies.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `payments.invoice_id` | `invoices.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `damage_report_logs.damage_report_id`| `damage_reports.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| `room_inventories.inventory_id` | `inventories.id` | **Intra-Module FK Fisik** | Database Engine `ON DELETE CASCADE` |
| **`rooms.building_id`** | `buildings.id` | **Cross-Module Soft-Ref** | Indexing + Validasi Application Service |
| **`occupancies.building_id`** | `buildings.id` | **Cross-Module Soft-Ref** | Indexing + Tenant Scope Middleware |
| **`occupancies.room_id`** | `rooms.id` | **Cross-Module Soft-Ref** | Indexing + Query via `RoomGateway` |
| **`occupancies.primary_user_id`** | `users.id` | **Cross-Module Soft-Ref** | Indexing + Query via `UserGateway` |
| **`invoices.occupancy_id`** | `occupancies.id` | **Cross-Module Soft-Ref** | Indexing + Event Bus Listener `OccupancyCreated` |
| **`damage_reports.reporter_user_id`** | `users.id` | **Cross-Module Soft-Ref** | Indexing + Query via `UserGateway` |
| **`damage_reports.room_id`** | `rooms.id` | **Cross-Module Soft-Ref** | Indexing + NullOnDelete Logic di Service |
| **`room_inventories.room_id`** | `rooms.id` | **Cross-Module Soft-Ref** | Indexing + Validasi Application Service |
| **`guests.occupancy_id`** | `occupancies.id` | **Cross-Module Soft-Ref** | Indexing + Validasi Application Service |
| **`notification_logs.recipient_user_id`**| `users.id` | **Cross-Module Soft-Ref**| Indexing + Async Event Bus Dispatcher |
