require("remote-nvim").setup({
  -- Configuration for SSH connections
  ssh = {
    -- Example SSH configuration
    -- You can customize this based on your needs
  },
  -- Configuration for Docker connections
  docker = {
    -- Docker configuration
  },
  -- Remote plugins directory (where plugins will be installed on remote)
  remote_plugins_dir = vim.fn.stdpath("data") .. "/remote-nvim",
  -- Client configurations
  client = {
    -- The path on your local machine to store remote configurations
    config_path = vim.fn.stdpath("data") .. "/remote-nvim/client",
  },
})
