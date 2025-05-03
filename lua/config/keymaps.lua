-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>cD", function()
  require("cmp").setup({ enabled = false })
  vim.notify("nvim-cmp globally disabled")
end, { desc = "Disable nvim-cmp globally" })

vim.keymap.set("n", "<leader>cE", function()
  require("cmp").setup({ enabled = true })
  vim.notify("nvim-cmp globally enabled")
end, { desc = "Enable nvim-cmp globally" })
