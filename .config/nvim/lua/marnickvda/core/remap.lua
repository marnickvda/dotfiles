vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- 🏗 File Explorer
vim.keymap.set("n", "<leader>e", function()
    require("nvim-tree.api").tree.toggle()
end, { desc = "Open my file tree explorer", noremap = true, silent = true })

vim.keymap.set("n", "<leader>fo", function()
    local path = vim.fn.expand("%:p:h")
    vim.fn.jobstart("open " .. path, { detach = true })
end, { desc = "Open file directory in Finder" })

-- 📑 Navigation Enhancements
vim.keymap.set("i", "<C-l>", "<C-o>l", { desc = "Move cursor right in insert mode" })
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join lines but keep cursor in place" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Move down half-page and center" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Move up half-page and center" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Keep search results centered" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Keep previous search results centered" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next location list item" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Previous location list item" })

-- Noice keymaps
vim.keymap.set("n", "<leader>nd", "<cmd>NoiceDismiss<CR>", { desc = "Dismiss Notification Message" })

-- 🔄 Moving lines up/down in Visual Mode
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selected lines down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selected lines up" })

-- 🖇️ Clipboard, Selection & Pasting Improvements
vim.keymap.set({ "n", "i" }, "<C-s>", "<cmd>w<cr>", { desc = "Write current buffer" })
vim.keymap.set({ "i", "n", "v" }, "<C-a>", "<ESC>ggvG", { desc = "Select all" })
vim.keymap.set("n", "<C-v>", '"+p', { desc = "Paste from system clipboard" })
vim.keymap.set("i", "<C-v>", '<Esc>"+pa', { desc = "Paste from system clipboard" })
vim.keymap.set({ "v" }, "<C-c>", '"+y', { desc = "Yank to system clipboard" })
vim.keymap.set({ "v" }, "<C-x>", '"+d', { desc = "Delete to system clipboard" })

-- 🛑 Fix Annoying Defaults
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Use <C-c> as <Esc>" })
vim.keymap.set("n", "Q", "<nop>", { desc = "Disable Ex mode" })

-- 🎯 LSP Actions
vim.keymap.set("n", "<leader>lr", "<cmd>lsp restart<cr>", { desc = "Restart LSP" })

-- 🔍 Quick Search & Replace
vim.keymap.set(
    "n",
    "<leader>s",
    [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
    { desc = "Replace word under cursor" }
)

-- 🛠 Make Current File Executable
vim.keymap.set("n", "<leader>fx", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })

-- 🔄 Source Neovim Config
vim.keymap.set("n", "<leader><leader>", function()
    vim.cmd("so")
end, { desc = "Reload Neovim config" })
