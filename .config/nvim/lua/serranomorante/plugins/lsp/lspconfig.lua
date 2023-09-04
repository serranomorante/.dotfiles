local utils = require("serranomorante.utils")

return {
	"neovim/nvim-lspconfig",
	cmd = { "LspInfo", "LspInstall", "LspStart" },
	event = { "BufReadPre", "BufNewFile" },
	dependencies = {
		"hrsh7th/cmp-nvim-lsp",
		"p00f/clangd_extensions.nvim",
		"b0o/SchemaStore.nvim",
		"pmizio/typescript-tools.nvim",
	},
	config = function()
		local lspconfig = require("lspconfig")
		local cmp_nvim_lsp = require("cmp_nvim_lsp")

		local on_attach = function(client, bufnr)
			-- Disable semanticTokensProvider
			-- https://gist.github.com/swarn/fb37d9eefe1bc616c2a7e476c0bc0316
			client.server_capabilities.semanticTokensProvider = nil

			local opts = { noremap = true, silent = true, buffer = bufnr }

			opts.desc = "Show LSP references"
			vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<CR>", opts)

			opts.desc = "Go to declaration"
			vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)

			opts.desc = "Show LSP definitions"
			vim.keymap.set("n", "gd", "<cmd>Telescope lsp_definitions<CR>", opts)

			opts.desc = "Show LSP implementations"
			vim.keymap.set("n", "gi", "<cmd>Telescope lsp_implementations<CR>", opts)

			opts.desc = "Show LSP type definitions"
			vim.keymap.set("n", "go", "<cmd>Telescope lsp_type_definitions<CR>", opts)

			opts.desc = "See available code actions"
			vim.keymap.set({ "n", "v" }, "<leader>la", vim.lsp.buf.code_action, opts)

			opts.desc = "Smart rename"
			vim.keymap.set("n", "<leader>lr", vim.lsp.buf.rename, opts)

			opts.desc = "Show buffer diagnostics"
			vim.keymap.set("n", "<leader>ld", "<cmd>Telescope diagnostics bufnr=0<CR>", opts)

			opts.desc = "Show line diagnostics"
			vim.keymap.set("n", "gl", vim.diagnostic.open_float, opts)

			opts.desc = "Go to previous diagnostic"
			vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)

			opts.desc = "Go to next diagnostic"
			vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)

			opts.desc = "Show documentation for what is under cursor"
			vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

			opts.desc = "Restart LSP"
			vim.keymap.set("n", "<leader>rs", ":LspRestart<CR>", opts)
		end

		local capabilities =
			vim.tbl_deep_extend("force", lspconfig.util.default_config, cmp_nvim_lsp.default_capabilities())

		-- For nvim-ufo
		-- See: https://github.com/kevinhwang91/nvim-ufo#minimal-configuration
		capabilities.textDocument.foldingRange = {
			dynamicRegistration = false,
			lineFoldingOnly = true,
		}

		-- Set symbols in the sign column
		local signs = { Error = "", Warn = "", Hint = "", Info = "" }
		for type, icon in pairs(signs) do
			local hl = "DiagnosticSign" .. type
			vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
		end

		local servers = require("mason-lspconfig").get_installed_servers()

		local skip_server_setup = { "tsserver", "lua_ls", "clangd" }

		for _, server in pairs(servers) do
			if not vim.tbl_contains(skip_server_setup, server) then
				lspconfig[server].setup({
					on_attach = on_attach,
					capabilities = capabilities,
				})
			end
		end

		require("typescript-tools").setup({
			capabilities = capabilities,
			on_attach = on_attach,
		})

		lspconfig["clangd"].setup({
			capabilities = { offsetEncoding = "utf-16" },
			on_attach = function()
				-- https://github.com/p00f/clangd_extensions.nvim#inlay-hints
				-- TODO: change to `vim.lsp.inlay_hint(bufnr, true)` on nvim 0.10
				require("clangd_extensions.inlay_hints").setup_autocmd()
				require("clangd_extensions.inlay_hints").set_inlay_hints()
			end,
		})

		if utils.is_available("schemastore") then
			lspconfig["jsonls"].setup({
				settings = {
					json = { schemas = require("schemastore").json.schemas(), validate = { enable = true } },
				},
			})
		else
			lspconfig["jsonls"].setup({})
		end

		lspconfig["ruff_lsp"].setup({
			on_attach = function(client, _)
				-- Disable hover in favor of Pyright
				client.server_capabilities.hoverProvider = false
			end,
		})

		-- configure lua server (with special settings)
		lspconfig["lua_ls"].setup({
			capabilities = capabilities,
			on_attach = on_attach,
			settings = {
				Lua = {
					runtime = {
						version = "LuaJIT",
					},
					diagnostics = {
						globals = { "vim" },
					},
					workspace = {
						library = {
							vim.env.VIMRUNTIME,
						},
					},
				},
			},
		})
	end,
}
