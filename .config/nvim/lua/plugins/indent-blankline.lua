local status, indent_blankline = pcall(require, "ibl")
if (not status) then return end

vim.opt.termguicolors = true
vim.opt.list = true

indent_blankline.setup {
  -- filetype_exclude = { 'NvimTree', 'man', 'dashboard', 'lsp-installer' },
}
