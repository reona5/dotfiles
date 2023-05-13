local status, lspconfig = pcall(require, "lspconfig")
local capabilities = require('cmp_nvim_lsp').default_capabilities()
capabilities.textDocument.completion.completionItem.snippetSupport = true

if (not status) then return end

local on_attach = function(client, bufnr)
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

  if client.server_capabilities.documentFormattingProvider then
    local group = vim.api.nvim_create_augroup('format', { clear = true })
    vim.api.nvim_create_autocmd("BufWritePre", {
      buffer = bufnr,
      callback = function()
        vim.lsp.buf.format { async = true }
      end,
      group = group
    })
    vim.api.nvim_create_autocmd("BufWritePost", {
      pattern = '*.go',
      command = 'lua GoOrgImports()',
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
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',a', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ',f', '', {
    noremap = true,
    silent = true,
    callback = function()
      vim.lsp.buf.format { async = true }
    end
  })
end

-- diagnosticls
lspconfig.diagnosticls.setup {
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'javascript', 'javascriptreact', 'json', 'typescript', 'typescriptreact', 'ruby', 'css', 'less', 'scss',
    'markdown', 'vue', 'astro', 'mdx', 'yml' },
  init_options = {
    linters = {
      eslint = {
        options = {
          rulePaths = { 'config/eslint/custom_rules' }
        },
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
      astro = 'eslint',
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
      astro = 'prettier',
      ruby = 'rubocop',
      vue = 'prettier',
      markdown = 'prettier',
      mdx = 'prettier',
      yml = 'prettier',
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

lspconfig.lua_ls.setup {
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

-- volar
lspconfig.volar.setup {
  on_attach = on_attach,
  capabilities = capabilities,
}

-- tsserver
lspconfig.tsserver.setup {
  capabilities = capabilities,
  -- refs: https://www.reddit.com/r/neovim/comments/nv3qh8/comment/h11d6cf/?utm_source=share&utm_medium=web2x&context=3
  handlers = {
    ['textDocument/publishDiagnostics'] = function()
    end
  },
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

-- sqlls
lspconfig.sqlls.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

-- astro
lspconfig.astro.setup {
  on_attach = on_attach,
  capabilities = capabilities
}

-- emmet
lspconfig.emmet_ls.setup({
  on_attach = on_attach,
  capabilities = capabilities,
  filetypes = { 'html', 'typescriptreact', 'javascriptreact', 'vue', 'css', 'sass', 'scss', 'less', 'astro' },
  init_options = {
    html = {
      options = {
        -- For possible options, see: https://github.com/emmetio/emmet/blob/master/src/config.ts#L79-L267
        ["bem.enabled"] = true,
      },
    },
  }
})
