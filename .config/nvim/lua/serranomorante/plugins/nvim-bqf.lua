return {
  "kevinhwang91/nvim-bqf",
  dependencies = {
    {
      "junegunn/fzf",
      build = function() vim.fn["fzf#install"]() end,
    },
  },
  ft = "qf",
  opts = {
    func_map = {
      tabc = "te",
      vsplit = "sv",
      split = "ss",
    },
    preview = {
      winblend = 0,
    },
  },
}
