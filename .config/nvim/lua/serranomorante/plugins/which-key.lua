return {
	"folke/which-key.nvim",
	event = "VeryLazy",
	init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 500
	end,
	opts = {
		disable = {
			buftypes = {
				"nofile",
				"prompt",
				"terminal",
			},
			filetypes = {
				"prompt",
				"nofile",
			},
		},
	},
}
