local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'astro',
    'emmet_ls',
    'gopls',
    'lua_ls',
    'solargraph',
    'stylelint_lsp',
    'tailwindcss',
    'tsserver',
    'volar',
  },
  automatic_installation = true
}
