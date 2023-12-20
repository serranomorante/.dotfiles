return {
  "stevearc/overseer.nvim",
  lazy = true,
  opts = {
    ---Disable the automatic patch and do it manually on nvim-dap config
    ---https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
    dap = false,
  },
}
