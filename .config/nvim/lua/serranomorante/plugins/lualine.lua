local utils = require("serranomorante.utils")

local BRANCH_MAX_LENGTH = 60
local CONTRAST_COLOR = "#ffffff"

--- Use gitsigns.nvim to get the current git diff
--- https://github.com/nvim-lualine/lualine.nvim/wiki/Component-snippets#using-external-source-for-diff
--- @return table|nil
local function diff_source()
	local gitsigns = vim.b.gitsigns_status_dict
	if gitsigns then
		return {
			added = gitsigns.added,
			modified = gitsigns.changed,
			removed = gitsigns.removed,
		}
	end
end

--- Get the current working directory
--- from: https://github.com/nvim-lualine/lualine.nvim/blob/master/lua/lualine/extensions/nerdtree.lua
--- @return string
local function get_short_cwd()
	return vim.fn.fnamemodify(vim.fn.getcwd(), ":~")
end

-- extensions
local harpoon_extension = {
	sections = {
		lualine_a = { "mode" },
	},
	filetypes = { "harpoon" },
}

local neo_tree_extension = {
	sections = {
		lualine_a = { get_short_cwd },
		lualine_b = {
			{
				"g:neo_tree_git_branch",
				fmt = function(str)
					return utils.shorten(str, BRANCH_MAX_LENGTH, true)
				end,
				icon = "",
				color = { fg = CONTRAST_COLOR },
			},
		},
	},
	filetypes = { "neo-tree" },
}

local function update_status()
	local excluded_clients = { "copilot", "gitsigns" }
	local buf_clients = vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })
	local lint_installed, lint = pcall(require, "lint")
	local buf_client_names = {}
	-- Append filetype linters
	if lint_installed then
		local buf_linters = lint.linters_by_ft[vim.bo.filetype]
		if vim.tbl_islist(buf_linters) then
			for _, linter in ipairs(buf_linters) do
				table.insert(buf_client_names, linter)
			end
		end
	end
	-- Append buffer LSPs
	for _, client in pairs(buf_clients) do
		if not vim.tbl_contains(excluded_clients, client.name) then
			table.insert(buf_client_names, string.format("%s:%s", client.name, client.id))
		end
	end
	return table.concat(buf_client_names, ",")
end

return {
	"nvim-lualine/lualine.nvim",
	lazy = false,
	-- Removed gitsigns.nvim as a dependency to fix the git worktrees
	opts = function(_, opts)
		local custom_opts = {
			sections = {
				-- left
				lualine_a = { "mode" },
				lualine_b = {
					{
						"b:gitsigns_head",
						fmt = function(str)
							return utils.shorten(str, BRANCH_MAX_LENGTH, true)
						end,
						icon = "",
						color = { fg = CONTRAST_COLOR },
					},
					{
						"diff",
						source = diff_source,
					},
					"diagnostics",
				},
				lualine_c = { "filename" },

				-- right
				lualine_x = {
					{
						update_status,
						icon = "",
					},
					{
						function()
							if package.loaded["auto-session"] then
								return require("auto-session.lib").current_session_name()
							end
							return ""
						end,
						icon = "",
					},
				},
				lualine_y = {
					{ "progress", color = { fg = CONTRAST_COLOR } },
				},
				lualine_z = { "searchcount", "location" },
			},
			options = {
				globalstatus = true,
			},
			extensions = { "lazy", "fugitive", "quickfix", harpoon_extension, neo_tree_extension },
		}

		-- Custom colors for git diff
		if utils.is_available("tokyonight.nvim") then
			local colors = require("tokyonight.colors").setup()

			local diff_colors = vim.tbl_deep_extend("force", custom_opts.sections.lualine_b[2], {
				diff_color = {
					-- Check `tokyonight.lua` for the custom colors
					added = { fg = colors.diff.add },
					modified = { fg = colors.diff.change },
					removed = { fg = colors.diff.delete },
				},
			})

			custom_opts.sections.lualine_b[2] = diff_colors
		end

		opts = vim.tbl_deep_extend("force", opts, custom_opts)
		return opts
	end,
}
