local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local utils = require("serranomorante.utils")
local events = require("serranomorante.events")

local general = augroup("General Settings", { clear = true })

autocmd("TextYankPost", {
  desc = "Highlight yanked text",
  group = augroup("highlightyank", { clear = true }),
  callback = function(event)
    local highlight_timeout = 1000
    local illuminate_available = utils.is_available("vim-illuminate")

    if illuminate_available then
      require("illuminate").invisible_buf(event.buf)
      vim.defer_fn(function() require("illuminate").visible_buf(event.buf) end, highlight_timeout)
    end

    vim.highlight.on_yank({
      higroup = "Substitute",
      timeout = highlight_timeout,
      on_macro = true,
    })
  end,
})

autocmd("BufWinEnter", {
  desc = "Make q close help, man, quickfix, dap floats",
  group = augroup("q_close_windows", { clear = true }),
  callback = function(event)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = event.buf })
    if vim.tbl_contains({ "help", "nofile", "quickfix" }, buftype) and vim.fn.maparg("q", "n") == "" then
      vim.keymap.set("n", "q", "<cmd>close<cr>", {
        desc = "Close window",
        buffer = event.buf,
        silent = true,
        nowait = true,
      })
    end
  end,
})

autocmd({ "BufReadPost", "BufNewFile", "BufWritePost" }, {
  desc = "Adds support for worktrees in gitsigns.nvim",
  group = augroup("file_user_events", { clear = true }),
  callback = function(args)
    local current_file = vim.fn.resolve(vim.fn.expand("%"))

    if not (current_file == "" or vim.api.nvim_get_option_value("buftype", { buf = args.buf }) == "nofile") then
      events.event("File")

      local worktree = utils.file_worktree()

      if worktree or utils.cmd({ "git", "-C", vim.fn.fnamemodify(current_file, ":p:h"), "rev-parse" }, false) then
        events.event("GitFile")
        vim.api.nvim_del_augroup_by_name("file_user_events")
      end
    end
  end,
})

autocmd("InsertEnter", {
  desc = "Triggers new InsertEnter user event that omits prompt buffers",
  group = augroup("insert_enter_user_event", { clear = true }),
  callback = function(args)
    local buftype = vim.api.nvim_get_option_value("buftype", { buf = args.buf })
    if buftype == "prompt" then return end
    events.event("InsertEnter")
    vim.api.nvim_del_augroup_by_name("insert_enter_user_event")
  end,
})

autocmd("BufEnter", {
  desc = "Disable New Line Comment",
  group = general,
  callback = function() vim.opt.formatoptions:remove({ "c", "r", "o" }) end,
})

autocmd("BufReadPre", {
  desc = "Disable certain functionality on very large files",
  group = augroup("large_buf", { clear = true }),
  callback = function(args)
    local ok, stats = pcall((vim.uv or vim.loop.fs_stat), vim.api.nvim_buf_get_name(args.buf))
    vim.b[args.buf].large_buf = (ok and stats and stats.size > vim.g.max_file.size)
      or vim.api.nvim_buf_line_count(args.buf) > vim.g.max_file.lines
  end,
})

-- I don't want `typescript-tools.nvim` CodeLens to be enable on startup
-- I also don't want `typescript-tools.nvim` CodeLens to refresh on "CursorHold" event
-- I want to enable both things on demand with keymaps
autocmd("LspAttach", {
  desc = "Remove auto commands from typescript-tools.nvim CodeLens feature",
  group = augroup("remove_typescript_tools_codelens", { clear = true }),
  callback = function()
    local cmds_found, ts_codelens_cmds = pcall(vim.api.nvim_get_autocmds, {
      group = "TypescriptToolsCodeLensGroup",
    })
    if cmds_found then
      if cmds_found then vim.tbl_map(function(cmd) vim.api.nvim_del_autocmd(cmd.id) end, ts_codelens_cmds) end
    end
  end,
})

-- https://vi.stackexchange.com/a/8997
autocmd({ "BufWinLeave", "BufWinEnter" }, {
  desc = "Keep screen position zt,zz,zb after switching buffer",
  group = augroup("keep_screen_position", { clear = true }),
  callback = function(event)
    if event.event == "BufWinLeave" then
      vim.b.winview = vim.fn.winsaveview()
    else
      if vim.b.winview == nil then return end

      vim.fn.winrestview(vim.b.winview)
      vim.b.winview = nil
    end
  end,
})
