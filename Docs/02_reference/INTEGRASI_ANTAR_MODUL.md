# Integrasi Antar Modul — Modular Monolith

**Terakhir diupdate:** 2025-09-19

## Prinsip (KNOWLEDGE_BASE.md:4.3)

Modul **tidak mengakses DB modul lain langsung**. Komunikasi via Service/Interface.

```
Controller (Module A) → Service A → Service B (Module B) → Repository B → DB B
```

Contoh: `RentalService::createReservation()` → `FinanceService::createBill()` → `NotificationService::queueReminder()`

## Daftar Ketergantungan Resmi

| Dari | Ke | Via | Trigger |
|---|---|---|---|
| Rental (Reservasi) | Room | `RoomService::checkAvailability()` | Saat validasi bentrok |
| Rental | Finance | `FinanceService::generateBill()` | Setelah reservasi `dipesan` |
| Finance | Midtrans | `MidtransService::createSnapToken()` | Saat penghuni bayar |
| Finance | Notification | `NotificationService::sendWhatsApp()` | Tagihan jatuh tempo / settlement |
| Maintenance | Notification | `NotificationService::notifyNewReport()` | Laporan baru |
| Semua | Auth | `AuthService`, `Spatie` middleware | `auth:sanctum` + `role:pemilik` |

## Feature Toggle

`modules_statuses.json` → `false` = modul nonaktif (route & provider tidak load). Untuk properti lain (hotel/villa) matikan modul yang tidak perlu.

## Aturan untuk AI

- Jika tambah cross-module call, daftarkan di tabel ini + update `DECISIONS.md` jika signifikan.
- Jangan import `Modules\Finance\Models\Tagihan` di `Modules\Room\Services` — pakai `FinanceService` interface.
