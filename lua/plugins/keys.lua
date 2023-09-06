return {
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
			vim.opt.timeoutlen = 500
		end,
		config = function(_, opts)
			require("which-key").setup(opts)
		end,
	},

	-- custom submodes and menus
	{ "anuvyklack/hydra.nvim" },

	{
		"Iron-E/nvim-libmodal",
		lazy = true, -- don't load until necessary
		version = "^3.0", -- OPTIONAL: unsubscribe from breaking changes
	},
}
