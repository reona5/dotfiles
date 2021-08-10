nnoremap <silent> <leader>a :Gwrite<CR>
nnoremap <silent> <leader>c :Git commit<CR>
nnoremap <silent> <leader>b :GBrowse<CR>
nnoremap <silent> <leader>d :Git diff<CR>

function! ToggleGStatus()
    if buflisted(bufname('.git/index'))
        bd .git/index
    else
        Git
    endif
endfunction
command ToggleGStatus :call ToggleGStatus()
nmap <leader>s :ToggleGStatus<CR>

" Status line
if !exists('*fugitive#statusline')
  set statusline=%F\ %m%r%h%w%y%{'['.(&fenc!=''?&fenc:&enc).':'.&ff.']'}[L%l/%L,C%03v]
  set statusline+=%=
  set statusline+=%{fugitive#statusline()}
endif