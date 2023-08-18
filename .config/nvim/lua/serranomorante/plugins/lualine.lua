local utils = require("serranomorante.utils")

local BRANCH_MAX_LENGTH = 20

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "lewis6991/gitsigns.nvim" },
	opts = {
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{
					"branch",
					fmt = function(str)
						return utils.shorten(str, BRANCH_MAX_LENGTH, true)
					end,
				},
				"b:gitsigns_status",
				"diagnostics",
			},
			lualine_c = { "filename" },
			lualine_x = {},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		options = {
			disabled_filetypes = { "NvimTree", "neo-tree" },
		},
	},
}
