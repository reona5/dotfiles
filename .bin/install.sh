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
    if command -v cargo &> /dev/null; then
      cargo install sheldon
    else
      echo "Cargo not found, skipping sheldon installation"
    fi
  else
    echo "sheldon already installed, skipping..."
  fi

  if [ -f ".bin/link.sh" ]; then
    bash .bin/link.sh
  fi

  echo "Changing default shell to zsh..."
  if [ "$SHELL" != "/bin/zsh" ]; then
    chsh -s /bin/zsh || echo "Could not change shell, continuing..."
  fi
else
  echo "Unsupported OS: $(uname)"
  exit 1
fi

if command -v pnpm &> /dev/null; then
  pnpm -g i
fi

echo "Dotfiles installation completed!"
