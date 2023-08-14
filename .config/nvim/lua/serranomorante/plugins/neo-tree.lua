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
					local win_history = vim.t.win_history
					local prev_win = win_history[1]

					-- Go to the window to the right as a fallback
					if vim.fn.win_getid() == prev_win then
						vim.cmd.wincmd("l")
					-- Go to the previous window
					else
						vim.fn.win_gotoid(prev_win)
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
		enable_normal_mode_for_inputs = true,
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
