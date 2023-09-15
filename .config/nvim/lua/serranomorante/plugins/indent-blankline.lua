local utils = require("serranomorante.utils")

return {
	"lukas-reineke/indent-blankline.nvim",
	config = function(_, opts)
		require("indent_blankline").setup(opts)

		-- Dim the indent char a little bit
		if utils.is_available("tokyonight.nvim") then
			local colors = require("tokyonight.colors").setup()

			vim.api.nvim_set_hl(0, "IndentBlanklineChar", { fg = colors.bg_highlight, nocombine = true })
		end
	end,
}
