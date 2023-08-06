return {
	"RRethy/vim-illuminate",
	event = "BufEnter",
	opts = {
		filetypes_denylist = { "dirvish", "fugitive", "harpoon", "TelescopePrompt" },
	},
	config = function(_, opts)
		require("illuminate").configure(opts)
	end,
}
