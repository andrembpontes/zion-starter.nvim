--- [[ Modes ]]
--- "n" -> normal
--- "i" -> insert
--- "v" -> visual + select
--- "o" -> operator
--- "!" -> insert + command_line
--- "t" -> terminal
--- "c" -> command_line

-- [[ Modifier Keys ]]
-- <C-a> -> Ctrl + A
-- <M-a> -> Meta (win key) + A
-- <A-a> -> Alt + A
-- <D-a> -> Cmd (macos) + A
-- <S-a> -> Shift + A

-- [[ Special Keys ]]
-- <Esc> -> escape
-- <CR> -> enter
-- <BS> -> backspace
-- <Tab> -> Tab

local map = vim.keymap.set
local iter = require("zion.keymap_iterator").setup_iterator

-- remap the key used to leave insert mode
map("i", "jk", "<esc>", { desc = "Exit Insert mode" })

-- <F1> help
-- <F2> vim-codepainter
-- <F3> vim-codepainter navigate
map("n", "<F4>", ":set number! relativenumber!<CR>")
map("n", "<F5>", ":set list! list?<CR>")
--map('n', '<F6>', '<CMD>lua require("FTerm").toggle()<CR>', { noremap = true, silent = true })
--map('t', '<F6>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', { noremap = true, silent = true })
map("n", "<F7>", ":Neotree toggle<CR>")
--map('n', '<F8>', ':MinimapToggle<CR>', {noremap = false, silent = true})
--map('n', '<leader>nm', ':Dispatch npm start<CR>')

-- Buffers
map("n", "<leader>bd", ":BDelete this<CR>")
map("n", "<leader>bda", ":BDelete! all<CR>")
map("n", "<leader>bdh", ":BDelete! hidden<CR>")
map("n", "<leader>bn", ":bnext<cr>")
map("n", "<leader>bp", ":bprevious<cr>")

-- Window
map("n", "<leader>h", ":wincmd h<cr>")
map("n", "<leader>j", ":wincmd j<cr>")
map("n", "<leader>k", ":wincmd k<cr>")
map("n", "<leader>l", ":wincmd l<cr>")

map("n", "<leader>H", ":vertical resize -5<cr>")
map("n", "<leader>J", ":resize -5<cr>")
map("n", "<leader>K", ":resize +5<cr>")
map("n", "<leader>L", ":vertical resize +5<cr>")

map({ "n", "v", "o" }, "<M-h>", ":wincmd h<cr>")
map({ "n", "v", "o" }, "<M-j>", ":wincmd j<cr>")
map({ "n", "v", "o" }, "<A-k>", ":wincmd k<cr>")
map({ "n", "v", "o" }, "<A-l>", ":wincmd l<cr>")

map({ "n", "v", "o" }, "<A-H>", ":vertical resize -5<cr>")
map({ "n", "v", "o" }, "<A-J>", ":resize -5<cr>")
map({ "n", "v", "o" }, "<A-K>", ":resize +5<cr>")
map({ "n", "v", "o" }, "<A-L>", ":vertical resize +5<cr>")

-- Trouble
map("n", "<leader>xx", "<cmd>Trouble<cr>")
map("n", "<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>")
map("n", "<leader>xd", "<cmd>Trouble document_diagnostics<cr>")
map("n", "<leader>xq", "<cmd>Trouble quickfix<cr>")

-- Code editing + navigate
map("n", "<BS>", "<C-o>")
map("n", "<S-BS>", "<C-i>")
map("n", "<CR>", [[:lua vim.lsp.buf.definition()<CR>]])

-- TODO: add support for range formatting, when visual mode
map("n", "<leader>cf", [[:FormatDocument<CR>]], { desc = "Format Document" })

map("n", "<leader>cr", function()
	local ok, _ = pcall(require, "inc_rename")

	if ok then
		return vim.cmd("IncRename " .. vim.fn.expand("<cword>"))
	else
		vim.lsp.buf.rename()
	end
end, { desc = "Rename" })

-- LSP
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("KeymapsLspConfig", {}),
	callback = function(ev)
		-- Buffer local mappings.
		-- See `:help vim.lsp.*` for documentation on any of the below functions
		local buf = ev.buf
		local opts = { buffer = buf }

		-- TODO review this
		vim.keymap.set("n", "<space>wa", vim.lsp.buf.add_workspace_folder, opts)
		vim.keymap.set("n", "<space>wr", vim.lsp.buf.remove_workspace_folder, opts)
		vim.keymap.set("n", "<space>wl", function()
			print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
		end, opts)

		vim.keymap.set({ "n", "v" }, "<space>ca", vim.lsp.buf.code_action, opts)
		vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
		vim.keymap.set("n", "<space>f", function()
			vim.lsp.buf.format({ async = true })
		end, opts)

		map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition", buffer = buf })
		map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References", buffer = buf })
		map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration", buffer = buf })
		map("n", "gi", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation", buffer = buf })

		map("n", "K", vim.lsp.buf.hover, { desc = "Hover", buffer = buf })
		map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = buf })
		map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help", buffer = buf })

		map({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action", buffer = buf })

		map({ "n", "v" }, "<leader>cA", function()
			vim.lsp.buf.code_action({
				context = {
					only = {
						"source",
					},
					diagnostics = {},
				},
			})
		end, { desc = "Source Action", buffer = buf })
	end,
})

-- [[ Diagnostics ]]
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })

iter("Diagnostic", "x", vim.diagnostic.goto_prev, vim.diagnostic.goto_next)
iter("Diagnostic", "d", vim.diagnostic.goto_prev, vim.diagnostic.goto_next)

iter("Error", "e", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["ERROR"] })
end, function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["ERROR"] })
end)

iter("Warning", "w", function()
	vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["WARN"] })
end, function()
	vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["WARN"] })
end)

-- QuickFix list
iter("n", "q", function()
	vim.cmd("cprev")
end, function()
	vim.cmd("cnext")
end)

-- Term keymaps
vim.api.nvim_create_autocmd({ "TermOpen" }, {
	group = vim.api.nvim_create_augroup("KeymapsTerm", {}),
	callback = function(args)
		local buf_name = vim.api.nvim_buf_get_name(args.buf)
		local buf_ftype = vim.api.nvim_buf_get_option(args.buf, "filetype")

		if vim.startswith(buf_name, "term://") then
			local o = { buffer = 0 }
			if buf_ftype ~= "lazygit" then
				map("t", "<esc><esc>", [[<C-\><C-n>]], o)
			end

			--vim.keymap.set("t", "jk", [[<C-\><C-n>]], o)
			map("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
			map("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
			map("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
			map("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
			map("t", "<C-w>", [[<C-\><C-n><C-w>]], o)
		end
	end,
})
