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
	local buf_clients = vim.lsp.buf_get_clients()
	local null_ls_installed, null_ls = pcall(require, "null-ls")
	local buf_client_names = {}
	for _, client in pairs(buf_clients) do
		if client.name == "null-ls" then
			if null_ls_installed then
				for _, source in ipairs(null_ls.get_source({ filetype = vim.bo.filetype })) do
					-- Exclude some clients
					if not vim.tbl_contains(excluded_clients, source.name) then
						-- Exclude duplicated clients
						if not vim.tbl_contains(buf_client_names, source.name) then
							table.insert(buf_client_names, source.name)
						end
					end
				end
			end
		else
			if not vim.tbl_contains(excluded_clients, client.name) then
				table.insert(buf_client_names, string.format("%s:%s", client.name, client.id))
			end
		end
	end
	return table.concat(buf_client_names, ",")
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
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
						diff_color = {
							added = { fg = "#42f5c8" },
							modified = { fg = "#f5d742" },
							removed = { fg = "#f56f42" },
						},
					},
					"diagnostics",
				},
				lualine_c = { "filename" },

				-- right
				lualine_x = {
					{
						update_status,
						fmt = function(str)
							return "[" .. str .. "]"
						end,
						icon = "",
					},
				},
				lualine_y = {
					{ "progress", color = { fg = CONTRAST_COLOR } },
				},
				lualine_z = { "location" },
			},
			options = {
				globalstatus = true,
			},
			extensions = { "lazy", "fugitive", "quickfix", harpoon_extension, neo_tree_extension },
		}

		-- Add session name to the statusline
		if utils.is_available("auto-session") then
			table.insert(custom_opts.sections.lualine_x, {
				require("auto-session.lib").current_session_name,
				icon = "",
			})
		end

		opts = vim.tbl_deep_extend("force", opts, custom_opts)
		return opts
	end,
}
