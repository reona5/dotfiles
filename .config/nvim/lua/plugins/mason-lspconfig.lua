local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'astro',
    'emmet_ls',
    'gopls',
    'lua_ls',
    'rubocop',
    'solargraph',
    'stylelint_lsp',
    'tailwindcss',
    'ts_ls',
    'volar',
  },
  automatic_installation = true
}
