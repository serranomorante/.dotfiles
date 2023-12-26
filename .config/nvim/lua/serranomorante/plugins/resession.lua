return {
  "stevearc/resession.nvim",
  event = "VeryLazy",
  keys = {
    {
      "<leader>ss",
      function() require("resession").save_tab(vim.fn.getcwd(), { dir = "dirsession", notify = true }) end,
      desc = "Session save",
    },
    {
      "<leader>sl",
      function() require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true }) end,
      desc = "Session load",
    },
    {
      "<leader>sd",
      function() require("resession").delete(vim.fn.getcwd(), { dir = "dirsession" }) end,
    },
  },
  opts = {
    load_detail = false,
    ---Only save buffers in the current tabpage directory
    ---https://github.com/stevearc/resession.nvim?tab=readme-ov-file#use-tab-scoped-sessions
    tab_buf_filter = function(tabpage, bufnr)
      local dir = vim.fn.getcwd(-1, vim.api.nvim_tabpage_get_number(tabpage))
      return vim.startswith(vim.api.nvim_buf_get_name(bufnr), dir)
    end,
    extensions = {
      quickfix = {
        enable_in_tab = true,
      },
      pin_buffers = {
        enable_in_tab = true,
      },
    },
  },
  config = function(_, opts)
    local resession = require("resession")
    resession.setup(opts)
    ---fixes: https://github.com/stevearc/resession.nvim/issues/44#issue-2006411201
    ---also: https://github.com/AstroNvim/AstroNvim/issues/2378#issue-2005950553
    resession.add_hook("post_load", function() vim.api.nvim_exec_autocmds("BufReadPost", {}) end)

    local autoload_session = function()
      -- Only load the session if nvim was started with no args
      if vim.fn.argc(-1) == 0 then
        -- Save these to a different directory, so our manual sessions don't get polluted
        resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true, reset = true })
      end
    end

    if vim.v.vim_did_enter then autoload_session() end
    vim.api.nvim_create_autocmd("VimEnter", {
      desc = "Load a dir-specific session when you open Neovim",
      group = vim.api.nvim_create_augroup("autoload_session", { clear = true }),
      callback = autoload_session,
    })

    vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "Save a dir-specific session when you close Neovim",
      group = vim.api.nvim_create_augroup("autosave_session", { clear = true }),
      callback = function() resession.save_tab(vim.fn.getcwd(), { dir = "dirsession", notify = false }) end,
    })
  end,
}
