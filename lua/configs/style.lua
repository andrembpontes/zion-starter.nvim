-- Set font
-- Automatically loaded on the VeryLazy event
-- see lua/configs/init.lua for more details

vim.opt.conceallevel = 2
vim.opt.concealcursor = ""

vim.opt.wrap = true
vim.opt.showbreak = "+++"
vim.opt.linebreak = true

for name, icon in pairs(require("config").icons.diagnostics) do
	name = "DiagnosticSign" .. name
	vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
end
