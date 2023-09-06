return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPost", "BufNewFile" },
        build = ":TSUpdate",
        dependencies = {
            { "JoosepAlviste/nvim-ts-context-commentstring" },
            { "nvim-treesitter/nvim-treesitter-context",    config = true },
            {
                "SmiteshP/nvim-gps",
                opts = {
                    icons = {
                        ["class-name"] = " ", -- Classes and class-like objects
                        ["function-name"] = " ", -- Functions
                        ["method-name"] = " ", -- Methods (functions inside class-like objects)
                        ["container-name"] = "⛶ ", -- Containers (example: lua tables)
                        ["tag-name"] = "炙", -- Tags (example: html tags)
                    },
                },
            },
        },
        opts = {
            ensure_installed = "all", -- one of "all", "maintained" (parsers with maintainers), or a list of languages
            ignore_install = {
                "phpdoc",
            },

            highlight = { enable = true },
            indent = { enable = true },
            context_commentstring = {
                enable = true,
                enable_autocmd = false,
            },
            matchup = {
                enable = true,
            },
        },
        config = function(_, opts)
            require("nvim-treesitter.configs").setup(opts)
        end,
    },
}
