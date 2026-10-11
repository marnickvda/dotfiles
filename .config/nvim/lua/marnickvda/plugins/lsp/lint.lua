return {
    "mfussenegger/nvim-lint",
    event = { "BufReadPost", "BufWritePost" },
    config = function()
        local lint = require("lint")
        lint.linters_by_ft = {
            go = { "golangcilint" },
            python = { "flake8" },
        }

        local project_root = {
            go = function()
                return vim.fs.root(0, { "go.work", "go.mod" })
            end,
            python = function()
                return require("marnickvda.python").root()
            end,
        }

        vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost" }, {
            group = vim.api.nvim_create_augroup("Lint", { clear = true }),
            callback = function()
                local root = project_root[vim.bo.filetype]
                lint.try_lint(nil, { cwd = root and root() })
            end,
        })
    end,
}
