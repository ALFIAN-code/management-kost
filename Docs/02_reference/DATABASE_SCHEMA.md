# Skema Database — Wisma Amal Gorontalo (Hasil Audit Aktual)

> Sumber kebenaran skema aktual per 2026-10-03 (diaudit dari seluruh `database/migrations/` + `Modules/*/database/migrations/` dan model Eloquent). Detail kolom lengkap per tabel ada di kamus data BAB 3 §3.6.

**Terakhir diupdate:** 2026-10-03
**Database:** MySQL 8.x (produksi) / SQLite (dev & testing — catatan: ada drift skema, lihat §5)

## 1. Inventaris Tabel Aktual per Modul (39 tabel)

| Modul | Tabel | Kolom kunci |
|---|---|---|
| Global/Auth | `users` | `id` PK, `name`, `email` UQ, `password`, `email_verified_at?` |
| Global/Auth | `user_profiles` | `id` PK, `user_id` UQ FK→users cascade, KTP/phone/gender/alamat |
| Global | `roles`, `permissions` | Spatie + kolom custom `description`, `target` |
| Global | `model_has_roles`, `model_has_permissions`, `role_has_permissions` | Pivot Spatie (PK komposit) |
| Global | `personal_access_tokens` | Sanctum (morph `tokenable_*`) |
| Global | `password_reset_tokens`, `sessions`, `cache`, `cache_locks`, `jobs`, `job_batches`, `failed_jobs` | Infra Laravel |
| Room | `rooms` | `id` PK, `number` UQ, `price` (string!), `status`, `facilities` json?, `price_daily`? |
| Room | `room_images` | `id` PK, `room_id` FK→rooms cascade, `image_path`, `order`, `thumbnail_path?` |
| Schedule | `room_schedules` | `id` PK, `room_id` (soft-ref, tanpa FK!), `type` (sewa/maintenance/kebersihan/blokir), `status`, `start_date`, `end_date`, snapshot tenant (`tenant_name/phone/id_number/photo`, `tenant_user_id` soft-ref), `agreed_price`, `payment_scheme`, `dp_amount?` |
| Finance | `invoices` | `id` PK, `schedule_id`? soft-ref (tanpa FK), `invoice_number` UQ, `amount`, `due_date`, `status`, snapshot (`tenant_*`, `room_number`, `period_*`), `lease_id` legacy? |
| Finance | `payments` | `id` PK, `invoice_id` FK→invoices cascade, `payment_method`, `status`, `snap_token?`, `payment_data` (text/array), `midtrans_fee` |
| Finance | `expenses`, `fixed_expense_entries` | Beban fleksibel + beban rutin (`jenis/bulan/tahun` UQ) |
| Finance | `fines`, `fine_invoice` | Denda (`tenant_user_id` FK→users cascade, `schedule_id` soft-ref) + pivot denda↔invoice |
| Finance | `refund_requests` | `schedule_id` FK→room_schedules cascade, `payment_id` FK→payments cascade |
| Finance | `finance_active_tenants` | Cache snapshot: `schedule_id` UQ (tanpa FK!), `tenant_*` |
| Maintenance | `maintenance_requests` | `id` PK, `room_id`? FK→rooms nullOnDelete, `reporter_user_id`? soft-ref, `title`, `status` enum |
| Maintenance | `maintenance_request_images`, `maintenance_request_updates`, `maintenance_update_images` | Foto + jejak penanganan (FK cascade berantai) |
| Maintenance | `maintenance_schedules`, `maintenance_schedule_updates` | Jadwal pembersihan/perawatan + updatenya (beda dari `room_schedules`!) |
| Guest | `guests` | `id` PK, `user_id`? soft-ref, `schedule_reference_id`? soft-ref, `name`, check-in/out, `charge_amount` |
| Guest | `guest_bills` | `guest_id` FK→guests cascade, `bill_number` UQ, `amount`, `status` |
| Guest | `guest_active_contexts` | Cache konteks tamu aktif (semua soft-ref) |
| Inventory | `inventories` | `name`, `quantity`, `condition`, `purchase_price?` (tanpa FK ke rooms!) |
| Notification | `notification_logs` | `type`, `target_phone`, `message_body`, `status`, `is_read` (tanpa FK ke users!) |
| Setting | `app_settings` | `key` UQ, `value` text? |
| Setting | `bank_accounts` | Rekening bank properti |
| Setting | `feature_toggles` | Self-ref `parent_id` FK cascade?, `key` UQ |
| Setting | `feature_toggle_logs` | `toggle_id` FK cascade, `user_id` soft-ref (tanpa `updated_at`!) |

## 2. FK Fisik Lintas-Modul (disengaja, sedikit)

`user_profiles→users`, `payments→invoices`, `fine_invoice→fines/invoices`, `refund_requests→room_schedules/payments`, `maintenance_requests→rooms` (nullOnDelete), `maintenance_*updates→users`, `fines→users`, `guest_bills→guests`, `room_images→rooms`, `feature_toggle_logs→feature_toggles`. Selebihnya **soft-ref/snapshot tanpa FK fisik** (sesuai aturan event-driven/deptrac: `room_schedules.room_id`, `invoices.schedule_id`, `fines.schedule_id`, cache `finance_active_tenants`/`guest_active_contexts`).

## 3. Temuan Audit Penting (2026-10-03)

1. **`building_id` = 0 hasil di seluruh repo.** Multi-tenancy multi-gedung murni desain target (ERD konseptual + BAB 3), belum ada di kode.
2. **Kolom hantu:** `rooms.is_highlighted` difilter repository tapi migration-nya no-op → risiko SQL error; `dashboard_preferences/config` no-op serupa.
3. **Tipe menyimpang:** `rooms.price` & `price_daily` bertipe string (bukan decimal).
4. **Legacy modul mati:** `lease_id` (invoices, guests) & `resident_id` (maintenance_requests) tersisa sebagai kolom plain pasca-hapus Rental/Resident.
5. **Drift SQLite vs MySQL:** `rooms.status` ENUM diubah via raw `DB::statement` khusus MySQL (nilai `reserved` tidak ada di SQLite).

## 4. ERD Visual

- **Aktual (kode):** `PA/docs/diagrams/12_erd_multi_tenant_global/erd_full_database.mmd` / `.png` — 39 tabel + relasi FK fisik & soft-ref utama.
- **Target (desain PA):** `PA/docs/diagrams/12_erd_multi_tenant_global/erd_multi_tenant_global.mmd` / `.png` — sentral `buildings` + `keycloak_id` + `mcp_tool_logs`.

## 5. Delta Desain Target vs Kode Aktual

| Desain target (BAB 3) | Status di kode (per 2026-10-03) |
|---|---|
| Tabel `buildings` + `building_id` di 13 tabel domain + `users.assigned_building_id` | ✅ Terimplementasi via `2026_10_03_000001/000002` (soft-ref + index, tanpa FK lintas-modul) |
| `users.keycloak_id` + `auth_provider` | ✅ Terimplementasi via `2026_10_03_000003` (+ fillable `User`) |
| Tabel `mcp_tool_logs` | ✅ Terimplementasi via `2026_10_03_000004` |
| Drop FK `refund_requests.schedule_id`, `maintenance_requests.room_id` | ✅ Terimplementasi via `2026_10_03_000005` (pola defensif, no-op di SQLite) |
| `inventories.room_id`, `notification_logs.user_id` | Belum ada FK (disengaja — soft-ref) |

## 6. Migration History (lanjutan)

| Tanggal | File | Deskripsi |
|---|---|---|
| 2026-10-03 | `database/migrations/2026_10_03_000001_create_buildings_table.php` | Tabel `buildings` (Core tenant) |
| 2026-10-03 | `database/migrations/2026_10_03_000002_add_building_scope_columns.php` | `building_id` (13 tabel) + `users.assigned_building_id` |
| 2026-10-03 | `database/migrations/2026_10_03_000003_add_sso_columns_to_users_table.php` | `keycloak_id` UQ + `auth_provider` |
| 2026-10-03 | `database/migrations/2026_10_03_000004_create_mcp_tool_logs_table.php` | Tabel audit tool MCP AI |
| 2026-10-03 | `database/migrations/2026_10_03_000005_drop_cross_module_fk_constraints.php` | Lepas 2 FK lintas-modul bisnis → soft-ref |

## Untuk AI Agent

- Sebelum buat migration, baca file ini + cek `php artisan migrate:status`; perubahan aditif dulu (tambah kolom/tabel), jangan destructive-first.
- Sinkronkan perubahan ke kamus data BAB 3 §3.6 dalam sesi yang sama (AGENTS.md:3 checklist).
