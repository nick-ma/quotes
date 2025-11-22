#!/usr/bin/env bash
# Batch fetch Goodreads quotes for all tags in tags.md
# Dependencies: fetch_goodreads_quotes.sh

set -euo pipefail

# ---------------- Defaults ----------------
TAGS_FILE="tags.md"
FETCH_SCRIPT="./fetch_goodreads_quotes.sh"
OUTPUT_DIR="quotes"
FORCE=false
MAX_PAGE=5
MAX_DELAY_MS=10

# ---------------- Usage ----------------
usage() {
cat <<EOF
Usage:
  $(basename "$0") [options]

Options:
  -f, --force              Force re-fetch even if files already exist
  -t, --tags-file <file>   Tags file to read from (default: tags.md)
  -m, --max-page <number>  Max pages to fetch per tag (default: 5)
  -d, --max-delay-ms <num> Max random delay between requests, in ms (default: 10)
  -D, --output-dir <dir>   Base output directory (default: quotes)
  -h, --help               Show this help

Examples:
  $(basename "$0")                          # Fetch all tags, skip existing
  $(basename "$0") --force                  # Force re-fetch all tags
  $(basename "$0") -m 10 -d 50              # Fetch with custom page limit and delay
EOF
exit 0
}

# ---------------- Parse args ----------------
# Separate --force from other args
FETCH_ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    -f|--force)
      FORCE=true
      shift
      ;;
    -t|--tags-file)
      TAGS_FILE="$2"
      shift 2
      ;;
    -m|--max-page)
      MAX_PAGE="$2"
      FETCH_ARGS+=("-m" "$2")
      shift 2
      ;;
    -d|--max-delay-ms)
      MAX_DELAY_MS="$2"
      FETCH_ARGS+=("-d" "$2")
      shift 2
      ;;
    -D|--output-dir)
      OUTPUT_DIR="$2"
      FETCH_ARGS+=("-D" "$2")
      shift 2
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# ---------------- Validation ----------------
if [[ ! -f "$TAGS_FILE" ]]; then
  echo "Error: Tags file not found: $TAGS_FILE"
  exit 1
fi

if [[ ! -f "$FETCH_SCRIPT" ]]; then
  echo "Error: Fetch script not found: $FETCH_SCRIPT"
  exit 1
fi

if [[ ! -x "$FETCH_SCRIPT" ]]; then
  echo "Warning: Making fetch script executable..."
  chmod +x "$FETCH_SCRIPT"
fi

# ---------------- Derived paths ----------------
CSV_DIR="${OUTPUT_DIR}/csv"
JSON_DIR="${OUTPUT_DIR}/json"

# ---------------- Functions ----------------
check_tag_exists() {
  local tag="$1"
  local csv_file="${CSV_DIR}/${tag}.csv"
  local json_file="${JSON_DIR}/${tag}.json"
  
  if [[ -f "$csv_file" ]] && [[ -f "$json_file" ]]; then
    return 0  # Both files exist
  else
    return 1  # At least one file missing
  fi
}

fetch_tag() {
  local tag="$1"
  echo "Fetching tag: $tag"
  "$FETCH_SCRIPT" -t "$tag" "${FETCH_ARGS[@]}"
}

# ---------------- Main ----------------
echo "Batch fetching Goodreads quotes"
echo "  Tags file:    $TAGS_FILE"
echo "  Output dir:   $OUTPUT_DIR"
echo "  Max pages:    $MAX_PAGE"
echo "  Max delay:    ${MAX_DELAY_MS} ms"
echo "  Force mode:   $FORCE"
echo

# Read tags from file
if [[ ! -s "$TAGS_FILE" ]]; then
  echo "Error: Tags file is empty: $TAGS_FILE"
  exit 1
fi

total_tags=0
skipped_tags=0
fetched_tags=0
failed_tags=0

# Process each tag
while IFS= read -r tag || [[ -n "$tag" ]]; do
  # Skip empty lines and comments
  tag=$(echo "$tag" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [[ -z "$tag" ]] && continue
  [[ "$tag" =~ ^# ]] && continue
  
  total_tags=$((total_tags + 1))
  
  # Check if tag already exists
  if check_tag_exists "$tag"; then
    if [[ "$FORCE" == "true" ]]; then
      echo "[$total_tags] Tag '$tag': Files exist, but --force specified, re-fetching..."
      if fetch_tag "$tag"; then
        fetched_tags=$((fetched_tags + 1))
      else
        failed_tags=$((failed_tags + 1))
        echo "  ❌ Failed to fetch tag: $tag"
      fi
    else
      echo "[$total_tags] Tag '$tag': Already exists, skipping..."
      skipped_tags=$((skipped_tags + 1))
    fi
  else
    echo "[$total_tags] Tag '$tag': Not found, fetching..."
    if fetch_tag "$tag"; then
      fetched_tags=$((fetched_tags + 1))
    else
      failed_tags=$((failed_tags + 1))
      echo "  ❌ Failed to fetch tag: $tag"
    fi
  fi
  
  echo  # Empty line for readability
  
done < "$TAGS_FILE"

# ---------------- Summary ----------------
echo "=========================================="
echo "Summary:"
echo "  Total tags:   $total_tags"
echo "  Fetched:      $fetched_tags"
echo "  Skipped:      $skipped_tags"
echo "  Failed:       $failed_tags"
echo "=========================================="

if [[ $failed_tags -gt 0 ]]; then
  exit 1
fi

