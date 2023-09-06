local function configure_term(baseOpts, config)
    local Terminal = require("toggleterm.terminal").Terminal
    local opts = config.opts
    local name = config.cmd or ("Term" .. opts.cmd:gsub("^%l", string.upper))

    local termOpts = vim.tbl_deep_extend("force", baseOpts, { hidden = true }, opts)
    local t = Terminal:new(termOpts)

    vim.api.nvim_create_user_command(name, function()
        t:toggle()
    end, {})

    if config.key then
        vim.keymap.set("n", config.key, function()
            t:toggle()
        end, { desc = name .. " toggle" })
    end

    return t
end

local function configure_htop(config)
    config({
        opts = {
            cmd = "htop",
            direction = "float",
            float_opts = {
                border = "double",
            },
        },
    })
end

local function configure_lazygit(config)
    config({
        --key = "<leader>gg",
        opts = {
            cmd = "lazygit",
            dir = "git_dir",
            env = {
                GIT_EDITOR = "nvr -cc close -cc split --remote-wait +'set bufhidden=wipe'",
            },

            direction = "float",
            float_opts = {
                border = "double",
            },
        },
    })
end

return {
    {
        "akinsho/toggleterm.nvim",
        event = { "VeryLazy" },
        version = "*",
        keys = {
            { "<leader>1", [[:1ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 1" } },
            { "<leader>2", [[:2ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 2" } },
            { "<leader>3", [[:3ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 3" } },
            { "<leader>4", [[:4ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 4" } },
            { "<leader>5", [[:5ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 5" } },
            { "<leader>6", [[:6ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 6" } },
            { "<leader>7", [[:7ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 7" } },
            { "<leader>8", [[:8ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 8" } },
            { "<leader>9", [[:9ToggleTerm<CR>]],  "n", { desc = "ToggleTerm idx 9" } },
            { "<leader>0", [[:10ToggleTerm<CR>]], "n", { desc = "ToggleTerm idx 10" } },
        },
        opts = { --[[ things you want to change go here]]
            size = function(term)
                if term.direction == "horizontal" then
                    return 15
                elseif term.direction == "vertical" then
                    return vim.o.columns * 0.4
                end
            end,

            open_mapping = [[<c-CR>]],

            --on_create = fun(t: Terminal), -- function to run when the terminal is first created
            --on_open = fun(t: Terminal), -- function to run when the terminal opens
            --on_close = fun(t: Terminal), -- function to run when the terminal closes
            --on_stdout = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stdout
            --on_stderr = fun(t: Terminal, job: number, data: string[], name: string) -- callback for processing output on stderr
            --on_exit = fun(t: Terminal, job: number, exit_code: number, name: string) -- function to run when terminal process exits

            --hide_numbers = true, -- hide the number column in toggleterm buffers
            --shade_filetypes = {},
            --autochdir = false, -- when neovim changes it current directory the terminal will change it's own when next it's opened
            -- highlights = {
            --   -- highlights which map to a highlight group name and a table of it's values
            --   -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
            --   Normal = {
            --     guibg = "<VALUE-HERE>",
            --   },
            --   NormalFloat = {
            --     link = 'Normal'
            --   },
            --   FloatBorder = {
            --     guifg = "<VALUE-HERE>",
            --     guibg = "<VALUE-HERE>",
            --   },
            -- },
            shade_terminals = true, -- NOTE: this option takes priority over highlights specified so if you specify Normal highlights you should set this to false
            shading_factor = -30, -- the percentage by which to lighten terminal background, default: -30 (gets multiplied by -3 if background is light)

            start_in_insert = true,
            --insert_mappings = true, -- whether or not the open mapping applies in insert mode
            --terminal_mappings = true, -- whether or not the open mapping applies in the opened terminals

            --persist_size = true,
            --persist_mode = true, -- if set to true (default) the previous terminal mode will be remembered
            --direction = "horizontal", -- 'vertical' | 'horizontal' | 'tab' | 'float',

            --close_on_exit = true, -- close the terminal window when the process exits

            -- Change the default shell. Can be a string or a function returning a string
            --shell = vim.o.shell,
            --auto_scroll = true, -- automatically scroll to the bottom on terminal output

            -- This field is only relevant if direction is set to 'float'
            float_opts = {
                -- The border key is *almost* the same as 'nvim_open_win'
                -- see :h nvim_open_win for details on borders however
                -- the 'curved' border is a custom border type
                -- not natively supported but implemented in this plugin.
                border = "single", -- 'single' | 'double' | 'shadow' | 'curved' | ... other options supported by win open

                -- like `size`, width and height can be a number or function which is passed the current terminal
                -- width = <value>,
                -- height = <value>,
                -- winblend = 3,
                -- zindex = <value>,
            },
            winbar = {
                enabled = false,
                name_formatter = function(term) --  term: Terminal
                    return term.name
                end,
            },
        },
        config = function(_, opts)
            require("toggleterm").setup(opts)

            -- if you only want these mappings for toggle term use term://*toggleterm#* instead
            vim.api.nvim_create_autocmd({ "TermOpen" }, {
                callback = function(args)
                    if vim.startswith(vim.api.nvim_buf_get_name(args.buf), "term://") then
                        local o = { buffer = 0 }
                        vim.keymap.set("t", "<esc><esc>", [[<C-\><C-n>]], o)
                        --vim.keymap.set("t", "jk", [[<C-\><C-n>]], o)
                        vim.keymap.set("t", "<C-h>", [[<Cmd>wincmd h<CR>]], o)
                        vim.keymap.set("t", "<C-j>", [[<Cmd>wincmd j<CR>]], o)
                        vim.keymap.set("t", "<C-k>", [[<Cmd>wincmd k<CR>]], o)
                        vim.keymap.set("t", "<C-l>", [[<Cmd>wincmd l<CR>]], o)
                        vim.keymap.set("t", "<C-w>", [[<C-\><C-n><C-w>]], o)
                    end
                end,
            })

            local function configFn(termOpts)
                configure_term(opts, termOpts)
            end

            configure_lazygit(configFn)
            configure_htop(configFn)
        end,
    },
}
