-- Ignore
-- REMOVE THIS WHEN USING AS TEMPLATE
if true then
	return {}
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				["server_name"] = {

					-- setup = function(name, opts) end,

					-- generate LS settings
					opts = {
						-- custom options
					},
				},
			},

			--install =  {
			-- optional, default true
			-- return true to auto install (i.e. using mason)
			--["server_name"] = function(name, opts) end
			--}

			--setup =  {
			-- optional, default true
			-- setup the LS
			-- return true to auto setup (i.e. using lsp-config)
			--["server_name"] = function(name, opts) end
			--}
		},
	},
}
