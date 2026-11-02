-- Rex configuration
-- ~/.config/rex/init.lua
-- 旧 .tmux.conf(と herdr の割り当て)からの移植。prefix は ctrl+q。

local terminal = "com.superlogical.terminal"
local shell = "com.superlogical.terminal.shell"

-- 旧 bind-key C-q send-prefix: ctrl+q を 2 回押すと端末に ctrl+q を送る
rex.bind("ctrl+q>ctrl+q", "pane.send_key", { key = "ctrl+q" })

-- タブ(tmux の window)
rex.bind("ctrl+q>c", "client.tab.new")
rex.bind("ctrl+q>n", "client.tab.next")
rex.bind("ctrl+q>p", "client.tab.previous")
rex.bind("ctrl+q>,", "client.tab.rename")
rex.bind("ctrl+q>shift+7", "client.tab.close") -- & on a US layout
-- 旧 base-index 1: prefix+1 が 1 番目のタブ
for i = 1, 9 do
  rex.bind("ctrl+q>" .. i, "client.tab.goto", { index = i })
end

-- セッション
rex.bind("ctrl+q>s", "session.switch")
rex.bind("ctrl+q>shift+4", "session.rename") -- $ on a US layout
rex.bind("ctrl+q>shift+9", "session.previous") -- ( on a US layout
rex.bind("ctrl+q>shift+0", "session.next") -- ) on a US layout

-- 分割。旧 | と -。herdr の v も左右分割に割り当てる
rex.bind("ctrl+q>shift+\\", "pane.split", { direction = "right" }) -- | on a US layout
rex.bind("ctrl+q>v", "pane.split", { direction = "right" })
rex.bind("ctrl+q>-", "pane.split", { direction = "down" })

-- 旧 vim キーバインドでペインを移動する
rex.bind("ctrl+q>h", "pane.focus", { direction = "left" })
rex.bind("ctrl+q>j", "pane.focus", { direction = "down" })
rex.bind("ctrl+q>k", "pane.focus", { direction = "up" })
rex.bind("ctrl+q>l", "pane.focus", { direction = "right" })

rex.bind("ctrl+q>z", "pane.zoom")
rex.bind("ctrl+q>x", "pane.close")

-- 旧 bind -r H/J/K/L resize-pane 5。
-- tmux の -r(prefix のあと続けて押せる)の代わりに、prefix+H/J/K/L で 1 回リサイズして
-- resize モードに入る。モードの間は h/j/k/l(shift 付きも)で続けてリサイズし、Escape か Enter で抜ける
rex.mode("resize", { exclusive = true })

rex.action{
  name = "resize_repeat",
  title = "Resize Pane and Keep Resizing",
  args = { direction = "string" },
  run = function(ctx, args)
    rex.client.queue("pane.resize", { direction = args.direction })
    rex.client.queue("client.mode.enter", { name = "resize" })
  end,
}

local resize_keys = { h = "left", j = "down", k = "up", l = "right" }
for key, direction in pairs(resize_keys) do
  rex.bind("ctrl+q>shift+" .. key, "resize_repeat", { direction = direction })
  rex.bind("resize/" .. key, "pane.resize", { direction = direction })
  rex.bind("resize/shift+" .. key, "pane.resize", { direction = direction })
end
rex.bind("resize/=", "pane.balance")
rex.bind("resize/enter", "client.mode.exit")

-- 旧 popup。フォーカス中のペインの作業ディレクトリで、浮いたレイヤーに開く
local function current_dir(ctx)
  local p = rex.block.call(terminal, "process", { block_id = ctx.block_id })
  if p and p.foreground and p.foreground.cwd then
    return p.foreground.cwd
  end
  return os.getenv("HOME")
end

local function open_popup(ctx, command, bounds)
  local options = { cwd = current_dir(ctx) }
  if command then
    options.command = command
  end
  local _, err = rex.session.new_layer{
    bounds = bounds or { 0.15, 0.15, 0.7, 0.7 }, -- 旧 -w70% -h70%、中央
    layout = rex.layout.block{ flavor = shell, options = options },
    focus = true,
  }
  if err ~= nil then error(err, 0) end
end

-- フォーカス中のペインの位置と大きさ(ウィンドウに対する割合)を session.view から探す
local function find_rect(node, block_id)
  if node == nil then return nil end
  if node.block_id == block_id then return node.rect end
  if node.split then
    return find_rect(node.split.before, block_id) or find_rect(node.split.after, block_id)
  end
  return nil
end

local function pane_bounds(ctx)
  local res = rex.session.view{}
  local view = res and (res.view or res)
  for _, w in ipairs(view and view.windows or {}) do
    for _, layer in ipairs(w.layers or {}) do
      if layer.kind == "tiled" then
        local rect = find_rect(layer.layout, ctx.block_id)
        if rect then return rect end
      end
    end
  end
  return nil
end

rex.action{
  name = "popup_shell",
  title = "Open Popup Shell",
  run = function(ctx) open_popup(ctx) end,
}

rex.action{
  name = "popup_lazygit",
  title = "Open lazygit in Popup",
  run = function(ctx) open_popup(ctx, { "lazygit" }) end,
}

rex.action{
  name = "edit_config",
  title = "Open Config in nvim",
  run = function(ctx)
    local path = os.getenv("REX_CONFIG") or (os.getenv("HOME") .. "/.config/rex/init.lua")
    open_popup(ctx, { "nvim", path })
  end,
}

-- 旧 copy-mode-vi の代わり。フォーカス中のペインのスクロールバックを、同じ位置に重ねた nvim で開く。
-- v / V / ctrl+v で選択し、y でクリップボードにコピーして閉じる(旧 copy-pipe-and-cancel)。貼り付けは cmd+v
-- コマンドはセッションのホスト(mac-mini など)で動くので、nvim に読ませる Lua はスクリプトに埋め込んで
-- そのホストのファイルに頼らない。コピーも pbcopy ではなく OSC 52 で書き、手元の Rex のクリップボードに届ける
rex.action{
  name = "copy_mode",
  title = "Copy Mode (Scrollback in nvim)",
  run = function(ctx)
    local script = [[
f=$(mktemp -t rex-scrollback)
l=$(mktemp -t rex-copy-mode)
trap 'rm -f "$f" "$l"' EXIT
cat > "$l" <<'EOF'
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    local ev = vim.v.event
    if ev.operator ~= "y" then return end
    -- 行単位の選択でも末尾に改行を付けない。貼り付けたコマンドがそのまま実行されるのを避ける
    local text = table.concat(ev.regcontents, "\n")
    -- stderr は端末につながっているので、OSC 52 を書き終えてから閉じられる
    vim.api.nvim_chan_send(vim.v.stderr, "\027]52;c;" .. vim.base64.encode(text) .. "\007")
    vim.schedule(function() vim.cmd("qa!") end)
  end,
})
EOF
rex capture -s "$1" -b "$2" --trim --unwrap > "$f"
nvim -R + -c "luafile $l" "$f"
]]
    open_popup(ctx, { "sh", "-c", script, "sh", ctx.session_id, ctx.block_id }, pane_bounds(ctx))
  end,
}

-- 旧 bind Space popup / bind g popup lazygit
rex.bind("ctrl+q>space", "popup_shell")
rex.bind("ctrl+q>g", "popup_lazygit")
rex.bind("ctrl+q>e", "edit_config")
rex.bind("ctrl+q>[", "copy_mode")
