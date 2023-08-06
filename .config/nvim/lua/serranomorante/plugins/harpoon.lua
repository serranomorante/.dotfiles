return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>a",
			function()
				require("harpoon.mark").add_file()
			end,
		},
		{
			"<C-e>",
			function()
				require("harpoon.ui").toggle_quick_menu()
			end,
		},
	},
	opts = {
		global_settings = {
			excluded_filetypes = { "harpoon", "neo-tree", "NvimTree" },
		},
		menu = {
			width = vim.api.nvim_win_get_width(0) - 50,
		},
	},
}
