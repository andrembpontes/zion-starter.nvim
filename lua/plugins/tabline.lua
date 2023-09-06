return {
	{
		"akinsho/bufferline.nvim",
		event = "VeryLazy",
		version = "*",
		dependencies = "nvim-tree/nvim-web-devicons",
		opts = {
			options = {
				mode = "tabs", -- key tabline the VIM-way
				show_close_icon = false,
				show_buffer_close_icons = false,
			},
		},
	},
}
