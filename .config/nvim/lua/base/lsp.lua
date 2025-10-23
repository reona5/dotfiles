local ok_cmp, cmp_lsp = pcall(require, "cmp_nvim_lsp")
local capabilities = vim.lsp.protocol.make_client_capabilities()

if ok_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

capabilities.textDocument.completion.completionItem.snippetSupport = true

vim.lsp.config("*", {
  capabilities = capabilities,
})

vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(
  vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    virtual_text = {
      spacing = 4,
      prefix = "",
    },
  }
)

local format_group = vim.api.nvim_create_augroup("LspFormatOnSave", { clear = true })
local go_import_group = vim.api.nvim_create_augroup("LspGoImports", { clear = true })
local attach_group = vim.api.nvim_create_augroup("BaseLspOnAttach", { clear = true })

local function go_org_imports(bufnr, wait_ms)
  local params = vim.lsp.util.make_range_params()
  params.context = { only = { "source.organizeImports" } }

  local result = vim.lsp.buf_request_sync(bufnr, "textDocument/codeAction", params, wait_ms)
  for client_id, res in pairs(result or {}) do
    for _, action in pairs(res.result or {}) do
      if action.edit then
        local client = vim.lsp.get_client_by_id(client_id)
        local encoding = client and client.offset_encoding or "utf-16"
        vim.lsp.util.apply_workspace_edit(action.edit, encoding)
      end
    end
  end
end

vim.api.nvim_create_autocmd("LspAttach", {
  group = attach_group,
  callback = function(args)
    local bufnr = args.buf
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if not client then
      return
    end

    local function lsp_format()
      vim.lsp.buf.format({
        filter = function(c)
          return c.name ~= "ts_ls" and c.name ~= "volar"
        end,
        async = true,
        bufnr = bufnr,
      })
    end

    vim.api.nvim_clear_autocmds({ group = format_group, buffer = bufnr })
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = format_group,
      buffer = bufnr,
      callback = lsp_format,
    })

    if vim.bo[bufnr].filetype == "go" then
      vim.api.nvim_clear_autocmds({ group = go_import_group, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = go_import_group,
        buffer = bufnr,
        callback = function()
          go_org_imports(bufnr, 1000)
        end,
      })
    end

    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set("n", "<C-[>", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "<C-]>", vim.lsp.buf.definition, opts)
    vim.keymap.set("n", "<C-t>", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set("n", "<space>wl", function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set("n", "<space>D", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<space>q", vim.diagnostic.setloclist, opts)
    vim.keymap.set("n", ",a", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", ",f", lsp_format, opts)
  end,
})

local ok_registry, registry = pcall(require, "mason-registry")
if ok_registry then
  local packages = {
    "astro-language-server",
    -- "biome",
    "diagnostic-languageserver",
    "emmet-language-server",
    "gopls",
    "intelephense",
    "lua-language-server",
    "ruby-lsp",
    "stylelint-lsp",
    "tailwindcss-language-server",
    "typescript-language-server",
    "vue-language-server",
  }

  local function ensure_installed()
    for _, name in ipairs(packages) do
      local ok, pkg = pcall(registry.get_package, name)
      if ok and not pkg:is_installed() then
        pkg:install()
      end
    end
  end

  if registry.refresh then
    registry.refresh(ensure_installed)
  else
    ensure_installed()
  end
end

vim.lsp.enable({
  "diagnosticls",
  -- "biome", diagnosticls と競合するケースがあるので必要になるまではエスケープ
  "emmet_ls",
  "gopls",
  "intelephense",
  "lua_ls",
  "ruby_lsp",
  "stylelint_lsp",
  "ts_ls",
  "volar",
})
