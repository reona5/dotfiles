local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out,                            "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("plugins.catppuccin")
    end
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufRead" },
    dependencies = {
      {
        "williamboman/mason.nvim",
        lazy = true,
        cmd = "Mason",
        config = function()
          require("plugins.mason")
        end,
      },
      {
        "williamboman/mason-lspconfig.nvim",
        lazy = true,
        config = function()
          require("plugins.mason-lspconfig")
        end
      },
      { "hrsh7th/cmp-nvim-lsp", lazy = true },
    },
    config = function()
      require("plugins.nvim-lspconfig")
    end
  },
  {
    "mfussenegger/nvim-lint",
    event = {
      "BufReadPre",
      "BufNewFile",
    },
    config = function()
      require("plugins.nvim-lint")
    end
  },
  {
    "glepnir/lspsaga.nvim",
    event = "BufRead",
    config = function()
      require("plugins.lspsaga")
    end,
  },
  {
    "hrsh7th/nvim-cmp",
    event = { "InsertEnter" },
    dependencies = {
      { "hrsh7th/cmp-buffer",  event = { "InsertEnter" } },
      { "hrsh7th/cmp-path",    event = { "InsertEnter" } },
      { "hrsh7th/cmp-cmdline", event = { "InsertEnter" } },
      { "hrsh7th/cmp-vsnip",   event = { "InsertEnter" } },
      {
        "hrsh7th/vim-vsnip",
        event = { "InsertEnter" },
        config = function()
          require("plugins.vim-vsnip")
        end
      },
      { "onsails/lspkind-nvim", event = { "InsertEnter" } },
    },
    config = function()
      require("plugins.nvim-cmp")
    end,
  },
  {
    "hoob3rt/lualine.nvim",
    event = "VimEnter",
    dependencies = {
      { "kyazdani42/nvim-web-devicons", lazy = true },
    },
    config = function()
      require("plugins.lualine")
    end
  },
  {
    "tpope/vim-fugitive",
    dependencies = { "tpope/vim-rhubarb", lazy = true },
    config = function()
      require("plugins.fugitive")
    end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    dependencies = { "JoosepAlviste/nvim-ts-context-commentstring" },
    build = ":TSUpdate",
    event = "BufRead",
    config = function()
      require("plugins.nvim-treesitter")
    end
  },
  {
    "kyazdani42/nvim-tree.lua",
    dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
    config = function()
      require("plugins.nvim-tree")
    end
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufRead",
    config = function()
      require("plugins.gitsigns")
    end
  },
  {
    "lukas-reineke/indent-blankline.nvim",
    version = "2.20.8",
    event = "BufRead",
    config = function()
      require("plugins.indent-blankline")
    end
  },
  {
    "terrortylor/nvim-comment",
    event = "BufRead",
    config = function()
      require("plugins.nvim-comment")
    end
  },
  {
    "akinsho/bufferline.nvim",
    event = "VimEnter",
    dependencies = { "kyazdani42/nvim-web-devicons", lazy = true },
    config = function()
      require("plugins.bufferline")
    end
  },
  {
    "iamcco/markdown-preview.nvim",
    build = function()
      vim.fn["mkdp#util#install"]()
    end
  },
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", lazy = true },
    event = "VimEnter",
    config = function()
      require("plugins.telescope")
    end
  },
  {
    "vim-test/vim-test",
    event = "BufRead",
    dependencies = { "preservim/vimux", lazy = true },
    config = function()
      require("plugins.vim-test")
    end
  },
  {
    "windwp/nvim-ts-autotag",
    event = { "InsertEnter" },
    config = function()
      require("plugins.nvim-ts-autotag")
    end
  },
  {
    "windwp/nvim-autopairs",
    event = { "InsertEnter" },
    config = function()
      require("plugins.nvim-autopairs")
    end
  },
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    dependencies = { "zbirenbaum/copilot-cmp", lazy = true },
    config = function()
      require("plugins.copilot")
    end,
  },
  {
    "zbirenbaum/copilot-cmp",
    dependencies = { "hrsh7th/nvim-cmp", lazy = true },
    config = function()
      require("plugins.copilot-cmp")
    end
  },
  {
    "CopilotC-Nvim/CopilotChat.nvim",
    event = { "BufRead" },
    branch = "main",
    dependencies = {
      { "zbirenbaum/copilot.lua",        lazy = true },
      { "nvim-lua/plenary.nvim",         lazy = true },
      { "nvim-telescope/telescope.nvim", lazy = true },
    },
    config = function()
      require("plugins.copilot-chat")
    end,
    keys = {
      {
        ",cp",
        function()
          local actions = require("CopilotChat.actions")
          require("CopilotChat.integrations.telescope").pick(actions.prompt_actions())
        end,
        desc = "CopilotChat - Prompt actions",
        mode = { "n", "v" }
      },
      {
        ",ca",
        function()
          local input = vim.fn.input("Quick Chat: ")
          if input ~= "" then
            require("CopilotChat").ask(input, { selection = require("CopilotChat.select").buffer })
          end
        end,
        desc = "CopilotChat - Quick chat",
        mode = { "n", "v" }
      },
    }
  },
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    lazy = false,
    version = "*",
    build = "make",
    opts = {
      provider = "copilot",
      auto_suggestions_provider = "copilot",
      behaviour = {
        support_paste_from_clipboard = true,
      },
    },
    dependencies = {
      "stevearc/dressing.nvim",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      "hrsh7th/nvim-cmp",
      "nvim-tree/nvim-web-devicons",
      "zbirenbaum/copilot.lua",
      {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
          },
        },
      },
      {
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
})
