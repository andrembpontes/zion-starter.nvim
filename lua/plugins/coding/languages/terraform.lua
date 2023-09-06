return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["terraformls"] = function()
					local util = require("lspconfig").util
					return {
						filetypes = { "terraform", "hcl" },

						root_dir = util.root_pattern(".git")
							or util.root_pattern(".terraform")
							or vim.loop.os_homedir(),
					}
				end,
			},
		},
	},
}
