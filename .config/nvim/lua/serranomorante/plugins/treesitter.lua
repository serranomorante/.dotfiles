return {
	"nvim-treesitter/nvim-treesitter",
	dependencies = {
		"windwp/nvim-ts-autotag",
		"JoosepAlviste/nvim-ts-context-commentstring",
	},
	event = "BufEnter",
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
	opts = {
		ensure_installed = {
			"bash",
			"fish",
			-- lua
			"lua",
			-- typescript
			"javascript",
			"jsdoc",
			"tsx",
			"typescript",
			-- python
			"python",
			"toml",
			-- golang
			"go",
			-- toml
			"toml",
			-- rust
			"rust",
			-- c
			"c",
			"cpp",
			-- kdl
			"kdl",
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
	},
	config = function(_, opts)
		require("nvim-treesitter.configs").setup(opts)
	end,
}
