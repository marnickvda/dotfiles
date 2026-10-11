return {
    "nvim-neotest/neotest",
    dependencies = {
        "nvim-neotest/nvim-nio",
        "nvim-lua/plenary.nvim",
        "nvim-treesitter/nvim-treesitter",
        "fredrikaverpil/neotest-golang",
        "nvim-neotest/neotest-python",
    },
    keys = {
        { "<leader>tt", function() require("neotest").run.run() end, desc = "Test: nearest" },
        { "<leader>tf", function() require("neotest").run.run(vim.fn.expand("%")) end, desc = "Test: file" },
        { "<leader>ta", function() require("neotest").run.run(vim.uv.cwd()) end, desc = "Test: all" },
        { "<leader>tl", function() require("neotest").run.run_last() end, desc = "Test: last" },
        { "<leader>td", function() require("neotest").run.run({ strategy = "dap" }) end, desc = "Test: debug nearest" },
        { "<leader>ts", function() require("neotest").summary.toggle() end, desc = "Test: summary" },
        { "<leader>to", function() require("neotest").output.open({ enter = true }) end, desc = "Test: output" },
        { "<leader>tO", function() require("neotest").output_panel.toggle() end, desc = "Test: output panel" },
    },
    config = function()
        local python = require("neotest-python")({
            runner = "pytest",
            dap = { justMyCode = false },
            python = function(root)
                return require("marnickvda.python").venv_python(root) or "python3"
            end,
        })
        python.filter_dir = function(name)
            return not vim.tbl_contains({ "venv", ".venv", "ve", "env", "__pycache__", "node_modules" }, name)
        end

        require("neotest").setup({
            adapters = {
                require("neotest-golang")({ runner = "go" }),
                python,
            },
        })
    end,
}
