local status, lspconfig = pcall(require, "lspconfig")
local capabilities = require("cmp_nvim_lsp").default_capabilities()

capabilities.textDocument.completion.completionItem.snippetSupport = true

if not status then return end

local on_attach = function(_, bufnr)
  -- Enable to insert imported library for golang
  -- refs: https://github.com/golang/tools/blob/master/gopls/doc/vim.md#neovim-imports
  function GoOrgImports(wait_ms)
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, wait_ms)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
  end

  local lsp_format = function()
    -- Avoid format using ts_ls and volar
    -- https://neovim.io/doc/user/lsp.html#vim.lsp.buf.format():~:text=%2D%2D%20Never%20request%20typescript%2Dlanguage%2Dserver%20for%20formatting%0Avim.lsp.buf.format%20%7B%0A%20%20filter%20%3D%20function(client)%20return%20client.name%20~%3D%20%22tsserver%22%20end%0A%7D
    vim.lsp.buf.format({
      filter = function(c) return c.name ~= 'ts_ls' and c.name ~= 'volar' end,
      async = true,
      bufnr = bufnr,
    })
  end

  local group = vim.api.nvim_create_augroup("format", { clear = true })
  vim.api.nvim_create_autocmd("BufWritePre", {
    buffer = bufnr,
    callback = lsp_format,
    group = group,
  })
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = "*.go",
    command = "lua GoOrgImports()",
    group = group,
  })

  local opts = { noremap = true, silent = true }
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-[>", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-]>", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-t>", "<cmd>lua vim.lsp.buf.references()<CR>", opts)
  -- vim.api.nvim_buf_set_keymap(bufnr, "n", "<C-t>", "<cmd>lua vim.lsp.buf.implementation()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wa", "<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>wr", "<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>", opts)
  vim.api.nvim_buf_set_keymap(
    bufnr,
    "n",
    "<space>wl",
    "<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>",
    opts
  )
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>D", "<cmd>lua vim.lsp.buf.type_definition()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", "<space>q", "<cmd>lua vim.diagnostic.setloclist()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", ",a", "<cmd>lua vim.lsp.buf.code_action()<CR>", opts)
  vim.api.nvim_buf_set_keymap(bufnr, "n", ",f", "", {
    noremap = true,
    silent = true,
    callback = lsp_format,
  })
end

-- diagnosticls
lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'javascript', 'javascriptreact', 'json', 'typescript', 'typescriptreact', 'css', 'less', 'scss',
    'markdown', 'vue', 'astro', 'mdx', 'yaml', 'txt' },
  init_options = {
    -- linters = {
    --   eslint = {
    --     sourceName = 'eslint',
    --     command = 'eslint',
    --     rootPatterns = {
    --       'package.json'
    --     },
    --     debounce = 100,
    --     args = {
    --       '--cache',
    --       '--stdin',
    --       '--stdin-filename',
    --       '%filepath',
    --       '--format',
    --       'json'
    --     },
    --     parseJson = {
    --       errorsRoot = '[0].messages',
    --       line = 'line',
    --       column = 'column',
    --       endLine = 'endLine',
    --       endColumn = 'endColumn',
    --       message = '${message} [${ruleId}]',
    --       security = 'severity'
    --     },
    --     securities = {
    --       [2] = 'error',
    --       [1] = 'warning'
    --     }
    --   },
    --   eslint_d = {
    --     command = 'eslint_d',
    --     rootPatterns = { '.git' },
    --     debounce = 100,
    --     args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
    --     sourceName = 'eslint_d',
    --     parseJson = {
    --       errorsRoot = '[0].messages',
    --       line = 'line',
    --       column = 'column',
    --       endLine = 'endLine',
    --       endColumn = 'endColumn',
    --       message = '[eslint] ${message} [${ruleId}]',
    --       security = 'severity'
    --     },
    --     securities = {
    --       [2] = 'error',
    --       [1] = 'warning'
    --     }
    --   },
    --   actionlint = {
    --     command = 'actionlint',
    --     sourceName = 'actionlint',
    --     rootPatterns = {
    --       '.github/workflows/*.yml',
    --       '.github/workflows/*.yaml'
    --     },
    --     debounce = 100,
    --     args = { '-oneline', '-stdin-filename', '%filepath', '-format', '{{json .}}' },
    --     isStderr = false,
    --     isStdout = true,
    --     parseJson = {
    --       errorsRoot = '[0].messages',
    --       line = 'line',
    --       column = 'column',
    --       endLine = 'endLine',
    --       endColumn = 'endColumn',
    --       message = '[actionlint] ${message} [${ruleId}]',
    --       security = 'severity'
    --     },
    --     formatLines = 1,
    --     formatPattern = {
    --       "^([^:]+):(\\d+):(\\d+):\\s+(.*)$",
    --       {
    --         line = 'line',
    --         column = 'column',
    --         message = 'message',
    --         security = 'security'
    --       }
    --     },
    --     securities = {
    --       [2] = 'error',
    --       [1] = 'warning'
    --     }
    --   }
    -- },
    -- filetypes = {
    --   javascript = 'eslint',
    --   javascriptreact = 'eslint',
    --   typescript = 'eslint',
    --   typescriptreact = 'eslint',
    --   astro = 'eslint',
    --   vue = 'eslint',
    --   yaml = 'actionlint'
    -- },
    formatters = {
      prettier = {
        command = 'prettier',
        rootPatterns = { 'package.json' },
        args = { '--stdin-filepath', '%filename' }
      },
    },
    formatFiletypes = {
      css = 'prettier',
      javascript = 'prettier',
      javascriptreact = 'prettier',
      json = 'prettier',
      scss = 'prettier',
      less = 'prettier',
      typescript = 'prettier',
      typescriptreact = 'prettier',
      astro = 'prettier',
      vue = 'prettier',
      markdown = 'prettier',
      mdx = 'prettier',
      yaml = 'prettier',
    }
  }
}

-- diagnostics-icon
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
  underline = true,
  virtual_text = {
    spacing = 4,
    prefix = "",
  },
})

-- biome
lspconfig.biome.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})

-- emmet
lspconfig.emmet_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { "html", "typescriptreact", "javascriptreact", "vue", "css", "sass", "scss", "less", "astro" },
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ["bem.enabled"] = true,
      },
    },
  },
})

-- gopls
lspconfig.gopls.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

-- intelephense
lspconfig.intelephense.setup({
  on_attach = on_attach,
  capabilities = capabilities
})

-- lua-language-server
local runtime_path = vim.split(package.path, ";")
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.lua_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      format = {
        enable = true,
      },
      runtime = {
        version = "LuaJIT",
        path = runtime_path,
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

-- ruby_lsp
lspconfig.ruby_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  flags = {
    debounce_text_changes = 150,
  },
  settings = {
    rubyLsp = {
      formatter = true,
      diagnostics = {
        enabled = true,
      },
    },
  },
})

-- stylelint
lspconfig.stylelint_lsp.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    stylelintplus = {
      autoFixOnSave = true,
      autoFixOnFormat = true,
    },
  },
})

-- ts_ls
lspconfig.ts_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  init_options = {
    plugins = {
      {
        name = "@vue/typescript-plugin",
        location = require("mason-registry").get_package("vue-language-server"):get_install_path() ..
            "/node_modules/@vue/language-server/node_modules/@vue/typescript-plugin",
        languages = { "javascript", "typescript", "vue" },
      },
    },
  },
  filetypes = { "javascript", "javascriptreact", "javascript.jsx", "typescript", "typescriptreact", "typescript.tsx", "vue" },
})

-- volar
lspconfig.volar.setup({
  on_attach = on_attach,
  capabilities = capabilities,
})
