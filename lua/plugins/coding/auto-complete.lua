return {
    {
        "hrsh7th/nvim-cmp",
        event = "VeryLazy",

        dependencies = {
            -- Auto Pairs (on fn completion)
            { "windwp/nvim-autopairs", config = true },

            -- Type Symbols (e.g. 󰊕, , 󰜢)
            "onsails/lspkind.nvim",

            -- Sources
            "hrsh7th/cmp-buffer",         -- source from buffer words
            "hrsh7th/cmp-nvim-lsp",       -- source from LSP
            "saadparwaiz1/cmp_luasnip",   -- LuaSnip
            "hrsh7th/cmp-nvim-lsp-signature-help", -- LSP Signature help
            "FelipeLema/cmp-async-path",  -- file path
        },

        opts = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            local lspkind = require("lspkind")

            return {
                snippet = {
                    -- REQUIRED - you must specify a snippet engine
                    expand = function(args)
                        -- vim.fn["vsnip#anonymous"](args.body) -- For `vsnip` users.
                        require("luasnip").lsp_expand(args.body) -- For `luasnip` users.
                        -- require('snippy').expand_snippet(args.body) -- For `snippy` users.
                        -- vim.fn["UltiSnips#Anon"](args.body) -- For `ultisnips` users.
                    end,
                },

                formatting = {
                    format = lspkind.cmp_format({
                        mode = "symbol_text",
                        menu = {
                            buffer = "[Buff]",
                            nvim_lsp = "[LSP]",
                            luasnip = "[LSnip]",
                            nvim_lua = "[Lua]",
                            latex_symbols = "[LaTeX]",
                        },
                    }),
                },

                view = {
                    entries = {
                        name = "custom",
                        selection_order = "near_cursor",
                    },
                },

                window = {
                    --completion = cmp.config.window.bordered(),
                    --documentation = cmp.config.window.bordered(),
                },

                mapping = cmp.mapping.preset.insert({
                    ["<D-k>"] = cmp.mapping.select_prev_item(),
                    ["<D-j>"] = cmp.mapping.select_next_item(),
                    ["<D-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<D-d>"] = cmp.mapping.scroll_docs(4),

                    ["<C-k>"] = cmp.mapping.select_prev_item(),
                    ["<C-j>"] = cmp.mapping.select_next_item(),
                    ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-d>"] = cmp.mapping.scroll_docs(4),

                    ["<C-Space>"] = cmp.mapping.complete(),

                    -- ["<CR>"] = cmp.mapping.confirm({
                    -- 	behavior = cmp.ConfirmBehavior.Replace,
                    -- 	select = true,
                    -- }),

                    ["<CR>"] = cmp.mapping({
                        i = function(fallback)
                            if cmp.visible() and cmp.get_active_entry() then
                                cmp.confirm({
                                    behavior = cmp.ConfirmBehavior.Replace,
                                    select = false,
                                })
                            else
                                fallback()
                            end
                        end,
                        s = cmp.mapping.confirm({ select = true }),
                        c = cmp.mapping.confirm({ behavior = cmp.ConfirmBehavior.Replace, select = true }),
                    }),

                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_next_item()
                        elseif luasnip.expand_or_jumpable() then
                            luasnip.expand_or_jump()
                        else
                            fallback()
                        end
                    end, { "i", "s" }),

                    ["<S-Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then
                            cmp.select_prev_item()
                        elseif luasnip.jumpable(-1) then
                            luasnip.jump(-1)
                        else
                            fallback()
                        end
                    end, { "i", "s" }),
                }),

                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    -- { name = "vsnip" }, -- For vsnip users.
                    { name = "luasnip" }, -- For luasnip users.
                    -- { name = 'ultisnips' }, -- For ultisnips users.
                    -- { name = 'snippy' }, -- For snippy users.

                    { name = "async_path" },
                    { name = "nvim_lsp_signature_help" },
                }, {
                    { name = "buffer" },
                }),
            }

            -- -- Set up lspconfig.
            -- local capabilities = require("cmp_nvim_lsp").default_capabilities()

            -- -- Replace <YOUR_LSP_SERVER> with each lsp server you've enabled.
            -- require("lspconfig")["<YOUR_LSP_SERVER>"].setup({
            -- 	capabilities = capabilities,
            -- })

            -- return {
            -- 	snippet = {
            -- 		expand = function(args)
            -- 			luasnip.lsp_expand(args.body)
            -- 		end,
            -- 	},
            -- 	mapping = cmp.mapping.preset.insert({
            -- 		["<D-k>"] = cmp.mapping.select_prev_item(),
            -- 		["<D-j>"] = cmp.mapping.select_next_item(),
            -- 		["<D-u>"] = cmp.mapping.scroll_docs(-4),
            -- 		["<D-d>"] = cmp.mapping.scroll_docs(4),
            -- 		["<C-Space>"] = cmp.mapping.complete(),
            -- 		["<CR>"] = cmp.mapping.confirm({
            -- 			behavior = cmp.ConfirmBehavior.Replace,
            -- 			select = true,
            -- 		}),
            -- 		["<Tab>"] = cmp.mapping(function(fallback)
            -- 			if cmp.visible() then
            -- 				cmp.select_next_item()
            -- 			elseif luasnip.expand_or_jumpable() then
            -- 				luasnip.expand_or_jump()
            -- 			else
            -- 				fallback()
            -- 			end
            -- 		end, { "i", "s" }),
            -- 		["<S-Tab>"] = cmp.mapping(function(fallback)
            -- 			if cmp.visible() then
            -- 				cmp.select_prev_item()
            -- 			elseif luasnip.jumpable(-1) then
            -- 				luasnip.jump(-1)
            -- 			else
            -- 				fallback()
            -- 			end
            -- 		end, { "i", "s" }),
            -- 	}),
            -- 	sources = {
            -- 		{ name = "nvim_lsp" },
            -- 		{ name = "luasnip" },
            -- 	},
            -- }
        end,

        config = function(_, opts)
            local cmp = require("cmp")
            cmp.setup(opts)

            -- If you want insert `(` after select function or method item
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

            -- If a file is too large, disable cmp
            vim.api.nvim_create_autocmd("BufReadPre", {
                callback = function(t)
                    local max_filesize = 512 * 1024 -- 512 KB
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(t.buf))
                    if ok and stats and stats.size > max_filesize then
                        cmp.setup.buffer({ enabled = false })
                    end
                end,
            })
        end,
    },
}
