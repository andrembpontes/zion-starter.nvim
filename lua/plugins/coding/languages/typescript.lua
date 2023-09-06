return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ["tsserver"] = {
                    filetypes = {
                        "typescript",
                        "typescriptreact",
                        "typescript.tsx",
                        "javascript",
                        "javascriptreact",
                    },

                    cmd = { "typescript-language-server", "--stdio" },

                    on_attach = function(_client, bfnr)
                    end,
                },
                ["eslint"] = {
                    on_attach = function(_client, bufnr)
                        vim.api.nvim_create_autocmd("BufWritePre", {
                            buffer = bufnr,
                            command = "EslintFixAll",
                        })
                    end,
                },
            },
        },
    },
}
