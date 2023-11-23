local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

return {
  "mfussenegger/nvim-lint",
  event = { "BufReadPre", "BufReadPost" },
  keys = {
    {
      "<leader>lt",
      function()
        local lint = require("lint")
        lint.try_lint()
      end,
      desc = "Trigger linting for current file",
    },
  },
  config = function()
    local lint = require("lint")

    lint.linters_by_ft = {
      javascript = { "eslint_d" },
      typescript = { "eslint_d" },
      javascriptreact = { "eslint_d" },
      typescriptreact = { "eslint_d" },
      python = { "mypy", "pylint" },
    }

    local venv_path =
      'import sys; sys.path.append("/usr/lib/python3.11/site-packages"); import pylint_venv; pylint_venv.inithook(force_venv_activation=True, quiet=True)'

    local pylint = lint.linters.pylint
    pylint.args = vim.list_extend(vim.deepcopy(pylint.args), { "--init-hook", venv_path })

    autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
      group = augroup("lint", { clear = true }),
      callback = function() lint.try_lint() end,
    })
  end,
}
