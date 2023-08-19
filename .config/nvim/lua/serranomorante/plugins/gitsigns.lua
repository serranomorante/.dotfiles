return {
	"lewis6991/gitsigns.nvim",
	enabled = vim.fn.executable("git") == 1,
	-- Inspired by AstroNvim, added worktrees support
	event = "User CustomGitFile",
	opts = {
		worktrees = vim.g.git_worktrees,
	},
	keys = {
		{
			"<leader>gl",
			function()
				require("gitsigns").blame_line()
			end,
		},
		{
			"<leader>gd",
			function()
				require("gitsigns").diffthis()
			end,
		},
		{
			"<leader>gp",
			function()
				require("gitsigns").preview_hunk()
			end,
		},
		{
			"]g",
			function()
				require("gitsigns").next_hunk()
			end,
		},
		{
			"[g",
			function()
				require("gitsigns").prev_hunk()
			end,
		},
		{
			"<leader>gh",
			function()
				require("gitsigns").reset_hunk()
			end,
		},
		{
			"<leader>gs",
			function()
				require("gitsigns").stage_hunk()
			end,
		},
	},
}
