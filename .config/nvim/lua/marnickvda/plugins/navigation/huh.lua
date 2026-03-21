return {
    "marnickvda/huh.nvim",
    dependencies = { "nvim-telescope/telescope.nvim" },
    keys = {
        {
            "<leader>huh",
            function()
                require("huh").pick()
            end,
            desc = "huh: fuzzy search plugins, keymaps & commands",
        },
    },
    config = function()
        require("huh").setup()
    end,
}
