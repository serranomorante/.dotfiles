return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	dependencies = { "lewis6991/gitsigns.nvim" },
	opts = {
		sections = {
			lualine_a = { "mode" },
			lualine_b = { "b:gitsigns_status", "diagnostics" },
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
