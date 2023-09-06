-- Automatically loaded on the VeryLazy event
-- see lua/configs/init.lua for more details

local keys = require("user.utils.keymaps")
local hydra = require("hydra")
local iterator = nil --require("configs.keymaps.IteratorMode"):new()
local LayerMode = require("configs.keymaps.LayerMode")
local noop = function() end

local function cmd(str)
    return "<cmd>" .. str .. "<cr>"
end

local function wrap_input(input)
    if type(input) == "string" then
        return function()
            vim.api.nvim_input(input)
        end
    elseif type(input) == "function" then
        return input
    else
        error("wrap_input() invalid type: " .. type(input))
    end
end

local function x_layermode_set_iterator(name, key, on_prev, on_next, on_list)
    local mode = LayerMode:new("ITER" .. string.upper(name), "]" .. key, {
        { "]", on_next or noop },
        { "[", on_prev or noop },
        { "l", on_list or noop },
    })
end

local function x_itermode_set_iterator(name, key, on_prev, on_next, on_list)
    iterator:add_iterator({
        name = name,
        key = key,
        on_prev = on_prev,
        on_next = on_next,
        on_list = on_list,
    })
end

local function x_set_iterator(name, key, on_prev, on_next, on_list)
    local config = {
        name = name,
        hint = [[%{name}
_[_: Get prev
_]_: Get next]],
        mode = "n",
        heads = {
            { "[", on_prev },
            { "]", on_next },
        },
        config = {
            hint = {
                type = "window",
                position = "middle-right",
                offset = 3,
                funcs = {
                    name = function()
                        return name
                    end,
                },
            },
            invoke_on_body = true,
        },
    }

    if on_list then
        config.heads[#config.heads + 1] = { "l", on_list, { exit = true } }
        config.hint = config.hint .. [[

_l_: List
        ]]
    end

    hydra(vim.tbl_deep_extend("force", config, {
        body = "]" .. key,
        config = {
            on_enter = wrap_input(on_next),
        },
    }))
    hydra(vim.tbl_deep_extend("force", config, {
        body = "[" .. key,
        config = {
            on_enter = wrap_input(on_prev),
        },
    }))
end


local function set_iterator(name, key, on_prev, on_next, on_list)
    return x_layermode_set_iterator(name, key, on_prev, on_next, on_list)
end

-- e.g. modifier keys
-- <C-a> -> Ctrl + A
-- <M-a> -> Meta (win key) + A
-- <A-a> -> Alt + A
-- <D-a> -> Cmd (macos) + A

-- remap the key used to leave insert mode
keys.imap("jk", "<esc>")

-- TODO review mappings

-- <F1> help
-- <F2> vim-codepainter
-- <F3> vim-codepainter navigate
keys.nmap("<F4>", ":set number! relativenumber!<CR>")
keys.nmap("<F5>", ":set list! list?<CR>")
--map('n', '<F6>', '<CMD>lua require("FTerm").toggle()<CR>', { noremap = true, silent = true })
--map('t', '<F6>', '<C-\\><C-n><CMD>lua require("FTerm").toggle()<CR>', { noremap = true, silent = true })
keys.nmap("<F7>", ":Neotree toggle<CR>")
--map('n', '<F8>', ':MinimapToggle<CR>', {noremap = false, silent = true})
--map('n', '<leader>nm', ':Dispatch npm start<CR>')

-- Buffers
keys.nmap("<leader>bd", ":BDelete this<CR>")
keys.nmap("<leader>bda", ":BDelete! all<CR>")
keys.nmap("<leader>bdh", ":BDelete! hidden<CR>")
keys.nmap("<leader>bn", ":bnext<cr>")
keys.nmap("<leader>bp", ":bprevious<cr>")

-- Window
keys.nmap("<leader>h", ":wincmd h<cr>")
keys.nmap("<leader>j", ":wincmd j<cr>")
keys.nmap("<leader>k", ":wincmd k<cr>")
keys.nmap("<leader>l", ":wincmd l<cr>")

keys.nmap("<leader>H", ":vertical resize -5<cr>")
keys.nmap("<leader>J", ":resize -5<cr>")
keys.nmap("<leader>K", ":resize +5<cr>")
keys.nmap("<leader>L", ":vertical resize +5<cr>")

keys.map("<M-h>", ":wincmd h<cr>")
keys.map("<M-j>", ":wincmd j<cr>")
keys.map("<A-k>", ":wincmd k<cr>")
keys.map("<A-l>", ":wincmd l<cr>")

keys.map("<A-H>", ":vertical resize -5<cr>")
keys.map("<A-J>", ":resize -5<cr>")
keys.map("<A-K>", ":resize +5<cr>")
keys.map("<A-L>", ":vertical resize +5<cr>")

-- Trouble
keys.nmap("<leader>xx", "<cmd>Trouble<cr>")
keys.nmap("<leader>xw", "<cmd>Trouble workspace_diagnostics<cr>")
keys.nmap("<leader>xd", "<cmd>Trouble document_diagnostics<cr>")
keys.nmap("<leader>xq", "<cmd>Trouble quickfix<cr>")

-- Code editing + navigate
keys.nmap("<BS>", "<C-o>")
keys.nmap("<S-BS>", "<C-i>")
keys.nmap("<CR>", [[:lua vim.lsp.buf.definition()<CR>]])

-- QuickFix list
keys.nmap("]q", [[:cnext<CR>]])
keys.nmap("[q", [[:cprevious<CR>]])

-- LSP
keys.nmap("<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
keys.nmap("<leader>cl", "<cmd>LspInfo<cr>", { desc = "Lsp Info" })
keys.nmap("gd", "<cmd>Telescope lsp_definitions<cr>", { desc = "Goto Definition" })
keys.nmap("gr", "<cmd>Telescope lsp_references<cr>", { desc = "References" })
keys.nmap("gD", vim.lsp.buf.declaration, { desc = "Goto Declaration" })
keys.nmap("gI", "<cmd>Telescope lsp_implementations<cr>", { desc = "Goto Implementation" })
keys.nmap("gt", "<cmd>Telescope lsp_type_definitions<cr>", { desc = "Goto Type Definition" })
keys.nmap("K", vim.lsp.buf.hover, { desc = "Hover" })
keys.nmap("gK", vim.lsp.buf.signature_help, { desc = "Signature Help" })
keys.imap("<c-k>", vim.lsp.buf.signature_help, { desc = "Signature Help" })

keys.nmap("]x", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
keys.nmap("[x", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })
keys.nmap("]d", vim.diagnostic.goto_next, { desc = "Next Diagnostic" })
keys.nmap("[d", vim.diagnostic.goto_prev, { desc = "Prev Diagnostic" })

keys.nmap("]e", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["ERROR"] })
end, { desc = "Next Error" })

keys.nmap("[e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["ERROR"] })
end, { desc = "Next Error" })

keys.nmap("]w", function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["WARN"] })
end, { desc = "Next Error" })

keys.nmap("[w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["WARN"] })
end, { desc = "Next Error" })

-- TODO: add support for range formatting, when visual mode
keys.nmap("<leader>cf", [[:FormatDocument<CR>]], { desc = "Format Document" })

keys.nmap("<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })

keys.nmap("<leader>cA", function()
    vim.lsp.buf.code_action({
        context = {
            only = {
                "source",
            },
            diagnostics = {},
        },
    })
end, { desc = "Source Action" })

keys.nmap("<leader>cr", function()
    if require("user.utils.plugins").has("inc-rename.nvim") then
        require("inc_rename")
        return vim.cmd("IncRename " .. vim.fn.expand("<cword>"))
    else
        vim.lsp.buf.rename()
    end
end, { desc = "Rename" })

set_iterator("buffer", "b", "bprev", "bnext", "ls")
set_iterator("quickfix", "q", cmd("cprev"), cmd("cnext"), cmd("Trouble quickfix"))

set_iterator(
    "diagnostic",
    "x",
    vim.diagnostic.goto_prev,
    vim.diagnostic.goto_next,
    cmd("Trouble workspace_diagnostics")
)

set_iterator("error", "e", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["ERROR"] })
end, function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["ERROR"] })
end)

set_iterator("warning", "w", function()
    vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity["WARN"] })
end, function()
    vim.diagnostic.goto_next({ severity = vim.diagnostic.severity["WARN"] })
end)

if iterator then
    iterator:setup_hydra()
end

return {} -- Lazy requires a table return
