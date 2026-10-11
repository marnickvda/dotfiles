return {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
        require("mason-tool-installer").setup({
            ensure_installed = {
                -- Formatters
                "stylua",
                "shfmt",
                "prettier",
                "black",
                "isort",
                "sqlfmt",

                "gofumpt",
                "goimports",

                -- Linters
                "flake8",
                "golangci-lint",

                -- Go tooling
                "gomodifytags",
                "gotests",
                "impl",
                "iferr",
                "delve",

                -- Python tooling
                "debugpy",
            },
            auto_update = true,
            run_on_start = true,
        })
    end,
}
