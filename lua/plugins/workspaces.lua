return {
	{
		"ahmedkhalf/project.nvim",
		opts = {
			detection_methods = { "lsp", "pattern" },
			patterns = { ".git" },
			-- Table of lsp clients to ignore by name
			-- eg: { "efm", ... }
			ignore_lsp = {},
		},
		config = function(_, opts)
			require("project_nvim").setup(opts)
		end,
	},
}
