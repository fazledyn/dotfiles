#!/usr/bin/env bash
#
# link.sh - Copy the dotfiles in this repo to their real locations.
#
# This is a one-way copy (repo -> machine). Existing files at the target are
# backed up to "<target>.bak" before being overwritten. Run from anywhere;
# paths are resolved automatically.

set -euo pipefail

# Repo root is the directory this script lives in.
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Mapping of "repo path" -> "target path" (target is relative to $HOME).
# Add new dotfiles here as the repo grows.
LINKS=(
  "zshrc:.zshrc"
  "zsh_aliases:.zsh_aliases"
  "zsh_path:.zsh_path"
  "nanorc:.nanorc"
  "screenrc:.screenrc"
  "nvim.init.lua:.config/nvim/init.lua"
  "alacritty.toml:.config/alacritty/alacritty.toml"
  "config/git/config:.config/git/config"
  "config/git/template:.config/git/template"
  "config/tmux/tmux.conf:.config/tmux/tmux.conf"
)

for entry in "${LINKS[@]}"; do
  source_path="$DOTFILES_DIR/${entry%%:*}"
  target_path="$HOME/${entry#*:}"

  # Skip entries whose source is missing so a typo doesn't break the run.
  if [[ ! -e "$source_path" ]]; then
    echo "!! Missing source, skipping: $source_path"
    continue
  fi

  # Already identical? Nothing to do.
  if cmp -s "$source_path" "$target_path"; then
    echo "== Already up to date: $target_path"
    continue
  fi

  # Make sure the target's parent directory exists.
  mkdir -p "$(dirname "$target_path")"

  # Back up anything already sitting at the target.
  if [[ -e "$target_path" || -L "$target_path" ]]; then
    echo "++ Backing up: $target_path -> $target_path.bak"
    mv "$target_path" "$target_path.bak"
  fi

  cp "$source_path" "$target_path"
  echo ">> Copied: $source_path -> $target_path"
done

echo ">> Done."
