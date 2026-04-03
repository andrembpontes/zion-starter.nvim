--[[ init.lua ]]
-- ref: https://mattermost.com/blog/how-to-install-and-set-up-neovim-for-code-editing/

vim.env.SUDO_ASKPASS = "/sbin/lxqt-openssh-askpass"

-- LEADER
-- These keybindings need to be defined before any other keymaps; otherwise,
-- it will default to "\"

vim.g.mapleader = " "
vim.g.localleader = "\\"

if vim.env.NVIM_DEBUG_NOTIFY == "1" then
	require("configs.debug").setup()
end

require('configs.lazy')
