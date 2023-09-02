return {
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		event = "InsertEnter",
		opts = {
			suggestion = { enabled = false },
			panel = { enabled = false },
			copilot_node_command = vim.fn.expand("$HOME") .. "/.volta/tools/image/node/18.16.0/bin/node",
		},
	},

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
		end,
	},

	-- Autocompletion
	{
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		dependencies = {
			{ "L3MON4D3/LuaSnip" },
			{ "zbirenbaum/copilot.lua" },
			{
				"zbirenbaum/copilot-cmp",
				-- The following config helps to improve start times
				-- https://github.com/zbirenbaum/copilot-cmp#copilot-cmp-1
				opts = {
					{
						event = { "InsertEnter", "LspAttach" },
						fix_pairs = false,
					},
				},
			},
			{ "saadparwaiz1/cmp_luasnip" },
			{ "hrsh7th/cmp-nvim-lua" },
		},
		config = function()
			require("lsp-zero").extend_cmp()

			local cmp = require("cmp")
			local cmp_action = require("lsp-zero").cmp_action()

			-- Thanks Astro!
			local border_opts = {
				border = "rounded",
				winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
			}

			-- https://github.com/zbirenbaum/copilot-cmp#tab-completion-configuration-highly-recommended
			local has_words_before = function()
				if vim.api.nvim_buf_get_option(0, "buftype") == "prompt" then
					return false
				end
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			cmp.setup({
				sources = {
					{ name = "copilot" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
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
			-- { "jose-elias-alvarez/typescript.nvim" },
			{ "pmizio/typescript-tools.nvim" },
		},
		config = function()
			local lsp = require("lsp-zero").preset({})

			lsp.on_attach(function(_, bufnr)
				-- Disable some keybindings
				-- See: https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#disable-keybindings
				lsp.default_keymaps({ buffer = bufnr, exclude = { "<F2>", "<F3>", "<F4>" } })

				-- Add new keybindings
				-- See: https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/doc/md/lsp.md#creating-new-keybindings
				vim.keymap.set("n", "gr", function()
					require("telescope.builtin").lsp_references()
				end, { buffer = true })

				vim.keymap.set("n", "gd", function()
					require("telescope.builtin").lsp_definitions()
				end, { buffer = true })

				vim.keymap.set("n", "<leader>ld", function()
					require("telescope.builtin").diagnostics()
				end)

				vim.keymap.set("n", "<leader>lr", function()
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
						"python",
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
					-- markdown
					"marksman",
					-- bash
					"bashls",
				},
				handlers = {
					lsp.default_setup,
					tsserver = function()
						-- See https://github.com/VonHeikemen/lsp-zero.nvim/discussions/39#discussioncomment-3311521
						require("typescript-tools").setup(
							vim.tbl_deep_extend("force", lsp.build_options("tsserver", {}), {})
						)
					end,
					clangd = function()
						require("lspconfig").clangd.setup({
							capabilities = { offsetEncoding = "utf-16" },
							on_attach = function()
								-- https://github.com/p00f/clangd_extensions.nvim#inlay-hints
								-- TODO: change to `vim.lsp.inlay_hint(bufnr, true)` on nvim 0.10
								require("clangd_extensions.inlay_hints").setup_autocmd()
								require("clangd_extensions.inlay_hints").set_inlay_hints()
							end,
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
					ruff_lsp = function()
						-- https://github.com/astral-sh/ruff-lsp
						local on_attach = function(client, _)
							-- Disable hover in favor of Pyright
							client.server_capabilities.hoverProvider = false
						end

						require("lspconfig").ruff_lsp.setup({
							on_attach = on_attach,
						})
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
					"mypy",
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
					-- Prevent the automatic setup of mason-null-ls and do
					-- the setup manually in the null-ls block below.
					pylint = function() end,
					-- mypy = function() end,
				},
			})

			-- TODO: remove fixed python path
			local venv_path =
				'import sys; sys.path.append("/usr/lib/python3.11/site-packages"); import pylint_venv; pylint_venv.inithook(force_venv_activation=True, quiet=True)'

			local null_ls = require("null-ls")
			null_ls.setup({
				sources = {
					-- https://github.com/lewis6991/gitsigns.nvim#null-ls
					null_ls.builtins.code_actions.gitsigns,
					null_ls.builtins.diagnostics.fish,
					null_ls.builtins.diagnostics.pylint.with({
						extra_args = { "--init-hook", venv_path },
					}),
					-- null_ls.builtins.diagnostics.mypy.with({
					-- 	extra_args = { "--python-executable", ".venv/bin/python" },
					-- }),
					-- https://github.com/jose-elias-alvarez/typescript.nvim#code-action-setup
					-- require("typescript.extensions.null-ls.code-actions"),
				},
			})
		end,
	},
}
