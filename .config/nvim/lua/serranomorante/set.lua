local utils = require("serranomorante.utils")

local undodir = utils.join_paths(vim.call("stdpath", "cache"), "undodir")

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

vim.opt.foldcolumn = "0"
vim.opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
vim.opt.foldlevelstart = 99 -- start with all code unfolded
vim.opt.foldenable = true -- enable fold for nvim-ufo
