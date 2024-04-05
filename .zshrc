eval "$(sheldon source)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
. /opt/homebrew/opt/asdf/libexec/asdf.sh

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

# bun completions
[ -s "/Users/reona.shimada/.bun/_bun" ] && source "/Users/reona.shimada/.bun/_bun"
