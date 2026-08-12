vim.loader.enable()

vim.o.shadafile = "NONE"
vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.autoindent = true
vim.o.cursorline = true
vim.o.number = true
vim.o.wrap = true
vim.o.swapfile = false
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.scrolloff = 5
vim.o.updatetime = 100
vim.o.laststatus = 3
vim.o.whichwrap = "b,s,h,l,[,],<,>"
vim.o.signcolumn = "yes"
vim.o.fileformats = "unix,dos,mac"

-- herdr のペイン内では clipboard を OSC 52 で渡す。
-- 既定のままだと nvim は pbcopy を掴むので、yank は herdr サーバーのある側
-- （Mac mini）の clipboard に入ってしまい、MacBook から `herdr --remote` で
-- 見ているときに手元へ取り出せない。OSC 52 なら herdr が「見ている側」の
-- クライアントへ渡すため、ローカルで開いていても remote attach でも
-- clipboard が手元に付いてくる。
--
-- 必ず 'clipboard' オプションより前に置くこと。オプションを設定した時点で
-- nvim が provider を解決してキャッシュするため、後から g:clipboard を
-- 差し替えても pbcopy のまま使われ続ける。
local in_herdr = vim.env.HERDR_ENV == "1"

if in_herdr then
  local osc52 = require("vim.ui.clipboard.osc52")

  -- OSC 52 の読み出しクエリには端末が応答しない（応答を待って固まる）ため、
  -- 問い合わせずに直前の無名レジスタを返す。手元から貼るのは端末側の
  -- ペースト操作で足りるので、これで困らない。
  local function paste_from_register()
    return vim.split(vim.fn.getreg('"'), "\n")
  end

  local copy_to_clipboard = osc52.copy("+")

  vim.g.clipboard = {
    name = "herdr-osc52",
    copy = { ["+"] = copy_to_clipboard, ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste_from_register, ["*"] = paste_from_register },
  }

  -- 'clipboard' に unnamed/unnamedplus を入れると d/x/c の削除内容まで
  -- クリップボードへ流れ、yank したものが直後の編集で上書きされてしまう。
  -- 自動同期は使わず、yank のときだけ明示的に送る。
  vim.opt.clipboard = ""

  vim.api.nvim_create_autocmd("TextYankPost", {
    group = vim.api.nvim_create_augroup("herdr-clipboard", { clear = true }),
    callback = function()
      if vim.v.event.operator ~= "y" then
        return
      end
      copy_to_clipboard(vim.v.event.regcontents)
    end,
  })
end

local has_clipboard = vim.fn.has("clipboard") == 1
local has_unnamedplus = vim.fn.has("unnamedplus") == 1

if has_clipboard and not in_herdr then
  if has_unnamedplus then
    vim.opt.clipboard = "unnamed,unnamedplus"
  else
    vim.opt.clipboard = "unnamed"
  end
end

vim.filetype.add({
  extension = {
    gotmpl = "gotmpl",
    mdx = "mdx",
    sss = "sugarss",
  },
  pattern = {
    [".*%.go%.tmpl"] = "gotmpl",
  },
})

-- Create the autocommand groups
local whitespace_group = vim.api.nvim_create_augroup('extra-whitespace', { clear = true })
local autosave_group = vim.api.nvim_create_augroup('auto-save', { clear = true })
local auto_quit_group = vim.api.nvim_create_augroup('auto-quit', { clear = true })

-- Set up whitespace autocommands
vim.api.nvim_create_autocmd({ 'VimEnter', 'WinEnter' }, {
  group = whitespace_group,
  callback = function()
    vim.fn.matchadd('ExtraWhitespace', '[\\u00A0\\u2000-\\u200B\\u3000]')
  end,
})

vim.api.nvim_create_autocmd('ColorScheme', {
  group = whitespace_group,
  callback = function()
    vim.api.nvim_set_hl(0, 'ExtraWhitespace', {
      default = true,
      underline = true,
      ctermfg = 'lightblue',
      bg = 'darkgray',
    })
  end,
})

vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  group = autosave_group,
  pattern = "*",
  callback = function()
    -- 無名バッファ、読み取り専用、変更不可は除外
    if vim.fn.expand("%") == "" or not vim.bo.modifiable or vim.bo.readonly then
      return
    end

    -- 特定のファイルタイプを除外
    local excluded_filetypes = { "gitcommit", "gitrebase" }
    if vim.tbl_contains(excluded_filetypes, vim.bo.filetype) then
      return
    end

    vim.cmd("silent! write")

    print("💾 " .. os.date("%H:%M:%S"))
    vim.cmd(string.format('echo "Saved at %s"', os.date("%H:%M:%S")))
  end,
})

-- Auto quit when only special windows remain
vim.api.nvim_create_autocmd("BufEnter", {
  group = auto_quit_group,
  callback = function()
    -- 特殊なウィンドウとして扱うfiletypeのリスト
    local special_filetypes = {
      "NvimTree",
      "fugitive",
      "fugitiveblame",
      "git",
      "qf",
      "help",
      "man",
    }

    -- すべてのウィンドウをチェック
    local normal_windows = 0
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      local ft = vim.api.nvim_buf_get_option(buf, "filetype")
      local bt = vim.api.nvim_buf_get_option(buf, "buftype")

      -- 通常のウィンドウかどうかを判定
      if not vim.tbl_contains(special_filetypes, ft) and bt ~= "nofile" and bt ~= "help" then
        normal_windows = normal_windows + 1
      end
    end

    -- 通常のウィンドウが0個の場合は終了
    if normal_windows == 0 then
      vim.cmd("qall")
    end
  end,
})
