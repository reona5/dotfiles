-- map <Leader> on space key
vim.g.mapleader = ' '

local keymap = vim.keymap

-- write
keymap.set('n', '<Leader>w', ':w<CR>')
-- read
keymap.set('n', '<Leader>e', ':e<CR>')
-- Change from insert mode to normal mode
keymap.set('i', 'jj', '<ESC>:<C-u>w<CR>')
-- Enable to use tab key for auto-completions
keymap.set('i', '<expr><TAB>', "pumvisible() ? '<Down>' : '<TAB>'")
keymap.set('i', '<expr><S-TAB>', "pumvisible() ? '<Up>' : '<S-TAB>'")

-- augroup Maps
vim.cmd([[
  autocmd!
  " Go to definition for Ruby by ctags
  autocmd BufEnter *.rb nnoremap <buffer> g] g<C-]>
  autocmd BufEnter *.rb inoremap <buffer> g] <ESC>g<C-]>
  " trail whitespace
  autocmd BufWritePre * :%s/\s\+$//e
augroup END
]])

-- Manage window
keymap.set('n', ',', '<Nop>')
keymap.set('n', ',j', '<C-w>j')
keymap.set('n', ',k', '<C-w>k')
keymap.set('n', ',l', '<C-w>l')
keymap.set('n', ',h', '<C-w>h')
keymap.set('n', ',=', '<C-w>=')
keymap.set('n', ',s', ':<C-u>sp<CR>')
keymap.set('n', ',v', ':<C-u>vs<CR>')

-- emacs keybind
keymap.set('i', '<C-p>', '<Up>')
keymap.set('i', '<C-n>', '<Down>')
keymap.set('i', '<C-b>', '<Left>')
keymap.set('i', '<C-f>', '<Right>')
keymap.set('i', '<C-a>', '<C-o>:call s:home()<CR>')
keymap.set('i', '<C-e>', '<End>')
keymap.set('i', '<C-d>', '<Del>')
keymap.set('i', '<C-h>', '<BS>')
keymap.set('i', '<C-k>', '<C-r>=s:kill()<CR>')

keymap.set('n', '<Leader>p', '<C-c>:r! paste_image_on_markdown <CR>')
