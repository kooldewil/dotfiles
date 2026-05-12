-- Autocmds are automatically loaded on the VeryLazy event
-- https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Treat *.json files as jsonc so comments are allowed (tsconfig, etc.)
vim.api.nvim_create_autocmd({ "BufNewFile", "BufRead", "BufWinEnter", "BufEnter" }, {
  group = vim.api.nvim_create_augroup("FileJsonc", {}),
  pattern = { "*.json" },
  callback = function()
    vim.opt.filetype = "jsonc"
  end,
})
