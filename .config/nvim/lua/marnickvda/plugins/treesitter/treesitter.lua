return {
    {
        "nvim-treesitter/nvim-treesitter",
        event = { "BufReadPre", "BufNewFile" },
        build = ":TSUpdate",
        dependencies = {
            "nvim-treesitter/nvim-treesitter-textobjects",
        },
        config = function()
            require("nvim-treesitter.configs").setup({
                ensure_installed = {
                    "bash",
                    "vimdoc",
                    "c",
                    "lua",
                    "rust",
                    "go",
                    "gomod",
                    "gowork",
                    "gosum",
                    "gotmpl",
                    "javascript",
                    "jsdoc",
                    "typescript",
                    "tsx",
                    "html",
                    "css",
                    "json",
                    "yaml",
                    "gitignore",
                    "dockerfile",
                    "vim",
                    "markdown",
                    "rust",
                    "ron",
                    "terraform",
                },
                sync_install = false,
                auto_install = true,
                indent = { enable = true },
                highlight = {
                    enable = true,
                    disable = function(lang, buf)
                        if lang == "html" then
                            return true
                        end

                        local max_filesize = 500 * 1024
                        local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
                        if ok and stats and stats.size > max_filesize then
                            vim.notify(
                                "File >500KB: Treesitter disabled",
                                vim.log.levels.WARN,
                                { title = "Treesitter" }
                            )
                            return true
                        end
                    end,
                    additional_vim_regex_highlighting = { "markdown" },
                },
                incremental_selection = {
                    enable = true,
                    keymaps = {
                        init_selection = "<C-space>",
                        node_incremental = "<C-space>",
                        scope_incremental = false,
                        node_decremental = "<bs>",
                    },
                },
                textobjects = {
                    select = {
                        enable = true,
                        lookahead = true,
                        keymaps = {
                            ["a="] = { query = "@assignment.outer", desc = "Select outer assignment" },
                            ["i="] = { query = "@assignment.inner", desc = "Select inner assignment" },
                            ["l="] = { query = "@assignment.lhs", desc = "Select assignment LHS" },
                            ["r="] = { query = "@assignment.rhs", desc = "Select assignment RHS" },

                            ["aa"] = { query = "@parameter.outer", desc = "Select outer parameter" },
                            ["ia"] = { query = "@parameter.inner", desc = "Select inner parameter" },

                            ["ai"] = { query = "@conditional.outer", desc = "Select outer conditional" },
                            ["ii"] = { query = "@conditional.inner", desc = "Select inner conditional" },

                            ["al"] = { query = "@loop.outer", desc = "Select outer loop" },
                            ["il"] = { query = "@loop.inner", desc = "Select inner loop" },

                            ["af"] = { query = "@call.outer", desc = "Select outer call" },
                            ["if"] = { query = "@call.inner", desc = "Select inner call" },

                            ["am"] = { query = "@function.outer", desc = "Select outer function" },
                            ["im"] = { query = "@function.inner", desc = "Select inner function" },

                            ["ac"] = { query = "@class.outer", desc = "Select outer class" },
                            ["ic"] = { query = "@class.inner", desc = "Select inner class" },
                        },
                    },
                    move = {
                        enable = true,
                        set_jumps = true,
                        goto_next_start = {
                            ["]m"] = "@function.outer",
                            ["]]"] = "@class.outer",
                        },
                        goto_next_end = {
                            ["]M"] = "@function.outer",
                            ["]["] = "@class.outer",
                        },
                        goto_previous_start = {
                            ["[m"] = "@function.outer",
                            ["[["] = "@class.outer",
                        },
                        goto_previous_end = {
                            ["[M"] = "@function.outer",
                            ["[]"] = "@class.outer",
                        },
                    },
                    swap = {
                        enable = true,
                        swap_next = {
                            ["<leader>pa"] = "@parameter.inner",
                        },
                        swap_previous = {
                            ["<leader>pA"] = "@parameter.inner",
                        },
                    },
                },
            })
        end,
    },
}
