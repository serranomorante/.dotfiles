local tools = require("serranomorante.tools")

return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format({
          lsp_fallback = true, -- Make it compatible with `clang-format`
          async = false,
          timeout_ms = 10000,
        })
      end,
      mode = { "n", "v" },
      desc = "Format file or range",
    },
  },
  opts = {
    formatters_by_ft = {
      lua = tools.by_filetype.lua.formatters,
      javascript = { tools.by_filetype.javascript.formatters },
      typescript = { tools.by_filetype.javascript.formatters },
      javascriptreact = { tools.by_filetype.javascript.formatters },
      typescriptreact = { tools.by_filetype.javascript.formatters },
      python = tools.by_filetype.python.formatters,
      go = tools.by_filetype.go.formatters,
      json = { tools.by_filetype.json.formatters },
      jsonc = { tools.by_filetype.json.formatters },
      markdown = { tools.by_filetype.markdown.formatters },
      fish = { tools.by_filetype.fish.formatters },
    },
    log_level = vim.log.levels[vim.env.CONFORM_LOG_LEVEL or "ERROR"],
  },
}
