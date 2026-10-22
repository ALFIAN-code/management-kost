#!/bin/bash
# Pipeline pembuatan dokumen akhir Proyek Akhir.
#
#   1. merender seluruh diagram (Mermaid dan HTML) menjadi PNG
#   2. menggabungkan BAB 1 sampai BAB 5 beserta Daftar Pustaka
#   3. mengubah catatan gambar menjadi embed gambar
#   4. mengubah markdown gabungan menjadi docx memakai Pandoc
#
# Pemakaian:  ./build-docx.sh

set -e
cd "$(dirname "$0")"

MD_OUT="full_draft.md"
DOCX_OUT="ProyekAkhir_PA.docx"
TEMPLATE="template_pens.docx"      # opsional: docx berisi style heading kampus
WIDTH="15cm"                       # lebar gambar dalam dokumen

echo "1/4 Merender diagram..."
python3 figures_to_images.py --render

echo "2/4 Menggabungkan naskah..."
: > "$MD_OUT"
for folder in bab1 bab2 bab3 bab4 bab5; do
    if [ -f "$folder/README.md" ]; then
        echo "   -> $folder/README.md"
        cat "$folder/README.md" >> "$MD_OUT"
        printf '\n\n' >> "$MD_OUT"
    fi
done
if [ -f "referensi/DAFTAR_PUSTAKA_LENGKAP.md" ]; then
    echo "   -> referensi/DAFTAR_PUSTAKA_LENGKAP.md"
    cat "referensi/DAFTAR_PUSTAKA_LENGKAP.md" >> "$MD_OUT"
    printf '\n' >> "$MD_OUT"
fi

echo "3/4 Menyisipkan gambar ke naskah..."
python3 figures_to_images.py --convert "$MD_OUT" --output "$MD_OUT"

echo "4/4 Mengubah markdown menjadi docx..."
if [ -f "$TEMPLATE" ]; then
    echo "   memakai template: $TEMPLATE"
    pandoc "$MD_OUT" -o "$DOCX_OUT" \
        --reference-doc="$TEMPLATE" \
        --toc --toc-depth=2 \
        --resource-path=. \
        --metadata lang=id-ID
else
    echo "   $TEMPLATE tidak ada, memakai style bawaan Pandoc"
    pandoc "$MD_OUT" -o "$DOCX_OUT" \
        --toc --toc-depth=2 \
        --resource-path=. \
        --metadata lang=id-ID
fi

echo "Selesai: $DOCX_OUT"
