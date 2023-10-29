local events = require("serranomorante.events")

return {
	{
		"williamboman/mason.nvim",
		dependencies = "folke/neodev.nvim",
		lazy = false,
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		config = true,
	},

	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
			events.event("MasonLspSetup")
		end,
	},

	-- We load this plugin on `CustomMasonLspSetup` because otherwise
	-- it would try to load `mason-lspconfig` and `lspconfig` on startup
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "User CustomMasonLspSetup",
		cmd = { "MasonToolsInstall", "MasonToolsUpdate", "MasonToolsClean" },
		opts = {
			ensure_installed = {
				-- Formatters
				"stylua", -- lua
				"prettierd", -- javascript/typescript
				"isort", -- python
				"black", -- python
				"gofumpt", -- go
				"goimports", -- go
				"gomodifytags", -- go

				-- Linters
				"mypy", -- python
				"pylint", -- python
				"eslint_d", -- javascript/typescript

				-- LSP servers
				"lua_ls", -- lua
				"tsserver", -- javascript/typescript
				"jsonls", -- json
				"pyright", -- python
				"ruff_lsp", -- python
				"gopls", -- go
				"taplo", -- toml
				"rust_analyzer", -- rust
				"clangd", -- c/c++
				"marksman", -- markdown
				"bashls", -- bash

				-- Others
				"iferr", -- go
				"impl", -- go
			},
		},
	},
}
