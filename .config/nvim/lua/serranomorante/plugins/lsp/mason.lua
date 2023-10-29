local events = require("serranomorante.events")

return {
	{
		"williamboman/mason.nvim",
		dependencies = "folke/neodev.nvim",
		lazy = false,
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		config = true,
	},

	-- We load this plugin on `CustomMasonLspSetup` because otherwise
	-- it would try to load `mason-lspconfig` and `lspconfig` on startup
	-- Be careful, `MasonToolsClean` command will delete the `mason-lspconfig` installed packages
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		event = "User CustomMasonLspSetup",
		cmd = { "MasonToolsInstall", "MasonToolsUpdate" },
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

				-- Others
				"iferr", -- go
				"impl", -- go
			},
		},
	},

	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInstall", "LspUninstall" },
		opts = {
			ensure_installed = {
				-- lua
				"lua_ls",
				-- typescript
				"tsserver",
				"jsonls",
				-- python
				"pyright",
				"ruff_lsp",
				-- golang
				"gopls",
				-- toml
				"taplo",
				-- rust
				"rust_analyzer",
				-- c/c++
				"clangd",
				-- markdown
				"marksman",
				-- bash
				"bashls",
			},
			automatic_installation = false,
		},
		config = function(_, opts)
			require("mason-lspconfig").setup(opts)
			events.event("MasonLspSetup")
		end,
	},
}
