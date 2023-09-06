return {
	{
		"nvim-neotest/neotest",
		event = "LspAttach",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
			"antoinemadec/FixCursorHold.nvim",
			"jfpedroza/neotest-elixir",
		},
		opts = function(_, opts)
			local patch = {
				adapters = {
					require("neotest-elixir")({
						-- The Mix task to use to run the tests
						-- Can be a function to return a dynamic value.
						-- Default: "test"
						mix_task = { "test" },
						-- Other formatters to pass to the test command as the formatters are overridden
						-- Can be a function to return a dynamic value.
						-- Default: {"ExUnit.CLIFormatter"}
						extra_formatters = { "ExUnit.CLIFormatter", "ExUnitNotifier" },
						-- Extra arguments to pass to mix test
						-- Can be a function that receives the position, to return a dynamic value
						-- Default: {}
						args = {},
						-- Command wrapper
						-- Must be a function that receives the mix command as a table, to return a dynamic value
						-- Default: function(cmd) return cmd end
						post_process_command = function(cmd)
							--print(vim.inspect(cmd))
							return cmd
						end,
						-- Delays writes so that results are updated at most every given milliseconds
						-- Decreasing this number improves snappiness at the cost of performance
						-- Can be a function to return a dynamic value.
						-- Default: 1000
						write_delay = 1000,
					}),
				},
			}

			return vim.tbl_deep_extend("force", opts, patch)
		end,
	},
}
