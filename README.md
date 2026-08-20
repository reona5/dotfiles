[![Dotfiles CI](https://github.com/reona5/dotfiles/actions/workflows/main.yml/badge.svg)](https://github.com/reona5/dotfiles/actions/workflows/main.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/reona5/dotfiles/blob/main/LICENSE)

# Reona's dotfiles

The dotfiles updated from time to time.
Editor: Neovim; Shell: zsh; Terminal: Alacritty, herdr; OS: MacOS

## Usage

Setup is driven by [mise](https://mise.jdx.dev/)'s native `bootstrap`. After
cloning this repository, run it from the repo root.

```shell
$ mise bootstrap
```

`mise bootstrap` applies, declaratively and idempotently, the system packages
(`[bootstrap.packages]`: brew formulae, casks, and Mac App Store apps), the
`$HOME` symlinks (`[dotfiles]`), the macOS system settings
(`[bootstrap.macos.defaults]`), the login shell (`[bootstrap.user]`), and the
runtimes from `[tools]`. Use `mise bootstrap -n` to preview without applying.

On a fresh machine, run the one-liner below. It clones this repo into the ghq
layout (`~/src/github.com/reona5/dotfiles`), seeds Homebrew and mise, then hands
off to `mise bootstrap`. No prior `git`/`ghq` install is needed — the Homebrew
installer brings the Xcode CLT (and `git`), and `ghq` itself is installed later
by `[bootstrap.packages]`.

```shell
$ curl -fsSL https://raw.githubusercontent.com/reona5/dotfiles/main/.bin/install.sh | bash
```

> Note: on a machine where GUI apps are already installed, mise's `brew-cask`
> and `mas` backends track their own state and will attempt to (re)install
> them. Preview with `mise bootstrap -n` first.

## Agent skills

`skills/` is the source of truth for my own agent skills, laid out the way
[`gh skill`](https://cli.github.com/manual/gh_skill) discovers them
(`skills/<name>/SKILL.md`). `mise bootstrap` symlinks each of them into both
`~/.claude/skills/` (Claude Code) and `~/.agents/skills/` (the Agent Skills
standard directory read by opencode and pi), so editing a file under `skills/`
takes effect immediately across all agents.

```shell
$ gh skill publish . --dry-run   # validate
$ gh skill publish . --tag v0.1.0
```

Skills from elsewhere are installed with `gh skill install` and are not vendored
here — they are declared in `mise.toml`'s `bootstrap` task and gitignored, so
`gh skill update` keeps them current.

## Claude Code

`~/.claude` is symlinked to `.config/claude/hooks/` (a historical name — it holds
the whole Claude home, not just hooks). Claude Code keeps its history, sessions
and caches there too, so `.gitignore` ignores the directory by default and picks
out only the configuration: `settings.json`, `statusline.py`, `*.sh`, and the
`skills/` symlinks.

> Note: launching `claude` even once creates `~/.claude` as a real directory,
> which blocks the symlink. On a fresh machine run `mise bootstrap` before the
> first launch.

## pi and Switchyard

[pi](https://github.com/earendil-works/pi) is managed by mise like any other
tool. It talks to open-weight models through
[NeMo Switchyard](https://github.com/NVIDIA-NeMo/Switchyard), a local router that
speaks the OpenAI API and dispatches each request to a different backend.

The router runs in a container whose definition lives in its own repo,
[reona5/switchyard-bundle](https://github.com/reona5/switchyard-bundle) — it is
client-agnostic, so the pi-side wiring stays here. `.config/pi/models.json` declares
one entry per route the bundle serves (`auto`, `auto-esc`, `weak-only`,
`strong-only`, `k3-only`); those ids have to stay in step with the bundle's
`routes.toml` or pi cannot select them.

`switchyard-serve` wraps the bundle's compose file:

```shell
$ switchyard-serve            # starts detached on 127.0.0.1:4100
$ switchyard-serve status     # or stop / logs / validate / build
$ pi
```

The routes call Fireworks, so an API key is required. The bundle only reads it
from the environment, which leaves the choice of secret store here:
`switchyard-serve` resolves it from 1Password at launch, so no plaintext key and
no `.env` ever lands on disk. Create an item holding the key — the default
reference is `op://Private/Fireworks AI/credential`, overridable per invocation:

```shell
$ FIREWORKS_API_KEY_REF="op://Work/Fireworks/credential" switchyard-serve
```

Note the tradeoff Docker imposes: the resolved key is visible in the container's
environment via `docker inspect`. Keeping it off disk is as far as this gets.

`mise.toml`'s `bootstrap` task builds the image when it is missing, and
reinstalls pi's extensions from the `packages` list in
`.config/pi/settings.json`, since only that manifest is version controlled and
not the packages themselves.

## Screenshot
<img width="5120" height="2880" alt="CleanShot 2025-09-21 at 22 56 27@2x" src="https://github.com/user-attachments/assets/debcd661-8918-4c9f-a34e-a9ce03d1c60f" />
