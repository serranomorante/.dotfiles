local utils = require("serranomorante.utils")

return {
  "jedrzejboczar/possession.nvim",
  event = "VeryLazy",
  enabled = false,
  dependencies = "nvim-lua/plenary.nvim",
  opts = {
    silent = true,
    load_silent = true,
    debug = true,
    logfile = true,
    autosave = {
      current = true,
      tmp = true,
      tmp_name = utils.get_escaped_cwd,
      on_load = true,
      on_quit = true,
    },
    plugins = {
      close_windows = false,
      delete_hidden_buffers = false,
      nvim_tree = false,
      neo_tree = false,
      symbols_outline = false,
      tabby = false,
      dap = true,
      dapui = false,
      neotest = false,
      delete_buffers = false,
    },
    hooks = {
      before_save = function(_)
        utils.tab_buffer_only(true)
        return {}
      end,
    },
  },
  config = function(_, opts)
    require("possession").setup(opts)

    local autoload_session = function()
      ---Only load the session if nvim was started with no args
      if vim.fn.argc(-1) == 0 then
        ---@diagnostic disable-next-line: param-type-mismatch
        local ok, _ = pcall(vim.cmd, "PossessionLoad " .. utils.get_escaped_cwd())
        if not ok then return end
        vim.api.nvim_exec_autocmds("BufReadPost", {})
      end
    end

    if vim.v.vim_did_enter then autoload_session() end
    vim.api.nvim_create_autocmd("VimEnter", {
      desc = "Load a dir-specific session when you open Neovim",
      group = vim.api.nvim_create_augroup("autoload_session", { clear = true }),
      callback = autoload_session,
    })
  end,
}
