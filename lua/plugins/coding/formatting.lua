local state = {
	autoformatEnabled = true,
}

local function toggleAutoformat()
	state.autoformatEnabled = not state.autoformatEnabled

	if state.autoformatEnabled then
		print("[Autoformat] Enabled format on save")
	else
		print("[Autoformat] Disabled format on save")
	end
end

local function formatBuffer(bufnr)
	if not state.autoformatEnabled then
		return
	end

	local ft = vim.bo[bufnr].filetype
	local have_null_ls = #require("null-ls.sources").get_available(ft, "NULL_LS_FORMATTING") > 0

	vim.lsp.buf.format(vim.tbl_deep_extend("force", {
		bufnr = bufnr,

		-- filter clients to be used
		-- TODO: review precedence
		filter = function(client)
			if have_null_ls then
				return client.name == "null-ls"
			else
				return client.name ~= "null-ls" and client.supports_method("textDocument/formatting")
			end
		end,
	}, require("user.utils.plugins").getOpts("nvim-lspconfig").format or {}))
end

vim.api.nvim_create_autocmd("BufWritePre", {
	group = vim.api.nvim_create_augroup("Autoformat", {}),
	callback = function()
		formatBuffer(vim.api.nvim_get_current_buf())
	end,
})

vim.api.nvim_create_user_command("FormatDocument", function()
	formatBuffer(vim.api.nvim_get_current_buf())
end, {})

vim.api.nvim_create_user_command("FormatOnSaveToggle", toggleAutoformat, {})

return {}
