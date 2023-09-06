return {
	{
		"SmiteshP/nvim-navbuddy",
		cmd = "Navbuddy",
		dependencies = {
			"MunifTanjim/nui.nvim",
		},
		init = function()
			vim.api.nvim_create_autocmd("LspAttach", {
				group = vim.api.nvim_create_augroup("Navbuddy", {}),
				callback = function(args)
					local bufnr = args.buf
					local client = vim.lsp.get_client_by_id(args.data.client_id)
					if client.server_capabilities.documentSymbolProvider then
						require("nvim-navbuddy").attach(client, bufnr)
					end
				end,
			})
		end,
	},
}
