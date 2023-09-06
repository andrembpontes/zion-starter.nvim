-- Set font
if vim.fn.has("unix") == 1 then
	local uname = vim.fn.system("uname")
	if uname == "Darwin\n" then
		vim.opt.guifont = "JetBrainsMono Nerd Font:h14"
	else
		vim.opt.guifont = "JetBrains Mono 8"
	end
end

return {} -- Lazy requires a table return
