return {
  "stevearc/oil.nvim",
  lazy = false,
  keys = {
    {
      "<leader>e",
      function()
        ---https://github.com/stevearc/oil.nvim/issues/153#issuecomment-1675154847
        if vim.bo.filetype == "oil" then
          require("oil").close()
        else
          require("oil").open()
        end
      end,
      desc = "File navigation",
    },
  },
  opts = {
    ---https://github.com/stevearc/oil.nvim/issues/201#issuecomment-1771146785
    cleanup_delay_ms = false,
    ---Copied here for readability
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["sv"] = "actions.select_vsplit", -- <C-s>
      ["ss"] = "actions.select_split", -- <C-h>
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = false, -- "actions.preview"
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = false, -- "actions.refresh"
      ["r"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["gs"] = "actions.change_sort",
      ["gx"] = "actions.open_external",
      ["g."] = "actions.toggle_hidden",
      ["g\\"] = "actions.toggle_trash",
      ["yy"] = "actions.copy_entry_path",
    },
  },
}
