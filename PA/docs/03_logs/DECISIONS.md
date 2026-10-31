# Decisions — PA (Alasan Keputusan Naskah)

> Append-only. Alasan pilih judul/metode/rumusan. Sinkron penting ke `Docs/03_logs/DECISIONS.md`.

---

## PA-DEC-001: Judul Integrasi vs 4 Sub-judul

**Tanggal:** 2025-09-19
**Status:** Proposed (butuh pembimbing)
**Konteks:** 4 proposal punya sub-judul sendiri (Penghuni, Kamar, Keuangan, Operasional). Final PA user adalah 1 sistem terintegrasi.
**Keputusan (sementara):** 1 judul integrasi "Pengembangan Sistem Informasi Wisma Amal Gorontalo" dengan 4 domain sebagai scope BAB3. 4 sub-judul jadi section, bukan dokumen terpisah.
**Konsekuensi:** BAB1 latar belakang harus digabung (tidak copy 4 latar mentah).

---

## PA-DEC-002: Scrum sebagai Metodologi

**Tanggal:** 2025-09-19
**Status:** Accepted (dari proposal)
**Konteks:** Tim 4 orang, modul paralel, kebutuhan berubah.
**Keputusan:** Scrum 4 sprint (Mar-Jun 2025). Alternatif Waterfall (proposal terkait) ditolak karena tidak cocok untuk modular paralel.
**Konsekuensi:** BAB3 wajib ada sprint backlog + user story.

---

## PA-DEC-003: Sitasi Numeric [1]

**Tanggal:** 2025-09-19
**Status:** Accepted (sementara, konfirmasi pembimbing)
**Konteks:** Semua 4 proposal pakai numeric IEEE-like, bukan APA.
**Keputusan:** Pertahankan numeric urut kemunculan. Jika pembimbing minta APA, buat ADR baru + konversi via skill.

---

## PA-DEC-004: Ratifikasi Skema Basis Data 21 Tabel Domain Utama (Modular Monolith)

**Tanggal:** 2026-10-29  
**Status:** Accepted  
**Konteks:** Naskah BAB 3 membutuhkan konsistensi antara 17 fitur yang diratifikasi, pemodelan proses bisnis, dan skema ERD. Skema sementara 13 tabel (ADR-007) tidak memuat Dynamic RBAC, Pengeluaran, dan Servis Berkala.  
**Keputusan:** Menetapkan skema 21 tabel domain utama (24 entitas fisik) dari `erd_sistem_dinamis.html` / `erd_sistem_dinamis.png` sebagai dasar perancangan ERD pada BAB 3 §3.6.1 (Gambar 3.18).  
**Konsekuensi:** Menggantikan Gambar 3.18 dengan `erd_sistem_dinamis.png`, merinci 21 tabel pada 9 modul di teks §3.6.1, dan menyelaraskan referensi di seluruh naskah BAB 1–3.
