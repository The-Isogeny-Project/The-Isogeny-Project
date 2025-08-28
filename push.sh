#!/bin/bash

# Define paths
TEX_FILE="tex/main.tex"
PARTS_DIR="tex/parts"
PDF_DIR="pdf"
OLD_DIR="$PDF_DIR/old"
OUTPUT_PDF="$PDF_DIR/full.pdf"

# Compile the LaTeX file
pushd "$(dirname "$TEX_FILE")" > /dev/null
pdflatex "$(basename "$TEX_FILE")"
popd > /dev/null

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

# Compile individual parts and move them to the /pdf folder
for PART_DIR in "$PARTS_DIR"/part*/; do
    PART_NAME=$(basename "$PART_DIR")
    PART_TEX="${PART_DIR}${PART_NAME}.tex"
    PART_PDF="${PDF_DIR}/${PART_NAME}.pdf"

    # Navigate to the part directory and compile the LaTeX file
    if [ -f "$PART_TEX" ]; then
        pushd "$PART_DIR" > /dev/null
        pdflatex "$PART_NAME.tex"
        popd > /dev/null

        # Move the resulting PDF to the /pdf folder
        if [ -f "${PART_DIR}${PART_NAME}.pdf" ]; then
            mv "${PART_DIR}${PART_NAME}.pdf" "$PART_PDF"
        else
            echo "Error: Failed to generate PDF for $PART_TEX"
        fi
    else
        echo "Error: LaTeX file $PART_TEX not found."
    fi
done

# Add all new updates and push to git
git add .
git commit -m "Updated PDF and moved old version"
git pull
git push

echo "Process completed successfully."


