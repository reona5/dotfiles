local status, telescope = pcall(require, "telescope")
if (not status) then return end

local actions = require('telescope.actions')
local builtin = require('telescope.builtin')
local opts = { noremap = true, silent = true }
vim.keymap.set('n', '<Leader>f', builtin.find_files, opts)
vim.keymap.set('n', '<Leader>g', builtin.live_grep, opts)
vim.keymap.set('n', '<Leader><leader>', builtin.buffers, opts)

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
      'ctags'
    },
  }
}
