# Konvensi Pengembangan — Federated

> Aturan penulisan kode, naming, commit, pattern. AI wajib patuh. Spesifik per stack ada di `00_overview/STACK.md`.

**Terakhir diupdate:** 2025-09-19

## Bahasa

- Kode: Inggris (variable, function, class)
- Dokumen `Docs/` & `PA/docs` & `Project/docs` : Indonesia
- Komentar: Indonesia untuk domain (Wisma Amal), Inggris untuk generic

## Naming

| Elemen | Aturan | Contoh |
|---|---|---|
| File backend | `snake_case.php`, Module `PascalCase` | `RoomController.php`, `Modules/Room/` |
| Class backend | `PascalCase` | `RoomService`, `RoomRepository` |
| Function backend | `camelCase` | `getRoomById()` |
| File Flutter | `snake_case.dart` | `room_repository.dart` |
| Class Flutter | `PascalCase` | `RoomEntity`, `GetRoomsUseCase` |
| Tabel DB | `snake_case`, plural (Laravel default) | `rooms`, `midtrans_transactions` |
| Kolom DB | `snake_case` | `created_at`, `original_tagihan_id` |
| Docs | `SNAKE_CASE` atau kebab, konsisten | `TEMPLATE_BASELINE.md` |

## Format & Lint

- Backend: `vendor/bin/pint` (Laravel Pint), `php artisan test` (Pest)
- Frontend: `dart format .`, `flutter analyze` (wajib 0 issue sebelum commit)
- Docs: tidak perlu lint, tapi jangan biarkan placeholder `[...]` tersisa

## Commit Message

Format: `[tipe] deskripsi singkat` — tipe: `feat`, `fix`, `docs`, `refactor`, `chore`, `build`

Contoh:
- `feat: tambah validasi konflik jadwal di RentalService`
- `docs: update ERD di PA/docs Bab3`
- `fix: Midtrans callback status settlement`

## Pattern Wajib

- **API Response Konsisten:** Pakai `App\Traits\ApiResponse` → `apiSuccess($data, $message)` / `apiError()`. Wrapper `{success, data, message, meta}`.
- **Repository-Service:** Controller → Service → RepositoryInterface → Eloquent. Service koordinasi antar modul, bukan controller akses DB langsung.
- **Flutter BLoC → UseCase → Repository:** BLoC dilarang depend ke RepositoryImpl, wajib via UseCase (lihat `CLEAN_ARCHITECTURE_GUIDELINE.md`).
- **Source-first untuk PA:** klaim di `PA/docs` wajib ada jejak `Project/backend/Modules/*` atau `Project/fe/lib/*` atau DOI jurnal. Tanpa bukti → `[NEEDS EVIDENCE]`.
- **Sitasi:** Numeric `[1]` urut kemunculan (disarankan untuk TI) atau APA sesuai template kampus — konsisten. Jangan mix.

## Pattern yang Dilarang

- Jangan pakai `App\Models\User` di modul — pakai `Modules\Auth\Models\User`
- Jangan query langsung di widget Flutter — pakai repository via usecase
- Jangan hardcode Midtrans key di kode — pakai `.env`
- Jangan buat `lib/features/` atau `lib/src/` di Flutter — pakai `lib/modules/` atau struktur guideline repo
- Jangan copy-paste widget — cek `lib/modules/shared/presentation/widgets/` dulu, tambah variant via param

## Handling Error & Log

- Backend: pakai `logger` + `ApiResponse::apiError`, jangan `dd()` di production
- Frontend: `logger` package, bukan `print()`
- Docs: log perubahan di `03_logs/PROGRESS_LOG.md` (append paling atas) + `STATE.md`

## Catatan untuk AI Agent

- Jika task melanggar konvensi ini, konfirmasi dulu dan catat di `DECISIONS.md` jika disetujui.
- Untuk PA writing: ikuti `PA/docs/01_guides/PANDUAN_PENULISAN.md` (aturan kampus) sebagai prioritas tertinggi, file ini sekunder.
