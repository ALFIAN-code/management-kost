# ERD Global — Gabungan 4 Proposal

> ERD final untuk BAB3. Sumber: Fig 3.12 (Penghuni), Fig 3.12 (Kamar), Fig 3.6 (Keuangan), Fig 3.9 (Operasional). Versi mermaid untuk draft, PNG untuk docx final.

```mermaid
erDiagram
    USERS ||--o{ RESIDENT : has
    USERS ||--o{ RESERVASI : makes
    USERS ||--o{ TAGIHAN : billed
    USERS ||--o{ LAPORAN_KERUSAKAN : reports
    ROOMS ||--o{ RESERVASI : reserved
    ROOMS ||--o{ JADWAL_KAMAR : scheduled
    ROOMS ||--o{ FOTO_KAMAR : has
    ROOMS ||--o{ INVENTARIS : contains
    RESERVASI ||--o{ TAGIHAN : generates
    TAGIHAN ||--o{ PEMBAYARAN : paid_via
    TAGIHAN ||--o{ TAGIHAN_PEMBAYARAN : pivot
    PEMBAYARAN ||--o{ TAGIHAN_PEMBAYARAN : pivot
    PEMBAYARAN ||--o{ MIDTRANS_TRANSACTION : via
    TAGIHAN ||--o{ PENGEMBALIAN_DANA : refunded
    INVENTARIS ||--o{ PENGAJUAN_PEMBELIAN : requested
    LAPORAN_KERUSAKAN ||--o{ TANGGAPAN_LAPORAN : replied
    NOTIFIKASI }o--|| USERS : sent_to
    USER_ROLE }o--|| USERS : assigns
```

## Catatan Desain

- `laporan_kerusakan.room_id` nullable (fasilitas umum vs kamar).
- `tagihan.original_tagihan_id` self-ref untuk perpanjangan bulanan.
- `midtrans_transaction` = tabel baru krusial (order_id unique, snap_token, expired_at).
- `tagihan_pembayaran` pivot many-to-many (1 bayar ↔ N tagihan, retry support).
- Lihat `Docs/02_reference/DATABASE_SCHEMA.md` untuk kolom lengkap + `Project/backend/docs/02_reference/DATABASE_SCHEMA.md` untuk migration aktual.
