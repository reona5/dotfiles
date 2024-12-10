local status, copilot = pcall(require, "copilot")
if (not status) then return end

local node_path = vim.fn.system('which node'):gsub('%s+', '')

copilot.setup({
  copilot_node_command = node_path,
  suggestion = { enabled = false, auto_trigger = true },
  panel = { enabled = false },
})
