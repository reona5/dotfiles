#!/bin/bash
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOTFILES_DIR"

if [ "$(uname)" = "Darwin" ]; then
  echo "Running full installation for macOS..."
  make
elif [ "$(uname)" = "Linux" ]; then
  echo "Running installation for Linux/DevContainer..."

  # Install sheldon (zsh plugin manager)
  echo "Installing sheldon..."
  if ! command -v sheldon &> /dev/null; then
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
    export SHELDON_CONFIG_FILE="$DOTFILES_DIR/.config/sheldon/plugins.toml"
  else
    echo "sheldon already installed, skipping..."
  fi

  if [ -f ".bin/link.sh" ]; then
    bash .bin/link.sh
  fi
else
  echo "Unsupported OS: $(uname)"
  exit 1
fi

# Install uv (python package manager)
echo "Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh

if command -v mise &> /dev/null; then
  mise trust
  # mise --yes install
fi

if command -v pnpm &> /dev/null; then
  pnpm -g i
fi

# Change default shell to zsh (skip in DevContainer or if already zsh)
current_shell=$(basename "$SHELL")
if [ "$current_shell" != "zsh" ]; then
  # Check if we're in a DevContainer or similar environment
  if [ -n "${REMOTE_CONTAINERS:-}" ] || [ -n "${CODESPACES:-}" ] || [ -f "/.dockerenv" ]; then
    echo "DevContainer/Docker environment detected, skipping shell change..."
  else
    echo "Changing default shell to zsh..."
    if command -v chsh &> /dev/null; then
      chsh -s "$(command -v zsh)" 2>/dev/null || echo "Could not change shell (may require password), continuing..."
    else
      echo "chsh command not available, skipping shell change..."
    fi
  fi
else
  echo "Shell is already zsh, skipping..."
fi

echo "Dotfiles installation completed!"
