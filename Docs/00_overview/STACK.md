# Stack Aktif — Federated Fullstack

> File ini adalah **hasil merge** untuk stack federated PA-Management-kost. Tidak pakai 1 stack template mentah — merge manual dari `flutter.md` + backend `moodle/Laravel` + custom fullstack.

**Stack:** `fullstack` — Backend Laravel Modular + Frontend Flutter
**Tipe:** `fullstack`
**Versi:** Laravel 11.31, PHP 8.2, Flutter 3.8.1, Dart 3.8.1

**Alasan pilih stack ini:** Sistem Wisma Amal butuh modular monolith — 4 domain (Room, Resident, Finance, Operational) dalam 1 deployment tapi tetap loosely-coupled. Laravel Modules memungkinkan feature toggle per properti (kost/hotel/villa) dan memudahkan pembagian kerja tim (4 mahasiswa PA). Flutter dipilih untuk frontend penghuni (mobile-first) dengan 1 codebase untuk iOS/Android/Web.

**Stack tambahan:**
- Backend: `laravel-modular` (nwidart/laravel-modules 12, Spatie 6.23)
- Frontend: `flutter-bloc` (BLoC 9.1, GetIt 8.2, AutoRoute 11.1)

---

## Aturan Stack Terpilih

### Backend — Laravel Modular Monolith

**Sumber:** `Project/backend-wismaamalgorontalo/KNOWLEDGE_BASE.md` + `composer.json`

**Struktur Folder Wajib:**
```
backend-wismaamalgorontalo/
├── app/Traits/ApiResponse.php      # apiSuccess/apiError konsisten
├── Modules/
│   ├── Auth/ (Http, Services, Repositories/Contracts, Models, Transformers, routes/api.php)
│   ├── Room/
│   ├── Resident/
│   ├── Finance/ (Midtrans)
│   ├── Rental/
│   ├── Maintenance/
│   ├── Inventory/ (Iventory typo ada)
│   ├── Notification/
│   └── Setting/
├── config/modules.php
├── modules_statuses.json           # toggle true/false per modul
└── database/migrations/ (global User, Permission)
```

**Command Penting:**
| Perlu | Command |
|---|---|
| Install | `composer install && npm install` |
| Dev | `composer run dev` (serve + queue + pail + vite) |
| Module baru | `php artisan module:make NamaFitur` |
| Migrate modul | `php artisan module:migrate` |
| Test | `php artisan test` (Pest) |
| Pint format | `vendor/bin/pint` |
| API Docs | `GET /docs/api` (Scramble) |

**Anatomi Modul (Repository-Service):**
1. Controller → Service → RepositoryInterface → EloquentRepository
2. Service handle logika bisnis, koordinasi antar-modul via Service (jangan akses DB modul lain langsung). Contoh: `RentalService` → `FinanceService->createInvoice()`
3. Bind interface di `Providers/*ServiceProvider.php`

**Library Wajib/Dilarang:**
| Library | Status | Alasan |
|---|---|---|
| `nwidart/laravel-modules` | Wajib | Modular monolith |
| `spatie/laravel-permission` | Wajib | RBAC |
| `midtrans/midtrans-php` | Wajib | Payment |
| `dedoc/scramble` | Rekomendasi | Auto API docs |

**Catatan:** Selalu pakai `Modules\Auth\Models\User` bukan `App\Models\User`.

### Frontend — Flutter BLoC Semi-Clean → Clean

**Sumber:** `Project/fe_wisma_amal_gorontalo/CLEAN_ARCHITECTURE_GUIDELINE.md` + `README.md`

**Struktur Wajib (sesuai guideline repo, namun README pakai semi-clean):**
```
lib/
├── core/ (constant, dependency_injection, navigation, services, theme)
├── data/ (datasource, model, repository - concrete)
├── domain/ (entity)
└── presentation/ (bloc, pages, widget)
```
**Target Clean (wajib untuk fitur baru):**
```
lib/
├── core/
├── domain/
│   ├── entity/
│   ├── repository/ (abstract)
│   └── usecase/ (<fitur>/)
├── data/
│   ├── datasource/
│   ├── model/ (toEntity)
│   └── repository/ (impl)
└── presentation/
    └── bloc/ (depend on UseCase, bukan Repository)
```

**Dependency Rule:** `presentation → domain ← data`. Domain dilarang import Material/Dio. BLoC wajib depend ke UseCase, bukan RepoImpl.

**DI via GetIt:** `datasource.dart` → `repository.dart` → `usecase.dart` → `bloc.dart` di `lib/core/dependency_injection/`

**Command:**
| Perlu | Command |
|---|---|
| Install | `flutter pub get` |
| Generate | `dart run build_runner build --delete-conflicting-outputs` |
| Run | `flutter run` |
| Analyze | `flutter analyze` (wajib sebelum commit) |
| Test | `flutter test` |

**Library:** `bloc 9.1`, `flutter_bloc 9.1`, `get_it 8.2`, `dio 5.9`, `auto_route 11.1`, `flutter_secure_storage 10`, `equatable`, `formz`

**Aturan Tambahan Flutter (template):**
- Widget reuse dari `lib/modules/shared/presentation/widgets/` cek dulu via `ls`
- Jangan hardcode warna/font → pakai token `02_reference/UI_STYLE.md`
- Clean Code: 1 widget ≤50 baris, logic di usecase bukan widget

---

## Kebutuhan Dokumen untuk Stack Ini

> Tabel dipakai AI untuk selective copy saat init. Untuk federated fullstack, kebutuhan digabung.

| Kategori | File | Wajib? | Alasan |
|---|---|---|---|
| 00_overview | ARCHITECTURE.md, STATE.md, STACK.md | Ya | hub federasi |
| 01_guides | GETTING_STARTED, CONVENTIONS, GLOSSARY | Ya | onboarding federated |
| 01_guides | WORKFLOW.md | Ya | Scrum 4 sprint (khusus PA) |
| 02_reference | API_REFERENCE.md | Ya | backend endpoints |
| 02_reference | API_STYLE.md | Ya | wrapper success/data/meta |
| 02_reference | UI_STYLE.md | Opsional | tanya jika butuh design system frontend |
| 02_reference | DATABASE_SCHEMA.md | Ya | ERD global + per-modul |
| 02_reference | SECURITY_AND_DATA.md | Ya | RBAC, Midtrans, Sanctum |
| 03_logs | PROGRESS_LOG, DECISIONS, CHANGELOG | Ya | history federated |
| modules | modules/_template.md | Ya | template per modul high-level |

**Catatan Federated:** `PA/docs` butuh `DATABASE_SCHEMA` (untuk ERD di BAB3), `Project/backend/docs` butuh `DATABASE_SCHEMA`, `Project/fe/docs` tidak butuh DB tapi butuh `API_STYLE`.
