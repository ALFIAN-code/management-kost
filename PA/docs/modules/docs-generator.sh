#!/bin/bash

# Pastikan script dijalankan dari folder 'docs'
cd "$(dirname "$0")"

OUTPUT_MD="full_draft.md"
OUTPUT_DOCX="Proposal_Proyek_Akhir_Bagus.docx"
TEMPLATE="template_pens.docx" # Siapkan file docx kosong yang style heading-nya sudah diatur

echo "🔄 Menggabungkan file Markdown..."

# Kosongkan file output jika sudah ada dari percobaan sebelumnya
> "$OUTPUT_MD"

# Daftar urutan folder secara eksplisit agar Bab 1 - Bab 5 tidak acak
FOLDERS=("bab1" "bab2" "bab3" "bab4" "bab5" "referensi")

for folder in "${FOLDERS[@]}"; do
    FILE_PATH="$folder/README.md"
    
    if [ -f "$FILE_PATH" ]; then
        echo "   -> Menambahkan $FILE_PATH"
        cat "$FILE_PATH" >> "$OUTPUT_MD"
        # Tambahkan 2 baris kosong sebagai pemisah antar bab
        echo -e "\n\n" >> "$OUTPUT_MD" 
    else
        echo "   ⚠️ Peringatan: $FILE_PATH tidak ditemukan, dilewati."
    fi
done

echo "✅ Penggabungan selesai (tersimpan di $OUTPUT_MD)"

# Proses Konversi Pandoc
if [ ! -f "$TEMPLATE" ]; then
    echo "⚠️ $TEMPLATE tidak ditemukan! Mengonversi dengan style default Pandoc..."
    pandoc "$OUTPUT_MD" -o "$OUTPUT_DOCX"
else
    echo "⚙️ Mengonversi ke DOCX menggunakan template $TEMPLATE..."
    pandoc "$OUTPUT_MD" \
        -o "$OUTPUT_DOCX" \
        --reference-doc="$TEMPLATE" \
        --toc # Hapus baris ini jika tidak ingin generate Daftar Isi otomatis
fi

echo "🎉 Selesai! Dokumen akhir: $OUTPUT_DOCX"