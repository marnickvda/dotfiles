return {
    "pwntester/octo.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "nvim-telescope/telescope.nvim",
        "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    keys = {
        { "<leader>pr", "<cmd>Octo pr list<cr>", desc = "Octo: list PRs" },
        { "<leader>isu", "<cmd>Octo issue list<cr>", desc = "Octo: list issues" },
    },
    opts = {},
}
