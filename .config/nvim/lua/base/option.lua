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

-- Create the autocommand group
local whitespace_group = vim.api.nvim_create_augroup('extra-whitespace', { clear = true })

-- Set up autocommands
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
