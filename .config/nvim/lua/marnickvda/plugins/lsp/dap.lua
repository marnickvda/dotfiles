return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "leoluz/nvim-dap-go",
        "mfussenegger/nvim-dap-python",
        "rcarriga/nvim-dap-ui",
        "nvim-neotest/nvim-nio",
    },
    keys = {
        { "<leader>db", function() require("dap").toggle_breakpoint() end, desc = "Debug: toggle breakpoint" },
        { "<leader>dB", function() require("dap").set_breakpoint(vim.fn.input("Condition: ")) end, desc = "Debug: conditional breakpoint" },
        { "<leader>dc", function() require("dap").continue() end, desc = "Debug: start / continue" },
        { "<leader>dn", function() require("dap").step_over() end, desc = "Debug: step over" },
        { "<leader>di", function() require("dap").step_into() end, desc = "Debug: step into" },
        { "<leader>do", function() require("dap").step_out() end, desc = "Debug: step out" },
        { "<leader>dr", function() require("dap").repl.toggle() end, desc = "Debug: REPL" },
        { "<leader>dq", function() require("dap").terminate() end, desc = "Debug: stop" },
        { "<leader>du", function() require("dapui").toggle() end, desc = "Debug: toggle UI" },
    },
    config = function()
        local dap, dapui = require("dap"), require("dapui")
        require("dap-go").setup()
        require("dap-python").setup(vim.fn.stdpath("data") .. "/mason/packages/debugpy/venv/bin/python")
        require("dap-python").test_runner = "pytest"
        require("dap-python").resolve_python = function()
            local python = require("marnickvda.python")
            return python.venv_python(python.root() or vim.fn.getcwd())
        end
        dapui.setup()

        dap.listeners.on_config.go_module_root = function(config)
            if config.type ~= "go" then
                return config
            end
            config = vim.deepcopy(config)
            if type(config.program) == "string" and config.program:sub(1, 2) == "./" then
                config.program = vim.fn.getcwd() .. config.program:sub(2)
            end
            config.dlvCwd = config.dlvCwd or vim.fs.root(0, { "go.work", "go.mod" })
            return config
        end

        dap.listeners.after.event_initialized.dapui = function()
            dapui.open()
        end
        dap.listeners.before.event_terminated.dapui = function()
            dapui.close()
        end
        dap.listeners.before.event_exited.dapui = function()
            dapui.close()
        end
    end,
}
