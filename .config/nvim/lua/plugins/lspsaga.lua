local status, lspsaga = pcall(require, "lspsaga")
if (not status) then return end

lspsaga.setup({
  symbol_in_winbar = {
    folder_level = 5
  }
})

local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<C-k>', "<Cmd>Lspsaga diagnostic_jump_prev<CR>", opts)
vim.keymap.set('n', '<C-j>', '<Cmd>Lspsaga diagnostic_jump_next<CR>', opts)
vim.keymap.set('n', 'K', '<Cmd>Lspsaga hover_doc<CR>', opts)
vim.keymap.set('n', 'gd', '<Cmd>Lspsaga lsp_finder<CR>', opts)
vim.keymap.set('i', '<C-k>', '<Cmd>Lspsaga signature_help<CR>', opts)
vim.keymap.set('n', 'gp', '<Cmd>Lspsaga preview_definition<CR>', opts)
vim.keymap.set('n', 'gr', '<Cmd>Lspsaga rename<CR>', opts)
