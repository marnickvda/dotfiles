return {
    "christoomey/vim-tmux-navigator",
    cmd = {
        "TmuxNavigateLeft",
        "TmuxNavigateDown",
        "TmuxNavigateUp",
        "TmuxNavigateRight",
        "TmuxNavigatePrevious",
        "TmuxNavigatorProcessList",
    },
    keys = {
        { "<c-h>",  "<cmd><C-U>TmuxNavigateLeft<cr>", desc = "Move to left split / tmux pane" },
        { "<c-j>",  "<cmd><C-U>TmuxNavigateDown<cr>", desc = "Move to lower split / tmux pane" },
        { "<c-k>",  "<cmd><C-U>TmuxNavigateUp<cr>", desc = "Move to upper split / tmux pane" },
        { "<c-l>",  "<cmd><C-U>TmuxNavigateRight<cr>", desc = "Move to right split / tmux pane" },
        { "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", desc = "Move to previous split / tmux pane" },
    },
}
