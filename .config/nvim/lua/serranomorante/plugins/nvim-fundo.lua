return {
  "kevinhwang91/nvim-fundo",
  dependencies = {
    "kevinhwang91/promise-async",
  },
  build = function() require("fundo").install() end,
  lazy = false,
  init = function() vim.opt.undofile = true end,
  config = true,
}
