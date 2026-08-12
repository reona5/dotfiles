-- herdr のペイン内では option.lua が 'clipboard' を空にして、yank のときだけ
-- OSC 52 で送る方式にしている。ここで足し直すと削除内容まで流れてしまう。
if vim.env.HERDR_ENV ~= "1" then
  vim.opt.clipboard:append { 'unnamedplus' }
end
