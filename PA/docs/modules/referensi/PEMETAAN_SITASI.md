# Debug Sitasi — Peta Nomor, Verifikasi, dan Cacat

> **File ini tidak masuk dokumen.** Berisi catatan kerja untuk menjaga daftar pustaka tetap sehat.
> Dokumen yang dipakai pengguna hanya `DAFTAR_PUSTAKA_LENGKAP.md`.

**Terakhir diupdate:** 2026-10-18

---

## 1. Kenapa daftar lama dibuang

| Masalah | Detail |
|---|---|
| Bentrok nomor | Naskah memakai `[10]–[13]` untuk 4 proposal *previous work*, sedangkan `02_reference/DAFTAR_PUSTAKA.md` memakai nomor sama untuk 4 jurnal lain (Carvalho, Al-Qora'n, Dejonckheere, Su & Li) |
| Bentrok makna | Nomor `[3]` di naskah dipakai mendukung klaim *double booking*, isinya paper perbandingan monolitik vs terdistribusi — tidak relevan |
| Judul arXiv salah | Entri Su & Li tercatat sebagai *"Modular Monolith: Is This the Trend in Software Architecture?"*. Judul asli pada arXiv:2401.11867 adalah *"Reconsidering Modular Monoliths: Architectural Alternatives Between Monolith and Microservice"* |

---

## 2. Peta Nomor → Lokasi Pemakaian (rencana)

### BAB 1

| Nomor | Dipakai untuk | Target bagian |
|---|---|---|
| [2] | Konteks industri sewa kost | §1.1.1 |
| [1] | Definisi dan fungsi SIM | §1.1.1 |
| [3] | Status kamar dan risiko *double booking* | §1.1.1 butir 2 |
| [4] | Penagihan berkala dan pembayaran digital | §1.1.1 butir 3 |
| [5]–[8] | Empat proposal *previous work* | §1.1.2 tabel + poin 1 |
| [9] | Modular Monolith (SLR) | §1.1.2 poin 2, §1.1.3 pilar 2 |
| [10] | DDD *bounded context* | §1.1.2 poin 2 |
| [16] | Clean Architecture | §1.1.2 poin 4, §1.1.3 pilar 4 |
| [21] | MCP *read-only tool* | §1.1.2 poin 5, §1.1.3 pilar 5 |
| [22] | Pengujian berlapis | §1.1.2 poin 6, §1.1.3 pilar 6 |
| [25] | Midtrans produksi | §1.1.2 poin 7, §1.1.3 pilar 7 |
| [19] | OIDC Core 1.0 | §1.1.2 poin 8, §1.1.3 pilar 8 |
| [24] | Scrum | §1.4 butir 9 |

### BAB 2 §2.2 — 15 sub-bab deskriptif

| Sub-bab | Nomor |
|---|---|
| §2.2.1 Sistem Informasi Manajemen | [1] |
| §2.2.2 Arsitektur Modular Monolithic | [9] [10] |
| §2.2.3 NestJS | [13] |
| §2.2.4 Flutter | [15] |
| §2.2.5 Clean Architecture | [16] |
| §2.2.6 BLoC | [15] |
| §2.2.7 PostgreSQL | [17] |
| §2.2.8 Multi-Tenancy | [18] |
| §2.2.9 SSO, OIDC, Keycloak | [19] [20] |
| §2.2.10 Docker dan Docker Compose | [23] [41] |
| §2.2.11 Midtrans SNAP | [25] |
| §2.2.12 Standar Kontrak I/O REST | [36] |
| §2.2.13 Pengujian Otomatis | [22] |
| §2.2.14 Model Context Protocol | [21] |

### BAB 2 §2.3 Penelitian Terkait

| Nomor | Penelitian |
|---|---|
| [2] | Wahyuni — Codeigniter |
| [3] | JATI 2025 — Kos SidoRame12 |
| [4] | Ayyubi — Midtrans |
| [26] | JSCR 2025 — Kelola Kosku |
| [27] | JITET 2026 — Transformasi Digital Kos |
| [28] | INTECOMS 2026 — Laravel 12 |
| [5]–[8] | Empat *previous work* |

---

## 3. Daftar Cacah (harus dibereskan sebelum generate docx)

| Nomor | Masalah | Tindakan |
|---|---|---|
| [1] | ISBN belum dicantumkan; DOI lama `10.59095/jmb.v1i2.107` **tidak terdaftar di Crossref**; nama jurnal tidak dapat dipastikan | Cek langsung ke penerbit. Bila tidak ditemukan, ganti dengan buku SIM lain yang ISBN-nya jelas |
| [2] | Nama jurnal masih perlu dipastikan | Sudah diisi sebagai *J. Berkah Ilmiah* — **verifikasi ulang** |
| [5]–[8] | Metadata diambil dari `PA/old-files/Final Proposal PA.pdf` | Cocokkan nama dan NRP dengan dokumen skeleton proposal asli |
| [11] | Nomor halaman pada sumber tidak konsisten (ada yang menulis 1–8, ada 1–7) | Samakan dengan jurnal aslinya |

---

## 4. Aturan Perubahan

1. Menambah referensi: taruh di akhir daftar dengan nomor berikutnya, lalu perbarui bagian 2 file ini.
2. Menghapus referensi: dilarang. Tandai `TIDAK DIPAKAI` di bagian 2.
3. Mengubah nomor referensi: dilarang setelah naskah memakainya. Kalau dipaksa, seluruh naskah dirombak nomornya sekaligus.
4. Entri tanpa DOI atau URL belum terverifikasi dan dilarang masuk generate docx final.
5. Jumlah target 25–30 entri. Kalau lebih dari 35, dipangkas — terlalu banyak referensi membuat naskah terlihat seperti bukan hasil riset sendiri.
