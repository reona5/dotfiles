eval "$(sheldon source)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

. /usr/local/opt/asdf/libexec/asdf.sh

# pnpm
export PNPM_HOME="/Users/reona5/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end