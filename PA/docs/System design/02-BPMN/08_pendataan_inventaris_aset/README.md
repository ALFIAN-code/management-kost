# Alur 08: Pendataan & Audit Inventaris Aset (Asset & Inventory)

> Modul Terkait: **Modul Opsional (Asset & Inventory)**  
> Sifat: **Aktif pada Properti yang Mendata Fasilitas/Perabotan Kamar Secara Rinci**

---

## 1. Deskripsi Alur
Alur ini mengatur pencatatan master aset barang per unit kamar (contoh: unit AC, kasur springbed, lemari baju, meja belajar, kunci digital), audit fisik kondisi kelayakan barang secara berkala (terutama saat momen *check-in* penghuni baru dan *check-out*), serta integrasi penanganan jika ditemukan barang rusak atau hilang.

## 2. Aktor yang Terlibat
* **Pengelola Gedung:** Pihak yang mendaftarkan barang dan memimpin inspeksi audit fisik.
* **Penghuni Kamar:** Pihak yang mendiami kamar dan memverifikasi kelengkapan barang saat serah terima kunci.

## 3. Titik Integrasi (*Plug & Play Hooks*)
1. **Ke Modul Maintenance:** Jika saat audit ditemukan barang rusak berat karena faktor usia pakai, sistem dapat memicu pembuatan tiket servis secara otomatis.
2. **Ke Modul Finance:** Jika kerusakan/kehilangan barang disebabkan oleh kelalaian penghuni saat masa sewa, sistem dapat menerbitkan tagihan ganti rugi aset ke invoice penghuni.

## 4. Status Kondisi Aset (*Asset Conditions*)
$$\text{Good (Baik)} \quad\vert\quad \text{Minor Damage (Rusak Ringan)} \quad\vert\quad \text{Heavy Damage (Rusak Berat)} \quad\vert\quad \text{Lost (Hilang)}$$
