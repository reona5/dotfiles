vim.cmd([[
	function! ToggleGStatus()
			if buflisted(bufname('.git'))
					bd .git
			else
					Git
			endif
	endfunction
	command ToggleGStatus :call ToggleGStatus()
]])

local opts = {noremap = true, silent = true}
vim.api.nvim_set_keymap('n', '<leader>a', ':Git add %<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>c', ':Git commit<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>b', ':GBrowse<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>d', ':Git diff<CR>', opts)
vim.api.nvim_set_keymap('n', '<leader>s', ':ToggleGStatus<CR>', opts)
