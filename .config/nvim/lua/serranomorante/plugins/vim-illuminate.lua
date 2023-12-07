return {
  "RRethy/vim-illuminate",
  event = "User CustomFile",
  keys = {
    {
      "<leader>an",
      function() require("illuminate").goto_next_reference() end,
      desc = "Next reference",
    },
    {
      "<leader>ap",
      function() require("illuminate").goto_prev_reference() end,
      desc = "Prev reference",
    },
  },
  opts = {
    delay = 200,
    large_file_cutoff = 2000,
    large_file_overrides = {
      providers = { "lsp" },
    },
    -- Disable this plugin on these modes: visual, line visual and visual block
    modes_denylist = { "v", "V", "\22" },
    filetypes_denylist = { "dirvish", "fugitive", "harpoon", "TelescopePrompt" },
  },
  config = function(_, opts) require("illuminate").configure(opts) end,
}
