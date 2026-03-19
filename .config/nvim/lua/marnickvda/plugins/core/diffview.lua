return {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
    keys = {
        { "<leader>gv", "<cmd>DiffviewOpen<cr>", desc = "Git: diff view" },
        { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "Git: file history" },
        { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "Git: branch history" },
    },
}
