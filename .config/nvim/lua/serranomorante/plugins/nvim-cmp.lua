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
			local cmp = require("cmp")
			local luasnip = require("luasnip")

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
				---@diagnostic disable-next-line: deprecated
				local line, col = unpack(vim.api.nvim_win_get_cursor(0))
				return col ~= 0
					and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
			end

			cmp.setup({
				snippet = { -- configure how nvim-cmp interacts with snippet engine
					expand = function(args)
						luasnip.lsp_expand(args.body)
					end,
				},
				sources = {
					{ name = "copilot" },
					{ name = "luasnip" },
					{ name = "nvim_lsp" },
					{ name = "nvim_lua" },
				},
				mapping = {
					["<C-y>"] = cmp.mapping.confirm({ select = false }),
					["<C-e>"] = cmp.mapping.abort(),
					-- Do not implement luasnip supertab because
					-- we need this on copilot
					["<Tab>"] = vim.schedule_wrap(function(fallback)
						if cmp.visible() and has_words_before() then
							cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
						else
							fallback()
						end
					end),
					["<S-Tab>"] = cmp.mapping(function(fallback)
						if cmp.visible() then
							cmp.select_prev_item()
						else
							fallback()
						end
					end, { "i", "s" }),
					["<CR>"] = cmp.mapping.confirm({
						behavior = cmp.ConfirmBehavior.Replace,
						select = false,
					}),
					["<C-Space>"] = cmp.mapping.complete(),
					["<C-f>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(1) then
							luasnip.jump(1)
						else
							fallback()
						end
					end, { "i", "s" }),
					["<C-b>"] = cmp.mapping(function(fallback)
						if luasnip.jumpable(-1) then
							luasnip.jump(-1)
						else
							fallback()
						end
					end, { "i", "s" }),
				},
				window = {
					completion = cmp.config.window.bordered(border_opts),
					documentation = cmp.config.window.bordered(border_opts),
				},
			})
		end,
	},
}