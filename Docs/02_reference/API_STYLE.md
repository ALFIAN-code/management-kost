# API Style Guide — Federated

> Kontrak style API Wisma Amal. Wajib dibaca sebelum tambah/consume endpoint. Backend Laravel, frontend Flutter.

**Terakhir diupdate:** 2025-09-19
**Tipe stack:** `fullstack` — Laravel 11 + Flutter

## Base URL & Versioning

| Env | Base URL | Contoh |
|---|---|---|
| Dev | `http://localhost:8000/api` | `GET /api/rooms` |
| Prod | `https://wisma-amal.example.com/api` |  |

Version tidak di URL (monolith internal). Breaking → ADR.

## Format Response Wrapper (Wajib)

Semua response backend pakai `App\Traits\ApiResponse`:

```json
{
  "success": true,
  "data": { },
  "message": "OK",
  "meta": { "page": 1, "limit": 20, "total": 100 }
}
```
- `success: false` → `data` null, `message` user-friendly + `errors` jika validasi
- Jangan return array di root — selalu bungkus `data`
- Flutter `Datasource` wajib parse wrapper ini, bukan langsung `response.data`

## Pagination

Query: `?page=1&limit=20&sort=created_at:desc`
Response `meta` wajib jika list.

## Filter & Search

- Filter: `?status=active&tipe=putri&from=2025-01-01`
- Search: `?q=keyword`
- Tanggal: `YYYY-MM-DD` (ISO)
- Status kamar: `kosong | dipesan | terisi_harian | terisi_bulanan | terisi_tahunan`

## Error Format

```json
{
  "success": false,
  "message": "Validasi gagal",
  "errors": { "email": ["Email sudah dipakai"] }
}
```

| Status | Arti | Aksi frontend |
|---|---|---|
| 400 | Bad request | Tampilkan `errors` |
| 401 | Unauthorized | Redirect login, refresh token |
| 403 | Forbidden (RBAC) | "Tidak punya akses" |
| 404 | Not found |  |
| 422 | Validasi Laravel | Sama 400 |
| 500 | Server error | Generic + log |

## Auth

- Header: `Authorization: Bearer <sanctum_token>`
- Login: `POST /api/auth/login` (Auth module)
- Register: `POST /api/auth/register`
- Me: `GET /api/auth/me`

Untuk proposal Firebase Auth (opsional) — override via `STACK.md`.

## Naming Endpoint (per modul)

- Plural noun: `/rooms`, `/rooms/{id}/schedules`, `/residents`, `/bills`, `/maintenances`
- Per modul di `Modules/*/routes/api.php` — prefix otomatis dari `RouteServiceProvider`
- Contoh aktuari:
  - `GET /api/rooms?page=1&status=kosong` → daftar kamar real-time
  - `POST /api/reservations` → body `{room_id, jenis_sewa, tanggal_mulai, tanggal_selesai}`
  - `GET /api/bills?status=belum_lunas` → tagihan Penghuni
  - `POST /api/maintenance` → laporan kerusakan (multipart, foto)

## Contoh Request/Response

### `GET /api/rooms?page=1&limit=20`
Header: `Authorization: Bearer xxx`
```json
{
  "success": true,
  "data": [{ "id": 1, "nomor": "A01", "tipe": "putri", "status": "kosong", "harga_harian": 100000 }],
  "meta": { "page": 1, "limit": 20, "total": 42 }
}
```

### `POST /api/reservations` (bentrok → 422)
```json
{
  "success": false,
  "message": "Periode sewa bentrok dengan jadwal aktif",
  "errors": { "tanggal_mulai": ["Bentrok dengan reservasi 2025-06-01 s/d 2025-06-30"] }
}
```

## Catatan untuk AI Agent

- Flutter: jangan hardcode base URL — ambil dari `env.dart` / `--dart-define`
- Jika tambah endpoint baru, wajib ikut wrapper & pagination, lalu update `Project/backend/docs/02_reference/API_REFERENCE.md` dan `Docs/modules/*`
- Cek `KNOWLEDGE_BASE.md:4.2` untuk trait `ApiResponse`
