local utils = require("serranomorante.utils")

return {
  "LeonHeidelbach/trailblazer.nvim",
  lazy = true,
  dependencies = "nvim-treesitter/nvim-treesitter",
  keys = {
    {
      "<A-M>",
      function()
        vim.ui.input(
          { prompt = "Stack Name: " },
          function(input) require("trailblazer").switch_trail_mark_stack(input, false) end
        )
      end,
      desc = "Add trailblazer stack",
    },
  },
  opts = function()
    local opts = {
      auto_save_trailblazer_state_on_exit = false, -- we are manually doing it on `resession.nvim`
      auto_load_trailblazer_state_on_enter = false, -- we are manually doing it on `resession.nvim`
      trail_options = {
        mark_symbol = "",
        newest_mark_symbol = "",
        cursor_mark_symbol = "",
        next_mark_symbol = "",
        previous_mark_symbol = "",
        trail_mark_priority = 20, -- nvim-dap breakpoints priority is 21
        multiple_mark_symbol_counters_enabled = false,
        number_line_color_enabled = false,
        trail_mark_in_text_highlights_enabled = false,
        trail_mark_symbol_line_indicators_enabled = true,
      },
      force_mappings = {
        nv = {
          motions = {
            new_trail_mark = "<A-l>",
            track_back = "<A-b>",
            peek_move_next_down = "<A-J>",
            peek_move_previous_up = "<A-K>",
            move_to_nearest = "<A-N>",
            toggle_trail_mark_list = "<A-m>",
          },
          actions = {
            delete_all_trail_marks = "<A-S>",
            switch_to_next_trail_mark_stack = "<A-.>",
            switch_to_previous_trail_mark_stack = "<A-,>",
          },
        },
      },
      force_quickfix_mappings = {
        nv = {
          actions = {
            qf_action_delete_trail_mark_selection = "d",
            qf_action_save_visual_selection_start_line = "v",
          },
          alt_actions = {
            qf_action_save_visual_selection_start_line = "V",
          },
        },
        v = {
          actions = {
            qf_action_move_selected_trail_marks_down = "<C-j>",
            qf_action_move_selected_trail_marks_up = "<C-k>",
          },
        },
      },
    }

    local hl_groups = {}
    if utils.is_available("nightfox.nvim") then
      if vim.g.colors_name == "nightfox" then
        local palette = require("nightfox.palette").load("nightfox")

        hl_groups = vim.tbl_deep_extend("force", hl_groups, {
          TrailBlazerTrailMark = {
            guifg = palette.fg2,
          },
          TrailBlazerTrailMarkNext = {
            guifg = palette.fg2,
          },
          TrailBlazerTrailMarkPrevious = {
            guifg = palette.fg2,
          },
          TrailBlazerTrailMarkNewest = {
            guibg = palette.fg2,
          },
        })
      end
    end
    opts.hl_groups = hl_groups

    return opts
  end,
}