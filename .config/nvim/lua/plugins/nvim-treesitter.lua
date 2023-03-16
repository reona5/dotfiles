local status, _ = pcall(require, "nvim-treesitter")
if (not status) then return end

-- NOTE: https://github.com/nvim-treesitter/nvim-treesitter/issues/270#issuecomment-725883316jI
require 'nvim-treesitter.configs'.setup {
  ensure_installed = 'all',
  sync_install = false,
  auto_install = true,
  ignore_install = { "phpdoc" },
  indent = {
    enable = true
  },
  highlight = {
    enable = true,
    -- https://github.com/nvim-treesitter/nvim-treesitter/issues/703#issuecomment-818838957
    additional_vim_regex_highlighting = true,
  },
}

-- refs: https://phelipetls.github.io/posts/mdx-syntax-highlight-treesitter-nvim/
require("nvim-treesitter.parsers").filetype_to_parsername.mdx = "markdown"
