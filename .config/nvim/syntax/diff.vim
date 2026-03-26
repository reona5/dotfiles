" Workaround for E484 with vim-fugitive on Neovim 0.11
" syn include cannot find syntax/diff.vim via runtimepath, so we forward explicitly.
if exists("b:current_syntax") | finish | endif
execute 'source ' .. $VIMRUNTIME .. '/syntax/diff.vim'
