eval "$(sheldon source)"
eval "$(starship init zsh)"
eval "$(direnv hook zsh)"
eval "$(mise activate zsh)"

export GOPATH=$(go env GOPATH)
export PATH=$PATH:$GOPATH/bin

for file in $HOME/.zsh/*.zsh
do
    [[ -f "$file" ]] && source "$file"
done

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

if [[ -n "$AWS_VAULT" ]]; then
  export AWS_VAULT_PROMPT="[aws-vault:$AWS_VAULT]"
  export PS1="${AWS_VAULT_PROMPT} ${PS1}"
fi
