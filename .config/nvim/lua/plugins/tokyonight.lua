require("tokyonight").setup({
    style = "night", -- storm, moon, night, day
    styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
        comments = { italic = true },
        keywords = { italic = true },
    },
})

-- setup must be called before loading
vim.cmd.colorscheme "tokyonight"
