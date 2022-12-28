vim.cmd([[
  let g:vsnip_filetypes.ruby = ['rails']
  let g:lsp_settings = {
    \   'gopls': {
    \     'initialization_options': {
    \       'usePlaceholders': v:true,
    \     },
    \   },
    \ }
]])
