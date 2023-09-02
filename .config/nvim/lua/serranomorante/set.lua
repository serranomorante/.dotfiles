local utils = require("serranomorante.utils")

local undodir = utils.join_paths(vim.call("stdpath", "cache"), "undodir")
local shadadir = utils.join_paths(vim.call("stdpath", "cache"), "shadadir")

if not utils.is_directory(undodir) then
	vim.fn.mkdir(undodir, "p")
end

vim.opt.viewoptions:remove("curdir")

vim.opt.guicursor =
	"n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50,a:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor,sm:block-blinkwait175-blinkoff150-blinkon175"

if vim.fn.has("nvim-0.9") == 1 then
	vim.opt.diffopt:append("linematch:60") -- enable linematch diff algorithm
end

vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
-- vim.opt.cursorcolumn = true
vim.opt.linebreak = true

vim.opt.tabstop = 2
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 2
vim.opt.expandtab = true
-- vim.opt.listchars = { eol = "↵", tab = "  " } -- because of tabstop=2
-- vim.opt.list = true

vim.opt.smartindent = true
vim.opt.preserveindent = true
vim.opt.breakindent = true
vim.opt.copyindent = true

vim.opt.wrap = false

vim.opt.swapfile = false
vim.opt.backup = false

--  ! - Save and restore global variables (their names should be without lowercase letter).
--  ' - Specify the maximum number of marked files remembered. It also saves the jump list and the change list.
--  < - Maximum of lines saved for each register. All the lines are saved if this is not included, <0 to disable pessistent registers.
--  % - Save and restore the buffer list. You can specify the maximum number of buffer stored with a number.
--  / or : - Number of search patterns and entries from the command-line history saved. vim.o.history is used if it’s not specified.
--  f - Store file (uppercase) marks, use 'f0' to disable.
--  s - Specify the maximum size of an item’s content in KiB (kilobyte).
--      For the viminfo file, it only applies to register.
--      For the shada file, it applies to all items except for the buffer list and header.
--  h - Disable the effect of 'hlsearch' when loading the shada file.
vim.opt.shada = "'0,<0,%0,:100,/100,s500,h"
vim.opt.shadafile = shadadir
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

vim.opt.clipboard = "unnamedplus"

vim.g.mapleader = " "

vim.g.markdown_fenced_languages = { "html", "javascript", "typescript", "css", "scss", "vim", "lua", "json", "yaml" }

-- Global variable to neo-tree window width
vim.g.neo_tree_width = 30

vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
vim.opt.foldlevelstart = 99 -- start with all code unfolded
vim.opt.foldenable = true -- enable fold for nvim-ufo

-- This is specific to my setup in order to add git worktrees support
-- to gitsigns.nvim
vim.g.git_worktrees = {
	{
		toplevel = vim.env.HOME,
		gitdir = vim.env.HOME .. "/.dotfiles",
	},
}
