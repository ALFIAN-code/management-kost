# Project State — Kode

**Terakhir diupdate:** 2026-09-22 11:00
**Fase:** Development — backend modular aktif, frontend semi-clean; **local env ready** (MySQL Docker `wisma-mysql`, `.env` mysql, migrate+seed OK, serve :8000 verified, FE pub get + build_runner + analyze 0 error)

## Backend

- 9 modul aktif, Repository-Service pattern, Sanctum + Spatie RBAC, Midtrans terintegrasi di Finance.
- API docs via Scramble `/docs/api`.

## Frontend

- Semi-clean (concrete repo), BLoC + GetIt + AutoRoute. Fitur auth (login/register/guard/token) done.
- Target: fitur baru wajib full Clean (UseCase + interface).

## Next

1. Lengkapi `backend/docs/modules/*.md` per modul dari kode aktual.
2. Audit `fe/lib/` vs guideline — catat deviasi di `fe/docs/03_logs/DECISIONS.md`.
