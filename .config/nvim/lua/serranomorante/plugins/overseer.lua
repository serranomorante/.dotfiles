return {
  "stevearc/overseer.nvim",
  lazy = true,
  keys = {
    { "<leader>oo", "<cmd>OverseerToggle<CR>" },
    { "<leader>or", "<cmd>OverseerRun<CR>" },
    { "<leader>oc", "<cmd>OverseerRunCmd<CR>" },
    { "<leader>ol", "<cmd>OverseerLoadBundle<CR>" },
    { "<leader>ob", "<cmd>OverseerToggle! bottom<CR>" },
    { "<leader>od", "<cmd>OverseerQuickAction<CR>" },
    { "<leader>os", "<cmd>OverseerTaskAction<CR>" },
  },
  opts = {
    ---Disable the automatic patch and do it manually on nvim-dap config
    ---https://github.com/stevearc/overseer.nvim/blob/master/doc/third_party.md#dap
    dap = false,
    templates = { "builtin", "vscode", "editor" },
    task_win = {
      padding = 6,
      border = "single",
      win_opts = {
        winblend = 0,
      },
    },
  },
}
