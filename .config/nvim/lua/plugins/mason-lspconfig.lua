local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'diagnosticls',
    'sumneko_lua',
    'solargraph',
    'tsserver',
    'vuels',
    'stylelint_lsp',
    'gopls',
    'emmet_ls'
  },
  automatic_installation = true
}
