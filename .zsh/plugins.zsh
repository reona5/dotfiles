zinit wait lucid blockf light-mode for \
  @'zsh-users/zsh-autosuggestions' \
  @'zdharma-continuum/fast-syntax-highlighting' \
  @'zsh-users/zsh-completions'

# NOTE: https://gist.github.com/ctechols/ca1035271ad134841284
autoload -Uz compinit
if [[ -n ${ZDOTDIR}/.zcompdump(#qN.mh+24) ]]; then
	compinit;
else
	compinit -C;
fi;

eval "$(direnv hook zsh)"
