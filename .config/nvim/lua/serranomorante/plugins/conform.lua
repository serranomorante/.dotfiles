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
      lua = { "stylua" },
      javascript = { { "prettierd", "prettier" } },
      typescript = { { "prettierd", "prettier" } },
      javascriptreact = { { "prettierd", "prettier" } },
      typescriptreact = { { "prettierd", "prettier" } },
      python = { "isort", "black" },
      go = { "gofumpt", "goimports" },
      json = { { "prettierd", "prettier" } },
      jsonc = { { "prettierd", "prettier" } },
    },
  },
}
