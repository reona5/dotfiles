local status, indent_blankline = pcall(require, "indent_blankline")
if (not status) then return end

vim.opt.termguicolors = true
vim.opt.list = true

indent_blankline.setup {
  show_current_context = true,
  show_current_context_start = true,
  filetype_exclude = { 'NvimTree', 'man', 'dashboard', 'lsp-installer' },
}
