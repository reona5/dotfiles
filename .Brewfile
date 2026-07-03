cask_args appdir: "/Applications"

# Taps
tap "github/gh"
tap "hashicorp/tap"
tap "k1LoW/tap"
tap "suzuki-shunsuke/ghalint"

# CLI Tools & Development Dependencies
brew "act"
brew "actionlint"
brew "bat"
brew "deno"
brew "devcontainer"
brew "direnv"
brew "fd"
brew "fzf"
brew "gh"
brew "ghq"
brew "git", link: true, conflicts_with: ["git"]
brew "git-lfs"
brew "jq"
brew "k1LoW/tap/git-wt", trusted: true
brew "k1LoW/tap/mo", trusted: true
brew "lazygit"
brew "lua-language-server"
brew "luajit", args: ["HEAD"]
brew "luarocks"
brew "mas"
brew "mise"
brew "mosh"
brew "fastfetch"
brew "neovim"
brew "npm"
brew "pngpaste"
brew "pnpm"
brew "ripgrep"
brew "ruby-lsp"
brew "rustup-init"
brew "sheldon"
brew "starship"
brew "hashicorp/tap/terraform", trusted: true
brew "tmux"
brew "tree"
brew "tree-sitter"
brew "tree-sitter-cli"
brew "universal-ctags"
brew "vim"
brew "yamllint"
brew "yarn"

if OS.mac?
  # Applications
  cask "alacritty"
  cask "chromedriver"
  cask "claude-code"
  cask "codex"
  cask "cleanshot"
  cask "cursor"
  cask "deepl"
  cask "discord"
  cask "docker-desktop"
  cask "firefox"
  cask "font-jetbrains-mono-nerd-font"
  cask "google-chrome"
  cask "google-japanese-ime"
  cask "gyazo"
  cask "imageoptim"
  cask "iterm2"
  cask "muzzle"
  cask "nani"
  cask "raycast"
  cask "sequel-ace"
  cask "slack"
  cask "spotify"
  cask "visual-studio-code"
  cask "zoom"

  # Mac App Store Applications
  mas "LINE", id: 539883307
  mas "RunCat", id: 1429033973
  mas "Xcode", id: 497799835
end
