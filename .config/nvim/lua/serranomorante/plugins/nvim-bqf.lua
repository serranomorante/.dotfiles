return {
  "kevinhwang91/nvim-bqf",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    {
      ---`junegunn/fzf` vim plugin is necessary because `nvim-bqf` uses `fzf#run(...)`
      ---https://github.com/junegunn/fzf/blob/master/README-VIM.md#summary
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
      buf_label = false,
    },
  },
}
