local utils = require("serranomorante.utils")

-- Toggle wrap
vim.keymap.set("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. (vim.wo.wrap and "enabled" or "disabled"))
end, { desc = "Toggle wrap" })

-- New file
vim.keymap.set("n", "<leader>n", "<cmd>enew<cr>", { desc = "New buffer" })
vim.keymap.set("n", "<leader>c", "<cmd>bd<cr>", { desc = "Close buffer" })

-- Move selected lines around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "H", "<gv")
vim.keymap.set("v", "L", ">gv")

-- Delete highlighted word into the void
-- register and paste over it.
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without losing previous copy" })

-- Replace the highlighted word
vim.keymap.set(
  "n",
  "<leader>s",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace highlighted word" }
)

-- Horizontal and vertical splits
vim.keymap.set("n", "ss", "<cmd>split<CR><C-w>w", { desc = "Horizontal split" })
vim.keymap.set("n", "sv", "<cmd>vsplit<CR><C-w>w", { desc = "Vertical split" })

-- Close window
vim.keymap.set("n", "<C-q>", "<C-w>q")

-- Tabs navigation
vim.keymap.set("n", "te", "<cmd>tabedit<CR>", { desc = "New tab" })
vim.keymap.set("n", "H", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
vim.keymap.set("n", "L", "<cmd>tabnext<CR>", { desc = "Next tab" })

-- Tabs move
vim.keymap.set("n", "<t", "<cmd>tabmove -1<CR>", { desc = "Move tab left" })
vim.keymap.set("n", ">t", "<cmd>tabmove +1<CR>", { desc = "Move tab right" })

vim.keymap.set("n", "<leader>qf", function() utils.toggle_qf("q") end, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<leader>ql", function() utils.toggle_qf("l") end, { desc = "Toggle location list" })
