#!/usr/bin/env bash
# Fetch Goodreads quotes by tag and export as CSV & JSON
# Dependencies: curl, htmlq, jq

set -euo pipefail

# ---------------- Defaults ----------------
TAG="inspirational"
MAX_PAGE=5
OUTPUT_DIR="quotes"      # base output directory
OUTPUT_PREFIX=""         # prefix (default = tag)
MAX_DELAY_MS=10

usage() {
cat <<EOF
Usage:
  $(basename "$0") [options]

Options:
  -t, --tag <tag>              Tag to scrape (default: inspirational)
  -m, --max-page <number>      Max pages to fetch (default: 5)
  -o, --output-prefix <prefix> Output filename prefix (default: <tag>)
  -D, --output-dir <dir>       Base output directory (default: quotes)
  -d, --max-delay-ms <num>     Max random delay between requests, in ms (default: 10)
  -h, --help                   Show this help

Example:
  $(basename "$0") -t love -m 50
  $(basename "$0") --tag life --max-page 10 --output-prefix life_quotes --output-dir results
EOF
exit 0
}

# -------------- Parse args ---------------
while [[ $# -gt 0 ]]; do
  case "$1" in
    -t|--tag) TAG="$2"; shift 2 ;;
    -m|--max-page) MAX_PAGE="$2"; shift 2 ;;
    -o|--output-prefix) OUTPUT_PREFIX="$2"; shift 2 ;;
    -D|--output-dir) OUTPUT_DIR="$2"; shift 2 ;;
    -d|--max-delay-ms) MAX_DELAY_MS="$2"; shift 2 ;;
    -h|--help) usage ;;
    *) echo "Unknown option: $1"; usage ;;
  esac
done

[[ -z "${OUTPUT_PREFIX}" ]] && OUTPUT_PREFIX="${TAG}"

# ---------------- Derived paths ----------------
CSV_DIR="${OUTPUT_DIR}/csv"
JSON_DIR="${OUTPUT_DIR}/json"

OUTPUT_CSV="${CSV_DIR}/${OUTPUT_PREFIX}.csv"
OUTPUT_JSON="${JSON_DIR}/${OUTPUT_PREFIX}.json"

mkdir -p "$CSV_DIR" "$JSON_DIR"

TMP_FILE=$(mktemp)
trap 'rm -f "$TMP_FILE"' EXIT

# ---------------- Info ----------------
echo "Fetching Goodreads quotes:"
echo "  Tag:           $TAG"
echo "  Pages:         1–$MAX_PAGE"
echo "  Output Dir:    $OUTPUT_DIR"
echo "  Files:         $OUTPUT_CSV , $OUTPUT_JSON"
echo "  Delay:         0–${MAX_DELAY_MS} ms per request"
echo

> "$TMP_FILE"

# ---------------- Fetch loop ----------------
for i in $(seq 1 "$MAX_PAGE"); do
  echo "  → Page $i"
  URL="https://www.goodreads.com/quotes/tag/${TAG}?page=${i}"

  curl -sL "$URL" \
    -H "User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0 Safari/537.36" \
  | htmlq -t '.quoteText' \
  | awk '
      BEGIN { RS=""; ORS="\n" }
      {
        gsub(/\r/, "");
        gsub(/[[:space:]]+/, " ");
        sub(/^[[:space:]]+/, "");
        sub(/[[:space:]]+$/, "");
        if (length($0)) print $0;
      }
    ' >> "$TMP_FILE"

  # random sleep
  delay_s=$(awk -v r=$RANDOM -v max=$MAX_DELAY_MS 'BEGIN { printf "%.3f", (r % (max + 1)) / 1000 }')
  sleep "$delay_s"
done

# ---------------- Write CSV ----------------
echo
echo "Formatting CSV → $OUTPUT_CSV"
echo '"quote"' > "$OUTPUT_CSV"
while IFS= read -r line; do
  clean=$(printf "%s" "$line" | sed 's/"/""/g' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [[ -n "$clean" ]] && printf "\"%s\"\n" "$clean" >> "$OUTPUT_CSV"
done < "$TMP_FILE"

# ---------------- Write JSON ----------------
echo "Formatting JSON → $OUTPUT_JSON"
jq -R -s -c 'split("\n")[:-1] | map(select(length>0)) | map({quote: .})' < "$TMP_FILE" > "$OUTPUT_JSON"

# ---------------- Summary ----------------
count=$(grep -c . "$TMP_FILE" || true)
echo
echo "✅ Done. Extracted ${count} quotes"
echo "📁 CSV : $OUTPUT_CSV"
echo "📁 JSON: $OUTPUT_JSON"
