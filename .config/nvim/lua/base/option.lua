vim.loader.enable()

vim.o.shadafile = "NONE"
vim.o.lazyredraw = true
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

local has_clipboard = vim.fn.has("clipboard") == 1
local has_unnamedplus = vim.fn.has("unnamedplus") == 1

if has_clipboard then
  if has_unnamedplus then
    vim.opt.clipboard = "unnamed,unnamedplus"
  else
    vim.opt.clipboard = "unnamed"
  end
end

vim.filetype.add({ extension = { mdx = 'mdx' } })

-- Create the autocommand groups
local whitespace_group = vim.api.nvim_create_augroup('extra-whitespace', { clear = true })
local autosave_group = vim.api.nvim_create_augroup('auto-save', { clear = true })

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
