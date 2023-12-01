local utils = require("serranomorante.utils")

local undodir = utils.join_paths(vim.call("stdpath", "cache"), "undodir")
local shadadir = utils.join_paths(vim.call("stdpath", "cache"), "shadadir")

if not utils.is_directory(undodir) then vim.fn.mkdir(undodir, "p") end

if not utils.is_directory(shadadir) then vim.fn.mkdir(shadadir, "p") end

vim.opt.viewoptions:remove("curdir")

vim.opt.guicursor = "n-v-c-sm:block,i-ci-ve:ver25-Cursor,r-cr-o:hor20,a:blinkon1"

if vim.fn.has("nvim-0.9") == 1 then
  vim.opt.diffopt:append("linematch:60") -- enable linematch diff algorithm
end

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.expandtab = true

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
vim.opt.shadafile = utils.join_paths(shadadir, "nvim.shada")
vim.opt.undodir = undodir
vim.opt.undofile = true

vim.opt.termguicolors = true

vim.opt.signcolumn = "yes:1"
vim.opt.isfname:append("@-@")

vim.opt.clipboard = "unnamedplus"

vim.opt.foldcolumn = "1"
vim.opt.foldlevel = 99 -- set high foldlevel for nvim-ufo
vim.opt.foldlevelstart = 99 -- start with all code unfolded
vim.opt.foldenable = true -- enable fold for nvim-ufo
vim.opt.foldopen:remove({ "hor" })
vim.opt.fillchars:append({ eob = " ", fold = " ", foldopen = " ", foldsep = " ", foldclose = "+" })

vim.g.mapleader = " "

vim.g.markdown_fenced_languages = { "html", "javascript", "typescript", "css", "scss", "vim", "lua", "json", "yaml" }

-- Global variable to neo-tree window width
vim.g.neo_tree_width = 30

vim.g.max_file = { size = 1024 * 100, lines = 10000 } -- set global limits for large files
vim.g.codelens_enabled = false

-- This is specific to my setup in order to add git worktrees support
-- to gitsigns.nvim
vim.g.git_worktrees = {
  {
    toplevel = vim.env.HOME,
    gitdir = vim.env.HOME .. "/.dotfiles",
  },
}
