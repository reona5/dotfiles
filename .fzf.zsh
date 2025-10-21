# Setup fzf
# ---------
if [ "$(uname)" = "Darwin" ]; then
  # macOS (Homebrew)
  if [[ ! "$PATH" == */opt/homebrew/opt/fzf/bin* ]]; then
    PATH="${PATH:+${PATH}:}/opt/homebrew/opt/fzf/bin"
  fi

  if [[ ! -d /opt/homebrew/opt/fzf/shell ]]; then
    $(brew --prefix)/opt/fzf/install
  fi

  # Auto-completion
  [[ $- == *i* ]] && source "/opt/homebrew/opt/fzf/shell/completion.zsh" 2> /dev/null

  # Key bindings
  source "/opt/homebrew/opt/fzf/shell/key-bindings.zsh"
else
  # Linux / devcontainer
  if [ -d "$HOME/.fzf" ]; then
    # Add fzf to PATH
    if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
      PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
    fi

    # Auto-completion
    [[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

    # Key bindings
    [ -f "$HOME/.fzf/shell/key-bindings.zsh" ] && source "$HOME/.fzf/shell/key-bindings.zsh"
  fi
fi

export FZF_CTRL_T_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
export FZF_CTRL_T_OPTS='--preview "bat --color=always --style=header,grid --line-range :100 {}"'
export FZF_TMUX=0
