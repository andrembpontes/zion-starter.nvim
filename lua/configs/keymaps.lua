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

local map = vim.keymaps.set;

-- remap the key used to leave insert mode
map("n", "jk", "<esc>", { desc = "Exit Insert mode" })

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

-- QuickFix list
map("n", "]q", [[:cnext<CR>]])
map("n", "[q", [[:cprevious<CR>]])

-- LSP
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
map("n", "gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
map("n", "gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
map("n", "gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
map("n", "gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
map("n", "gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto Type Definition" })
map("n", "K", vim.lsp.buf.hover, { desc = "Hover" })
map("n", "gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
map("i", "<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

map("n", "]x", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[x", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
map("n", "]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
map("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

map("n", "]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["ERROR"] })
end, { desc = "Next Error" })

map("n", "[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["ERROR"] })
end, { desc = "Next Error" })

map("n", "]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["WARN"] })
end, { desc = "Next Warning" })

map("n", "[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["WARN"] })
end, { desc = "Next Warning" })

-- TODO: add support for range formatting, when visual mode
map("n", "<leader>cf", [[:FormatDocument<CR>]], { desc = "Format Document" })

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

map("n", "<leader>cA", function()
    vim.lsp.buf.code_action({
        context = {
            only = {
                "source",
            },
            diagnostics = {},
        },
    })
end, { desc = "Source Action" })

map("n", "<leader>cr", function()
    if require("user.utils.plugins").has("inc-rename.nvim") then
        require("inc_rename")
        return vim.cmd("IncRename " .. vim.fn.expand("<cword>"))
    else
        vim.lsp.buf.rename()
    end
end, { desc = "Rename" })
