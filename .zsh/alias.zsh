alias -g @g='| rg'
alias -g @l='| less'
alias -g @f='--force-with-lease --force-if-includes'

alias awsume='. awsume'
alias ssh='TERM=xterm-256color ssh'
alias exa='exa -ahHl'
alias dc='docker compose'
alias da='docker attach'
alias gst='git status'
alias gb='git branch'
alias gbm='git branch -m'
alias gbd='git branch -D'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcherry='git cherry-pick'
alias gc='git commit'
alias ga='git add .'
alias gd='git diff'
alias gl='git log'
alias glo='git log --oneline'
alias gf='git fetch'
alias gm='git merge'
alias gca='git commit --amend'
alias gcm='git commit -m'
alias grm='git rebase main'
alias grd='git rebase master'
alias grim='git rebase -i main'
alias grid='git rebase -i master'
alias grc='git rebase --continue'
alias gra='git rebase --abort'
alias grs='git rebase --skip'
alias gp='git push'
alias gpo='git push origin'
alias gpom='git push origin main'
alias gpod='git push origin master'
alias gpoh='git push origin HEAD'
alias gpoh='git push origin HEAD'
alias gpl='git pull'
alias gplo='git pull origin'
alias gplom='git pull origin main'
alias gplod='git pull origin master'
alias gsw='git switch'
alias gswc='git switch -c'
alias gs='git stash -u'
alias gsl='git stash list'
alias gsp='git stash pop'
alias gss='git stash save'
alias gsd='git stash drop'
alias gsc='git stash clear'
alias grsh='git reset --soft HEAD^'
alias grhh='git reset --hard HEAD^'
alias gre='git restore'
alias vi='nvim'
alias vanish='git branch | grep -v "main" | grep -v "develop" | xargs git branch -D'
alias rm='rm -i'
alias mv='mv -i'
alias cp='cp -i'
export EDITOR=/usr/local/bin/nvim
