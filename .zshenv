# zmodload zsh/zprof && zprof

#
# Defines environment variables.
#

export LANG=en_US.UTF-8
export EDITOR=nvim
export VISUAL=nvim
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export STARSHIP_CONFIG=$HOME/.zsh/starship/config.toml
export GPG_TTY=$TTY # commit signing ($TTY は zsh 組み込みでプロセス起動不要)
export PNPM_HOME=$HOME/.config/pnpm/5/node_modules/.bin
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PNPM_HOME:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$HOME/.bin.local:$PATH"
# Install JSR dependencies for zeno.zsh
export DENO_TLS_CA_STORE=system

# Mac mini は MacBook から herdr 越しに使うので、URL を開く挙動が起きると
# 手元では見えない Mac mini 側の Chrome が立ち上がってしまう。
# ブラウザを開かせず URL を端末に出させる ($HOST は zsh 組み込みでプロセス起動不要)
if [[ ${HOST%%.*} == silen-mac-mini ]]; then
  export BROWSER=echo
fi

[[ -f "$HOME/.cargo/env" ]] && . "$HOME/.cargo/env"
