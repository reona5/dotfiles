local status, autopairs = pcall(require, "nvim-autopairs")
if (not status) then return end

autopairs.setup({
  disable_filetype = { "TelescopePrompt", "vim" },
})
autopairs.add_rules(require('nvim-autopairs.rules.endwise-ruby'))
