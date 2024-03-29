local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
  { import = "serranomorante.plugins" },
  { import = "serranomorante.plugins.lsp" },
  { import = "serranomorante.plugins.dap" },
  { import = "serranomorante.plugins.statusline.heirline" },
}, {
  change_detection = {
    notify = false,
  },
  dev = {
    path = "~/repos",
    fallback = true,
    patterns = {
      -- "mfussenegger/nvim-dap",
      -- "neovim/nvim-lspconfig",
      -- "marilari88/neotest-vitest",
      -- "ibhagwan/fzf-lua",
    },
  },
})
