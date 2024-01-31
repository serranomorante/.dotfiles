return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable("git") == 1,
  ---Do not lazy load gitsigns
  ---https://github.com/lewis6991/gitsigns.nvim/issues/796#issuecomment-1554076466
  lazy = false,
  opts = {
    worktrees = vim.g.git_worktrees,
  },
  keys = {
    {
      "<leader>gl",
      function() require("gitsigns").blame_line() end,
      desc = "Blame line",
    },
    {
      "<leader>gL",
      function() require("gitsigns").blame_line({ full = true }) end,
      desc = "Blame full buffer",
    },
    {
      "<leader>gd",
      function() require("gitsigns").diffthis() end,
      desc = "Diff this",
    },
    {
      "<leader>gp",
      function() require("gitsigns").preview_hunk() end,
      desc = "Preview hunk",
    },
    {
      "]g",
      function() require("gitsigns").next_hunk() end,
      desc = "Next hunk",
    },
    {
      "[g",
      function() require("gitsigns").prev_hunk() end,
      desc = "Prev hunk",
    },
    {
      "<leader>gh",
      function() require("gitsigns").reset_hunk() end,
      desc = "Reset hunk",
    },
    {
      "<leader>gh",
      ":Gitsigns reset_hunk<CR>",
      desc = "Reset hunk (partial)",
      mode = "v",
    },
    {
      "<leader>gH",
      function() require("gitsigns").reset_buffer() end,
      desc = "Reset buffer",
    },
    {
      "<leader>gS",
      function() require("gitsigns").stage_buffer() end,
      desc = "Stage buffer",
    },
    {
      "<leader>gs",
      function() require("gitsigns").stage_hunk() end,
      desc = "Stage hunk",
    },
    {
      "<leader>gs",
      ":Gitsigns stage_hunk<CR>",
      desc = "Stage hunk (partial)",
      mode = "v",
    },
    {
      "<leader>gu",
      function() require("gitsigns").undo_stage_hunk() end,
      desc = "Unstage hunk",
    },
  },
}
