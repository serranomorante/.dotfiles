return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"JoosepAlviste/nvim-ts-context-commentstring",
		"nvim-treesitter/nvim-treesitter-textobjects",
	},
	event = "User CustomFile",
	cmd = {
		"TSBufDisable",
		"TSBufEnable",
		"TSBufToggle",
		"TSDisable",
		"TSEnable",
		"TSToggle",
		"TSInstall",
		"TSInstallInfo",
		"TSInstallSync",
		"TSModuleInfo",
		"TSUninstall",
		"TSUpdate",
		"TSUpdateSync",
	},
	build = ":TSUpdate",
	init = function(plugin)
		-- PERF: add nvim-treesitter queries to the rtp and it's custom query predicates early
		-- This is needed because a bunch of plugins no longer `require("nvim-treesitter")`, which
		-- no longer trigger the **nvim-treeitter** module to be loaded in time.
		-- Luckily, the only thins that those plugins need are the custom queries, which we make available
		-- during startup.
		-- CODE FROM LazyVim (thanks folke!) https://github.com/LazyVim/LazyVim/commit/1e1b68d633d4bd4faa912ba5f49ab6b8601dc0c9
		require("lazy.core.loader").add_to_rtp(plugin)
		require("nvim-treesitter.query_predicates")
	end,
	opts = {
		ensure_installed = {
			-- HACK: force install of shipped neovim parsers since TSUpdate doesn't correctly update them
			-- Source: AstroNvim
			"bash",
			"c",
			"lua",
			"markdown",
			"markdown_inline",
			"python",
			"query",
			"vim",
			"vimdoc",
			"fish", -- shell
			"javascript", -- typescript
			"jsdoc", -- typescript
			"tsx", -- typescript
			"typescript", -- typescript
			"toml", -- python
			"go", -- golang
			"rust", -- rust
			"cpp", -- c/c++
			"kdl", -- kdl
		},
		highlight = {
			enable = true,
		},
		incremental_selection = { enable = true },
		indent = { enable = true },
		autotag = {
			enable = true,
			enable_close_on_slash = false,
		},
		context_commentstring = { enable = true, enable_autocmd = false },
		textobjects = {
			select = {
				enable = true,
				lookahead = true,
				keymaps = {
					["ak"] = { query = "@block.outer", desc = "around block" },
					["ik"] = { query = "@block.inner", desc = "inside block" },
					["ac"] = { query = "@class.outer", desc = "around class" },
					["ic"] = { query = "@class.inner", desc = "inside class" },
					["a?"] = { query = "@conditional.outer", desc = "around conditional" },
					["i?"] = { query = "@conditional.inner", desc = "inside conditional" },
					["af"] = { query = "@function.outer", desc = "around function " },
					["if"] = { query = "@function.inner", desc = "inside function " },
					["al"] = { query = "@loop.outer", desc = "around loop" },
					["il"] = { query = "@loop.inner", desc = "inside loop" },
					["aa"] = { query = "@parameter.outer", desc = "around argument" },
					["ia"] = { query = "@parameter.inner", desc = "inside argument" },
				},
			},
			move = {
				enable = true,
				set_jumps = true,
				goto_next_start = {
					["]k"] = { query = "@block.outer", desc = "Next block start" },
					["]f"] = { query = "@function.outer", desc = "Next function start" },
					["]a"] = { query = "@parameter.inner", desc = "Next argument start" },
				},
				goto_next_end = {
					["]K"] = { query = "@block.outer", desc = "Next block end" },
					["]F"] = { query = "@function.outer", desc = "Next function end" },
					["]A"] = { query = "@parameter.inner", desc = "Next argument end" },
				},
				goto_previous_start = {
					["[k"] = { query = "@block.outer", desc = "Previous block start" },
					["[f"] = { query = "@function.outer", desc = "Previous function start" },
					["[a"] = { query = "@parameter.inner", desc = "Previous argument start" },
				},
				goto_previous_end = {
					["[K"] = { query = "@block.outer", desc = "Previous block end" },
					["[F"] = { query = "@function.outer", desc = "Previous function end" },
					["[A"] = { query = "@parameter.inner", desc = "Previous argument end" },
				},
			},
			swap = {
				enable = true,
				swap_next = {
					[">K"] = { query = "@block.outer", desc = "Swap next block" },
					[">F"] = { query = "@function.outer", desc = "Swap next function" },
					[">A"] = { query = "@parameter.inner", desc = "Swap next argument" },
				},
				swap_previous = {
					["<K"] = { query = "@block.outer", desc = "Swap previous block" },
					["<F"] = { query = "@function.outer", desc = "Swap previous function" },
					["<A"] = { query = "@parameter.inner", desc = "Swap previous argument" },
				},
			},
		},
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
