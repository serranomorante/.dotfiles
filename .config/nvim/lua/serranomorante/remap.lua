local utils = require("serranomorante.utils")

-- Toggle wrap
vim.keymap.set("n", "<leader>uw", function()
  vim.wo.wrap = not vim.wo.wrap
  vim.notify("Wrap " .. utils.bool2str(vim.wo.wrap))
end, { desc = "Toggle wrap" })

-- New file
vim.keymap.set("n", "<leader>n", "<cmd>enew<cr>", { desc = "New buffer" })

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
  "<leader>sr",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace highlighted word" }
)

-- Horizontal and vertical splits
vim.keymap.set("n", "ss", "<cmd>split<CR><C-w>w", { desc = "Horizontal split" })
vim.keymap.set("n", "sv", "<cmd>vsplit<CR><C-w>w", { desc = "Vertical split" })

-- Close window
vim.keymap.set("n", "<C-q>", "<cmd>close<CR>")

-- Tabs navigation
vim.keymap.set("n", "te", "<cmd>tabedit<CR>", { desc = "New tab" })
vim.keymap.set("n", "<leader>zf", function()
  -- https://github.com/pocco81/true-zen.nvim/blob/2b9e210e0d1a735e1fa85ec22190115dffd963aa/lua/true-zen/focus.lua#L11-L15
  if vim.fn.winnr("$") == 1 then
    vim.notify("there is only one window open", vim.log.levels.INFO)
    return
  end
  vim.cmd("tab split")
end, { desc = "Focus split on new tab" })

-- Tabs move
vim.keymap.set("n", "<t", "<cmd>tabmove -1<CR>", { desc = "Move tab left" })
vim.keymap.set("n", ">t", "<cmd>tabmove +1<CR>", { desc = "Move tab right" })

vim.keymap.set("n", "<leader>qf", function() utils.toggle_qf("q") end, { desc = "Toggle quickfix" })
vim.keymap.set("n", "<leader>ql", function() utils.toggle_qf("l") end, { desc = "Toggle location list" })

vim.keymap.set({ "i", "n" }, "<esc>", "<cmd>noh<cr><esc>", { desc = "Escape and clear hlsearch" })

vim.keymap.set("i", "<C-f>", "<Esc>gUiw`]a", { desc = "Make the word before the cursor uppercase" })

vim.keymap.set("n", "<leader>zl", function()
  local winid = vim.api.nvim_get_current_win()
  local foldopen_visible = vim.wo[winid].fillchars:gsub("foldopen: ", "foldopen:")
  vim.wo[winid].fillchars = foldopen_visible

  -- Hide available folds after timout
  local timeout = 2000
  vim.defer_fn(function()
    local foldopen_hidden = vim.wo[winid].fillchars:gsub("foldopen:", "foldopen: ")
    vim.wo[winid].fillchars = foldopen_hidden
  end, timeout)
end, { desc = "Temporary show available folds" })

---https://github.com/nvim-telescope/telescope.nvim/pull/2793#issue-2000972124
vim.keymap.set("n", "<leader>aa", function()
  local is_pinned = utils.toggle_buffer_pin()
  vim.notify(is_pinned and "Buffer pin" or "Removed buffer pin", vim.log.levels.INFO)
end, { desc = "Toggles the pin state of a buffer" })
