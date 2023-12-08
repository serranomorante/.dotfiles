local utils = require("serranomorante.utils")

return {
  {
    "Exafunction/codeium.nvim",
    cmd = "Codeium",
    enabled = false,
    config = function() require("codeium").setup({}) end,
  },

  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    build = vim.fn.has("win32") == 0
        and "echo 'NOTE: jsregexp is optional, so not a big deal if it fails to build\n'; make install_jsregexp"
      or nil,
    opts = {
      -- Don't jump into snippets that have been left
      -- Thanks: https://github.com/AstroNvim/AstroNvim/commit/af54d1481ee217a2389230109cbd298f24639118
      history = true,
      delete_check_events = "TextChanged",
      region_check_events = "CursorMoved",
    },
    config = function(_, opts)
      if opts then require("luasnip").config.setup(opts) end
      require("luasnip.loaders.from_lua").lazy_load({
        paths = { vim.fn.stdpath("config") .. "/lua/serranomorante/snippets" },
      })
    end,
  },

  -- Autocompletion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      { "L3MON4D3/LuaSnip" },
      { "saadparwaiz1/cmp_luasnip" },
      { "hrsh7th/cmp-nvim-lua" },
      { "onsails/lspkind.nvim" },
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")
      local lspkind = require("lspkind")

      lspkind.init({
        symbol_map = {
          Codeium = "",
        },
      })

      -- Thanks Astro!
      local border_opts = {
        border = "rounded",
        winhighlight = "Normal:NormalFloat,FloatBorder:FloatBorder,CursorLine:PmenuSel,Search:None",
      }

      -- https://github.com/zbirenbaum/copilot-cmp#tab-completion-configuration-highly-recommended
      local has_words_before = function()
        if vim.api.nvim_get_option_value("buftype", { buf = 0 }) == "prompt" then return false end
        local line, col = (unpack or table.unpack)(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, 0, line - 1, col, {})[1]:match("^%s*$") == nil
      end

      cmp.setup({
        snippet = { -- configure how nvim-cmp interacts with snippet engine
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        sources = {
          { name = "luasnip" },
          {
            name = "nvim_lsp",
            entry_filter = function(entry, _)
              return require("cmp.types").lsp.CompletionItemKind[entry:get_kind()] ~= "Text"
            end,
          },
          { name = "nvim_lua" },
          { name = "codeium" },
        },
        mapping = {
          ["<C-y>"] = cmp.mapping.confirm({ select = false }),
          ["<C-e>"] = cmp.mapping.abort(),
          -- Do not implement luasnip supertab because
          -- we need this on copilot
          ["<Tab>"] = vim.schedule_wrap(function(fallback)
            if cmp.visible() and has_words_before() then
              cmp.select_next_item({ behavior = cmp.SelectBehavior.Select })
            else
              fallback()
            end
          end),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<CR>"] = cmp.mapping.confirm({
            behavior = cmp.ConfirmBehavior.Replace,
            select = false,
          }),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-f>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(1) then
              luasnip.jump(1)
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<C-b>"] = cmp.mapping(function(fallback)
            if luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        },
        window = {
          completion = cmp.config.window.bordered(border_opts),
          documentation = cmp.config.window.bordered(border_opts),
        },
        formatting = {
          format = lspkind.cmp_format({
            with_text = true,
            menu = {
              buffer = "[buf]",
              nvim_lsp = "[LSP]",
              nvim_lua = "[api]",
              path = "[path]",
              luasnip = "[snip]",
              codeium = "[codeium]",
            },
          }),
        },
      })

      cmp.setup.filetype("gitcommit", {
        sources = {
          { name = "path" },
          { name = "buffer" },
        },
      })

      -- Setup `codeium.nvim` after `cmp`
      if utils.is_available("codeium.nvim") then require("codeium") end
    end,
  },
}
