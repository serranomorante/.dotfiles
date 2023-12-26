local tools_by_filetype = require("serranomorante.plugins.lsp.mason-tools.by_filetype")

return {
  "stevearc/conform.nvim",
  cmd = "ConformInfo",
  keys = {
    {
      "<leader>lf",
      function()
        require("conform").format({
          lsp_fallback = false,
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
      lua = tools_by_filetype.lua.formatters,
      javascript = { tools_by_filetype.javascript.formatters },
      typescript = { tools_by_filetype.javascript.formatters },
      javascriptreact = { tools_by_filetype.javascript.formatters },
      typescriptreact = { tools_by_filetype.javascript.formatters },
      python = tools_by_filetype.python.formatters,
      go = tools_by_filetype.go.formatters,
      json = { tools_by_filetype.javascript.formatters },
      jsonc = { tools_by_filetype.javascript.formatters },
    },
  },
}
