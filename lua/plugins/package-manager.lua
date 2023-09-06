return {
	{
		"williamboman/mason.nvim",
		lazy = false, --Lazy loading NOT recommended by the authors
		config = function(_, opts)
			require("mason").setup(opts)
		end,
	},
}
