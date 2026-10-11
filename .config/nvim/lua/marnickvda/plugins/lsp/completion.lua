return {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
        "L3MON4D3/LuaSnip",
        "rafamadriz/friendly-snippets",
        "saadparwaiz1/cmp_luasnip",
        "neovim/nvim-lspconfig",
        "hrsh7th/cmp-buffer",
        "hrsh7th/cmp-path",
        "hrsh7th/cmp-cmdline",
        "hrsh7th/cmp-nvim-lua",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        require("luasnip.loaders.from_vscode").lazy_load()

        local cmp = require("cmp")
        cmp.setup({
            sources = {
                { name = "nvim_lsp" },
                { name = "luasnip" },
            },
            window = {
                documentation = cmp.config.window.bordered(),
            },
            mapping = cmp.mapping.preset.insert({
                ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = "select" }),
                ["<C-n>"] = cmp.mapping.select_next_item({ behavior = "select" }),
                ["<CR>"] = cmp.mapping.confirm({ select = false }),
                ["<C-Space>"] = cmp.mapping.complete(),
                ["<C-u>"] = cmp.mapping.scroll_docs(-4),
                ["<C-d>"] = cmp.mapping.scroll_docs(4),
                ["<C-k>"] = cmp.mapping(function()
                    vim.lsp.buf.signature_help()
                end, { "i", "c" }),
            }),
            snippet = {
                expand = function(args)
                    require("luasnip").lsp_expand(args.body)
                end,
            },
        })

        cmp.setup.filetype("lua", {
            sources = cmp.config.sources({
                { name = "nvim_lua" },
                { name = "nvim_lsp" },
            }, {
                { name = "buffer" },
            }),
        })

        require("marnickvda.go.struct_tags").register()
        cmp.setup.filetype("go", {
            sources = {
                { name = "go_struct_tags" },
                { name = "nvim_lsp" },
                { name = "luasnip" },
            },
        })

        cmp.setup.cmdline("/", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = { { name = "buffer" } },
        })

        cmp.setup.cmdline(":", {
            mapping = cmp.mapping.preset.cmdline(),
            sources = cmp.config.sources({
                { name = "path" },
            }, {
                {
                    name = "cmdline",
                    option = { ignore_cmds = { "Man", "!" } },
                },
            }),
        })
    end,
}
