local status, copilotCmp = pcall(require, "copilot_cmp")
if (not status) then return end

-- copilot-cmp still calls client.is_stopped(), which is deprecated in Nvim 0.12.
local source = require("copilot_cmp.source")

function source:is_available()
  if self.client:is_stopped() or self.client.name ~= "copilot" then
    return false
  end

  return next(vim.lsp.get_clients({
    bufnr = vim.api.nvim_get_current_buf(),
    id = self.client.id,
  })) ~= nil
end

copilotCmp.setup({
  event = { "InsertEnter", "LspAttach" },
  fix_pairs = true,
})
