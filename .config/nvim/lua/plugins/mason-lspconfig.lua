local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'astro',
    'biome',
    'emmet_ls',
    'gopls',
    'intelephense',
    'lua_ls',
    'ruby_lsp',
    'stylelint_lsp',
    'tailwindcss',
    'ts_ls',
    'volar',
  },
  automatic_installation = true
}
