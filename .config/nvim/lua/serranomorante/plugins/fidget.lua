return {
	"j-hui/fidget.nvim",
	tag = "legacy",
	event = "LspAttach",
	opts = {
		sources = {
			["null-ls"] = { ignore = true },
		},
	},
}
