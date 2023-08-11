return {
	"nvim-neo-tree/neo-tree.nvim",
	branch = "v3.x",
	cmd = "Neotree",
	keys = {
		{
			"<leader>e",
			"<cmd>Neotree toggle<cr>",
		},
		{
			"<leader>o",
			function()
				if vim.bo.filetype == "neo-tree" then
					local REAL_PREV_WIN_INDEX = 3
					local rec = vim.t.winid_rec
					local current, prev = rec[#rec], rec[#rec - 1]

					-- When you create a new file in neo-tree and then
					-- try to execute this keymap, it won't go back
					-- because the previous window is the same as the current.
					if current == prev then
						-- We need to go further back to get the real previous window
						if #rec >= REAL_PREV_WIN_INDEX then
							local real_prev = rec[REAL_PREV_WIN_INDEX]
							vim.fn.win_gotoid(real_prev)
						else
							-- At least, get out of neo-tree by going to the
							-- window to the right.
							vim.cmd.wincmd("l")
						end
					else
						vim.cmd.wincmd("p")
					end
				else
					vim.cmd.Neotree("focus")
				end
			end,
		},
		{
			"<leader>rb",
			"<cmd>Neotree filesystem reveal left<cr>",
		},
	},
	dependencies = {
		"nvim-lua/plenary.nvim",
		-- "nvim-tree/nvim-web-devicons", -- not strictly required, but recommended
		"MunifTanjim/nui.nvim",
	},
	opts = {
		close_if_last_window = true,
		window = {
			width = 30,
		},
		default_component_configs = {
			git_status = {
				symbols = {
					added = "",
					deleted = "",
					-- modified = "",
					renamed = "",
					untracked = "",
					ignored = "",
					unstaged = "",
					staged = "",
					conflict = "",
				},
			},
		},
	},
}
