local utils = require("serranomorante.utils")

-- Open vim explorer [replaced by neo-tree]
-- vim.keymap.set("n", "<leader>pv", vim.cmd.Ex)

-- Toggle wrap
vim.keymap.set("n", "<leader>uw", function()
	vim.wo.wrap = not vim.wo.wrap
end)

-- Navigate display lines
vim.keymap.set({ "n", "x" }, "j", function()
	return vim.v.count > 0 and "j" or "gj"
end, { noremap = true, expr = true })
vim.keymap.set({ "n", "x" }, "k", function()
	return vim.v.count > 0 and "k" or "gk"
end, { noremap = true, expr = true })

-- New file
vim.keymap.set("n", "<leader>n", "<cmd>enew<cr>")

-- Move selected lines around
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")
vim.keymap.set("v", "H", "<gv")
vim.keymap.set("v", "L", ">gv")

-- Half page jumping keep cursor at the middle
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- Keep cursor in the middle while doing search
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

-- Delete highlighted word into the void
-- register and paste over it.
vim.keymap.set("x", "<leader>p", '"_dP')

-- Replace the highlighted word
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])

-- Horizontal and vertical splits
vim.keymap.set("n", "ss", ":split<Return><C-w>w")
vim.keymap.set("n", "sv", ":vsplit<Return><C-w>w")

-- Navigate between nvim splits
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- Close window
vim.keymap.set("n", "<C-q>", "<C-w>q")

-- Tabs navigation
vim.keymap.set("n", "te", ":tabedit<Return>")
vim.keymap.set("n", "H", ":tabprevious<Return>")
vim.keymap.set("n", "L", ":tabnext<Return>")

-- Tabs move
vim.keymap.set("n", "<t", ":tabmove -1<Return>")
vim.keymap.set("n", ">t", ":tabmove +1<Return>")

vim.keymap.set("n", "<leader>qf", function()
	utils.toggle_qf("q")
end)
vim.keymap.set("n", "<leader>ql", function()
	utils.toggle_qf("l")
end)

-- Keymap to open lazygit in zellij floating pane
-- This should be compatible with worktrees
if vim.env.ZELLIJ == "0" and vim.fn.executable("lazygit") == 1 then
	vim.keymap.set("n", "<leader>gg", function()
		local Job = require("plenary.job")

		local function open_lazygit_in_zellij_floating_page()
			local worktree = utils.file_worktree()
			local args = {
				"run",
				"-f",
				"--name",
				"lazygit",
				"--",
				"lazygit",
			}

			if worktree then
				table.insert(args, ("--work-tree=%s"):format(worktree.toplevel))
				table.insert(args, ("--git-dir=%s"):format(worktree.gitdir))
			end

			Job:new({
				command = "zellij",
				args = args,
			}):start()
		end

		open_lazygit_in_zellij_floating_page()
	end)
end
