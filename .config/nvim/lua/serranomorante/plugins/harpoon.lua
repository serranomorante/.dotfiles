local DEFAULT_WIDTH = 100
local MAX_ALLOWED_WIDTH = 120

local width = vim.api.nvim_win_get_width(0) - 50
local is_valid_width = width > 100 and width < MAX_ALLOWED_WIDTH

return {
	"ThePrimeagen/harpoon",
	dependencies = {
		"nvim-lua/plenary.nvim",
	},
	keys = {
		{
			"<leader>aa",
			function()
				require("harpoon.mark").add_file()
			end,
			desc = "Add file to harpoon",
		},
		{
			"<leader>ae",
			function()
				require("harpoon.ui").toggle_quick_menu()
			end,
			desc = "Toggle harpoon menu",
		},
	},
	opts = {
		global_settings = {
			excluded_filetypes = { "harpoon", "neo-tree", "NvimTree" },
		},
		menu = {
			width = is_valid_width and width or DEFAULT_WIDTH,
		},
	},
}
