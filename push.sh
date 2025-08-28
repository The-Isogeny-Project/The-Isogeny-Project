#!/bin/bash

# Define paths
TEX_FILE="tex/main.tex"
PDF_DIR="pdf"
OLD_DIR="$PDF_DIR/old"
OUTPUT_PDF="$PDF_DIR/full.pdf"

# Compile the LaTeX file
pdflatex -output-directory=$(dirname "$TEX_FILE") "$TEX_FILE"

# Wait for the resulting PDF file
COMPILED_PDF="$(dirname "$TEX_FILE")/main.pdf"
if [ ! -f "$COMPILED_PDF" ]; then
    echo "Error: PDF file not generated."
    exit 1
fi

# Rename the previous full.pdf to old_[DATE].pdf
if [ -f "$OUTPUT_PDF" ]; then
    DATE=$(date +"%Y-%m-%d_%H-%M-%S")
    mv "$OUTPUT_PDF" "$OLD_DIR/old_$DATE.pdf"
fi

# Move the new PDF to the /pdf folder as full.pdf
mv "$COMPILED_PDF" "$OUTPUT_PDF"

# Add all new updates and push to git
git add .
git commit -m "Updated PDF and moved old version"
git push

echo "Process completed successfully."