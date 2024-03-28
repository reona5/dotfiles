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
vim.o.whichwrap = "b,s,h,l,[,],<,>"
vim.o.signcolumn = "yes"
vim.o.clipboard = "unnamedplus"

vim.filetype.add({ extension = { mdx = 'mdx' } })

vim.cmd([[
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
