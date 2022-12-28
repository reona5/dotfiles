local status, mason_lspconfig = pcall(require, "mason-lspconfig")
if (not status) then return end

mason_lspconfig.setup {
  ensure_installed = {
    'diagnostic-languageserver',
    'lua-language-server',
    'textlint',
    'typescript-language-server',
    'terraform-ls',
    'vetur-vls',
    'yamllint',
    'stylelint-lsp',
    'golangci-lint-langserver',
    'gopls',
    'prettierd',
    'prettier',
    'eslint-lsp',
    'eslint_d',
    'haml-lint',
    'vue-language-server',
    'emmet-ls',
    'dockerfile-language-server',
  },
  automatic_installation = true
}
