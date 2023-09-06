return {
	-- Manage global and project-local settings
	-- Neoconf show
	{ "folke/neoconf.nvim", cmd = "Neoconf", config = true },

	-- Navbar symbols
	{
		"SmiteshP/nvim-navic",
		lazy = true,

		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("Navic", {}),
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client.server_capabilities.documentSymbolProvider then
						require("nvim-navic").attach(client, bufnr)
					end
				end,
			})
		end,
	},

	{
		-- code structure
		"majutsushi/tagbar",
		enabled = false,
	},

	{
		"windwp/nvim-autopairs",
		event = "InsertEnter",
		config = true,
	},

	-- Comment code
	{
		"numToStr/Comment.nvim",
		keys = {
			{ "gcc" },
			{ "gbc" },
			{ "gc", mode = "v" },
			{ "gb", mode = "v" },
		},
		config = true,
	},

	{
		"weilbith/nvim-code-action-menu",
		dependencies = {
			"kosayoda/nvim-lightbulb",
			dependencies = { "antoinemadec/FixCursorHold.nvim" },
			opts = {
				autocmd = { enabled = true },
			},
		},
		cmd = "CodeActionMenu",
		-- TODO: add keys
	},

	-- LSP Diagnostic UI
	{
		"folke/trouble.nvim",
		event = "LspAttach", -- Not required before LSP is attached
		dependencies = { "nvim-tree/nvim-web-devicons" },
	},

	-- LSP servers progress
	{
		"j-hui/fidget.nvim",
		event = "LspAttach", -- Not required before LSP is attached
		tag = "legacy",
		opts = {},
	},
}
