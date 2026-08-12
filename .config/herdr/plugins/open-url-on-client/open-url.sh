#!/bin/sh
# ペイン内の URL を Ctrl+click したときに herdr から呼ばれ、URL を開く。
#
# herdr の標準動作はサーバー側で open するというもので、MacBook から remote attach
# している間は手元では見えない Mac mini 側の Chrome が立ち上がってしまう。
# herdr-remote-attach が reverse トンネルを張っているときは、その出口(Unix ソケット)
# へ URL を流して手元の herdr-url-listener に開かせる。
#
# トンネルが無いときはこのマシンを直接使っているということなので、ここで開く。

set -eu

url="${HERDR_PLUGIN_CLICKED_URL:-}"
[ -n "$url" ] || exit 0

env_file="${XDG_CONFIG_HOME:-$HOME/.config}/herdr/remote.env"
[ -f "$env_file" ] && . "$env_file"

sock="${HERDR_URL_SOCK:-/tmp/herdr-url-relay.sock}"

if [ -S "$sock" ] && printf '%s\n' "$url" | nc -U "$sock" > /dev/null 2>&1; then
  exit 0
fi

exec open -a "${HERDR_URL_BROWSER:-Google Chrome}" "$url"
