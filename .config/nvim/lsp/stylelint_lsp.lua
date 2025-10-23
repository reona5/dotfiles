return {
  cmd = { "stylelint-lsp", "--stdio" },
  filetypes = { "css", "less", "scss", "sugarss", "vue" },
  settings = {
    stylelintplus = {
      autoFixOnSave = true,
      autoFixOnFormat = true,
    },
  },
}
