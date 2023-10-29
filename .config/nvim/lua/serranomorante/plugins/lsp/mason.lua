local events = require("serranomorante.events")

return {
	{
		"WhoIsSethDaniel/mason-tool-installer.nvim",
		lazy = true,
	},

	{
		"williamboman/mason.nvim",
		dependencies = "folke/neodev.nvim",
		lazy = false,
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		config = function(_, opts)
			local mason = require("mason")

			mason.setup(opts)

			local mason_tool_installer = require("mason-tool-installer")

			mason_tool_installer.setup({
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
			})
		end,
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
