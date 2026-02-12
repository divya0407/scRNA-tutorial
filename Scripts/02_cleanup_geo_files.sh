#!/bin/bash

# Base directory containing all GSM folders
BASE_DIR="~/GSE279086/raw_geo_data"

# Expand ~ manually
BASE_DIR=$(eval echo "$BASE_DIR")

cd "$BASE_DIR" || { echo "Directory not found: $BASE_DIR"; exit 1; }

echo "Cleaning GEO files in: $BASE_DIR"
echo ""

# Loop through each GSM* folder
for GSM_DIR in GSM*; do
    if [[ -d "$GSM_DIR" ]]; then
        echo "Processing $GSM_DIR ..."
        cd "$GSM_DIR" || continue

        # Delete the original (unprocessed) files
        rm -f *_barcodes_processed.tsv.gz *_features_processed.tsv.gz *_matrix_processed.mtx.gz

        # Rename the processed files to simple names
        for f in *_barcodes.tsv.gz; do
            [[ -f "$f" ]] && mv "$f" "barcodes.tsv.gz"
        done

        for f in *_features.tsv.gz; do
            [[ -f "$f" ]] && mv "$f" "features.tsv.gz"
        done

        for f in *_matrix.mtx.gz; do
            [[ -f "$f" ]] && mv "$f" "matrix.mtx.gz"
        done

        echo "   Cleaned up $GSM_DIR"
        cd ..
    fi
done

echo ""
echo " Cleanup complete! Each folder now contains:"
echo " barcodes.tsv.gz, features.tsv.gz, matrix.mtx.gz"
