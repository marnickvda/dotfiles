return {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-telescope/telescope-ui-select.nvim" },
    config = function()
        local open_with_trouble = require("trouble.sources.telescope").open

        require("telescope").setup({
            defaults = {
                file_ignore_patterns = {
                    "node_modules",
                    ".next",
                    ".git",
                    "dist",
                    "build",
                    "vendor",
                    "%.lock",
                    "%-lock%.json",
                    "yarn%.lock",
                    "pnpm%-lock%.yaml",
                    "go%.sum",
                    "Cargo%.lock",
                    "composer%.lock",
                    "%.min.js",
                    "%.png",
                    "%.jpg",
                    "%.jpeg",
                },
                mappings = {
                    i = { ["<c-t>"] = open_with_trouble },
                    n = { ["<c-t>"] = open_with_trouble },
                },
            },
            pickers = {
                find_files = {
                    hidden = true,
                },
            },
        })

        local builtin = require("telescope.builtin")

        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find All Files" })
        vim.keymap.set("n", "<leader>fp", builtin.git_files, { desc = "Telescope: Find Git Project Files" })
        vim.keymap.set("n", "<leader>fq", builtin.quickfix, { desc = "Telescope: Quickfix list" })
        vim.keymap.set("n", "<leader>fl", builtin.loclist, { desc = "Telescope: Location list" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help Tags" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Find in Files" })

        vim.keymap.set("n", "<leader>ls", builtin.lsp_document_symbols, { desc = "Telescope: Document symbols" })
        vim.keymap.set("n", "<leader>lS", builtin.lsp_dynamic_workspace_symbols, { desc = "Telescope: Workspace symbols" })
        vim.keymap.set("n", "<leader>ld", function()
            builtin.diagnostics({ bufnr = 0 })
        end, { desc = "Telescope: Document diagnostics" })
        vim.keymap.set("n", "<leader>lD", builtin.diagnostics, { desc = "Telescope: Workspace diagnostics" })

        require("telescope").load_extension("noice")
        require("telescope").load_extension("ui-select")
    end,
}
