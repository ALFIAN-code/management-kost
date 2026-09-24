# Arsitektur Kode — Hub Project

**Terakhir diupdate:** 2025-09-19

## Overview

Sistem Wisma Amal: backend Laravel 11 Modular Monolith + frontend Flutter BLoC. 1 deployment backend, modul toggle via `modules_statuses.json`.

## Pointer

| Scope | Dokumen | Sumber adopt |
|---|---|---|
| Backend detail | [backend/docs/00_overview/ARCHITECTURE.md](../backend-wismaamalgorontalo/docs/00_overview/ARCHITECTURE.md) | `KNOWLEDGE_BASE.md` |
| Frontend detail | [fe/docs/00_overview/ARCHITECTURE.md](../fe_wisma_amal_gorontalo/docs/00_overview/ARCHITECTURE.md) | `CLEAN_ARCHITECTURE_GUIDELINE.md` + `README.md` |
| Global hub | [Docs/00_overview/ARCHITECTURE.md](../../Docs/00_overview/ARCHITECTURE.md) | — |

## Modul Aktif (dari modules_statuses.json)

Room, Resident, Finance, Maintenance, Auth, Inventory (+Iventory typo), Setting, Rental, Notification — semua `true`.

## Aturan Routing AI

- Ubah API/DB/migration → baca `backend/docs/` dulu.
- Ubah UI/BLoC → baca `fe/docs/` dulu.
- Ubah keduanya → baca `Docs/02_reference/INTEGRASI_ANTAR_MODUL.md` untuk kontrak.
