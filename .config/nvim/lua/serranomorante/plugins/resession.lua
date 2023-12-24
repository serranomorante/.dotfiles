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
      function()
        require("resession").load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true, reset = true })
      end,
      desc = "Session load",
    },
    {
      "<leader>sd",
      function() require("resession").delete(vim.fn.getcwd(), { dir = "dirsession" }) end,
    },
  },
  opts = {
    load_detail = false,
    extensions = {
      quickfix = {
        enable_in_tab = true,
      },
    },
  },
  config = function(_, opts)
    local resession = require("resession")
    resession.setup(opts)

    ---`schedule_wrap` fixes: https://github.com/stevearc/resession.nvim/issues/44#issue-2006411201
    ---also: https://github.com/AstroNvim/AstroNvim/issues/2378#issue-2005950553
    local autoload_session = vim.schedule_wrap(function()
      -- Only load the session if nvim was started with no args
      if vim.fn.argc(-1) == 0 then
        -- Save these to a different directory, so our manual sessions don't get polluted
        resession.load(vim.fn.getcwd(), { dir = "dirsession", silence_errors = true, reset = true })
      end
    end)

    if vim.v.vim_did_enter then
      autoload_session()
    else
      vim.api.nvim_create_autocmd("VimEnter", {
        desc = "Load a dir-specific session when you open Neovim",
        group = vim.api.nvim_create_augroup("autoload_session", { clear = true }),
        callback = autoload_session,
      })
    end

    vim.api.nvim_create_autocmd("VimLeavePre", {
      desc = "Save a dir-specific session when you close Neovim",
      group = vim.api.nvim_create_augroup("autosave_session", { clear = true }),
      callback = function() resession.save_tab(vim.fn.getcwd(), { dir = "dirsession", notify = false }) end,
    })
  end,
}
