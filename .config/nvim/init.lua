require('base.option')
require('base.maps')
if vim.g.vscode then
else
  require('plugins.lazy')
end

local has = function(x)
  return vim.fn.has(x) == 1
end
local is_mac = has "macunix"
local is_win = has "win32"

if is_mac then
  require('base.macos')
end
if is_win then
  require('base.windows')
end

