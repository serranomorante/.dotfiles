return {
	"RRethy/vim-illuminate",
	event = "BufEnter",
	opts = {
		delay = 200,
		-- Disable this plugin on these modes: visual, line visual and visual block
		modes_denylist = { "v", "V", "\22" },
		filetypes_denylist = { "dirvish", "fugitive", "harpoon", "TelescopePrompt" },
	},
	config = function(_, opts)
		require("illuminate").configure(opts)

		-- Fix jsdoc comments not being visible
		vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = "#323a50" })
		vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = "#323a50" })
		vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = "#323a50" })
	end,
}
