if vim.g.neovide then
	-- Running inside NeoVide
	require("user.configs.neovide.globals")
	require("user.configs.neovide.keymaps")
	require("user.configs.neovide.style")
end
