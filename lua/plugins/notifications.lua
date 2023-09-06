return {
	{
		"rcarriga/nvim-notify",
		cmd = { "Notifications" },
		init = function()
			vim.notify = require("notify")
		end,
	},
}
