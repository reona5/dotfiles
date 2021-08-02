"return" 2>&- || "exit"

runtime ./plug.vim
runtime ./config.vim
runtime ./maps.vim
colorscheme nord

" Read config files
call map(sort(split(globpath(&runtimepath, './plugins/**'))), {->[execute('exec "so" v:val')]})
