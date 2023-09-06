return {
	{
		"nvim-telescope/telescope.nvim",
		dependencies = {
			{ "nvim-lua/plenary.nvim" },

			-- extensions
			"barrett-ruth/telescope-http.nvim",
		},
		opts = function()
			local config = require("telescope.config")
			local trouble = require("trouble.providers.telescope")

			-- Clone the default Telescope configuration
			local vimgrep_arguments = { unpack(config.values.vimgrep_arguments) }

			-- I want to search in hidden/dot files.
			table.insert(vimgrep_arguments, "--hidden")
			-- I don't want to search in the `.git` directory.
			table.insert(vimgrep_arguments, "--glob")
			table.insert(vimgrep_arguments, "!**/.git/*")

			return {
				defaults = {
					-- `hidden = true` is not supported in text grep commands.
					vimgrep_arguments = vimgrep_arguments,

					mappings = {
						i = { ["<c-t>"] = trouble.open_with_trouble },
						n = { ["<c-t>"] = trouble.open_with_trouble },
					},
				},

				pickers = {
					find_files = {
						-- `hidden = true` will still show the inside of `.git/` as it's not `.gitignore`d.
						find_command = { "rg", "--files", "--hidden", "--glob", "!**/.git/*" },
					},

					live_grep = {
						additional_args = { "--hidden" },
						glob_pattern = { "!**/.git/*" },
					},
				},
			}
		end,
		cmd = "Telescope",
		keys = {
			{ "<leader><leader>", [[:Telescope buffers<cr>]], desc = "Telescope Buffers" },
			{ "<leader>/", [[:Telescope live_grep<cr>]], desc = "Telescope LiveGrep" },
			{
				"<leader><cr>",
				[[:Telescope lsp_dynamic_workspace_symbols<cr>]],
				desc = "Telescope LSP DynWrk Symbols",
			},

			{ "<leader>ff", [[:Telescope find_files<cr>]], desc = "Telescode Find Files" },
			{ "<leader>fp", [[:Telescope projects<cr>]], desc = "Telescope Projects" },
			{ "<leader>fx", [[:Telescope diagnostics<cr>]], desc = "Telescope Diagnostics" },
			{ "<leader>fb", [[:Telescope buffers<cr>]], desc = "Telescope Buffers" },
			{ "<leader>fS", [[:Telescope lsp_dynamic_workspace_symbol<cr>]], desc = "Telescope LSP DynWrk Symbols" },
			{ "<leader>fs", [[:Telescope treesitter<cr>]], desc = "Telescope Treesitter" },
			{ "<leader>fg", [[:Telescope live_grep<cr>]], desc = "Telescope LiveGrep" },
			{ "<leader>fr", [[:Telescope lsp_references<cr>]], desc = "Telescope References" },
			{ "<leader>fd", [[:Telescope lsp_definitions<cr>]], desc = "Telescope Definitions" },
		},
		config = function(_, opts)
			local telescope = require("telescope")
			telescope.setup(opts)

			-- load extension
			telescope.load_extension("projects")
			telescope.load_extension("notify")
			telescope.load_extension("http")
		end,
	},
}
