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
            gh \
            silversearcher-ag || echo "Some packages failed to install, continuing..."

        echo "Packages installed successfully!"
    else
        echo "Skipping package installation"
    fi

    echo "Installing latest Neovim..."
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "Latest Neovim version: $NVIM_VERSION"
    
    if [ "$(uname -m)" = "x86_64" ]; then
        NVIM_ARCH="linux64"
    elif [ "$(uname -m)" = "aarch64" ]; then
        NVIM_ARCH="linux64"
    else
        echo "Unsupported architecture: $(uname -m)"
        exit 1
    fi
    
    curl -LO "https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-${NVIM_ARCH}.tar.gz"
    tar xzf "nvim-${NVIM_ARCH}.tar.gz"
    
    if [ -d "/usr/local/nvim" ]; then
        rm -rf /usr/local/nvim
    fi
    
    mv "nvim-${NVIM_ARCH}" /usr/local/nvim
    rm "nvim-${NVIM_ARCH}.tar.gz"
    
    if ! grep -q '/usr/local/nvim/bin' "$HOME/.zshrc" 2>/dev/null; then
        echo 'export PATH="/usr/local/nvim/bin:$PATH"' >> "$HOME/.zshrc"
    fi
    
    export PATH="/usr/local/nvim/bin:$PATH"
    echo "Neovim installed successfully!"
    nvim --version

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
exit 0
