return {
	{
		"neovim/nvim-lspconfig",
		lazy = false,
		event = { "BufReadPre", "BufNewFile" },
		dependencies = {
			-- LS manager
			"williamboman/mason.nvim",
			"williamboman/mason-lspconfig.nvim",
			{ import = "plugins.coding.languages" },
		},

		opts = {
			-- LSP server options
			-- setup: fn(server, opts) => bool - True if Mason should auto setup it
			-- opts: fn(server, opts) => opts - Options to setup server

			servers = {
				["*"] = function()
					local util = require("lspconfig").util
					local capabilities =
						require("cmp_nvim_lsp").default_capabilities(vim.lsp.protocol.make_client_capabilities())

					return {
						capabilities = vim.deepcopy(capabilities),

						root_dir = util.root_pattern(".lsp_root") or util.root_pattern(".git") or vim.loop.os_homedir(),
					}
				end,
			},

			install = {
				["*"] = function()
					return true
				end,
			},

			setup = {
				["*"] = function()
					return true
				end,
			},
		},

		config = function(_, opts)
			pcall(require, "neoconf") --if NeoConf, then ensure it is loaded first

			require("mason") --ensure mason is loaded first
			local mason_lspconfig = require("mason-lspconfig")
			local server_opts_cache = {}

			--vim.lsp.set_log_level("info")
			--vim.lsp.set_log_level("debug")

			--print(vim.inspect(opts))

			local function eval_server_opts(server_opts, name, base_opts)
				if type(server_opts) == "function" then
					return server_opts(name, base_opts or {})
				end

				return vim.tbl_deep_extend("force", base_opts or {}, server_opts or {})
			end

			local function get_server_opts(name)
				if server_opts_cache[name] then
					return server_opts_cache[name]
				end

				local fallback_opts = eval_server_opts(opts.servers["*"], name)
				server_opts_cache[name] = eval_server_opts(opts.servers[name], name, fallback_opts)
				return server_opts_cache[name]
			end

			local function setup_server(name)
				local server_opts = get_server_opts(name)

				if opts.setup[name] then
					if not opts.setup[name](name, server_opts) then
						-- setup returned false, skip setup
						return
					end
				else
					if not opts.setup["*"](name, server_opts) then
						-- setup returned false, skip setup
						return
					end
				end

				require("lspconfig")[name].setup(server_opts)
			end

			-- get all the servers that are available thourgh mason-lspconfig
			local available_servers = vim.tbl_keys(require("mason-lspconfig.mappings.server").lspconfig_to_package)

			local to_install = {} ---@type string[]
			for key, value in pairs(opts.servers) do
				local server_opts = get_server_opts(key) or {}

				-- skip
				if key ~= "*" and server_opts then
					-- run manual setup if mason=false or if this is a server that cannot be installed with mason-lspconfig
					local install_fn = opts.install[key] or opts.install["*"]

					if install_fn(key, server_opts) and vim.tbl_contains(available_servers, key) then
						-- add into to_install
						-- setup is called by mason setup_handlers
						to_install[#to_install + 1] = key
					else
						-- not available or optted-out
						-- call setup directly
						setup_server(key)
					end
				end
			end

			mason_lspconfig.setup({ ensure_installed = to_install })
			mason_lspconfig.setup_handlers({ setup_server })
		end,
	},

	{
		"jose-elias-alvarez/null-ls.nvim",
		event = { "BufReadPre", "BufNewFile" },
		opts = function()
			local nls = require("null-ls")
			return {
				root_dir = require("null-ls.utils").root_pattern(".null-ls-root", ".neoconf.json", "Makefile", ".git"),

				sources = {
					nls.builtins.formatting.fish_indent,
					nls.builtins.diagnostics.fish,
					nls.builtins.formatting.stylua,
					nls.builtins.formatting.shfmt,
					-- nls.builtins.diagnostics.flake8,
					-- nls.builtins.diagnostics.eslint_d,
				},
			}
		end,
	},

	-- LSP hover signature
	{
		"ray-x/lsp_signature.nvim",
		event = "LspAttach", -- useless before having LSP attached
		opts = {},
	},
}
