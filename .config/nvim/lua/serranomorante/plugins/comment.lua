return {
  "numToStr/Comment.nvim",
  keys = {
    {
      "gc",
      mode = { "n", "v" },
      desc = "Comment toggle linewise",
    },
    {
      "gb",
      mode = { "n", "v" },
      desc = "Comment toggle blockwise",
    },
    {
      "<leader>/",
      function() require("Comment.api").toggle.linewise.count(vim.v.count > 0 and vim.v.count or 1) end,
      desc = "Comment toggle linewise",
    },
    {
      "<leader>/",
      "<esc><cmd>lua require('Comment.api').toggle.linewise(vim.fn.visualmode())<cr>",
      mode = "v",
      desc = "Comment toggle in visual mode",
    },
  },
  opts = function()
    local commentstring_avail, commentstring = pcall(require, "ts_context_commentstring.integrations.comment_nvim")
    return commentstring_avail and commentstring and { pre_hook = commentstring.create_pre_hook() } or {}
  end,
}
