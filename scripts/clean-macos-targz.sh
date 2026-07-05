#!/usr/bin/env bash
# Re-pack a macOS-created .tar.gz, stripping AppleDouble (`._*`),
# `.DS_Store`, and `__MACOSX/` entries that confuse Linux/Windows users.
#
# Usage: clean-targz.sh <input.tar.gz> [output.tar.gz]

set -euo pipefail

if [[ $# -lt 1 || $# -gt 2 ]]; then
    echo "Usage: $(basename "$0") <input.tar.gz> [output.tar.gz]" >&2
    exit 1
fi

input=$1
if [[ ! -f $input ]]; then
    echo "Error: '$input' not found." >&2
    exit 1
fi

if [[ $# -eq 2 ]]; then
    output=$2
else
    case $input in
        *.tar.gz) output="${input%.tar.gz}-clean.tar.gz" ;;
        *.tgz)    output="${input%.tgz}-clean.tgz" ;;
        *)        output="${input}-clean.tar.gz" ;;
    esac
fi

input_abs=$(cd "$(dirname "$input")" && pwd)/$(basename "$input")
output_dir=$(cd "$(dirname "$output")" && pwd)
output_abs=$output_dir/$(basename "$output")

workdir=$(mktemp -d -t clean-targz)
trap 'rm -rf "$workdir"' EXIT

extract_dir=$workdir/extracted
mkdir -p "$extract_dir"

echo "Extracting $input_abs ..."
# COPYFILE_DISABLE keeps macOS tar from re-emitting AppleDouble metadata.
COPYFILE_DISABLE=1 tar -xzf "$input_abs" -C "$extract_dir"

echo "Removing AppleDouble / DS_Store / __MACOSX entries ..."
removed=0
while IFS= read -r -d '' path; do
    rm -rf "$path"
    removed=$((removed + 1))
done < <(find "$extract_dir" \
    \( -name '._*' -o -name '.DS_Store' -o -name '__MACOSX' \) \
    -print0)
echo "  removed $removed entr$( [[ $removed -eq 1 ]] && echo y || echo ies )"

echo "Repacking to $output_abs ..."
# Pack the contents of extract_dir so we don't introduce an extra top-level
# wrapper. Use --no-xattrs / --no-mac-metadata when the local tar supports it
# (BSD tar on recent macOS does; older tars will ignore the flags via fallback).
pack_flags=(--no-xattrs)
if tar --help 2>&1 | grep -q -- '--no-mac-metadata'; then
    pack_flags+=(--no-mac-metadata)
fi

(
    cd "$extract_dir"
    COPYFILE_DISABLE=1 tar "${pack_flags[@]}" -czf "$output_abs" .
)

echo "Done. Clean archive: $output_abs"
