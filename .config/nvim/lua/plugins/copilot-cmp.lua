local status, copilotCmp = pcall(require, "copilot_cmp")
if (not status) then return end

copilotCmp.setup({
  event = { "InsertEnter", "LspAttach" },
  fix_pairs = true,
})
