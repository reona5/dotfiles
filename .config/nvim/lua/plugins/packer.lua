local status, packer = pcall(require, 'packer')
if (not status or not packer) then
  print('Packer is not installed')
  return
end
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath('data') .. '/site/pack/packer/start/packer.nvim'
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({ 'git', 'clone', '--depth', '1', 'https://github.com/wbthomason/packer.nvim', install_path })
    vim.cmd [[packadd packer.nvim]]
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

return packer.startup(function(use)
  use 'wbthomason/packer.nvim'
  use {
    'neovim/nvim-lspconfig',
    module = { 'lspconfig' },
    event = { 'BufRead' },
    requires = {
      {
        'williamboman/mason.nvim',
        opts = true,
        module = 'mason',
        cmd = 'Mason',
        requires = {
          'williamboman/mason-lspconfig.nvim',
          opts = true,
          module = 'mason-lspconfig',
          config = function()
            require('plugins.mason-lspconfig')
          end
        },
        config = function()
          require('plugins.mason')
        end
      },
      { 'hrsh7th/cmp-nvim-lsp', opts = true }
    },
    wants = { 'mason-lspconfig.nvim', 'mason.nvim', 'cmp-nvim-lsp' },
    config = function()
      require('plugins.nvim-lspconfig')
    end
  }
  use {
    'glepnir/lspsaga.nvim',
    module = { 'lspsaga' },
    event = 'BufRead',
    config = function()
      require('plugins.lspsaga')
    end,
  }
  use {
    'hrsh7th/nvim-cmp',
    module = { 'cmp' },
    event = { 'InsertEnter' },
    requires = {
      { 'hrsh7th/cmp-buffer', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-path', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-cmdline', event = { 'InsertEnter' } },
      { 'hrsh7th/cmp-vsnip', event = { 'InsertEnter' } },
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
    wants = { 'lspkind-nvim' }
  }
  use {
    'hoob3rt/lualine.nvim',
    module = { 'lualine' },
    event = 'VimEnter',
    requires = { 'kyazdani42/nvim-web-devicons', opts = true },
    wants = { 'nvim-web-devicons' },
    config = function()
      require('plugins.lualine')
    end
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    module = { 'nvim-treesitter' },
    run = ':TSUpdate',
    event = 'BufRead',
    config = function()
      require('plugins.nvim-treesitter')
    end
  }
  use {
    'kyazdani42/nvim-tree.lua',
    module = { 'nvim-tree' },
    event = 'VimEnter',
    requires = { 'kyazdani42/nvim-web-devicons', opts = true },
    wants = { 'nvim-web-devicons' },
    config = function()
      require('plugins.nvim-tree')
    end
  }
  use {
    'lewis6991/gitsigns.nvim',
    module = { 'gitsigns' },
    event = 'BufRead',
    config = function()
      require('plugins.gitsigns')
    end
  }
  use {
    'lukas-reineke/indent-blankline.nvim',
    module = { 'indent_blankline' },
    event = 'BufRead',
    config = function()
      require('plugins.indent-blankline')
    end
  }
  use {
    'terrortylor/nvim-comment',
    module = { 'nvim_comment' },
    event = 'BufRead',
    config = function()
      require('plugins.nvim-comment')
    end
  }
  use {
    'akinsho/bufferline.nvim',
    module = { 'bufferline' },
    event = 'VimEnter',
    requires = { 'kyazdani42/nvim-web-devicons', opts = true },
    wants = { 'nvim-web-devicons' },
    config = function()
      require('plugins.bufferline')
    end
  }
  use {
    'iamcco/markdown-preview.nvim',
    ft = { 'md', 'mdx' },
    run = function()
      vim.fn['mkdp#util#install']()
    end
  }
  use {
    'nvim-telescope/telescope.nvim',
    module = { 'telescope' },
    event = 'VimEnter',
    requires = { 'nvim-lua/plenary.nvim', opts = true },
    wants = { 'plenary.nvim' },
    config = function()
      require('plugins.telescope')
    end
  }
  use {
    'kdheepak/lazygit.nvim',
    event = 'VimEnter',
    config = function()
      require('plugins.lazygit')
    end
  }
  use {
    'tpope/vim-fugitive',
    event = 'VimEnter',
    requires = { 'tpope/vim-rhubarb', opts = true },
    wants = { 'vim-rhubarb' },
    config = function()
      require('plugins.fugitive')
    end
  }
  use {
    'vim-test/vim-test',
    event = 'BufRead',
    requires = { 'preservim/vimux', opts = true },
    wants = { 'vimux' },
    config = function()
      require('plugins.vim-test')
    end
  }
  use {
    'windwp/nvim-ts-autotag',
    module = { 'nvim-ts-autotag' },
    event = { 'InsertEnter' },
    config = function()
      require('plugins.nvim-ts-autotag')
    end
  }
  use {
    'windwp/nvim-autopairs',
    module = { 'nvim-autopairs' },
    event = { 'InsertEnter' },
    config = function()
      require('plugins.nvim-autopairs')
    end
  }
  use {
    'nanotee/sqls.nvim',
    ft = { 'sql' }
  }
  use {
    'rebelot/kanagawa.nvim',
    config = function()
      require('plugins.kanagawa')
    end
  }

  if packer_bootstrap then
    packer.sync()
  end
end)
