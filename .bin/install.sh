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

    echo "Installing latest fzf..."
    if [ ! -d "$HOME/.fzf" ]; then
        git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
        "$HOME/.fzf/install" --key-bindings --completion --no-update-rc --no-bash --no-fish
    else
        echo "fzf already installed, updating..."
        cd "$HOME/.fzf" && git pull && ./install --key-bindings --completion --no-update-rc --no-bash --no-fish
        cd "$DOTFILES_DIR"
    fi

    if [ -f ".bin/link.sh" ]; then
        bash .bin/link.sh
    fi

    chsh -s /bin/zsh
    export SHELL=/bin/zsh
    exec $SHELL -l
    source $HOME/.fzf.zsh
else
    echo "Unsupported OS: $(uname)"
    exit 1
fi

echo "Dotfiles installation completed!"
