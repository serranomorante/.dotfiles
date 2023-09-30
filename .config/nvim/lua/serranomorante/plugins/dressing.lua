return {
	"stevearc/dressing.nvim",
	lazy = false,
	opts = {
		input = {
			border = "single",
			default_prompt = "➤ ",
			insert_only = false,
			win_options = {
				winblend = 0,
			},
		},
		select = { backend = { "telescope", "builtin" } },
	},
}
