# Katalog Diagram Resmi — Proyek Akhir Wisma Amal Gorontalo

> Seluruh diagram disimpan dalam subfolder terisolasi berformat **Mermaid (`.mmd`)** dan gambar hasil render beresolusi tinggi **PNG (`.png`)**.

---

## Daftar 15 Diagram Terpadu (Clean-Modulith, Multi-Tenant, MCP AI, & Keycloak SSO)

| No | Folder | File Diagram & Gambar | Letak di Naskah | Deskripsi Singkat |
|---|---|---|---|---|
| **01** | `01_arsitektur_sistem_terpadu/` | `c4_level2_container_wisma_amal.svg` ✅ FINAL (`.mmd`/`.png` lama disupersede) | BAB 2.2 & BAB 3.3.1 | Arsitektur keseluruhan Clean-Modulith, Multi-Tenant, Module Gateway, dan AI MCP — SVG final yang dipakai di docx |
| **02** | `02_hierarki_3_tier_modulith/` | `component_diagram_modular_monolith_3_tier.svg` ✅ FINAL (`hierarki_3_tier_modulith.mmd`/`.png` lama disupersede) | BAB 2.2.2 & BAB 3.3 | Aturan dependensi 3-Tier (Infrastructure, Core, Business) — SVG final yang dipakai di docx |
| **03** | `03_clean_architecture_frontend/` | `clean_architecture_frontend.mmd` / `.png` | BAB 2.2.7 & BAB 3.3 | Pola Clean Architecture Flutter (Presentation BLoC, Domain, Data) Single Codebase |
| **04** | `04_bpmn_reservasi_pembayaran/` | `bpmn_reservasi_pembayaran.mmd` / `.png` | BAB 3.4.1 | Alur BPMN 2.0 reservasi multi-gedung, penguncian jadwal, dan pembayaran Midtrans |
| **05** | `05_bpmn_komplain_pemeliharaan/` | `bpmn_komplain_pemeliharaan.mmd` / `.png` | BAB 3.4.2 | Alur BPMN 2.0 tiket komplain kerusakan fasilitas dan penguncian jadwal maintenance |
| **06** | `06_bpmn_konsultasi_ai_mcp/` | `bpmn_konsultasi_ai_mcp.mmd` / `.png` | BAB 3.4.3 | Alur BPMN 2.0 konsultasi wawasan operasional via Asisten AI berbasis protokol MCP |
| **07** | `07_use_case_global/` | `use_case_global.mmd` / `.png` | BAB 3.5.1 | Diagram Use Case Global memetakan 3 Aktor (Pemilik, Pengelola, Penghuni) & AI MCP |
| **08** | `08_dfd_level_0_context/` | `dfd_level_0_context.mmd` / `.png` | BAB 3.5.3 | Data Flow Diagram Level 0 (Diagram Konteks Sistem Manajemen Wisma) |
| **09** | `09_dfd_level_1_dekomposisi/` | `dfd_level_1_dekomposisi.mmd` / `.png` | BAB 3.5.3 | DFD Level 1 membagi 6 proses fungsional utama dan 9 data store terisolasi |
| **10** | `10_sequence_reservasi_event_driven/` | `sequence_reservasi_event_driven.mmd` / `.png` | BAB 3.3 & BAB 3.4 | Sequence Diagram Pessimistic Row Lock (`SELECT FOR UPDATE`), Event Bus, & Callback |
| **11** | `11_sequence_mcp_ai_tool_call/` | `sequence_mcp_ai_tool_call.mmd` / `.png` | BAB 2.2.5 & BAB 3.8 | Sequence Diagram JSON-RPC Tool-Use AI, Tenant Boundary Guardrail, & Grounding |
| **12** | `12_erd_multi_tenant_global/` | `erd_full_database.mmd` / `.png` ✅ AKTUAL (41 tabel pasca-migration 2026-10-03) + `erd_multi_tenant_global.mmd` / `.png` (konseptual target) + `permodule/erd_1..5_*.html` ✅ FINAL per cluster (Gambar 3.6c–3.6g, terverifikasi akurat) | BAB 3.6.1 | ERD keseluruhan aktual + ERD per 5 domain cluster untuk docx |
| **13** | `13_feature_toggle_architecture/` | `feature_toggle_architecture.mmd` / `.png` | BAB 2.2.2 & BAB 3.3 | Mekanisme runtime Dynamic Module Discovery via `modules_statuses.json` & Gate |
| **14** | `14_testing_pyramid/` | `testing_pyramid.mmd` / `.png` | BAB 2.2.10 & BAB 3.9 | Piramida Pengujian: Unit, API Contract, Tenant Isolation, dan Integration Tests |
| **15** | `15_sequence_sso_keycloak/` | `sequence_sso_keycloak.mmd` / `.png` | BAB 2.2.6 & BAB 3.3 | Sequence Diagram Otentikasi Terfederasi Keycloak OIDC, JWKS, & JIT Provisioning |

---

## Petunjuk Ekspor dan Re-render

Jika Anda ingin mengubah kode sumber diagram `.mmd`, Anda dapat me-render ulang seluruh file `.png` secara otomatis menggunakan perintah berikut:

```bash
cd PA/docs/diagrams
for file in */*.mmd; do
    out="${file%.mmd}.png"
    echo "Rendering $file -> $out"
    npx @mermaid-js/mermaid-cli -i "$file" -o "$out" -s 2 -b white
done
```
