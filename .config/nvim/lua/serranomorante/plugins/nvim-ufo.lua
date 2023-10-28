local utils = require("serranomorante.utils")

local handler = function(virtText, lnum, endLnum, width, truncate)
	local newVirtText = {}
	local suffix = (" 󰁂 %d "):format(endLnum - lnum)
	local sufWidth = vim.fn.strdisplaywidth(suffix)
	local targetWidth = width - sufWidth
	local curWidth = 0
	for _, chunk in ipairs(virtText) do
		local chunkText = chunk[1]
		local chunkWidth = vim.fn.strdisplaywidth(chunkText)
		if targetWidth > curWidth + chunkWidth then
			table.insert(newVirtText, chunk)
		else
			chunkText = truncate(chunkText, targetWidth - curWidth)
			local hlGroup = chunk[2]
			table.insert(newVirtText, { chunkText, hlGroup })
			chunkWidth = vim.fn.strdisplaywidth(chunkText)
			-- str width returned from truncate() may less than 2nd argument, need padding
			if curWidth + chunkWidth < targetWidth then
				suffix = suffix .. (" "):rep(targetWidth - curWidth - chunkWidth)
			end
			break
		end
		curWidth = curWidth + chunkWidth
	end
	table.insert(newVirtText, { suffix, "MoreMsg" })
	return newVirtText
end

return {
	-- Remove ugly numbers in the foldcolumn
	-- Thanks: https://github.com/kevinhwang91/nvim-ufo/issues/4#issuecomment-1512772530
	{
		"luukvbaal/statuscol.nvim",
		lazy = false,
		config = function()
			local builtin = require("statuscol.builtin")
			require("statuscol").setup({
				relculright = true,
				segments = {
					{ text = { "%s" }, click = "v:lua.ScSa" },
					{ text = { builtin.lnumfunc }, click = "v:lua.ScLa" },
					{
						text = { " ", builtin.foldfunc, " " },
						condition = { builtin.not_empty, true, builtin.not_empty },
						click = "v:lua.ScFa",
					},
				},
			})
		end,
	},

	{
		"kevinhwang91/nvim-ufo",
		event = "User	CustomFile",
		keys = {
			{
				"zR",
				function()
					require("ufo").openAllFolds()
				end,
				desc = "Open all folds",
			},
			{
				"zM",
				function()
					-- require("ufo").closeAllFolds()

					-- Apparently this completely fixes auto-folding insert issues
					-- https://github.com/kevinhwang91/nvim-ufo/issues/85#issue-1402031998
					local row, _ = unpack(vim.api.nvim_win_get_cursor(0))
					vim.cmd("normal gg")
					for i = 1, vim.api.nvim_buf_line_count(0) do
						vim.cmd("silent! normal " .. tostring(i) .. "GzC")
					end
					vim.cmd("normal " .. tostring(row) .. "G")
				end,
				desc = "Close all folds",
			},
			{
				"zr",
				function()
					require("ufo").openFoldsExceptKinds()
				end,
				desc = "Open folds except kinds",
			},
			{
				"zm",
				function()
					require("ufo").closeFoldsWith()
				end,
				desc = "Close folds with level",
			},
			{
				"zp",
				function()
					require("ufo").peekFoldedLinesUnderCursor()
				end,
				desc = "Peek folded lines under cursor",
			},
		},
		dependencies = "kevinhwang91/promise-async",
		init = function()
			vim.opt.fillchars:append({ eob = " ", fold = " ", foldopen = "", foldsep = " ", foldclose = "+" })
			vim.opt.foldcolumn = "1"
			vim.opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
			vim.opt.foldlevelstart = 99 -- start with all code unfolded
			vim.opt.foldenable = true -- enable fold for nvim-ufo
			vim.opt.foldopen:remove({ "hor" })
		end,
		opts = {
			fold_virt_text_handler = handler,
			preview = {
				mappings = {
					scrollB = "<C-b>",
					scrollF = "<C-f>",
					scrollU = "<C-u>",
					scrollD = "<C-d>",
				},
			},
			provider_selector = function(_, filetype, buftype)
				local function handleFallbackException(bufnr, err, providerName)
					if type(err) == "string" and err:match("UfoFallbackException") then
						return require("ufo").getFolds(bufnr, providerName)
					else
						return require("promise").reject(err)
					end
				end

				return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
					or function(bufnr)
						return require("ufo")
							.getFolds(bufnr, "lsp")
							:catch(function(err)
								return handleFallbackException(bufnr, err, "treesitter")
							end)
							:catch(function(err)
								return handleFallbackException(bufnr, err, "indent")
							end)
					end
			end,
		},
		config = function(_, opts)
			require("ufo").setup(opts)

			if utils.is_available("tokyonight.nvim") then
				local colors = require("tokyonight.colors").setup()

				-- Fix jsdoc comments not being visible with default `Folded` highlight
				vim.api.nvim_set_hl(0, "Folded", { bg = colors.bg_dark })
			end

			if utils.is_available("tint.nvim") then
				require("tint").refresh()
			end
		end,
	},
}
