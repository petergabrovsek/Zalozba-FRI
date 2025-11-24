#!/bin/bash

# Script to download all PDFs referenced in index.html
# Organizes files into subdirectories based on their section
# Usage: ./download_pdfs.sh [output_directory]

OUTPUT_DIR="${1:-files}"

# Create subdirectories
mkdir -p "$OUTPUT_DIR/ebooks"
mkdir -p "$OUTPUT_DIR/conference"
mkdir -p "$OUTPUT_DIR/out-of-print"

echo "Downloading PDFs..."
echo "Output directory: $OUTPUT_DIR"
echo ""

# Function to determine subdirectory based on filename
get_subdirectory() {
    local filename="$1"
    case "$filename" in
        SCORES2022.pdf|VIVID2017.pdf|VIVID2016.pdf)
            echo "conference"
            ;;
        Kavcic_PASP.pdf|Dobnikar_TIS.pdf|Dobnikar_LSS1.pdf|Dobnikar_LSS2.pdf|Dobnikar_mmr.pdf|Dobnikar_PS.pdf|Knjiga_UPO2004.pdf)
            echo "out-of-print"
            ;;
        *)
            echo "ebooks"
            ;;
    esac
}

# Function to map local filename to original URL
get_original_url() {
    local filename="$1"
    case "$filename" in
        vuk2024.pdf) echo "http://zalozba.fri.uni-lj.si/vuk2024.pdf" ;;
        golc_solina2023.pdf) echo "http://zalozba.fri.uni-lj.si/golc_solina2023.pdf" ;;
        fuerst2023.pdf) echo "http://zalozba.fri.uni-lj.si/fuerst2023.pdf" ;;
        virk2022.pdf) echo "http://zalozba.fri.uni-lj.si/virk2022.pdf" ;;
        solina2021.pdf) echo "http://zalozba.fri.uni-lj.si/solina2021.pdf" ;;
        solina2020.pdf) echo "http://zalozba.fri.uni-lj.si/solina2020.pdf" ;;
        moskon2020.pdf) echo "http://zalozba.fri.uni-lj.si/moskon2020.pdf" ;;
        bavec2019.pdf) echo "http://zalozba.fri.uni-lj.si/bavec2019.pdf" ;;
        guid2017.pdf) echo "http://zalozba.fri.uni-lj.si/guid2017.pdf" ;;
        moskon2017.pdf) echo "http://zalozba.fri.uni-lj.si/moskon2017.pdf" ;;
        smrdel2017.pdf) echo "http://zalozba.fri.uni-lj.si/smrdel2017.pdf" ;;
        oui-zbirka-nalog.pdf) echo "https://ailab.si/oui-zbirka-nalog.pdf" ;;
        la1.pdf) echo "http://matematika.fri.uni-lj.si/LA/la1.pdf" ;;
        ds.pdf) echo "http://matematika.fri.uni-lj.si/ds/ds.pdf" ;;
        matvsp.pdf) echo "http://matematika.fri.uni-lj.si/mat/matvsp.pdf" ;;
        SCORES2022.pdf) echo "http://zalozba.fri.uni-lj.si/SCORES2022.pdf" ;;
        VIVID2017.pdf) echo "http://zalozba.fri.uni-lj.si/VIVID2017.pdf" ;;
        VIVID2016.pdf) echo "http://zalozba.fri.uni-lj.si/VIVID2016.pdf" ;;
        Kavcic_PASP.pdf) echo "http://eprints.fri.uni-lj.si/3873/1/Kavcic_PASP.pdf" ;;
        Dobnikar_TIS.pdf) echo "http://eprints.fri.uni-lj.si/3865/1/Dobnikar_TIS.pdf" ;;
        Dobnikar_LSS1.pdf) echo "http://eprints.fri.uni-lj.si/3862/1/Dobnikar_LSS1.pdf" ;;
        Dobnikar_LSS2.pdf) echo "http://eprints.fri.uni-lj.si/3863/1/Dobnikar_LSS2.pdf" ;;
        Dobnikar_mmr.pdf) echo "http://eprints.fri.uni-lj.si/3864/1/Dobnikar_mmr.pdf" ;;
        Dobnikar_PS.pdf) echo "http://eprints.fri.uni-lj.si/3866/1/Dobnikar_PS.pdf" ;;
        Knjiga_UPO2004.pdf) echo "http://eprints.fri.uni-lj.si/3858/1/Knjiga_UPO2004.pdf" ;;
        *) echo "" ;;
    esac
}

# List of all PDF filenames
PDF_FILES=(
    vuk2024.pdf
    golc_solina2023.pdf
    fuerst2023.pdf
    virk2022.pdf
    solina2021.pdf
    solina2020.pdf
    moskon2020.pdf
    bavec2019.pdf
    guid2017.pdf
    moskon2017.pdf
    smrdel2017.pdf
    oui-zbirka-nalog.pdf
    la1.pdf
    ds.pdf
    matvsp.pdf
    SCORES2022.pdf
    VIVID2017.pdf
    VIVID2016.pdf
    Kavcic_PASP.pdf
    Dobnikar_TIS.pdf
    Dobnikar_LSS1.pdf
    Dobnikar_LSS2.pdf
    Dobnikar_mmr.pdf
    Dobnikar_PS.pdf
    Knjiga_UPO2004.pdf
)

# Count PDFs
PDF_COUNT=${#PDF_FILES[@]}
echo "Found $PDF_COUNT PDF file(s)"
echo ""

# Download each PDF
DOWNLOADED=0
FAILED=0

for filename in "${PDF_FILES[@]}"; do
    # Get subdirectory and URL
    subdir=$(get_subdirectory "$filename")
    original_url=$(get_original_url "$filename")
    
    if [ -z "$original_url" ]; then
        echo "⚠️  Warning: No URL mapping found for $filename, skipping"
        continue
    fi
    
    output_path="$OUTPUT_DIR/$subdir/$filename"
    
    # Skip if file already exists
    if [ -f "$output_path" ]; then
        echo "⏭️  Skipping (already exists): $subdir/$filename"
        continue
    fi
    
    echo "⬇️  Downloading: $subdir/$filename"
    echo "   From: $original_url"
    
    # Download with wget (preferred) or curl
    if command -v wget &> /dev/null; then
        if wget -q --show-progress -O "$output_path" "$original_url" 2>&1; then
            echo "   ✅ Success"
            ((DOWNLOADED++))
        else
            echo "   ❌ Failed"
            rm -f "$output_path"
            ((FAILED++))
        fi
    elif command -v curl &> /dev/null; then
        if curl -s -L -o "$output_path" "$original_url"; then
            # Check if download was successful (file exists and has content)
            if [ -s "$output_path" ]; then
                echo "   ✅ Success"
                ((DOWNLOADED++))
            else
                echo "   ❌ Failed (empty file)"
                rm -f "$output_path"
                ((FAILED++))
            fi
        else
            echo "   ❌ Failed"
            rm -f "$output_path"
            ((FAILED++))
        fi
    else
        echo "   ❌ Error: Neither wget nor curl is installed"
        exit 1
    fi
    
    echo ""
done

# Summary
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Download complete!"
echo "  Downloaded: $DOWNLOADED"
echo "  Failed: $FAILED"
echo "  Total: $PDF_COUNT"
echo "  Output directory: $OUTPUT_DIR"
echo "    - ebooks: $OUTPUT_DIR/ebooks"
echo "    - conference: $OUTPUT_DIR/conference"
echo "    - out-of-print: $OUTPUT_DIR/out-of-print"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
