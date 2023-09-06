local util = require("lspconfig").util

local filetypes = { "elixir", "eex", "heex", "surface" }

if true then
	return {
		{
			"neovim/nvim-lspconfig",
			opts = {
				servers = {
					["elixirls"] = {

						--cmd = "/usr/local/bin/elixir-ls.sh",
						settings = {
							elixirLS = {
								dialyzerEnabled = true,
								enableTestLenses = true,
								fetchDeps = false,
								suggestSpecs = true,
							},
						},
						on_attach = function()
							vim.keymap.set("i", ";;", "|>", { buffer = true, noremap = true })
						end,

						root_dir = function(fname)
							return util.root_pattern(".lsp_root")(fname)
								or util.root_pattern("mix.exs", ".git")(fname)
								or vim.loop.os_homedir()
						end,

						filetypes = filetypes,
						--root_dir = util.root_pattern(".git") or util.root_pattern("mix.exs") or vim.loop.os_homedir(),
					},
				},
			},
		},
	}
end

return {
	{
		"neovim/nvim-lspconfig",
		opts = {
			setup = {
				["elixirls"] = function()
					return true
				end,
			},
		},
	},
	{
		"elixir-tools/elixir-tools.nvim",
		version = "*",
		event = { "BufReadPre", "BufNewFile" },
		ft = filetypes,
		config = function()
			local elixir = require("elixir")
			local elixirls = require("elixir.elixirls")

			local manson_options = require("user.utils.plugins").getOpts("manson")
			local manson_install_dir = manson_options.install_root_dir or (vim.fn.stdpath("data") .. "/mason")

			elixir.setup({
				cmd = manson_install_dir .. "/packages/elixir-ls/language_server.sh",

				nextls = { enable = true },
				credo = {},
				elixirls = {
					enable = true,
					settings = elixirls.settings({
						dialyzerEnabled = true,
						enableTestLenses = true,
						fetchDeps = false,
						suggestSpecs = false,
					}),

					on_attach = function(client, bufnr)
						vim.keymap.set("n", "<space>fp", ":ElixirFromPipe<cr>", { buffer = true, noremap = true })
						vim.keymap.set("n", "<space>tp", ":ElixirToPipe<cr>", { buffer = true, noremap = true })
						vim.keymap.set("v", "<space>em", ":ElixirExpandMacro<cr>", { buffer = true, noremap = true })

						vim.keymap.set("i", ";;", "|>", { buffer = true, noremap = true })
					end,
				},

				--log_level = vim.lsp.protocol.MessageType.Log,
				--message_level = vim.lsp.protocol.MessageType.Log,

				filetypes = filetypes,
				--root_dir = util.root_pattern(".git") or util.root_pattern("mix.exs") or vim.loop.os_homedir(),
			})
		end,
		dependencies = {
			{ "nvim-lua/plenary.nvim" },
			{ "williamboman/mason.nvim" },
		},
	},
}
