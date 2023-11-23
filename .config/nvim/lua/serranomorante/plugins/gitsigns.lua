return {
  "lewis6991/gitsigns.nvim",
  enabled = vim.fn.executable("git") == 1,
  -- Inspired by AstroNvim, added worktrees support
  event = "User CustomGitFile",
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
      "<leader>gs",
      function() require("gitsigns").stage_hunk() end,
      desc = "Stage hunk",
    },
  },
}
