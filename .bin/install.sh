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
        apt update && apt install -y \
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
            silversearcher-ag || echo "Some packages failed to install, continuing..."

        echo "Installing GitHub CLI..."
        curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
        chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
        apt update
        apt install -y gh

        echo "Packages installed successfully!"
    else
        echo "Skipping package installation"
    fi

    echo "Installing latest Neovim..."
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    echo "Latest Neovim version: $NVIM_VERSION"
    
    if [ "$(uname -m)" = "x86_64" ]; then
        NVIM_ARCH="x86_64"
    elif [ "$(uname -m)" = "aarch64" ]; then
        NVIM_ARCH="arm64"
    else
        echo "Unsupported architecture: $(uname -m)"
        exit 1
    fi
    
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
    echo "Downloading Neovim tarball from: $NVIM_URL"
    
    # Download and extract tarball
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    curl -LO "$NVIM_URL"
    tar xzf "nvim-linux-${NVIM_ARCH}.tar.gz"
    
    # Remove old installation if exists
    if [ -d "/usr/local/nvim" ]; then
        echo "Removing old Neovim installation..."
        rm -rf /usr/local/nvim
    fi
    
    # Move extracted files to /usr/local/nvim
    echo "Installing to /usr/local/nvim..."
    mv "nvim-linux-${NVIM_ARCH}" /usr/local/nvim
    
    # Create symlink
    ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    
    # Cleanup
    cd -
    rm -rf "$TEMP_DIR"
    
    echo "Neovim installed successfully!"
    nvim --version

    echo "Installing Starship..."
    curl -sS https://starship.rs/install.sh | sh -s -- --yes
    
    echo "Installing Rust..."
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
    
    echo "Installing mise..."
    curl https://mise.run | sh

    echo "Installing sheldon..."
    if ! command -v sheldon &> /dev/null; then
        cargo install sheldon
    else
        echo "sheldon already installed, skipping..."
    fi

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

    echo "Changing default shell to zsh..."
    if [ "$SHELL" != "/bin/zsh" ]; then
        chsh -s /bin/zsh || echo "Could not change shell, continuing..."
    fi
else
    echo "Unsupported OS: $(uname)"
    exit 1
fi

echo "Dotfiles installation completed!"
