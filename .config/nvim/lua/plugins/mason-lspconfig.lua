local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'astro',
    'lua_ls',
    'solargraph',
    'volar',
    'stylelint_lsp',
    'gopls',
    'emmet_ls',
    'tailwindcss',
    'tsserver'
  },
  automatic_installation = true
}
