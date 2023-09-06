-- Automatically loaded on startup
-- see lua/configs/init.lua for more details

-- TODO check following options
-- opt.undofile
-- opt.undodir

-- [[ Context ]]
vim.opt.colorcolumn = "80" -- str:  Show col for max line length
vim.opt.number = true -- bool: Show line numbers
vim.opt.relativenumber = true -- bool: Show relative line numbers
vim.opt.scrolloff = 8 -- int:  Min num lines of context
vim.opt.signcolumn = "yes" -- str:  Show the sign column
vim.opt.showtabline = 2 -- int: 0: Never, 1: Auto, 2: Always

-- [[ Filetypes ]]
vim.opt.encoding = "utf8" -- str:  String encoding to use
vim.opt.fileencoding = "utf8" -- str:  File encoding to use
vim.opt.fileformat = "unix"
vim.opt.fixendofline = true -- bool: Ensure <EOL> at the end of document

-- [[ Theme ]]
vim.opt.syntax = "ON" -- str:  Allow syntax highlighting
vim.opt.termguicolors = true -- bool: If term supports ui color then enable
vim.opt.cursorline = true -- bool: highlight line under cursor
vim.opt.listchars = {
	tab = ">>>",
	trail = "·",
	precedes = "←",
	extends = "→",
	eol = "↲",
	nbsp = "␣",
}
vim.opt.list = true

-- [[ Search ]]
vim.opt.ignorecase = true -- bool: Ignore case in search patterns
vim.opt.smartcase = true -- bool: Override ignorecase if search contains capitals
vim.opt.incsearch = true -- bool: Use incremental search
vim.opt.hlsearch = true -- bool: Highlight search matches

-- [[ Whitespace ]]
vim.opt.expandtab = true -- bool: Use spaces instead of tabs
vim.opt.shiftwidth = 4 -- num:  Size of an indent
vim.opt.softtabstop = 4 -- num:  Number of spaces tabs count for in insert mode
vim.opt.tabstop = 4 -- num:  Number of spaces tabs count for

-- [[ Splits ]]
vim.opt.splitright = true -- bool: Place new window to right of current one
vim.opt.splitbelow = true -- bool: Place new window below the current one

-- [[ Language ]]
vim.opt.spelllang = "en"

vim.opt.mouse = "nvc"
vim.opt.updatetime = 250

return {} -- Lazy requires a table return
