#!/bin/sh
# herdr の worktree.created イベントで、新しく作られた worktree の初期(root)ペインに
# `claude --dangerously-skip-permissions` を流し込む。
#
# herdr が注入する env のうち、新 worktree ワークスペースの root ペイン id が
# HERDR_PANE_ID に入る（実測済み。worktree 直後は 1 ペインなのでそれが root）。
# 念のため取得できなければ HERDR_WORKSPACE_ID からペイン一覧で補完する。

herdr="${HERDR_BIN_PATH:-herdr}"

pane="$HERDR_PANE_ID"
if [ -z "$pane" ] && [ -n "$HERDR_WORKSPACE_ID" ]; then
  pane=$("$herdr" pane list --workspace "$HERDR_WORKSPACE_ID" 2>/dev/null \
          | jq -r '(.result.panes // .panes // [])[0].pane_id // empty' 2>/dev/null)
fi
[ -n "$pane" ] || exit 0

"$herdr" pane run "$pane" 'claude --dangerously-skip-permissions'
