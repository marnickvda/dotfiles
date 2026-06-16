return {
    "nvim-treesitter/nvim-treesitter-textobjects",
    branch = "main",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = { "BufReadPre", "BufNewFile" },
    config = function()
        require("nvim-treesitter-textobjects").setup({
            select = {
                lookahead = true,
                include_surrounding_whitespace = false,
            },
            move = {
                set_jumps = true,
            },
        })

        local select = require("nvim-treesitter-textobjects.select")
        local move = require("nvim-treesitter-textobjects.move")
        local swap = require("nvim-treesitter-textobjects.swap")

        local function map_select(lhs, query, desc)
            vim.keymap.set({ "x", "o" }, lhs, function()
                select.select_textobject(query, "textobjects")
            end, { desc = desc })
        end

        map_select("a=", "@assignment.outer", "Select outer assignment")
        map_select("i=", "@assignment.inner", "Select inner assignment")
        map_select("l=", "@assignment.lhs", "Select assignment LHS")
        map_select("r=", "@assignment.rhs", "Select assignment RHS")

        map_select("aa", "@parameter.outer", "Select outer parameter")
        map_select("ia", "@parameter.inner", "Select inner parameter")

        map_select("ai", "@conditional.outer", "Select outer conditional")
        map_select("ii", "@conditional.inner", "Select inner conditional")

        map_select("al", "@loop.outer", "Select outer loop")
        map_select("il", "@loop.inner", "Select inner loop")

        map_select("af", "@call.outer", "Select outer call")
        map_select("if", "@call.inner", "Select inner call")

        map_select("am", "@function.outer", "Select outer function")
        map_select("im", "@function.inner", "Select inner function")

        map_select("ac", "@class.outer", "Select outer class")
        map_select("ic", "@class.inner", "Select inner class")

        local function map_move(lhs, fn, query, desc)
            vim.keymap.set({ "n", "x", "o" }, lhs, function()
                move[fn](query, "textobjects")
            end, { desc = desc })
        end

        map_move("]m", "goto_next_start", "@function.outer", "Next function start")
        map_move("]]", "goto_next_start", "@class.outer", "Next class start")
        map_move("]M", "goto_next_end", "@function.outer", "Next function end")
        map_move("][", "goto_next_end", "@class.outer", "Next class end")
        map_move("[m", "goto_previous_start", "@function.outer", "Previous function start")
        map_move("[[", "goto_previous_start", "@class.outer", "Previous class start")
        map_move("[M", "goto_previous_end", "@function.outer", "Previous function end")
        map_move("[]", "goto_previous_end", "@class.outer", "Previous class end")

        vim.keymap.set("n", "<leader>pa", function()
            swap.swap_next("@parameter.inner")
        end, { desc = "Swap parameter with next" })
        vim.keymap.set("n", "<leader>pA", function()
            swap.swap_previous("@parameter.inner")
        end, { desc = "Swap parameter with previous" })
    end,
}
