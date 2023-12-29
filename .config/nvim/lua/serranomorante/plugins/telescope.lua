local utils = require("serranomorante.utils")

--- A delta previewer for git status, commits and bcommits
---
--- You should copy this `.gitconfig` pager change for scroll (<C-d> and <C-u>) to work
--- https://github.com/dandavison/delta/issues/630#issuecomment-860046929
---
---@param previewers table Don't import the telescope `previewers` inside this function to avoid issues. Use only from parameter.
---@param mode string? The preview git mode: bcommits, commits, etc.
---@param worktree table<string, string>? Make the previewer compatible with `.dotfiles`
local get_delta_previewer = function(previewers, mode, worktree)
  local delta = previewers.new_termopen_previewer({
    get_command = function(entry)
      local args = { "git", "diff" }

      -- Make it compatible with `.dotfiles`
      local worktree_match = worktree or utils.file_worktree() -- don't rely on `utils.file_worktree()` in here. Prefer the passing the param.
      if worktree_match ~= nil then
        table.insert(args, 2, ("--work-tree=%s"):format(worktree_match.toplevel))
        table.insert(args, 2, ("--git-dir=%s"):format(worktree_match.gitdir))
      end

      -- git commits and git bcommits
      if mode == "bcommits" then
        table.insert(args, entry.value .. "^!")
        table.insert(args, "--")
        table.insert(args, vim.fn.expand("#:p"))
      elseif mode == "commits" then
        table.insert(args, entry.value .. "^!")
      -- git status
      elseif mode == "status" then
        local value = worktree_match and ("%s/%s"):format(worktree_match.toplevel, entry.value) or entry.value
        table.insert(args, value)
      -- fallback
      else
        table.insert(args, entry.value .. "^!")
      end

      return args
    end,
  })
  return delta
end

return {
  {
    -- https://github.com/ThePrimeagen/git-worktree.nvim/pull/106
    "brandoncc/git-worktree.nvim",
    branch = "catch-and-handle-telescope-related-error",
    lazy = true,
    keys = {
      {
        "<leader>pf",
        function()
          local Job = require("plenary.job")
          if vim.env.TMUX ~= nil then
            Job:new({
              command = "tmux",
              args = {
                "split-window",
                "-v",
                "-t",
                "{bottom-right}",
              },
              cwd = vim.fn.getcwd(),
            }):start()
          end
        end,
        desc = "Open workspace directory",
      },
      {
        "<leader>pF",
        function()
          local Job = require("plenary.job")
          local current_file = vim.fn.resolve(vim.fn.expand("%"))
          local file_directory = vim.fn.fnamemodify(current_file, ":p:h")

          if vim.env.TMUX ~= nil then
            Job:new({
              command = "tmux",
              args = {
                "split-window",
                "-v",
                "-t",
                "{bottom-right}",
              },
              cwd = file_directory,
            }):start()
          end
        end,
        desc = "Open file directory",
      },
      {
        "<leader>pw",
        function()
          vim.ui.input({ prompt = "Git branch: " }, function(branch)
            local data = {}
            data.git_branch = branch

            vim.ui.input({ prompt = "Unique path: " }, function(path)
              data.unique_path = path

              require("git-worktree").create_worktree(data.unique_path, data.git_branch)
            end)
          end)
        end,
        desc = "Create new worktree",
      },
    },
    opts = {
      -- only change the pwd for the current vim Tab
      change_directory_command = "tcd",
      update_on_change = false,
    },
    config = function(_, opts)
      local git_worktree = require("git-worktree")
      git_worktree.setup(opts)

      ---https://github.com/ThePrimeagen/git-worktree.nvim?tab=readme-ov-file#hooks
      -- op = Operations.Switch, Operations.Create, Operations.Delete
      -- metadata = table of useful values (structure dependent on op)
      --      Switch
      --          path = path you switched to
      --          prev_path = previous worktree path
      --      Create
      --          path = path where worktree created
      --          branch = branch name
      --          upstream = upstream remote name
      --      Delete
      --          path = path where worktree deleted
      git_worktree.on_tree_change(function(op, metadata)
        if op == git_worktree.Operations.Switch then
          if utils.is_available("resession.nvim") then
            require("resession").load(metadata.path, { dir = "dirsession", silence_errors = true })
          end
        end
      end)
    end,
  },

  -- telescope.nvim
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      { "nvim-telescope/telescope-live-grep-args.nvim" },
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        enabled = vim.fn.executable("make") == 1,
        build = "make",
      },
      { "debugloop/telescope-undo.nvim" },
    },
    keys = {
      {
        "<leader>f<CR>",
        function() require("telescope.builtin").resume() end,
        desc = "Resume last telescope session",
      },
      {
        "<leader>fb",
        function() require("telescope.builtin").buffers() end,
        desc = "Buffers",
      },
      {
        "<leader>fh",
        function() require("telescope.builtin").help_tags() end,
        desc = "Help tags",
      },
      {
        "<leader>fk",
        function() require("telescope.builtin").keymaps() end,
        desc = "Keymaps",
      },
      {
        "<leader>fm",
        function() require("telescope.builtin").man_pages() end,
        desc = "Man pages",
      },
      {
        "<leader>fr",
        function() require("telescope.builtin").registers() end,
        desc = "Registers",
      },
      {
        "<leader>f'",
        function() require("telescope.builtin").marks() end,
        desc = "Find marks",
      },
      {
        "<leader>fc",
        function() require("telescope.builtin").grep_string() end,
        desc = "Find word under cursor (C-Space fuzzy)",
      },
      {
        "<leader>fv",
        function() require("telescope-live-grep-args.shortcuts").grep_visual_selection() end,
        mode = "v",
        desc = "Find visual selection (C-Space fuzzy)",
      },
      {
        "<leader>ff",
        function() require("telescope.builtin").find_files({ path_display = { "truncate" } }) end,
        desc = "Find files (fuzzy)",
      },
      {
        "<leader>fF",
        function()
          require("telescope.builtin").find_files({
            hidden = true,
            no_ignore = true,
            path_display = { "truncate" },
          })
        end,
        desc = "Find files (hidden, fuzzy)",
      },
      {
        "<leader>fw",
        function() require("telescope.builtin").live_grep() end,
        desc = "Live grep (C-Space fuzzy)",
      },
      {
        "<leader>fW",
        function()
          require("telescope.builtin").live_grep({
            additional_args = function(args) return vim.list_extend(args, { "--hidden", "--no-ignore" }) end,
          })
        end,
        desc = "Live grep (hidden, C-Space fuzzy)",
      },
      {
        "<leader>fg",
        function() require("telescope").extensions.live_grep_args.live_grep_args() end,
        desc = "Live grep (rg, C-Space fuzzy)",
      },
      {
        "<leader>uu",
        function() require("telescope").extensions.undo.undo() end,
        desc = "Undo history",
      },
      {
        "<leader>gw",
        function() require("telescope").extensions.git_worktree.git_worktrees() end,
        desc = "Git worktrees",
      },
      {
        "<leader>gW",
        function() require("telescope").extensions.git_worktree.create_git_worktree() end,
        desc = "Create git worktree",
      },
      {
        "<leader>gc",
        function()
          local worktree = utils.file_worktree()
          local previewers = require("telescope.previewers")
          local delta = get_delta_previewer(previewers, "bcommits", worktree)
          local options = { previewer = delta }
          require("telescope.builtin").git_bcommits(options)
        end,
        desc = "List commits for current buffer (bcommits)",
      },
      {
        "<leader>gC",
        function()
          local worktree = utils.file_worktree()
          local previewers = require("telescope.previewers")
          local delta = get_delta_previewer(previewers, "commits", worktree)
          local options = { previewer = delta }
          require("telescope.builtin").git_commits(options)
        end,
        desc = "List commits for current directory",
      },
      {
        "<leader>gt",
        function()
          local worktree = utils.file_worktree()
          local previewers = require("telescope.previewers")
          local delta = get_delta_previewer(previewers, "status", worktree)

          local options = { previewer = delta }

          if worktree ~= nil then
            options = vim.tbl_deep_extend("force", options, {
              -- if we should use git root as cwd or the cwd
              use_git_root = false,
            })
          else
            local current_file = vim.fn.resolve(vim.fn.expand("%"))
            local file_directory = vim.fn.fnamemodify(current_file, ":p:h")

            -- Make `git_bcommits` compatible with git worktrees in bare repos
            options = vim.tbl_deep_extend("force", options, {
              -- if we should use the current buffer git root
              use_file_path = true,
              -- specify the path of the repo
              cwd = file_directory,
            })
          end

          require("telescope.builtin").git_status(options)
        end,
        desc = "Git status",
      },
    },
    opts = function()
      local actions = require("telescope.actions")
      local action_state = require("telescope.actions.state")
      local action_set = require("telescope.actions.set")
      local lga_actions = require("telescope-live-grep-args.actions")

      local opts = {
        defaults = {
          git_worktrees = vim.g.git_worktrees,
          path_display = { "shorten" },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = {
              prompt_position = "top",
              preview_width = 0.55,
            },
            vertical = {
              mirror = false,
            },
            width = 0.87,
            height = 0.80,
            preview_cutoff = 120,
          },

          mappings = {
            i = {
              ["<C-l>"] = actions.cycle_history_next,
              ["<C-h>"] = actions.cycle_history_prev,
            },
            n = {
              ["q"] = actions.close,

              ["ss"] = actions.select_horizontal, -- default: ["<C-x>"]
              ["sv"] = actions.select_vertical, -- default: ["<C-v>"]
              ["te"] = actions.select_tab, -- default: ["<C-t>"]
              ["Q"] = actions.send_selected_to_qflist + actions.open_qflist, -- default: ["<M-q>"]
            },
          },
        },
        extensions = {
          undo = {
            use_delta = true,
          },
          live_grep_args = {
            mappings = {
              i = {
                ["<C-k>"] = lga_actions.quote_prompt(),
                ["<C-i>"] = lga_actions.quote_prompt({ postfix = " --iglob " }),
                ["<C-Space>"] = actions.to_fuzzy_refine,
              },
            },
          },
        },
        pickers = {
          buffers = {
            only_cwd = true,
            ---Sort buffer list with "harpoon-ish" behaviour.
            ---https://github.com/nvim-telescope/telescope.nvim/pull/2793#issue-2000972124
            sort_buffers = function(bufnr_a, bufnr_b)
              if vim.b[bufnr_a].is_buffer_pinned and vim.b[bufnr_b].is_buffer_pinned then
                ---Keep the pinned order. The lower the number the top of the priority
                return vim.b[bufnr_a].buffer_pinned_index < vim.b[bufnr_b].buffer_pinned_index
              elseif vim.b[bufnr_a].is_buffer_pinned then
                return true
              elseif vim.b[bufnr_b].is_buffer_pinned then
                return false
              end

              ---Same as passing `sort_mru=true`
              return vim.fn.getbufinfo(bufnr_a)[1].lastused > vim.fn.getbufinfo(bufnr_b)[1].lastused
            end,

            mappings = {
              n = {
                ["dd"] = actions.delete_buffer,
              },
            },
          },
          git_status = {
            mappings = {
              n = {
                ---Fix selection not working for `.dotfiles` bare repo
                ["<CR>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  local entry = getmetatable(selection)
                  if entry.toplevel ~= nil then
                    actions.close(prompt_bufnr)
                    local worktree_file = utils.join_paths(entry.toplevel, selection.value)
                    return vim.cmd("edit " .. worktree_file)
                  end
                  action_set.select(prompt_bufnr, "default")
                end,
                ---Fix staging not working for `.dotfiles` bare repo
                ["<Tab>"] = function(prompt_bufnr)
                  local selection = action_state.get_selected_entry()
                  if selection == nil then return end

                  ---https://github.com/nvim-telescope/telescope.nvim/blob/6213322ab56eb27356fdc09a5078e41e3ea7f3bc/lua/telescope/actions/init.lua#L891
                  local is_staged = selection.status:sub(2) == " "
                  local cmd = is_staged and { "git", "restore", "--staged" } or { "git", "add" }

                  ---Not a good experience, but refreshing the picker is too complex
                  actions.close(prompt_bufnr)
                  vim.notify("File " .. (is_staged and "unstaged" or "staged") .. " successfully!", vim.log.levels.INFO)

                  local entry = getmetatable(selection)
                  if entry.toplevel ~= nil then
                    local worktree_file = utils.join_paths(entry.toplevel, selection.value)
                    table.insert(cmd, 2, ("--git-dir=%s"):format(entry.gitdir))
                    table.insert(cmd, 3, ("--work-tree=%s"):format(entry.toplevel))
                    table.insert(cmd, worktree_file)
                    utils.cmd(cmd)
                  else
                    table.insert(cmd, selection.value)
                    utils.cmd(cmd)
                  end
                end,
              },
            },
          },
        },
      }

      return opts
    end,
    config = function(_, opts)
      local telescope = require("telescope")
      telescope.setup(opts)
      local conditional_func = utils.conditional_func
      conditional_func(telescope.load_extension, utils.is_available("telescope-fzf-native.nvim"), "fzf")
      -- https://github.com/nvim-telescope/telescope-live-grep-args.nvim
      conditional_func(telescope.load_extension, utils.is_available("live_grep_args"))
      conditional_func(telescope.load_extension, utils.is_available("telescope-undo.nvim"), "undo")
      -- https://github.com/ThePrimeagen/git-worktree.nvim
      conditional_func(telescope.load_extension, utils.is_available("git-worktree.nvim"), "git_worktree")
      -- https://github.com/rmagatti/auto-session#-session-lens
      conditional_func(telescope.load_extension, utils.is_available("auto-sessions"), "session-lens")
    end,
  },
}
