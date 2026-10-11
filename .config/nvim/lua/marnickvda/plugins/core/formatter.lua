return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters = {
                isort = {
                    condition = function(_, ctx)
                        local root = vim.fs.root(ctx.filename, { "pyproject.toml", "setup.cfg", ".isort.cfg", ".git" })
                        for _, name in ipairs({ ".isort.cfg", "pyproject.toml", "setup.cfg" }) do
                            local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(root or "", name))
                            if ok and table.concat(lines, "\n"):find("isort", 1, true) then
                                return true
                            end
                        end
                        return false
                    end,
                },
            },
            formatters_by_ft = {
                zsh = { "beautysh" },
                bash = { "shfmt" },
                sh = { "shfmt" },
                javascript = { "prettier" },
                typescript = { "prettier" },
                javascriptreact = { "prettier" },
                typescriptreact = { "prettier" },
                css = { "prettier" },
                html = { "prettier" },
                json = { "prettier" },
                yaml = { "prettier" },
                markdown = { "prettier" },
                graphql = { "prettier" },
                lua = { "stylua" },
                python = { "isort", "black" },
                go = { "goimports", "gofumpt" },
                sql = { "sqlfmt" },
            },
            -- format_on_save = {
            --     lsp_fallback = true,
            --     async = false,
            --     timeout_ms = 1000,
            -- },
        })

        vim.filetype.add({ extension = { avsc = "json" } })

        vim.keymap.set({ "n", "v" }, "<leader>mf", function()
            conform.format({
                lsp_fallback = true,
                async = false,
                timeout_ms = 1000,
            })
        end, { desc = "Format file or range (in visual mode)" })

        vim.api.nvim_create_autocmd("FileType", {
            pattern = "markdown",
            callback = function()
                vim.opt_local.colorcolumn = "120"
            end,
        })
    end,
}
