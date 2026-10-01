return {
	{
		"nvim-neo-tree/neo-tree.nvim",
		keys = {
			{
				"<leader>fE",
				function()
					-- Root the tree at the current file's project root, without
					-- touching vim's cwd (see `bind_to_cwd = false` below).
					local root = vim.fs.root(0, { ".lsp_root", ".git" }) or vim.fn.getcwd()
					vim.cmd("Neotree filesystem " .. vim.fn.fnameescape(root) .. " left")
				end,
				desc = "Explore project root",
			},
		},
		opts = function(_, opts)
			-- Upstream zion.nvim keeps neo-tree's `bind_to_cwd = true` default, which
			-- makes vim's cwd and the tree root a 2-way binding: browsing in the tree
			-- changes the cwd, and any cwd change (`:cd`, project.nvim on BufEnter, ...)
			-- re-roots the tree. Root changes are explicit here instead:
			-- `<leader>fe` (reveal current file) and `<leader>fE` (project root).
			opts.filesystem = opts.filesystem or {}
			opts.filesystem.bind_to_cwd = false
			return opts
		end,
	},
}
