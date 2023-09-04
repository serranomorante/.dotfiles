local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local timeout_ms = 10000

return {
	"williamboman/mason.nvim",
	dependencies = {
		{ "williamboman/mason-lspconfig.nvim", config = false },
		"jay-babu/mason-null-ls.nvim",
		"jose-elias-alvarez/null-ls.nvim",
	},
	lazy = false,
	cmd = { "Mason", "MasonInstall", "MasonUpdate" },
	init = function()
		-- Thanks Lsp-Zero!
		-- See: https://github.com/VonHeikemen/lsp-zero.nvim/blob/dev-v3/lua/lsp-zero/format.lua
		local key = "<leader>lf"

		local servers = {
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
		}

		local format_opts = {
			async = false,
			timeout_ms = 10000,
		}

		local mode = { "n", "x" }

		local format_id = augroup("LspFormatting", { clear = true })

		local filetype_setup = function(event)
			local client_id = vim.tbl_get(event, "data", "client_id")
			if client_id == nil then
				-- I don't know how this would happen
				-- but apparently it can happen
				return
			end

			local client = vim.lsp.get_client_by_id(client_id)
			local files = servers[client.name]

			if type(files) == "string" then
				files = { servers[client.name] }
			end

			if files == nil or vim.tbl_contains(files, vim.bo.filetype) == false then
				return
			end

			local config = {
				id = client.id,
				bufnr = event.buf,
				async = format_opts.async == true or false,
				timeout_ms = format_opts.timeout_ms or timeout_ms,
				formatting_options = format_opts.formatting_options,
			}

			local exec = function()
				vim.lsp.buf.format(config)
			end
			local desc = string.format("Format buffer with %s", client.name)

			vim.keymap.set(mode, key, exec, { buffer = event.buf, desc = desc })
		end

		local desc = string.format("Format buffer with %s", key)

		autocmd("LspAttach", {
			group = format_id,
			desc = desc,
			callback = filetype_setup,
		})
	end,
	config = function(_, opts)
		local mason = require("mason")
		local mason_lspconfig = require("mason-lspconfig")
		local mason_null_ls = require("mason-null-ls")
		local null_ls = require("null-ls")

		mason.setup(opts)

		mason_lspconfig.setup({
			-- list of servers for mason to install
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
		})

		mason_null_ls.setup({
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
				-- Prevent the automatic setup of pylint in mason-null-ls and do
				-- the setup manually in the null-ls block below.
				pylint = function() end,
				-- mypy = function() end,
			},
		})

		local venv_path =
			'import sys; sys.path.append("/usr/lib/python3.11/site-packages"); import pylint_venv; pylint_venv.inithook(force_venv_activation=True, quiet=True)'

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
			},
		})
	end,
}
