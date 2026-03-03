#!/usr/bin/env bash
# md_lint.sh — lightweight markdown style checker for internal_docs/
#
# Checks:
#   1. Every .md file has a top-level H1 heading.
#   2. No line exceeds 120 characters (warns, does not fail).
#   3. No trailing whitespace on any line.
#   4. File ends with a newline.
#
# Usage:
#   bash tools/md_lint.sh [DIRECTORY]
#
# Exits 0 if all checks pass, 1 if any error is found.

set -euo pipefail

TARGET="${1:-internal_docs}"
ERRORS=0
WARNINGS=0

if [[ ! -d "$TARGET" ]]; then
  echo "ERROR: directory not found: $TARGET" >&2
  exit 1
fi

echo "Linting markdown files in: $TARGET"
echo ""

while IFS= read -r -d '' filepath; do
  filename="${filepath#./}"
  file_errors=0

  # ── Check 1: H1 heading present ────────────────────────────────────────────
  if ! grep -qm1 '^# ' "$filepath"; then
    echo "  ERROR  $filename: no top-level H1 heading (line starting with '# ')"
    (( ERRORS++ )) || true
    (( file_errors++ )) || true
  fi

  # ── Check 2: line length ────────────────────────────────────────────────────
  line_num=0
  while IFS= read -r line; do
    (( line_num++ )) || true
    len="${#line}"
    if (( len > 120 )); then
      echo "  WARN   $filename:$line_num: line length $len > 120 characters"
      (( WARNINGS++ )) || true
    fi
  done < "$filepath"

  # ── Check 3: trailing whitespace ───────────────────────────────────────────
  trailing=$(grep -nP '\s+$' "$filepath" 2>/dev/null || true)
  if [[ -n "$trailing" ]]; then
    while IFS= read -r tline; do
      echo "  ERROR  $filename: trailing whitespace — $tline"
      (( ERRORS++ )) || true
      (( file_errors++ )) || true
    done <<< "$trailing"
  fi

  # ── Check 4: file ends with newline ────────────────────────────────────────
  last_char=$(tail -c 1 "$filepath" | wc -c)
  if [[ "$last_char" -eq 0 ]]; then
    echo "  ERROR  $filename: file does not end with a newline"
    (( ERRORS++ )) || true
    (( file_errors++ )) || true
  fi

  if [[ "$file_errors" -eq 0 ]]; then
    echo "  OK     $filename"
  fi

done < <(find "$TARGET" -name "*.md" -print0 | sort -z)

echo ""
echo "Result: $ERRORS error(s), $WARNINGS warning(s)"

if (( ERRORS > 0 )); then
  exit 1
fi
exit 0
