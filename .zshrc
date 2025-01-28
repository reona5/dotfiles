eval "$(sheldon source)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

export GOPATH=$(go env GOPATH)
export PATH=$PATH:$GOPATH/bin

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

# bun completions
[ -s "/Users/reona.shimada/.bun/_bun" ] && source "/Users/reona.shimada/.bun/_bun"

autoload -U +X bashcompinit && bashcompinit
complete -o nospace -C /opt/homebrew/bin/terraform terraform
