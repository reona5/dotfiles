function ToggleGStatus()
  local fugitive_buf_no = vim.fn.bufnr('^fugitive:')
  local buf_win_id = vim.fn.bufwinid(fugitive_buf_no)
  if fugitive_buf_no >= 0 and buf_win_id >= 0 then
    print('closing fugitive window')
    vim.api.nvim_win_close(buf_win_id, false)
  else
    vim.cmd(":G")
  end
end

vim.api.nvim_create_user_command('ToggleGStatus', ToggleGStatus, {})

local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<leader>a', ':Git add %<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>c', ':Git commit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':GBrowse<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':Git diff<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>s', ':ToggleGStatus<CR>', opts)
