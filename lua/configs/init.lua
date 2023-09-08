local M = {}

local load = require("zion.configs").load

function M.setup()
    load("configs.keymaps")
    load("configs.neovide")
end

function M.init()
    load("configs.options")
end

return M
