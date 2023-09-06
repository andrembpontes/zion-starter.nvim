local diagnostics_icons = {
	Error = " ",
	Warn = " ",
	Hint = " ",
	Info = " ",
}

for name, icon in pairs(diagnostics_icons) do
	name = "DiagnosticSign" .. name
	vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end

vim.diagnostic.config({
	-- more info: https://neovim.io/doc/user/diagnostic.html#vim.diagnostic.config()

	underline = true, --underlines diagnostic messages
	update_in_insert = false,
	virtual_text = { spacing = 4, prefix = "●" },
	severity_sort = true,
})

return {} -- Lazy requires a table return
