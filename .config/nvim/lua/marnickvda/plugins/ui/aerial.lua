return {
    "stevearc/aerial.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter",
        "nvim-tree/nvim-web-devicons",
    },
    opts = {
        layout = {
            default_direction = "right",
            min_width = 30,
        },
        attach_mode = "global",
        filter_kind = false,
    },
    keys = {
        { "<leader>o", "<cmd>AerialToggle<cr>", desc = "Toggle symbol outline" },
        { "{", "<cmd>AerialPrev<cr>", desc = "Previous symbol" },
        { "}", "<cmd>AerialNext<cr>", desc = "Next symbol" },
    },
}
