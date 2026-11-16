#!/usr/bin/env bash
# Install NEO Desktop wallpapers into the current user's data directory.
# Unprivileged, no system modifications. Only regular local image files copied.
set -euo pipefail

source_dir="${1:-}"
if [[ -z "$source_dir" || ! -d "$source_dir" ]]; then
  printf 'Usage: bash desktop/shell/install-wallpapers.sh /path/to/extracted/wallpapers\n' >&2
  exit 2
fi

target="${XDG_DATA_HOME:-$HOME/.local/share}/neo-os/wallpapers"
mkdir -p -- "$target"
shopt -s nullglob
count=0
for src in "$source_dir"/*.webp "$source_dir"/*.png "$source_dir"/*.jpg "$source_dir"/*.jpeg; do
  [[ -f "$src" && ! -L "$src" ]] || continue
  name="$(basename -- "$src")"
  if [[ "$name" =~ ^[a-zA-Z0-9._-]+\.(webp|png|jpg|jpeg)$ ]]; then
    install -m 0644 -- "$src" "$target/$name"
    printf 'Installed: %s\n' "$name"
    count=$((count + 1))
  fi
done
if (( count == 0 )); then
  printf 'No image files found in %s\n' "$source_dir" >&2
  exit 1
fi
printf '\nInstalled %d wallpaper(s) into %s\n' "$count" "$target"
printf 'Restart NEO Desktop to discover the new wallpaper themes.\n'
