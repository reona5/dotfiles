#!/bin/sh
# grill-with-docs で固まった docs を、現在ブランチに紐づく GitHub issue の
# コメントとして投稿する。
#
# 使い方: post-doc.sh <body-file>
#   <body-file> … 投稿する Markdown 本文のファイル。
#
# ブランチ名から issue 番号を推定し（resolve-issue.sh と同じ規則）、
# `gh issue comment` で投稿してコメント URL を標準出力に出す。
# 呼び出し側（skill）が AskUserQuestion で投稿可否を確認済みである前提。

body="$1"
[ -n "$body" ] || { echo "usage: post-doc.sh <body-file>" >&2; exit 2; }
[ -f "$body" ] || { echo "body file not found: $body" >&2; exit 2; }

branch=$(git branch --show-current 2>/dev/null) || { echo "not a git repository" >&2; exit 1; }
[ -n "$branch" ] || { echo "detached HEAD / branch を特定できません" >&2; exit 1; }

# 2 桁以上の最初の数字列を issue 番号候補にする（resolve-issue.sh と揃える）。
num=$(printf '%s\n' "$branch" | grep -oE '[0-9]{2,}' | head -n1)
[ -n "$num" ] || { echo "branch にissue番号が見つかりません: $branch" >&2; exit 1; }

command -v gh >/dev/null 2>&1 || { echo "gh コマンドが見つかりません" >&2; exit 1; }

# 投稿。成功すると gh はコメント URL を出力する。
gh issue comment "$num" --body-file "$body"
