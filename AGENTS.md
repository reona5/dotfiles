# Repository Guidelines

## Project Structure & Module Organization

The repository tracks macOS dotfiles and environment setup, driven by mise's native `bootstrap`. `mise.toml` at the repo root holds the declarative config: `[bootstrap.packages]` (brew formulae, `brew-cask` GUI apps, `mas` App Store apps) with `[bootstrap.brew.taps]`, `[dotfiles]` ($HOME symlinks), `[bootstrap.macos.defaults]` (macOS settings), `[bootstrap.user]` (login shell), and a `[tasks.bootstrap]` escape hatch for anything non-declarative (uv, pnpm). `.bin/` keeps only the remote installer `install.sh`. Application settings live under `.config/` (e.g. `.config/nvim/` for Neovim, `.config/alacritty/` for terminal profiles, `.config/mise/config.toml` for the `[tools]` runtimes). Shell tweaks reside in `.config/zsh/` (linked to `~/.zsh`), `.zshrc`, and `.zshenv`. Machine-specific helpers belong in `.bin.local/` so they are not symlinked automatically.

## Build, Test, and Development Commands

`mise bootstrap` orchestrates the full setup declaratively and idempotently: system packages, `$HOME` symlinks, macOS defaults, login shell, and runtimes from `[tools]`. Use `mise bootstrap -n` to preview without applying, or `mise bootstrap --only dotfiles` / `--skip packages` to run parts. Per-section subcommands exist too (`mise bootstrap dotfiles apply`, `mise bootstrap macos defaults apply`, `mise dotfiles status`). On a fresh machine without Homebrew or mise, run `.bin/install.sh`, which seeds Homebrew and mise before handing off to `mise bootstrap`. On CI (`.github/workflows/main.yml`), `mise bootstrap -n` runs on `macos-latest` as a config lint.

## Coding Style & Naming Conventions

Keep `mise.toml` grouped by bootstrap section with a comment header per block. Package entries are `"manager:name" = "latest"` (`brew:`, `brew-cask:`, `mas:` by numeric ADAM ID). macOS defaults are `"<domain>" = { key = value }` with the value type (int/float/bool/string) picking the write type. Dotfile sources are repo-relative paths with `mode = "symlink"`. The `install.sh` shell script uses `#!/bin/bash` with `set -e`; prefer two-space indentation and quote every variable. New config directories should match the upstream app name (e.g. `.config/alacritty/`).

## Testing Guidelines

There is no bespoke test harness; validation equals previewing the bootstrap. Run `mise bootstrap -n` to confirm the config resolves with zero unexpected drift, and per-section dry-runs (`mise bootstrap dotfiles apply -n`, `mise bootstrap macos defaults apply -n`) when editing those blocks. For `install.sh`, run `shellcheck .bin/install.sh` (provided via Homebrew).

## Commit & Pull Request Guidelines

Recent history favors concise messages like “Update,” but please adopt an imperative summary plus context. Reference related issues or tickets, and include screenshots or terminal captures when tweaking visual configs. For PRs, describe the affected tools, note any manual steps, and confirm you ran `mise bootstrap -n` cleanly.
