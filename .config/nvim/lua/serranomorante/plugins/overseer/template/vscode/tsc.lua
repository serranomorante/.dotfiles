return {
  name = "tsc --watch",
  builder = function()
    return {
      cmd = { "tsc", "--watch" },
      components = {
        "default",
        { "on_output_parse", problem_matcher = "$tsc-watch" },
        "on_result_diagnostics",
        "on_result_diagnostics_quickfix",
      },
    }
  end,
}
