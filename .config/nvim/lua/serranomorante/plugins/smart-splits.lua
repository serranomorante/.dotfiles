return {
	"mrjones2014/smart-splits.nvim",
	dependencies = {
		"kwkarlwang/bufresize.nvim",
		opts = {
			register = {
				keys = {
					{ "n", "<C-w>+", "", { noremap = true, silent = true } },
					{ "n", "<C-w>-", "", { noremap = true, silent = true } },
				},
			},
		},
	},
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
						vim.notify("Smart Splits: RESIZE MODE OFF")
					end,
					on_enter = function()
						vim.notify("Smart Splits: RESIZE MODE ON")
					end,
				},
			},
		}
	end,
}
