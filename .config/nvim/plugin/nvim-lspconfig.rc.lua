local status, lspconfig = pcall(require, "lspconfig")
local cmp_nvim_lsp = require('cmp_nvim_lsp')
local capabilities = cmp_nvim_lsp.default_capabilities()
if (not status) then return end

local on_attach = function(client, bufnr)
  -- Enable to insert imported library for golang
  function OrgImports(wait_ms)
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

  if client.server_capabilities.documentFormattingProvider then
    local group = vim.api.nvim_create_augroup('format', { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      command = 'lua vim.lsp.buf.formatting { async = true }',
      group = group
    })
    vim.api.nvim_create_autocmd("BufWritePre", {
      pattern = '*.go',
      command = 'lua OrgImports(100)',
      group = group
    })
  end

  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap = true, silent = true }
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-[>', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-]>', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<C-t>', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>wl',
    '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<space>q', '<cmd>lua vim.diagnostic.setloclist()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',f', '<cmd>lua vim.lsp.buf.formatting()<CR>', opts)
end

-- diagnosticls
lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'javascript', 'javascriptreact', 'json', 'typescript', 'typescriptreact', 'ruby', 'css', 'less', 'scss',
    'markdown', 'vue' },
  init_options = {
    linters = {
      eslint = {
        sourceName = 'eslint',
        command = 'eslint',
        rootPatterns = {
          '.git',
          'package.json'
        },
        debounce = 100,
        args = {
          '--cache',
          '--stdin',
          '--stdin-filename',
          '%filepath',
          '--format',
          'json'
        },
        parseJson = {
          errorsRoot = '[0].messages',
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '${message} [${ruleId}]',
          security = 'severity'
        },
        securities = {
          [2] = 'error',
          [1] = 'warning'
        }
      },
      eslint_d = {
        command = 'eslint_d',
        rootPatterns = { '.git' },
        debounce = 100,
        args = { '--stdin', '--stdin-filename', '%filepath', '--format', 'json' },
        sourceName = 'eslint_d',
        parseJson = {
          errorsRoot = '[0].messages',
          line = 'line',
          column = 'column',
          endLine = 'endLine',
          endColumn = 'endColumn',
          message = '[eslint] ${message} [${ruleId}]',
          security = 'severity'
        },
        securities = {
          [2] = 'error',
          [1] = 'warning'
        }
      },
      rubocop = {
        command = 'bundle',
        args = { 'exec', 'rubocop', '--format', 'json', '--force-exclusion', '%filepath' },
        debounce = 100,
        sourceName = 'rubocop',
        parseJson = {
          errorsRoot = 'files[0].offenses',
          line = 'location.line',
          column = 'location.column',
          message = '[${cop_name}] ${message}',
          security = 'severity'
        },
        securities = {
          fatal = 'error',
          warning = 'warning'
        }
      }
    },
    filetypes = {
      javascript = 'eslint',
      javascriptreact = 'eslint',
      typescript = 'eslint',
      typescriptreact = 'eslint',
      vue = 'eslint',
      ruby = 'rubocop'
    },
    formatters = {
      eslint = {
        command = 'eslint_d',
        args = { '--stdin', '--stdin-filename', '%filename', '--fix-to-stdout' },
        rootPatterns = { '.git' },
      },
      prettier = {
        command = 'prettier',
        args = { '--stdin-filepath', '%filename' }
      },
      rubocop = {
        command = 'bundle',
        args = { 'exec', 'rubocop', '-a', '--stderr', '--stdin', '%filepath' }
      },
      stylelint = {
        command = 'stylelint',
        args = { '--fix', '--stdin', '--stdin-filename', '%filepath' },
      }
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
      ruby = 'rubocop',
      vue = 'prettier',
      markdown = 'prettier',
    }
  }
}

-- diagnostics-icon
vim.lsp.handlers["textDocument/publishDiagnostics"] = vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics,
  {
    underline = true,
    virtual_text = {
      spacing = 4,
      prefix = ''
    }
  }
)

-- lua-language-server
local runtime_path = vim.split(package.path, ';')
table.insert(runtime_path, "lua/?.lua")
table.insert(runtime_path, "lua/?/init.lua")

lspconfig.sumneko_lua.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  settings = {
    Lua = {
      format = {
        enable = true,
      },
      runtime = {
        version = 'LuaJIT',
        path = runtime_path,
      },
      diagnostics = {
        globals = { 'vim' },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
      },
      telemetry = {
        enable = false,
      },
    },
  },
}

-- solargraph
lspconfig.solargraph.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "solargraph", "stdio" },
  init_options = {
    formatting = false
  },
  settings = {
    solargraph = {
      diagnostics = false
    }
  }
}

-- vuels
lspconfig.vuels.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- stylelint
lspconfig.stylelint_lsp.setup {
  filetypes = {
    'css',
    'scss',
    'vue'
  },
  cmd = { "stylelint-lsp", "--stdio" },
  settings = {
    stylelintplus = {
      autoFixOnSave = true,
      autoFixOnFormat = true,
    }
  }
}

-- gopls
lspconfig.gopls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  cmd = { "gopls", "serve" },
  filetypes = { "go", "gomod" },
  root_dir = require 'lspconfig.util'.root_pattern("go.work", "go.mod", ".git"),
  settings = {
    gopls = {
      analyses = {
        unusedparams = true,
      },
      staticcheck = true,
    },
  },
}

-- sqls
lspconfig.sqls.setup {
  on_attach = on_attach,
  capabilities = capabilities
}
