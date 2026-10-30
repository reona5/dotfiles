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

local function open_popup(ctx, command)
  local options = { cwd = current_dir(ctx) }
  if command then
    options.command = command
  end
  local _, err = rex.session.new_layer{
    bounds = { 0.15, 0.15, 0.7, 0.7 }, -- 旧 -w70% -h70%、中央
    layout = rex.layout.block{ flavor = shell, options = options },
    focus = true,
  }
  if err ~= nil then error(err, 0) end
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

-- 旧 bind Space popup / bind g popup lazygit
rex.bind("ctrl+q>space", "popup_shell")
rex.bind("ctrl+q>g", "popup_lazygit")
rex.bind("ctrl+q>e", "edit_config")
