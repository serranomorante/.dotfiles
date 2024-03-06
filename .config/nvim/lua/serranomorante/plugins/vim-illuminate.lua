return {
  "RRethy/vim-illuminate",
  event = "LspAttach",
  opts = {
    delay = 500,
    min_count_to_highlight = 2,
    large_file_cutoff = 2000,
    large_file_overrides = { providers = { "lsp" } },
    ---Disable this plugin on these modes: visual, line visual and visual block
    modes_denylist = { "v", "V", "\22" },
  },
  config = function(_, opts) require("illuminate").configure(opts) end,
}
