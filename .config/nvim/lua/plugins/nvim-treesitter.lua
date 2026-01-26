local status, treesitter = pcall(require, "nvim-treesitter")
if (not status) then return end

-- main ブランチでは setup 関数のオプションは install_dir のみ
treesitter.setup({})

-- 自動ハイライトの有効化
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("vim-treesitter-start", {}),
  callback = function()
    -- 遅延ロードしている場合は手動読み込み
    pcall(require, "nvim-treesitter")
    -- パーサーやクエリがあるか気にしなくて済むように pcall でエラーを無視
    pcall(vim.treesitter.start)
  end,
})

require('ts_context_commentstring').setup {}
vim.g.skip_ts_context_commentstring_module = true

-- refs: https://phelipetls.github.io/posts/mdx-syntax-highlight-treesitter-nvim/
vim.treesitter.language.register("markdown", "mdx")
