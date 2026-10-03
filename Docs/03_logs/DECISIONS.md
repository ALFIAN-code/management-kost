# Architecture Decision Records — Federated

> Append-only. Jika keputusan berubah, buat entry baru dan tandai lama sebagai Superseded.

---

## ADR-001: Federated Docs (Global Hub → PA/docs + Project/docs)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Proyek PA-Management-kost punya 2 concerns: skripsi (PA) dan sistem (Project). 1 docs raksasa akan basi dan membingungkan AI (campur aturan Laravel vs aturan tulis kampus). User minta Docs global sebagai pointer + komprehensif di masing-masing scope.
**Keputusan:** Struktur federated 3 hub: `Docs/` (global hub) → `PA/docs/` (skripsi BAB1-5, panduan kampus, jurnal) → `Project/docs/` (hub kode) → `backend/docs` & `fe/docs`. `Docs/00_overview/ARCHITECTURE.md` jadi index pointer, bukan detail.
**Alternatif:**
- 1 docs di root saja — ditolak, karena PA dan Project punya siklus & stakeholder beda (dosen vs user Wisma)
- Docs per modul saja tanpa hub — ditolak, AI butuh entry point tunggal tiap sesi (AGENTS.md:1)
**Konsekuensi:** AI wajib baca hub dulu baru routing ke sub-docs. Update `STATE.md` di 3 level. Tradeoff: sedikit overhead, tapi mencegah campur context.

---

## ADR-002: Hybrid Skill sebagai Blocker (Primary: 1-pluto1 thesis-writing)

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** User butuh AI bisa menulis PA dengan disiplin (sitasi, template docx, klaim trace ke kode) + search jurnal awal. 6 skill dievaluasi: David-Saeteros, 1-pluto1, Imbad0202 (48k stars), Composio docx, O0000 index, AlessandroCaforio.
**Keputusan:** Primary blocker = `1-pluto1/thesis-writing-en` (code-backed thesis, citation order, source-first, validate_docx), Engine = `Composio docx` (docx-js/ooxml), Rigor = subset `Imbad0202` (deep-research + Stage 2.5 integrity gate), Arsitektur = `AlessandroCaforio` (CLAUDE.md brain + 8 rules always-on).
**Alternatif:**
- Imbad0202 full pipeline — ditolak, overkill untuk D3 (butuh ~$4-6 & hooks)
- David-Saeteros saja — ditolak, tidak cek citation numeric & code evidence
**Konsekuensi:** Aturan blocker ditanam di `PA/docs/02_reference/*` dan `Docs/00_overview/STACK.md` sebagai SOP, bukan sekadar skill install.

---

## ADR-003: Modular Monolith, bukan Microservice

**Tanggal:** 2025-09-19
**Status:** Accepted (dari proposal, dipertahankan)
**Konteks:** Wisma Amal butuh 4 domain terpisah tapi sharing data (reservasi → tagihan → notif) dan tim kecil (4 mahasiswa PA). Microservice menambah kompleksitas jaringan & deployment.
**Keputusan:** `nwidart/laravel-modules` — 1 deployment, modul loosely-coupled highly-cohesive, toggle via `modules_statuses.json`, komunikasi via ServiceInterface.
**Alternatif:** Microservice — ditolak (proposal Nofianto 2021 pakai microservice tapi hanya mobile, tidak modular; overhead tidak sebanding).
**Konsekuensi:** Scaling vertikal dulu, миграция ke microservice bisa stepwise jika properti >1 (lihat Faustino et al. 2024 di proposal).

---

## ADR-004: Flutter BLoC Semi-Clean → Full Clean untuk Fitur Baru

**Tanggal:** 2025-09-19
**Status:** Accepted
**Konteks:** Repo `fe_wisma_amal_gorontalo` saat ini semi-clean (no interface, repo concrete) untuk kecepatan. Guideline `CLEAN_ARCHITECTURE_GUIDELINE.md` menuntut full Clean (UseCase + Repository Interface).
**Keputusan:** Fitur baru wajib full Clean (BLoC → UseCase → RepositoryInterface → Impl). Fitur lama boleh stay semi-clean, refactor bertahap.
**Konsekuensi:** Konsistensi meningkat, boilerplate bertambah — acceptable untuk PA yang akan di-review dosen.

---

## ADR-005: 5 Pilar Konseptual PA (Standar I/O, Multi-Tenant Gedung, MCP AI, Clean-Modulith)

**Tanggal:** 2026-10-03
**Status:** Accepted
**Konteks:** Naskah PA perlu penguatan bobot substansi teknis dan relevansi industri modern tanpa mengubah judul skripsi yang sudah terdaftar. 4 previous work memiliki kelemahan pada fragmentasi, isolasi data gedung, ketiadaan asisten cerdas, serta format API yang inkonsisten.
**Keputusan:** Mengadopsi 5 pilar konseptual terpadu:
1. **Standar Input-Output:** Format envelope API konsisten `{status, message, data, meta, errors}` dengan FormRequest input validation dan Resource DTO serialization.
2. **Multi-Tenant System (Multi-Gedung):** Logical data isolation berbasis `building_id` dan `TenantResolverMiddleware` untuk mendukung pengelolaan multi-properti oleh satu pemilik/pengelola.
3. **Model Context Protocol (MCP) with Built-in AI:** Modul MCP Server terisolasi yang menyediakan tool-use read-only untuk asisten AI (analitik keuangan, okupansi, laporan kerusakan) dengan ground data ketat dan tenant scoping.
4. **Modular Monolith Architecture (Backend):** 3-tier module hierarchy (Infrastructure, Core, Business) dengan komunikasi tulis event-driven dan pembacaan lintas modul via Module Gateway terkontrol `ModuleGate::isActive()`.
5. **Clean Architecture (Frontend Flutter):** Pemisahan 3 layer (Presentation BLoC, Domain UseCase/Entity/Interface, Data DataSource/Model/RepoImpl) pada single codebase Flutter Web + Mobile.
**Alternatif:**
- Separate database per tenant (ditolak, overhead operasional dan sumber daya terlalu besar untuk skala wisma/kost).
- Autonomous AI agent dengan write permission (ditolak untuk fase 1 demi keamanan transaksi dan integritas data).
**Konsekuensi:** Perubahan ERD global mencakup entitas `buildings`, pembaruan BAB 1, 2, 3 naskah PA, dan perancangan skenario evaluasi multi-tenant serta AI grounding di BAB 4.

---

## ADR-006: Single Sign-On (SSO) IAM Berbasis Keycloak OpenID Connect (OIDC)

**Tanggal:** 2026-10-03
**Status:** Accepted
**Konteks:** Sistem membutuhkan mekanisme otentikasi enterprise yang aman, terpusat, dan terstandarisasi industri tanpa perlu membangun sistem credential management dan MFA dari awal. Pengguna (Pemilik, Pengelola, Penghuni) membutuhkan kemudahan akses melalui Single Sign-On (SSO) dan Social Identity Brokering (Google Login via Keycloak).
**Keputusan:** Mengadopsi **Keycloak** sebagai *Identity Provider (IdP) & Authorization Server* eksternal berbasis protokol **OpenID Connect (OIDC) / OAuth 2.0**:
1. Keycloak mengelola Realm `wisma-amal-realm`, registrasi pengguna, kredensial password, MFA, dan *Identity Brokering* (Google OAuth).
2. Frontend Flutter melakukan otentikasi ke Keycloak OIDC $\rightarrow$ menerima ID Token & Access Token JWT.
3. Backend Laravel (Modul `Auth`) memverifikasi keaslian token OIDC via *JWKS (JSON Web Key Set)* endpoint Keycloak secara stateless.
4. Backend melakukan *Just-In-Time (JIT) Provisioning* pada tabel lokal `users` (sinkronisasi `keycloak_id`, email, nama) dan mengikatkan role Spatie RBAC serta tenant scope gedung, kemudian menerbitkan token sesi internal Laravel Sanctum.
**Alternatif:**
- Otentikasi username/password manual di Laravel saja (ditolak, beban keamanan tinggi, rentan brute-force, dan tidak mendukung federated SSO).
- Firebase Auth (disebut di proposal 2025, namun digantikan oleh Keycloak karena Keycloak sepenuhnya open-source, self-hostable, dan standar enterprise OIDC/SAML2).
**Konsekuensi:** Penambahan entitas `keycloak_id` pada tabel `users`, penambahan sub-bab teori protokol OIDC/JWKS di BAB 2, pemodelan alur SSO di BAB 3, dan penambahan diagram sequence otentikasi Keycloak. Masalah ketiadaan SMTP bawaan pada Keycloak diselesaikan melalui SMTP relay / mail catcher di level server.


