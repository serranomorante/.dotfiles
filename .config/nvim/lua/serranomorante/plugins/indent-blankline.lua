return {
	"lukas-reineke/indent-blankline.nvim",
	config = function(_, opts)
		require("indent_blankline").setup(opts)

		vim.cmd([[highlight IndentBlanklineChar guifg=#292e42 gui=nocombine]])
	end,
}
