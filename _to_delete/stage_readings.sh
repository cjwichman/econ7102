#!/usr/bin/env bash
# ---------------------------------------------------------------------------
# stage_readings.sh -- copy assigned reading PDFs into readings/
#
# Reads _generated/readings_manifest.tsv, produced by build/build.R, and copies
# each assigned PDF out of the course readings archive into readings/ under a
# stable, class-numbered filename. Only assigned readings are copied, which
# keeps the repository small.
#
# Usage, from the repository root:
#   ./build/stage_readings.sh /path/to/FALL2026/ECON7102/readings
#
# The default source path assumes the standard Dropbox teaching layout.
# ---------------------------------------------------------------------------

set -euo pipefail

SRC="${1:-$HOME/Dropbox/_teaching/FALL2026/ECON7102/readings}"
MANIFEST="_generated/readings_manifest.tsv"
DEST="readings"

if [[ ! -f "$MANIFEST" ]]; then
  echo "Manifest not found. Run: Rscript build/build.R" >&2
  exit 1
fi

if [[ ! -d "$SRC" ]]; then
  echo "Source readings directory not found: $SRC" >&2
  exit 1
fi

mkdir -p "$DEST"

copied=0
missing=0

# Skip the header row.
tail -n +2 "$MANIFEST" | while IFS=$'\t' read -r source_pdf served_pdf; do
  [[ -z "$source_pdf" ]] && continue
  if [[ -f "$SRC/$source_pdf" ]]; then
    cp "$SRC/$source_pdf" "$DEST/$served_pdf"
    copied=$((copied + 1))
  else
    echo "MISSING: $source_pdf" >&2
    missing=$((missing + 1))
  fi
done

echo "Staged $(find "$DEST" -name '*.pdf' | wc -l | tr -d ' ') PDFs in $DEST/"
echo "Total size: $(du -sh "$DEST" | cut -f1)"
