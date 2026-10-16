# Repository Guidelines

## Project Structure & Module Organization

Machine-specific helpers belong in `.bin.local/` so they are not symlinked automatically.

## Build, Test, and Development Commands

Use `mise bootstrap -n` to preview without applying, or `mise bootstrap --only dotfiles` / `--skip packages` to run parts. On a fresh machine without Homebrew or mise, run `.bin/install.sh`, which seeds Homebrew and mise before handing off to `mise bootstrap`.

## Coding Style & Naming Conventions

Keep `mise.toml` grouped by bootstrap section with a comment header per block. `macos-app:` entries are used only for apps that must not be a cask. macOS defaults are `"<domain>" = { key = value }` with the value type (int/float/bool/string) picking the write type. In `install.sh`, prefer two-space indentation and quote every variable. New config directories should match the upstream app name (e.g. `.config/alacritty/`).

## Testing Guidelines

There is no bespoke test harness; validation equals previewing the bootstrap. Run `mise bootstrap -n` to confirm the config resolves with zero unexpected drift, and per-section dry-runs (`mise dot apply -n`, `mise bootstrap macos defaults apply -n`) when editing those blocks. For `install.sh`, run `shellcheck .bin/install.sh` (provided via Homebrew).

## Commit & Pull Request Guidelines

Recent history favors concise messages like “Update,” but please adopt an imperative summary plus context. Reference related issues or tickets, and include screenshots or terminal captures when tweaking visual configs. For PRs, describe the affected tools, note any manual steps, and confirm you ran `mise bootstrap -n` cleanly.
