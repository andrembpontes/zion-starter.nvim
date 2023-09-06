return {
    {
        "neovim/nvim-lspconfig",
        opts = {
            servers = {
                ["pyright"] = {},
                ["ruff_lsp"] = {
                    on_attach = function(client, bfnr)
                        -- Disable hover in favor of Pyright
                        client.server_capabilities.hoverProvider = false
                    end,
                },
            },
        },
    },
}
