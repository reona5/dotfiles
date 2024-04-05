# zmodload zsh/zprof && zprof

#
# Defines environment variables.
#

export LANG=en_US.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export STARSHIP_CONFIG=$HOME/.zsh/starship/config.toml
export PNPM_HOME=$HOME/.config/pnpm
export GPG_TTY=$(tty) # commit signing

. "$HOME/.cargo/env"
