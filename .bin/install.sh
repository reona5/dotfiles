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

if command -v mise &> /dev/null; then
  mise trust
  # mise --yes install
fi

if command -v pnpm &> /dev/null; then
  pnpm -g i
fi

echo "Changing default shell to zsh..."
if [ "$SHELL" != "/bin/zsh" ]; then
  chsh -s /bin/zsh || echo "Could not change shell, continuing..."
fi

echo "Dotfiles installation completed!"
