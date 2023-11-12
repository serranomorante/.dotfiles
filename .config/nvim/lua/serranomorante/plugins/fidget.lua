return {
	"j-hui/fidget.nvim",
	event = "LspAttach",
	opts = {
		sources = {
			["null-ls"] = { ignore = true },
		},
	},
}
