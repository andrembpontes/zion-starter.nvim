return {

    { "mhinz/vim-startify" }, -- start screen

    -- TODO review { 'DanilaMihailov/beacon.nvim' } -- cursor jump

    {
        "petertriho/nvim-scrollbar",
        opts = function()
            return {
                handle = {
                    color = require("dracula").colors().visual,
                },
            }
        end,
    },

    {
        "nvim-lualine/lualine.nvim", -- statusline
        event = "VeryLazy",
        dependencies = {
            "nvim-tree/nvim-web-devicons",
        },
        opts = {
            options = {
                --theme = "dracula",
                --theme = "gruvbox",
                theme = "auto",
            },
        },
    },

    -- colorscheme
    {
        "Mofiqul/dracula.nvim",
        lazy = false,
        priority = 9999, -- Lazy recommeds high value for colorschemes
        setup = true,
    },

    {
        "folke/tokyonight.nvim",
        lazy = false,
        priority = 9999, -- Lazy recommeds high value for colorschemes
        setup = true,
    },

    {
        "ellisonleao/gruvbox.nvim",
        lazy = false,
        priority = 9999, -- Lazy recommeds high value for colorschemes
        opts = {
            undercurl = true,
            underline = true,
            bold = true,
            italic = {
                strings = true,
                comments = true,
                operators = false,
                folds = true,
            },
            strikethrough = true,
            invert_selection = false,
            invert_signs = false,
            invert_tabline = false,
            invert_intend_guides = false,
            inverse = true, -- invert background for search, diffs, statuslines and errors
            contrast = "",  -- can be "hard", "soft" or empty string
            palette_overrides = {},
            overrides = {},
            dim_inactive = false,
            transparent_mode = false,
        },
        init = function()
            vim.cmd.colorscheme("gruvbox")
        end,
    },

    -- delete buffers without affecting layout
    -- use :Bdelete and :Bwipewout
    -- instead of :bdelete and :bwipeout
    {
        "famiu/bufdelete.nvim",
        cmd = { "Bdelete", "Bwipeout" },
    },

    -- auto toggle relative line numbers
    -- normal: relative; else: absolute
    {
        "sitiom/nvim-numbertoggle",
        event = "VeryLazy",
    },

    -- autocomplete command mode
    {
        "gelguy/wilder.nvim",
        keys = {
            ":",
            "/",
            "?",
        },
        commit = "9929e1090dd84a60c1d1cc0220e0e35473c99b5e",
        enabled = true,
        config = function()
            local wilder = require("wilder")

            wilder.setup({
                modes = { ":", "/", "?" },
            })


            wilder.set_option('pipeline', {
                wilder.branch(
                    wilder.python_file_finder_pipeline({
                        -- to use ripgrep : {'rg', '--files'}
                        -- to use fd      : {'fd', '-tf'}
                        file_command = { 'find', '.', '-type', 'f', '-printf', '%P\n' },
                        -- to use fd      : {'fd', '-td'}
                        dir_command = { 'find', '.', '-type', 'd', '-printf', '%P\n' },
                        -- use {'cpsm_filter'} for performance, requires cpsm vim plugin
                        -- found at https://github.com/nixprime/cpsm
                        filters = { 'fuzzy_filter', 'difflib_sorter' },
                    }),
                    wilder.cmdline_pipeline({
                        -- sets the language to use, 'vim' and 'python' are supported
                        language = 'python',
                        -- 0 turns off fuzzy matching
                        -- 1 turns on fuzzy matching
                        -- 2 partial fuzzy matching (match does not have to begin with the same first letter)
                        fuzzy = 1,
                    }),
                    wilder.python_search_pipeline({
                        -- can be set to wilder#python_fuzzy_delimiter_pattern() for stricter fuzzy matching
                        pattern = wilder.python_fuzzy_pattern(),
                        -- omit to get results in the order they appear in the buffer
                        sorter = wilder.python_difflib_sorter(),
                        -- can be set to 're2' for performance, requires pyre2 to be installed
                        -- see :h wilder#python_search() for more details
                        engine = 're',
                    })
                ),
            })

            wilder.set_option('renderer', wilder.popupmenu_renderer({
                highlighter = wilder.basic_highlighter(),
                left = { ' ', wilder.popupmenu_devicons() },
                right = { ' ', wilder.popupmenu_scrollbar() },
            }))
            --
            -- -- 	wilder.set_option(
            -- 		"renderer",
            -- 		wilder.renderer_mux({
            -- 			[":"] = wilder.popupmenu_renderer({
            -- 				highlighter = wilder.basic_highlighter(),
            -- 				pumblend = 20,
            -- 			}),
            -- 			--["/"] = wilder.wildmenu_renderer({
            -- 			["/"] = wilder.popupmenu_renderer({
            -- 				highlighter = wilder.basic_highlighter(),
            -- 			}),
            -- 		})
            -- 	)
        end,
    },

    -- auto jump plugin
    {
        "ggandor/leap.nvim",
        enabled = true,
        config = function()
            local leap = require("leap")

            leap.setup({})
            leap.add_default_mappings()

            -- Searching in all windows (including the current one) on the tab page:
            function LeapAllWindows()
                require("leap").leap({
                    ["target-windows"] = vim.tbl_filter(function(win)
                        return vim.api.nvim_win_get_config(win).focusable
                    end, vim.api.nvim_tabpage_list_wins(0)),
                })
            end

            -- Bidirectional search in the current window is just a specific case of the
            -- multi-window mode - set `target-windows` to a table containing the current
            -- window as the only element:
            function LeapAllWindowBidirectional()
                require("leap").leap({ ["target-windows"] = { vim.api.nvim_get_current_win() } })
            end

            -- Map them to your preferred key, like:
            vim.keymap.set("n", "<leader>s", LeapAllWindows, { silent = true })
        end,
    },

    -- tmux replacement
    {
        event = "VeryLazy",
        "nikvdp/neomux",
        requires = {
            "mhinz/neovim-remote",
        },
    },
}
