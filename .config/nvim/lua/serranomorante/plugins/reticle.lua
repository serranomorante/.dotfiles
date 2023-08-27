return {
	"tummetott/reticle.nvim",
	event = "VeryLazy", -- lazyload the plugin if you like
	opts = {
		follow = {
			cursorcolumn = false,
		},
		always = {
			cursorline = {
				"neo-tree",
			},
		},
	},
}
