return {
	{
		"nvim-treesitter/nvim-treesitter",
		opts = function(_, opts)
			-- The upstream zion.nvim default is `ensure_installed = "all"`, which can
			-- trigger a lot of background parser installs and noisy messages.
			opts.ensure_installed = {
				"bash",
				"json",
				"lua",
				"markdown",
				"markdown_inline",
				"query",
				"regex",
				"toml",
				"vim",
				"vimdoc",
				"yaml",
			}
			opts.auto_install = false
			opts.sync_install = false
			return opts
		end,
	},
}
