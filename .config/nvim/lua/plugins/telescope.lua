local status, telescope = pcall(require, "telescope")
if (not status) then return end

local actions = require('telescope.actions')
local previewers = require("telescope.previewers")
local new_maker = function(filepath, bufnr, opts)
	opts = opts or {}

	filepath = vim.fn.expand(filepath)
	vim.loop.fs_stat(filepath, function(_, stat)
		if not stat then return end
		if stat.size > 100000 then
			return
		else
			previewers.buffer_previewer_maker(filepath, bufnr, opts)
		end
	end)
end
local opts = { noremap = true, silent = true }
vim.api.nvim_set_keymap('n', '<Leader>f', "<Cmd>lua require('telescope.builtin').find_files()<CR>", opts)
vim.api.nvim_set_keymap('n', '<Leader>g', "<Cmd>lua require('telescope.builtin').live_grep()<CR>", opts)
vim.api.nvim_set_keymap('n', '<Leader><leader>', "<Cmd>lua require('telescope.builtin').buffers()<CR>", opts)

-- Global remapping
------------------------------
telescope.setup {
	defaults = {
		vimgrep_arguments = {
			"rg",
			"--color=never",
			"--no-heading",
			"--with-filename",
			"--line-number",
			"--column",
			"--smart-case",
			"--trim"
		},
		pickers = {
			find_files = {
				find_command = {
					'fd',
					'--type',
					'f',
					'--no-ignore-vcs',
					'--color=never',
					'--hidden',
					'--follow',
				}
			},
		},
		mappings = {
			n = {
				["q"] = actions.close
			}
		},
		file_ignore_patterns = {
			'node_modules',
			'channel.html',
			'tags'
		},
		buffer_previewer_maker = new_maker,
	}
}
