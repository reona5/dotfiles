#!/bin/bash
# Rex のペインごとに、そこで動いている Claude Code のセッションを記録する。
# Mac の再起動などでペインのシェルが起動し直したとき、.zshrc がこの記録を読んで
# `claude --resume` で会話を再開する（tmux-resurrect の代わり）。
#
#   SessionStart: rex-resume.sh save  … ペイン(REX_BLOCK)→ session_id と cwd を記録
#   SessionEnd:   rex-resume.sh end   … /exit などで自分から終えたときは記録を消す
#
# Rex のブロック ID は Rex server を再起動しても変わらないので、キーに使える。
set -u

[[ -n "${REX_BLOCK:-}" ]] || exit 0

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/rex-claude"
state_file="$state_dir/${REX_BLOCK#block:}"
input=$(cat)

case "${1:-}" in
  save)
    session_id=$(printf '%s' "$input" | jq -r '.session_id // empty')
    cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
    [[ -n "$session_id" && -n "$cwd" ]] || exit 0
    mkdir -p "$state_dir"
    printf '%s\t%s\n' "$session_id" "$cwd" >"$state_file"
    ;;
  end)
    reason=$(printf '%s' "$input" | jq -r '.reason // empty')
    # シャットダウンやシグナルで落ちたとき(other など)は残して、次回起動時に再開する
    case "$reason" in
      prompt_input_exit | logout) rm -f "$state_file" ;;
    esac
    ;;
esac
exit 0
