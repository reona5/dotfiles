#!/bin/bash
set -e

# 新規マシンでの入口。次の 1 コマンドで完結する:
#
#   curl -fsSL https://raw.githubusercontent.com/reona5/dotfiles/main/.bin/install.sh | bash
#
# ghq レイアウトのパスへ dotfiles を clone し、Homebrew と mise を用意してから
# `mise bootstrap` に環境構築を委譲する。git と ghq の事前インストールは不要
# （git は Homebrew インストーラが Xcode CLT ごと用意し、ghq はディレクトリ規約
#  なので clone 先を合わせておけば後から入る ghq がそのまま認識する）。

DOTFILES_REPO="${DOTFILES_REPO:-https://github.com/reona5/dotfiles.git}"
DOTFILES_DIR="${DOTFILES_DIR:-$HOME/src/github.com/reona5/dotfiles}"

clone_dotfiles() {
  if [ ! -d "$DOTFILES_DIR/.git" ]; then
    echo "Cloning dotfiles into $DOTFILES_DIR..."
    mkdir -p "$(dirname "$DOTFILES_DIR")"
    git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
  fi
  cd "$DOTFILES_DIR"
}

if [ "$(uname)" = "Darwin" ]; then
  echo "Running full installation for macOS..."

  # Homebrew（インストーラが Xcode CLT ごと git も用意する）
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  fi
  # 同一シェルで brew を使えるようにする
  if [ -x /opt/homebrew/bin/brew ]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
  elif [ -x /usr/local/bin/brew ]; then
    eval "$(/usr/local/bin/brew shellenv)"
  fi

  clone_dotfiles

  # mise を先に入れてから、環境構築を native bootstrap へ委譲する
  if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    brew install mise
  fi

  mise trust
  mise bootstrap
elif [ "$(uname)" = "Linux" ]; then
  echo "Running installation for Linux/DevContainer..."

  # mise（Homebrew 非依存で seed）
  if ! command -v mise &> /dev/null; then
    echo "Installing mise..."
    curl https://mise.run | sh
    export PATH="$HOME/.local/bin:$PATH"
  fi

  clone_dotfiles

  # sheldon (zsh plugin manager)
  if ! command -v sheldon &> /dev/null; then
    echo "Installing sheldon..."
    curl --proto '=https' -fLsS https://rossmacarthur.github.io/install/crate.sh | bash -s -- --repo rossmacarthur/sheldon --to ~/.local/bin
  fi

  # brew 前提の packages と macOS 向けの user(login shell) はスキップ
  mise trust
  mise bootstrap --skip packages,user
else
  echo "Unsupported OS: $(uname)"
  exit 1
fi

echo "Dotfiles installation completed!"
