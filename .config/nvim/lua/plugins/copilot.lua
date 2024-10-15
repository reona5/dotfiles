local status, copilot = pcall(require, "copilot")
if (not status) then return end

copilot.setup({
  copilot_node_command = vim.fn.expand("$HOME") .. "/.asdf/shims/node",
  suggestion = { enabled = false, auto_trigger = true },
  panel = { enabled = false },
})
