# Getting Started — Federated

> Panduan setup untuk manusia & AI. Baca ini sebelum menjalankan command apa pun.

**Terakhir diupdate:** 2025-09-19

## Prasyarat

| Kebutuhan | Versi minimal | Cara cek |
|---|---|---|
| PHP | 8.2 | `php -v` |
| Composer | 2.x | `composer -v` |
| Node | 18+ | `node -v` |
| Flutter SDK | 3.8.1 | `flutter --version` |
| MySQL | 8.x | `mysql --version` |
| Docker | optional | `docker --version` |

## Install

```bash
# Backend
cd Project/backend-wismaamalgorontalo
composer install
npm install
cp .env.example .env
php artisan key:generate

# Frontend
cd ../fe_wisma_amal_gorontalo
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Setup Environment

1. Copy `Project/backend-wismaamalgorontalo/.env.example` → `.env`
2. Isi variable wajib (lihat `Docs/00_overview/ARCHITECTURE.md`):
   ```
   DB_HOST=127.0.0.1
   DB_DATABASE=wisma_amal
   MIDTRANS_SERVER_KEY=
   MIDTRANS_CLIENT_KEY=
   ```
3. Setup RBAC: `php artisan migrate --seed` (seed roles: pemilik, pengelola, penghuni)
4. Aktifkan modul: cek `modules_statuses.json` semua `true` untuk dev

## Menjalankan Project

| Perintah | Fungsi | Command |
|---|---|---|
| Dev backend | serve + queue + pail + vite | `composer run dev` (dari backend) |
| Dev frontend | run app | `flutter run` (dari fe) |
| Test backend | Pest | `php artisan test` |
| Analyze frontend | Lint | `flutter analyze` |
| Docs generate | PA docx | `python -m pip install python-docx && python scripts/generate_docx.py` |

## Verifikasi Setup Berhasil

- [ ] `GET /docs/api` (Scramble) bisa dibuka
- [ ] Login multi-role berhasil (pemilik/pengelola/penghuni)
- [ ] `flutter analyze` 0 issue
- [ ] `Docs/00_overview/STATE.md` sesuai fase

## Troubleshooting

| Masalah | Solusi |
|---|---|
| `module not found` | `php artisan module:list` & cek `modules_statuses.json` |
| `flutter analyze` error | `dart fix --apply` lalu cek lagi |
| Midtrans callback gagal | cek `MIDTRANS_SERVER_KEY` & webhook URL |

> Jika AI menemukan langkah yang belum tertulis tapi dibutuhkan, usulkan update ke file ini (L1 tanya dulu).
