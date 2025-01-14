local status, cmp = pcall(require, "cmp")
local lspkind = require('lspkind')

if (not status) then return end

local has_words_before = function()
  if vim.bo.buftype == "prompt" then return false end
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  local text_before_cursor = vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]
  return col ~= 0 and text_before_cursor:match("^%s*$") == nil
end

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      mode = "symbol",
      max_width = 50,
      preset = 'codicons',
      symbol_map = { Copilot = '' },
      ellipsis_char = '...',
    })
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-]>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ["<Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
    ["<S-Tab>"] = vim.schedule_wrap(function(fallback)
      if cmp.visible() and has_words_before() then
        cmp.select_prev_item({ behavior = cmp.SelectBehavior.Select })
      else
        fallback()
      end
    end),
  },
  sources = cmp.config.sources({
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    -- { name = 'copilot' },
  }, {
    { name = 'buffer' },
  }),
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  }),
  matching = { disallow_symbol_nonprefix_matching = false }
})
