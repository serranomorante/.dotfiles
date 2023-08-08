return {
	{
		"VonHeikemen/lsp-zero.nvim",
		branch = "dev-v3",
		lazy = true,
		config = false,
	},

	{
		"williamboman/mason.nvim",
		cmd = { "Mason", "MasonInstall", "MasonUpdate" },
		lazy = true,
		config = true,
	},

	{
		"L3MON4D3/LuaSnip",
		event = "InsertEnter",
		build = vim.fn.has("win32") == 0
				and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
			or nil,
		opts = {
			update_events = { "TextChanged", "TextChangedI" },
		},
		config = function(_, opts)
			if opts then
				require("luasnip").config.setup(opts)
			end
			require("luasnip.loaders.from_lua").lazy_load({
				paths = { vim.fn.stdpath("config") .. "/lua/serranomorante/snippets" },
			})
			-- vim.tbl_map(function(type)
			-- 	require("luasnip.loaders.from_" .. type).lazy_load()
			-- end, { "vscode", "snipmate", "lua" })
		end,
	},
	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "zbirenbaum/copilot.lua" },
			{ "saadparwaiz1/cmp_luasnip" },
		},
		config = function()
			-- Here is where you configure the autocompletion settings.
			require("lsp-zero").extend_cmp()

			-- And you can configure cmp even more, if you want to.
			local cmp = require("cmp")
			local cmp_action = require("lsp-zero").cmp_action()

			-- Thanks Astro!
			local border_opts = {
				border = "rounded",
				winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
			}

			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			cmp.setup({
				-- Make the first item on the list preselected
				-- https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/autocomplete.md#preselect-first-item
				preselect = "item",
				completion = {
					completeopt = "menu,menuone,noinsert",
				},
				sources = {
					{ name = "copilot" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
				},
				mapping = {
					-- Do not implement luasnip supertab because
					-- we need this on copilot
					["<Tab>"] = vim.schedule_wrap(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end),
					["<S-Tab>"] = cmp_action.select_prev_or_fallback(),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-f>"] = cmp_action.luasnip_jump_forward(),
					["<C-b>"] = cmp_action.luasnip_jump_backward(),
				},
				window = {
					completion = cmp.config.window.bordered(border_opts),
					documentation = cmp.config.window.bordered(border_opts),
				},
			})
		end,
	},

	-- LSP
	{
		"williamboman/mason-lspconfig.nvim",
		cmd = { "LspInfo", "LspInstall", "LspStart" },
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			{ "nvim-telescope/telescope.nvim" },
			{ "jose-elias-alvarez/null-ls.nvim" },
			{ "jay-babu/mason-null-ls.nvim" },
			{ "hrsh7th/cmp-nvim-lsp" },
			{ "neovim/nvim-lspconfig" },
			{ "kevinhwang91/nvim-ufo" },
			{ "p00f/clangd_extensions.nvim" },
			{ "b0o/SchemaStore.nvim" },
			{ "jose-elias-alvarez/typescript.nvim" },
		},
		config = function()
			local lsp = require("lsp-zero").preset({})

			lsp.on_attach(function(client, bufnr)
				-- Fix issue with multiple offset encondings
				-- if client.name == "clangd" then
				-- 	client.config.capabilities.offsetEncoding = { "utf-16" }
				-- end

				lsp.default_keymaps({ buffer = bufnr, omit = { "<F2>", "<F3>", "<F4>" } })

				vim.keymap.set("n", "gr", "<cmd>Telescope lsp_references<cr>", { buffer = true })
				vim.keymap.set("n", "<leader>lR", function()
					vim.lsp.buf.rename()
				end, { buffer = true })

				if vim.lsp.buf.range_code_action then
					vim.keymap.set("n", "<leader>la", function()
						vim.lsp.buf.range_code_action()
					end, { buffer = true })
				else
					vim.keymap.set("n", "<leader>la", function()
						vim.lsp.buf.code_action()
					end, { buffer = true })
				end
			end)

			lsp.set_server_config({
				on_init = function(client)
					client.server_capabilities.semanticTokensProvider = nil
				end,
				capabilities = {
					-- offsetEncoding = "utf-16",
					textDocument = {
						foldingRange = {
							dynamicRegistration = false,
							lineFoldingOnly = true,
						},
					},
				},
			})

			lsp.format_mapping("<leader>lf", {
				format_opts = {
					async = false,
					timeout_ms = 10000,
				},
				servers = {
					["null-ls"] = {
						"javascript",
						"typescript",
						"lua",
						"json",
						"jsonc",
						"javascriptreact",
						"typescriptreact",
						"typescript.tsx",
					},
				},
			})

			lsp.set_sign_icons({
				error = "",
				warn = "",
				hint = "",
				info = "",
			})

			require("mason-lspconfig").setup({
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
				},
				handlers = {
					lsp.default_setup,
					tsserver = function()
						require("typescript").setup({
							-- See https://github.com/VonHeikemen/lsp-zero.nvim/discussions/39#discussioncomment-3311521
							server = lsp.build_options("tsserver", {}),
						})
					end,
					clangd = function()
						require("clangd_extensions").setup({
							server = {
								capabilities = {
									offsetEncoding = { "utf-16" },
								},
							},
						})
					end,
					jsonls = function()
						local schemastore_avail, schemastore = pcall(require, "schemastore")
						if schemastore_avail then
							require("lspconfig").jsonls.setup({
								settings = {
									json = { schemas = schemastore.json.schemas(), validate = { enable = true } },
								},
							})
						else
							require("lspconfig").jsonls.setup({})
						end
					end,
					lua_ls = function()
						require("lspconfig").lua_ls.setup(lsp.nvim_lua_ls())
					end,
				},
			})

			require("mason-null-ls").setup({
				ensure_installed = {
					-- lua
					"stylua",
					-- typescript
					"prettierd",
					"eslint_d",
					-- python
					"isort",
					"black",
					"pylint",
					-- golang
					"gomodifytags",
					"gofumpt",
					"iferr",
					"impl",
					"goimports",
					-- rust
					-- "rustfmt", --deprecated
				},
				automatic_installation = false,
				handlers = {
					taplo = function() end,
				},
			})

			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- https://github.com/lewis6991/gitsigns.nvim#null-ls
					null_ls.builtins.code_actions.gitsigns,
					null_ls.builtins.diagnostics.fish,
					-- https://github.com/jose-elias-alvarez/typescript.nvim#code-action-setup
					require("typescript.extensions.null-ls.code-actions"),
				},
			})
		end,
	},
}
