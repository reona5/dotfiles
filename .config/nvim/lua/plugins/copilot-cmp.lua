local status, copilotCmp = pcall(require, "copilot_cmp")
if (not status) then return end

copilotCmp.setup({})
