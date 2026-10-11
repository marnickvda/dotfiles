return {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = function()
        local spec = require("marnickvda.cheatsheet").which_key_groups()
        vim.list_extend(spec, {
            { "<localleader>", group = "Language actions" },
            { "<localleader>e", group = "Insert error check" },
        })
        return { spec = spec }
    end,
    keys = {
        {
            "<leader>?",
            function()
                require("marnickvda.cheatsheet").open()
            end,
            desc = "Keymap cheatsheet",
        },
    },
}
