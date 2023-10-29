return {
	"stevearc/conform.nvim",
	event = "BufWritePre",
	cmd = "ConformInfo",
	keys = {
		{
			"<leader>lf",
			function()
				require("conform").format({
					lsp_fallback = true,
					async = false,
					timeout_ms = 10000,
				})
			end,
			mode = { "n", "v" },
			desc = "Format file or range",
		},
	},
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			javascript = { { "prettier", "prettierd" } },
			typescript = { { "prettier", "prettierd" } },
			javascriptreact = { { "prettier", "prettierd" } },
			typescriptreact = { { "prettier", "prettierd" } },
			python = { "isort", "black" },
			go = { "gofumpt", "goimports" },
		},
	},
}
