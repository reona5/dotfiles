#!/bin/sh
# 現在の git ブランチから GitHub issue 番号を推定し、あれば issue 内容を出力する。
# grill-me が grilling の前に呼ぶ。出力があれば材料に使い、無ければ issue 無しとして進める。
#
# 例: feat/2105-insight-index -> 2105 / fix/1234 -> 1234 / 1234-foo -> 1234
# 数字が無い・issue として解決できない（未認証/非GitHub/PR番号違い等）場合は無出力で終了。

branch=$(git branch --show-current 2>/dev/null) || exit 0
[ -n "$branch" ] || exit 0

# 2 桁以上の最初の数字列を issue 番号候補にする（単発の 1 桁やバージョンの誤検出を避ける）。
num=$(printf '%s\n' "$branch" | grep -oE '[0-9]{2,}' | head -n1)
[ -n "$num" ] || exit 0

command -v gh >/dev/null 2>&1 || exit 0

# issue を取得（解決できなければ黙って終了 = issue 無し扱い）
json=$(gh issue view "$num" --json number,title,state,labels,url,body,comments 2>/dev/null) || exit 0
[ -n "$json" ] || exit 0

printf '%s' "$json" | jq -r '
  "## Linked issue #\(.number): \(.title)  [\(.state)]",
  "URL: \(.url)",
  (if (.labels | length) > 0 then "Labels: " + (.labels | map(.name) | join(", ")) else empty end),
  "",
  (.body // "(no body)"),
  (if (.comments | length) > 0
     then "", "### Comments", (.comments[] | "- @\(.author.login): \(.body)")
     else empty end)
' 2>/dev/null
