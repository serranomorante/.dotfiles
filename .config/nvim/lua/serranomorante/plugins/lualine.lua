local utils = require("serranomorante.utils")

local BRANCH_MAX_LENGTH = 20
local LEFT_COMPONENT_SEPARATORS = { left = "", right = "" }

local function gitsigns_head()
	if not utils.is_available("gitsigns.nvim") then
		return ""
	end

	local head = vim.b[0].gitsigns_head
	if head == nil then
		return ""
	end
	return head
end

local function gitsigns_status()
	if not utils.is_available("gitsigns.nvim") then
		return ""
	end

	local sign = vim.b[0].gitsigns_status
	if sign == nil then
		return ""
	end
	return sign
end

return {
	"nvim-lualine/lualine.nvim",
	event = "VeryLazy",
	-- Removed gitsigns.nvim as a dependency to fix the git worktrees
	opts = {
		sections = {
			lualine_a = { "mode" },
			lualine_b = {
				{
					gitsigns_head,
					component_separators = LEFT_COMPONENT_SEPARATORS,
					fmt = function(str)
						local head = utils.shorten(str, BRANCH_MAX_LENGTH, true)
						return #head > 0 and " " .. head or head
					end,
				},
				{ gitsigns_status, component_separators = LEFT_COMPONENT_SEPARATORS },
				"diagnostics",
			},
			lualine_c = { "filename" },
			lualine_x = {},
			lualine_y = { "progress" },
			lualine_z = { "location" },
		},
		options = {
			disabled_filetypes = { "NvimTree", "neo-tree" },
			globalstatus = true,
		},
	},
}
