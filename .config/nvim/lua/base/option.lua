vim.o.expandtab = true
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.autoread = true
vim.o.autowrite = true
vim.o.autoindent = true
vim.o.cursorline = true
vim.o.number = true
vim.o.wrap = true
vim.o.tabstop = 2
vim.o.shiftwidth = 2
vim.o.scrolloff = 5
vim.o.updatetime = 500
vim.o.whichwrap = "b,s,h,l,[,],<,>"
vim.o.signcolumn = "yes"

vim.cmd([[
  let g:did_install_default_menus = 1
  let g:did_install_syntax_menu   = 1
  let g:did_indent_on             = 1
  let g:did_load_ftplugin         = 1
  let g:loaded_2html_plugin       = 1
  let g:loaded_gzip               = 1
  let g:loaded_man                = 1
  let g:loaded_matchit            = 1
  let g:loaded_matchparen         = 1
  let g:loaded_netrwPlugin        = 1
  let g:loaded_remote_plugins     = 1
  let g:loaded_shada_plugin       = 1
  let g:loaded_spellfile_plugin   = 1
  let g:loaded_tarPlugin          = 1
  let g:loaded_tutor_mode_plugin  = 1
  let g:loaded_zipPlugin          = 1
  let g:skip_loading_mswin        = 1

	" Full-width Space highlight
	function! Space()
		highlight Space cterm=underline ctermfg=lightblue guibg=darkgray
	endfunction

	if has('syntax')
		augroup Space
			autocmd!
			autocmd ColorScheme * call Space()
			autocmd VimEnter,WinEnter,BufRead * let w:m1=matchadd('Space', '　')
		augroup END
		call Space()
	endif

  " autosave
  function s:AutoWriteIfPossible()
    if &modified && !&readonly && bufname('%') !=# '' && &buftype ==# '' && expand("%") !=# ''
      write
    endif
  endfunction
  augroup AutoWrite
    autocmd!
    autocmd CursorHold * call s:AutoWriteIfPossible()
    autocmd CursorHoldI * call s:AutoWriteIfPossible()
    " settings for golang
    autocmd FileType go setlocal sw=4 ts=4 sts=4 noet
  augroup END
]])
