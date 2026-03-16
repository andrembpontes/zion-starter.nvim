--[[ init.lua ]]
-- ref: https://mattermost.com/blog/how-to-install-and-set-up-neovim-for-code-editing/

vim.env.SUDO_ASKPASS = "/sbin/lxqt-openssh-askpass"

-- LEADER
-- These keybindings need to be defined before any other keymaps; otherwise,
-- it will default to "\"

vim.g.mapleader = " "
vim.g.localleader = "\\"

require('configs.lazy')
