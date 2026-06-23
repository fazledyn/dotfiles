#!/usr/bin/env bash
#
# install-utils.sh - Install the basic command-line utilities I use.
#
# Supports Debian 13 (amd64) via apt-get and macOS (Apple Silicon) via Homebrew.

set -euo pipefail

# Packages common to both platforms. Platform-specific extras are added below.
COMMON_PACKAGES=(
  jq fastfetch htop zip unzip tar wget curl git zsh
  screen tmux tree ncdu fzf ripgrep bat python3
)

install_debian() {
  echo ">> Installing utilities with apt-get..."

  sudo apt-get update

  # Debian-only extras and packages whose names differ:
  #   p7zip-full      provides the 7z binary
  #   openssh-client  provides ssh
  #   dnsutils        provides dig
  #   python3-*       venv, virtualenv and pip for Python 3
  local packages=("${COMMON_PACKAGES[@]}")
  packages+=(p7zip-full binutils openssh-client dnsutils)
  packages+=(python3-venv python3-virtualenv python3-pip)

  sudo apt-get install -y "${packages[@]}"
}

install_macos() {
  echo ">> Installing utilities with Homebrew..."

  # Make sure Homebrew is available before doing anything else.
  if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi

  brew update

  # macOS already ships ssh, dig and binutils; 7-zip is left out (the p7zip
  # formula is deprecated). Homebrew's python3 bundles pip and venv, so only
  # virtualenv is added on top of the common list.
  brew install "${COMMON_PACKAGES[@]}" virtualenv
}

# Dispatch based on the operating system.
case "$(uname -s)" in
  Linux)  install_debian ;;
  Darwin) install_macos ;;
  *)
    echo "Unsupported OS: $(uname -s)" >&2
    exit 1
    ;;
esac

# Install SDKMAN (same installer on Linux and macOS). It needs curl, zip and
# unzip, which are installed above.
install_sdkman() {
  if [[ -d "${SDKMAN_DIR:-$HOME/.sdkman}" ]]; then
    echo ">> SDKMAN already installed, skipping."
    return
  fi
  echo ">> Installing SDKMAN..."
  curl -s "https://get.sdkman.io" | bash
}

install_sdkman

# Install Oh My Zsh into the custom location referenced by my zshrc. The
# --keep-zshrc flag leaves my own zshrc untouched. (Plugins are handled
# separately by install-zsh-plugins.sh.)
install_oh_my_zsh() {
  local zsh_dir="$HOME/.config/oh-my-zsh"
  if [[ -d "$zsh_dir" ]]; then
    echo ">> Oh My Zsh already installed, skipping."
    return
  fi
  echo ">> Installing Oh My Zsh..."
  ZSH="$zsh_dir" sh -c "$(curl -fsSL https://install.ohmyz.sh/)" "" --unattended --keep-zshrc
}

install_oh_my_zsh

# Install NVM (Node Version Manager). NVM_DIR is exported in zsh_path and my
# zshrc already sources nvm, so we tell the installer not to touch any rc files.
install_nvm() {
  if [[ -d "${NVM_DIR:-$HOME/.nvm}" ]]; then
    echo ">> NVM already installed, skipping."
    return
  fi
  echo ">> Installing NVM..."

  # Resolve the latest release tag, falling back to a known version.
  local version
  version="$(curl -fsSL https://api.github.com/repos/nvm-sh/nvm/releases/latest \
    | grep -oE '"tag_name": *"v[0-9.]+"' | grep -oE 'v[0-9.]+' || true)"
  version="${version:-v0.40.1}"

  # PROFILE=/dev/null stops the installer from editing our shell rc files.
  curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/${version}/install.sh" \
    | PROFILE=/dev/null bash
}

install_nvm

echo ">> Done."
