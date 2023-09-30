return {
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
			-- More vibrant c for git diff
			colors.diff.add = "#42f5c8"
			colors.diff.change = "#f5d742"
			colors.diff.delete = "#f56f42"
		end,
		on_highlights = function(hl, c)
			local util = require("tokyonight.util")

			-- Fix relative line numbers not fully visible
			hl.LineNr = { fg = util.lighten(c.fg_gutter, 0.8) }
			hl.CursorLineNr = { fg = util.lighten(c.dark5, 0.8) }

			-- Force background color despite transparency mode on floating windows
			hl.NormalFloat = { fg = c.fg_float, bg = c.bg_dark }
			hl.FloatBorder = { fg = c.border_highlight, bg = c.bg_dark }
			hl.FloatTitle = { fg = c.border_highlight, bg = c.bg_dark }

      -- Add more explicit border to splits
			hl.WinSeparator = { fg = c.bg_highlight }
		end,
	},
	config = function(_, opts)
		require("tokyonight").setup(opts)

		vim.cmd([[colorscheme tokyonight]])
	end,
}
