return {
	-- the colorscheme should be available when starting Neovim
	{
		"folke/tokyonight.nvim",
		lazy = false, -- make sure we load this during startup if it is your main colorscheme
		enabled = true, -- false will disable this plugin for everyone
		priority = 1000, -- make sure to load this before all the other start plugins
		opts = {
			lualine_bold = true,
			transparent = true,
			styles = {
				sidebars = "transparent",
				floats = "transparent",
			},
			on_colors = function(colors)
				-- Makes relative line numbers more visible
				colors.fg_gutter = "#5a6482"
				-- Add more explicit border to splits
				colors.border = "#474e70"
			end,
			on_highlights = function(hl, c)
				-- fix dressing.nvim float title letters hardly visible
				local black = "#0a0a0a"
				local white = "#f2f2f2"
				hl.FloatBorder = { fg = c.border_highlight, bg = black }
				hl.NormalFloat = { fg = white, bg = c.bg_dark }
			end,
		},
		config = function(_, opts)
			require("tokyonight").setup(opts)
			-- load the colorscheme here
			vim.cmd([[colorscheme tokyonight]])
			-- customize relative row numbers
			-- vim.api.nvim_set_hl(0, "LineNrAbove", { fg = "#6b77e9", bold = false })
			-- vim.api.nvim_set_hl(0, "LineNr", { fg = "white", bold = true })
			-- vim.api.nvim_set_hl(0, "LineNrBelow", { fg = "#c35550", bold = false })
		end,
	},
}
