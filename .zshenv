# zmodload zsh/zprof && zprof

#
# Defines environment variables.
#

export LANG=en_US.UTF-8
export XDG_CONFIG_HOME=$HOME/.config
export XDG_CACHE_HOME=$HOME/.cache
export XDG_DATA_HOME=$HOME/.local/share
export STARSHIP_CONFIG=$HOME/.zsh/starship/config.toml
export GPG_TTY=$(tty) # commit signing
export PNPM_HOME=$HOME/.config/pnpm/5/node_modules/.bin
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PNPM_HOME:$PATH"
export PATH="$HOME/.local/share/mise/shims:$PATH"
export PATH="$(brew --prefix mysql@5.7)/bin:$PATH"

export REQUESTS_CA_BUNDLE="/etc/ssl/certs/netskope-cert-bundle.pem"
export NODE_EXTRA_CA_CERTS="/etc/ssl/certs/netskope-cert-bundle.pem"
export CURL_CA_BUNDLE="/etc/ssl/certs/netskope-cert-bundle.pem"

. "$HOME/.cargo/env"

# Netskope Certificate for Cloud
export REQUESTS_CA_BUNDLE=/etc/ssl/certs/netskope-cert-bundle.pem

# Netskope Certificate for nodejs
export NODE_EXTRA_CA_CERTS=/etc/ssl/certs/netskope-cert-bundle.pem

# Netskope Certificate for curl
export CURL_CA_BUNDLE=/etc/ssl/certs/netskope-cert-bundle.pem
