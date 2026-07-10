# TTY がなければ実行しない
if [[ -t 0 ]]; then
  # 各ツールの init スクリプトは出力が固定なのでキャッシュし、
  # バイナリ更新時のみ再生成する(毎回の eval "$(...)" はプロセス起動で数百 ms かかる)
  _zsh_cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
  [[ -d "$_zsh_cache_dir" ]] || mkdir -p "$_zsh_cache_dir"

  _cached_eval() {
    local cache="$_zsh_cache_dir/$1.zsh"
    if [[ ! -s "$cache" || "${commands[$2]}" -nt "$cache" ]]; then
      "${@:2}" > "$cache"
    fi
    source "$cache"
  }

  # sheldon は plugins.toml の変更でも再生成する
  _sheldon_cache="$_zsh_cache_dir/sheldon.zsh"
  _sheldon_toml="${XDG_CONFIG_HOME:-$HOME/.config}/sheldon/plugins.toml"
  if [[ ! -s "$_sheldon_cache" || "$_sheldon_toml" -nt "$_sheldon_cache" || "${commands[sheldon]}" -nt "$_sheldon_cache" ]]; then
    sheldon source > "$_sheldon_cache"
  fi
  source "$_sheldon_cache"

  _cached_eval starship starship init zsh
  _cached_eval direnv direnv hook zsh
  _cached_eval mise mise activate zsh

  unfunction _cached_eval
  unset _zsh_cache_dir _sheldon_cache _sheldon_toml
fi

[[ -f "$HOME/.fzf.zsh" ]] && source "$HOME/.fzf.zsh"

# go env の呼び出しは mise shim 経由で遅いため、既定値を直接設定する
export GOPATH="${GOPATH:-$HOME/go}"
export PATH=$PATH:$GOPATH/bin

if [ ~/.zshrc -nt ~/.zshrc.zwc ]; then
  zcompile ~/.zshrc
fi

if (which zprof > /dev/null 2>&1) ;then
  zprof
fi

# bun completions
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

if [[ -x /opt/homebrew/bin/terraform ]]; then
  autoload -U +X bashcompinit && bashcompinit
  complete -o nospace -C /opt/homebrew/bin/terraform terraform
fi

if [[ -n "$AWS_VAULT" ]]; then
  export AWS_VAULT_PROMPT="[aws-vault:$AWS_VAULT]"
  export PS1="${AWS_VAULT_PROMPT} ${PS1}"
fi

# Added by Antigravity
[[ -d "$HOME/.antigravity/antigravity/bin" ]] && export PATH="$HOME/.antigravity/antigravity/bin:$PATH"
[[ -d /opt/homebrew/opt/openjdk@11/bin ]] && export PATH="/opt/homebrew/opt/openjdk@11/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"
