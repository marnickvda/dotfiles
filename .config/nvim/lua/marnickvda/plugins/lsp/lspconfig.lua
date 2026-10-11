return {
    "neovim/nvim-lspconfig",
    dependencies = {
        "mason-org/mason.nvim",
        "mason-org/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
        vim.lsp.config("*", {
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
        })

        -- A shared gopls daemon keeps its caches warm across nvim sessions and modules.
        vim.lsp.config("gopls", {
            cmd = { "gopls", "-remote=auto", "-remote.listen.timeout=30m" },
            settings = {
                gopls = {
                    analyses = {
                        unusedparams = true,
                        unusedwrite = true,
                        useany = true,
                        nilness = true,
                        shadow = true,
                        unusedvariable = true,
                        ST1000 = true,
                        ST1003 = true,
                    },
                    hints = {
                        assignVariableTypes = true,
                        compositeLiteralFields = true,
                        compositeLiteralTypes = true,
                        constantValues = true,
                        functionTypeParameters = true,
                        parameterNames = true,
                        rangeVariableTypes = true,
                    },
                    codelenses = {
                        generate = true,
                        test = true,
                        tidy = true,
                        upgrade_dependency = true,
                        vulncheck = true,
                    },
                    completeUnimported = true,
                    usePlaceholders = true,
                    matcher = "Fuzzy",
                    gofumpt = true,
                    staticcheck = true,
                    semanticTokens = true,
                    vulncheck = "Imports",
                },
            },
        })

        vim.lsp.config("pyright", {
            before_init = function(_, config)
                local python = require("marnickvda.python")
                local root = config.root_dir
                if not root then
                    return
                end
                config.settings.python = vim.tbl_deep_extend("force", config.settings.python or {}, {
                    pythonPath = python.venv_python(root),
                    analysis = { extraPaths = python.pytest_paths(root) },
                })
            end,
        })

        vim.lsp.config("lua_ls", {
            settings = {
                Lua = {
                    diagnostics = {
                        globals = { "vim", "it", "describe", "before_each", "after_each" },
                    },
                    telemetry = { enable = false },
                },
            },
        })

        vim.lsp.config("tailwindcss", {
            filetypes = { "html", "css", "scss", "javascriptreact", "typescriptreact" },
            root_markers = { "tailwind.config.js", "tailwind.config.ts", "package.json", ".git" },
        })

        require("mason-lspconfig").setup({
            ensure_installed = {
                "lua_ls",
                "rust_analyzer",
                "gopls",
                "pyright",
                "ts_ls",
                "eslint",
                "tailwindcss",
                "marksman",
                "taplo",
                "ols",
            },
        })

        vim.api.nvim_create_autocmd("LspAttach", {
            desc = "LSP Keymaps",
            callback = require("marnickvda.core.lsp-keymaps").setup_keymaps,
        })
    end,
}
