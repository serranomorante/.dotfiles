return {
  "kevinhwang91/nvim-ufo",
  event = { "User CustomFile", "User CustomInsertEnter" },
  keys = {
    {
      "zR",
      function() require("ufo").openAllFolds() end,
      desc = "Open all folds",
    },
    {
      "zM",
      function() require("ufo").closeAllFolds() end,
      desc = "Close all folds",
    },
    {
      "zr",
      function() require("ufo").openFoldsExceptKinds() end,
      desc = "Open folds except kinds",
    },
    {
      "zm",
      function() require("ufo").closeFoldsWith() end,
      desc = "Close folds with level",
    },
    {
      "zp",
      function() require("ufo").peekFoldedLinesUnderCursor() end,
      desc = "Peek folded lines under cursor",
    },
  },
  dependencies = "kevinhwang91/promise-async",
  opts = {
    preview = {
      win_config = {
        winblend = 0,
        winhighlight = "Normal:Folded",
      },
      mappings = {
        scrollB = "<C-b>",
        scrollF = "<C-f>",
        scrollU = "<C-u>",
        scrollD = "<C-d>",
      },
    },
    provider_selector = function(_, filetype, buftype)
      local function handleFallbackException(bufnr, err, providerName)
        if type(err) == "string" and err:match("UfoFallbackException") then
          return require("ufo").getFolds(bufnr, providerName)
        else
          return require("promise").reject(err)
        end
      end

      return (filetype == "" or buftype == "nofile") and "indent" -- only use indent until a file is opened
        or function(bufnr)
          return require("ufo")
            .getFolds(bufnr, "lsp")
            :catch(function(err) return handleFallbackException(bufnr, err, "treesitter") end)
            :catch(function(err) return handleFallbackException(bufnr, err, "indent") end)
        end
    end,
  },
  config = function(_, opts) require("ufo").setup(opts) end,
}
