local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'astro',
    'diagnosticls',
    'lua_ls',
    'solargraph',
    'tsserver',
    'volar',
    'stylelint_lsp',
    'gopls',
    'emmet_ls'
  },
  automatic_installation = true
}
