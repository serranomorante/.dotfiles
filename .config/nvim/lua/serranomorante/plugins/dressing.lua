return {
	"stevearc/dressing.nvim",
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
