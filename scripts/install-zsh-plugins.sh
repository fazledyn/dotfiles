#!/usr/bin/env bash
#
# install-zsh-plugins.sh - Install the Zsh plugins used by my zshrc.
#
# Clones the external plugins (zsh-autosuggestions, zsh-syntax-highlighting)
# into the Oh My Zsh custom directory. Oh My Zsh itself is installed by
# install-utils.sh, so run that first.

set -euo pipefail

# Match the locations referenced in zshrc.
export ZSH="$HOME/.config/oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

# External plugins as "name:git-url" pairs.
PLUGINS=(
  "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
)

# Oh My Zsh must be installed first (see install-utils.sh).
if [[ ! -d "$ZSH" ]]; then
  echo "Oh My Zsh not found at $ZSH. Run install-utils.sh first." >&2
  exit 1
fi

# Clone each plugin, or pull the latest if it's already there.
for entry in "${PLUGINS[@]}"; do
  name="${entry%%:*}"
  url="${entry#*:}"
  dest="$ZSH_CUSTOM/plugins/$name"

  if [[ -d "$dest" ]]; then
    echo ">> Updating plugin: $name"
    git -C "$dest" pull --quiet
  else
    echo ">> Installing plugin: $name"
    git clone --quiet --depth 1 "$url" "$dest"
  fi
done

echo ">> Done."
