return {
	-- the colorscheme should be available when starting Neovim
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		priority = 1000, -- make sure to load this before all the other start plugins
		opts = {
			lualine_bold = true,
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			on_colors = function(colors)
				-- More vibrant colors for git diff
				colors.diff.add = "#42f5c8"
				colors.diff.change = "#f5d742"
				colors.diff.delete = "#f56f42"
			end,
			on_highlights = function(hl, c)
				local util = require("tokyonight.util")
				-- Fix dressing.nvim float title letters not fully visible
				hl.NormalFloat = { fg = util.lighten(c.fg_float, 0.3) }

				-- Fix relative line numbers not fully visible
				hl.LineNr = { fg = util.lighten(c.fg_gutter, 0.8) }
				hl.CursorLineNr = { fg = util.lighten(c.dark5, 0.8) }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)

			vim.cmd([[colorscheme tokyonight]])
		end,
	},
}
