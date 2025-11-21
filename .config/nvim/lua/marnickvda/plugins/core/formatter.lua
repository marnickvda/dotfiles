return {
    "stevearc/conform.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        local conform = require("conform")

        conform.setup({
            formatters = {
                flake8 = {
                    command = "flake8",
                    args = { "--format=%(row)d,%(col)d,%(code).1s,%(code)s: %(text)s", "-" },
                    stdin = true,
                    parse = function(output)
                        local diagnostics = {}
                        for line in vim.gsplit(output, "\n") do
                            local row, col, severity, code, message = line:match("^(%d+),(%d+),(%a),([^:]+): (.+)$")
                            if row then
                                table.insert(diagnostics, {
                                    lnum = tonumber(row) - 1,
                                    col = tonumber(col) - 1,
                                    severity = severity == "E" and 1 or 2, -- 1 = Error, 2 = Warning
                                    source = "flake8",
                                    code = code,
                                    message = message,
                                })
                            end
                        end
                        return diagnostics
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
                go = { "gofmt" },
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
