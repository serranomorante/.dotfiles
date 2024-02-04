local tools = require("serranomorante.tools")
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufReadPost" },
  keys = {
    {
      "<leader>lt",
      function() require("lint").try_lint() end,
      desc = "Trigger linting for current file",
    },
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = tools.by_filetype.javascript.linters,
      typescript = tools.by_filetype.javascript.linters,
      javascriptreact = tools.by_filetype.javascript.linters,
      typescriptreact = tools.by_filetype.javascript.linters,
      python = tools.by_filetype.python.linters,
    }

    autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      desc = "Trigger linting",
      group = augroup("run_linters", { clear = true }),
      callback = function() lint.try_lint() end,
    })
  end,
}
