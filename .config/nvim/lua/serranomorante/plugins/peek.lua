return {
  -- TODO: Stop using this PR https://github.com/toppair/peek.nvim/pull/50
  -- when issue fixed upstream
	"Saimo/peek.nvim",
	build = "deno task --quiet build:fast",
	cmd = { "PeekOpen", "PeekClose" },
	config = function(_, opts)
		require("peek").setup(opts)

		vim.api.nvim_create_user_command("PeekOpen", require("peek").open, {})
		vim.api.nvim_create_user_command("PeekClose", require("peek").close, {})
	end,
}
