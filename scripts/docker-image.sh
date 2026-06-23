#!/usr/bin/env bash
#
# docker-image.sh - Export a Docker image to an archive, or import one back.
#
# Usage:
#   docker-image.sh export <image[:tag]> <output.tar|output.tar.gz>
#   docker-image.sh import <input.tar|input.tar.gz>
#
# The .tar.gz extension is detected automatically and (de)compressed with gzip.

set -euo pipefail

usage() {
  echo "Usage:" >&2
  echo "  $0 export <image[:tag]> <output.tar|output.tar.gz>" >&2
  echo "  $0 import <input.tar|input.tar.gz>" >&2
  exit 1
}

# Save an image to disk, gzip-compressing when the target ends in .gz.
export_image() {
  local image="$1" output="$2"

  # Write to a temporary file first so a failed export doesn't leave a
  # partial/empty archive behind; rename to the final name only on success.
  local tmp="$output.partial"
  trap 'rm -f "$tmp"' EXIT

  if [[ "$output" == *.gz ]]; then
    echo ">> Exporting '$image' to '$output' (gzip)..."
    docker save "$image" | gzip > "$tmp"
  else
    echo ">> Exporting '$image' to '$output'..."
    docker save -o "$tmp" "$image"
  fi

  mv "$tmp" "$output"
  trap - EXIT
  echo ">> Done."
}

# Load an image from disk, decompressing when the source ends in .gz.
import_image() {
  local input="$1"

  [[ -f "$input" ]] || { echo "File not found: $input" >&2; exit 1; }

  if [[ "$input" == *.gz ]]; then
    echo ">> Importing from '$input' (gzip)..."
    gunzip -c "$input" | docker load
  else
    echo ">> Importing from '$input'..."
    docker load -i "$input"
  fi
  echo ">> Done."
}

command -v docker >/dev/null 2>&1 || { echo "Docker is not installed." >&2; exit 1; }

case "${1:-}" in
  export)
    [[ $# -eq 3 ]] || usage
    export_image "$2" "$3"
    ;;
  import)
    [[ $# -eq 2 ]] || usage
    import_image "$2"
    ;;
  *)
    usage
    ;;
esac
