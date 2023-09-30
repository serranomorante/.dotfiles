local utils = require("serranomorante.utils")

return {
	"RRethy/vim-illuminate",
	event = "User CustomFile",
	opts = {
		delay = 200,
		-- Disable this plugin on these modes: visual, line visual and visual block
		modes_denylist = { "v", "V", "\22" },
		filetypes_denylist = { "dirvish", "fugitive", "harpoon", "TelescopePrompt" },
	},
	config = function(_, opts)
		require("illuminate").configure(opts)

		if utils.is_available("tokyonight.nvim") then
			local colors = require("tokyonight.colors").setup()

			-- Fix jsdoc comments not being visible
			vim.api.nvim_set_hl(0, "IlluminatedWordText", { bg = colors.bg_visual })
			vim.api.nvim_set_hl(0, "IlluminatedWordRead", { bg = colors.bg_visual })
			vim.api.nvim_set_hl(0, "IlluminatedWordWrite", { bg = colors.bg_visual })
		end

		if utils.is_available("tint.nvim") then
			require("tint").refresh()
		end
	end,
}
