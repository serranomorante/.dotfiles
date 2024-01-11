return {
  "RRethy/vim-illuminate",
  event = "LspAttach",
  opts = {
    delay = 200,
    min_count_to_highlight = 2,
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
