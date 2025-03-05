local status, lint = pcall(require, "lint")
if not status then return end

local function get_yaml_linter(bufnr)
  local filename = vim.api.nvim_buf_get_name(bufnr)

  -- GitHub Actions Workflow
  if string.match(filename, ".github/workflows/") then
    return "actionlint"
  else
    return "yamllint"
  end
end

lint.linters_by_ft = {
  javascript = { "eslint_d" },
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  vue = { "eslint_d" },
  ruby = { "rubocop" },
  yaml = {},
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    lint.linters_by_ft.yaml = { get_yaml_linter(bufnr) }
    lint.try_lint()
  end,
})
