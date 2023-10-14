local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git',
    'clone',
    '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require('lazy').setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require('plugins.catputtin')
    end
  },
  {
    'neovim/nvim-lspconfig',
    event = { 'BufRead' },
    dependencies = {
      {
        'williamboman/mason.nvim',
        lazy = true,
        cmd = 'Mason',
        config = function()
          require('plugins.mason')
        end,
      },
      {
        'williamboman/mason-lspconfig.nvim',
        lazy = true,
        config = function()
          require('plugins.mason-lspconfig')
        end
      },
      { 'hrsh7th/cmp-nvim-lsp',                  lazy = true },
      { 'davidosomething/format-ts-errors.nvim', lazy = true },
    },
    config = function()
      require('plugins.nvim-lspconfig')
    end
  },
  {
    'glepnir/lspsaga.nvim',
    event = 'BufRead',
    config = function()
      require('plugins.lspsaga')
    end,
  },
  {
    'hrsh7th/nvim-cmp',
    event = { 'InsertEnter' },
    dependencies = {
      { 'hrsh7th/cmp-buffer',  event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-path',    event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-cmdline', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-vsnip',   event = { 'InsertEnter' } },
      {
        'hrsh7th/vim-vsnip',
        event = { 'InsertEnter' },
        config = function()
          require('plugins.vim-vsnip')
        end
      },
      { 'onsails/lspkind-nvim', event = { 'InsertEnter' } },
    },
    config = function()
      require('plugins.nvim-cmp')
    end,
  },
  {
    'hoob3rt/lualine.nvim',
    event = 'VimEnter',
    dependencies = {
      { 'kyazdani42/nvim-web-devicons', lazy = true },
    },
    config = function()
      require('plugins.lualine')
    end
  },
  {
    'tpope/vim-fugitive',
    dependencies = { 'tpope/vim-rhubarb', lazy = true },
    config = function()
      require('plugins.fugitive')
    end
  },
  {
    'nvim-treesitter/nvim-treesitter',
    dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
    build = ':TSUpdate',
    event = 'BufRead',
    config = function()
      require('plugins.nvim-treesitter')
    end
  },
  {
    'kyazdani42/nvim-tree.lua',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
    config = function()
      require('plugins.nvim-tree')
    end
  },
  {
    'lewis6991/gitsigns.nvim',
    event = 'BufRead',
    config = function()
      require('plugins.gitsigns')
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
    version = '2.20.8',
    event = 'BufRead',
    config = function()
      require('plugins.indent-blankline')
    end
  },
  {
    'terrortylor/nvim-comment',
    event = 'BufRead',
    config = function()
      require('plugins.nvim-comment')
    end
  },
  {
    'akinsho/bufferline.nvim',
    event = 'VimEnter',
    dependencies = { 'kyazdani42/nvim-web-devicons', lazy = true },
    config = function()
      require('plugins.bufferline')
    end
  },
  {
    'iamcco/markdown-preview.nvim',
    build = function()
      vim.fn['mkdp#util#install']()
    end
  },
  {
    'nvim-telescope/telescope.nvim',
    dependencies = { 'nvim-lua/plenary.nvim', lazy = true },
    config = function()
      require('plugins.telescope')
    end
  },
  {
    'kdheepak/lazygit.nvim',
    event = 'VimEnter',
    config = function()
      require('plugins.lazygit')
    end
  },
  {
    'vim-test/vim-test',
    event = 'BufRead',
    dependencies = { 'preservim/vimux', lazy = true },
    config = function()
      require('plugins.vim-test')
    end
  },
  {
    'windwp/nvim-ts-autotag',
    event = { 'InsertEnter' },
    config = function()
      require('plugins.nvim-ts-autotag')
    end
  },
  {
    'windwp/nvim-autopairs',
    event = { 'InsertEnter' },
    config = function()
      require('plugins.nvim-autopairs')
    end
  },
})
