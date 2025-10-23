local mason_path = vim.env.MASON

if not mason_path or mason_path == "" then
  mason_path = vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
end

local vue_path = vim.fs.joinpath(
  mason_path,
  "packages",
  "vue-language-server",
  "node_modules",
  "@vue",
  "language-server"
)

return {
  cmd = { "typescript-language-server", "--stdio" },
  filetypes = {
    "javascript",
    "javascriptreact",
    "javascript.jsx",
    "typescript",
    "typescriptreact",
    "typescript.tsx",
    "vue",
  },
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        languages = { "vue" },
      },
      {
        name = "@vue/typescript-plugin",
        location = vue_path,
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
}
