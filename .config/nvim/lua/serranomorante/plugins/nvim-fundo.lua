return {
  "kevinhwang91/nvim-fundo",
  build = function() require("fundo").install() end,
  lazy = false,
  init = function() vim.opt.undofile = true end,
  config = true,
}
