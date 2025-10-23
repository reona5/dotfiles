return {
  cmd = { "emmet-language-server", "--stdio" },
  filetypes = {
    "html",
    "typescriptreact",
    "javascriptreact",
    "vue",
    "css",
    "sass",
    "scss",
    "less",
    "astro",
  },
  init_options = {
    html = {
      options = {
        ["bem.enabled"] = true,
      },
    },
  },
}
