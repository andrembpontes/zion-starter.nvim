local M = {}

function M.setup()
	local function _load_all(load_fn)
		load_fn("autocmds")
		load_fn("coding")
		load_fn("globals")
		load_fn("keymaps")
		load_fn("neovide")
		load_fn("style")
		load_fn("winbar")
	end

	if true or vim.fn.argc(-1) == 0 then
		-- autocmds and keymaps can wait to load
		vim.api.nvim_create_autocmd("User", {
			group = vim.api.nvim_create_augroup("LazyVim", { clear = true }),
			pattern = "VeryLazy",
			callback = function()
				_load_all(M.load)
			end,
		})
	else
		-- load them now so they affect the opened buffers
		_load_all(M.load)
	end
end

function M.load(name)
	local function _load(mod)
		local ok, resultOrError = pcall(require, mod)
		if ok then
			print(mod .. " successfully loaded")
		else
			print("Error loading: " .. mod)
			print(resultOrError)
		end
	end
	_load("configs." .. name)
end

M.did_init = false
function M.init()
	if not M.did_init then
		M.did_init = true

		-- load options here, before lazy init while sourcing plugin modules
		-- this is needed to make sure options will be correctly applied
		-- after installing missing plugins
		M.load("options")
	end
end

-- require("configs.options")
--
-- local function reload_configs()
-- 	require("configs.globals")
-- 	require("configs.keymaps")
-- 	require("configs.style")
-- 	require("configs.winbar")
-- 	require("configs.neovide")
-- end
--
-- vim.api.nvim_create_user_command("MyReloadConfigs", function()
-- 	reload_configs()
-- end, {})
--
-- if vim.fn.argc(-1) == 0 then
-- 	-- autocmds and keymaps can wait to load
-- 	vim.api.nvim_create_autocmd("User", {
-- 		group = vim.api.nvim_create_augroup("LazyVim", { clear = true }),
-- 		pattern = "VeryLazy",
-- 		callback = function()
-- 			print("Configs lazy loaded")
-- 			reload_configs()
-- 		end,
-- 	})
-- else
-- 	-- load them now so they affect the opened buffers
-- 	print("Configs loaded immediately")
-- 	reload_configs()
-- end

return M
