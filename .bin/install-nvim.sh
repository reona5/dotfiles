#!/usr/bin/env bash
set -ue

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/utilfuncs.sh"

install_neovim_latest() {
  local os_type
  os_type="$(uname)"

  if [ "$os_type" = "Darwin" ]; then
    print_info "Installing latest Neovim on macOS..."
    
    # Check if Homebrew is installed
    if ! command -v brew &> /dev/null; then
      print_error "Homebrew is not installed. Please run 'make init' first."
      exit 1
    fi

    # Uninstall existing neovim if present
    if brew list neovim &> /dev/null; then
      print_notice "Uninstalling existing Neovim..."
      brew uninstall neovim
    fi

    # Install latest stable version
    print_info "Installing Neovim (latest stable)..."
    brew install neovim

    # Alternatively, to install HEAD version, uncomment below:
    # print_info "Installing Neovim (HEAD)..."
    # brew install neovim --HEAD

    print_success "Neovim installed successfully!"
    nvim --version

  elif [ "$os_type" = "Linux" ]; then
    print_info "Installing latest Neovim on Linux..."
    
    # Get latest version from GitHub
    NVIM_VERSION=$(curl -s https://api.github.com/repos/neovim/neovim/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
    print_info "Latest Neovim version: $NVIM_VERSION"
    
    # Determine architecture
    if [ "$(uname -m)" = "x86_64" ]; then
      NVIM_ARCH="x86_64"
    elif [ "$(uname -m)" = "aarch64" ]; then
      NVIM_ARCH="arm64"
    else
      print_error "Unsupported architecture: $(uname -m)"
      exit 1
    fi
    
    NVIM_URL="https://github.com/neovim/neovim/releases/download/${NVIM_VERSION}/nvim-linux-${NVIM_ARCH}.tar.gz"
    print_info "Downloading Neovim tarball from: $NVIM_URL"
    
    # Download and extract tarball
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    curl -LO "$NVIM_URL"
    tar xzf "nvim-linux-${NVIM_ARCH}.tar.gz"
    
    # Remove old installation if exists
    if [ -d "/usr/local/nvim" ]; then
      print_notice "Removing old Neovim installation..."
      sudo rm -rf /usr/local/nvim
    fi
    
    # Move extracted files to /usr/local/nvim
    print_info "Installing to /usr/local/nvim..."
    sudo mv "nvim-linux-${NVIM_ARCH}" /usr/local/nvim
    
    # Create symlink
    sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim
    
    # Cleanup
    cd - > /dev/null
    rm -rf "$TEMP_DIR"
    
    print_success "Neovim installed successfully!"
    nvim --version

  else
    print_error "Unsupported OS: $os_type"
    exit 1
  fi
}

install_neovim_latest
