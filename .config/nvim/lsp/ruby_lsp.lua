return {
  cmd = { vim.fn.trim(vim.fn.system("which ruby-lsp")) },
  filetypes = { "ruby" },
  root_markers = { "Gemfile", ".ruby-version", ".git" },
  settings = {
    rubyLsp = {
      formatter = "auto",
    },
  },
}
