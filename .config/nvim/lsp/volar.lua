return {
  cmd = { "vue-language-server", "--stdio" },
  filetypes = { "vue" },
  init_options = {
    documentFeatures = {
      documentFormatting = {
        defaultPrintWidth = 100,
      },
    },
  },
}
