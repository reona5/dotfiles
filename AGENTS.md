# Repository Guidelines

## Project Structure & Module Organization
The repository tracks macOS dotfiles and bootstrap scripts. `.bin/` contains provisioning utilities such as `init.sh`, `link.sh`, and shared helpers in `utilfuncs.sh`; these are invoked by the Make targets. Application settings live under `.config/` (e.g. `.config/nvim/` for Neovim, `.config/ghostty/` for terminal profiles, `.config/mise/` for toolchains). Shell tweaks reside in `.zsh/`, `.zshrc`, and `.zshenv`, while global preferences (`.tmux.conf`, `.gitconfig`, `.npmrc`) sit alongside them. Machine-specific helpers belong in `.bin.local/` so they are not symlinked automatically.

## Build, Test, and Development Commands
`make all` orchestrates the full setup: Xcode CLI tools, dotfile linking, macOS defaults, and Homebrew bundle installs. Use `make init` to bootstrap system prerequisites only, `make link` to refresh symlinks after editing configs, `make defaults` to reapply macOS preferences, and `make brew` to sync packages declared in `.Brewfile`. On CI (`.github/workflows/main.yml`), the same sequence runs on `macos-latest`.

## Coding Style & Naming Conventions
Shell scripts default to `#!/usr/bin/env bash` with `set -ue` for strict mode. Prefer two-space indentation, `snake_case` function names, and `local` variables inside functions. Quote every variable in command substitutions, and route output through the color-aware helpers in `.bin/utilfuncs.sh` when printing status. New config directories should match the upstream app name (e.g. `.config/alacritty/`) so `link.sh` picks them up without extra wiring.

## Testing Guidelines
There is no bespoke test harness; validation equals running the provisioning commands. Dry-run changes by executing `make link` locally and inspecting the backup directory reported under `$HOME/.cache/dotbackup/`. For shell changes, run `shellcheck .bin/*.sh` (provided via Homebrew) to catch regressions and confirm `make defaults` exits cleanly on macOS.

## Commit & Pull Request Guidelines
Recent history favors concise messages like “Update,” but please adopt an imperative summary plus context (e.g. `feat: refresh ghostty theme`). Reference related issues or tickets, and include screenshots or terminal captures when tweaking visual configs. For PRs, describe the affected tools, note any manual steps, and confirm which `make` targets you exercised.
