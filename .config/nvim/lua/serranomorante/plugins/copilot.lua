return {
	"zbirenbaum/copilot.lua",
	cmd = "Copilot",
	event = "InsertEnter",
	-- Config for cmp is on its on lsp-zero.lua
	dependencies = { "zbirenbaum/copilot-cmp", config = true },
	opts = {
		suggestion = { enabled = false },
		panel = { enabled = false },
		copilot_node_command = vim.fn.expand("$HOME") .. "/.volta/tools/image/node/18.16.0/bin/node",
	},
}
