return {
    "folke/todo-comments.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {},
    keys = {
        { "]t", function() require("todo-comments").jump_next() end, desc = "Next TODO comment" },
        { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous TODO comment" },
        { "<leader>ft", "<cmd>TodoTelescope<cr>", desc = "Telescope: Find TODOs" },
        { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "TODOs (Trouble)" },
    },
}
