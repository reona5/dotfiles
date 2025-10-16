#!/bin/bash
set -e

DOTFILES_DIR="${DOTFILES_DIR:-$HOME/dotfiles}"
cd "$DOTFILES_DIR"

if [ "$(uname)" = "Darwin" ]; then
    echo "Running full installation for macOS..."
    make
elif [ "$(uname)" = "Linux" ]; then
    echo "Running installation for Linux/DevContainer..."

    if command -v apt &> /dev/null; then
        echo "Installing packages via apt..."
        apt install -y \
            git \
            vim \
            neovim \
            tmux \
            ripgrep \
            fd-find \
            fzf \
            jq \
            golang \
            tree \
            bat \
            curl \
            wget \
            build-essential \
            unzip \
            direnv \
            zsh \
            silversearcher-ag || echo "Some packages failed to install, continuing..."

        echo "Packages installed successfully!"
    else
        echo "Skipping package installation"
    fi

    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
    curl https://mise.run | sh

    cargo install sheldon

    if [ -f ".bin/link.sh" ]; then
        bash .bin/link.sh
    fi

    chsh -s /bin/zsh
    export SHELL=/bin/zsh
    exec $SHELL -l
else
    echo "Unsupported OS: $(uname)"
    exit 1
fi

echo "Dotfiles installation completed!"
