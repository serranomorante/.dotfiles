return {
	{
		"kwkarlwang/bufresize.nvim",
		event = "VeryLazy",
		config = true,
	},

	{
		"mrjones2014/smart-splits.nvim",
		keys = {
			{
				"<leader>rs",
				function()
					require("smart-splits").start_resize_mode()
				end,
			},
		},
		opts = function()
			return {
				ignored_filetypes = {
					"nofile",
					"quickfix",
					"prompt",
					"neo-tree",
					"harpoon",
					"NvimTree",
				},
				resize_mode = {
					silent = true,
					hooks = {
						on_leave = function()
							require("bufresize").register()
							vim.notify("Smart Splits: RESIZE MODE OFF", vim.log.levels.INFO)
						end,
						on_enter = function()
							vim.notify("Smart Splits: RESIZE MODE ON", vim.log.levels.WARN)
						end,
					},
				},
			}
		end,
	},
}
