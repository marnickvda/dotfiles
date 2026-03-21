return {
  -- Navigation
  ["telescope.nvim"] = {
    tags = { "navigation", "search" },
    tip = "Fuzzy find files, grep, buffers, and more. Your primary search tool.",
  },
  ["harpoon"] = {
    tags = { "navigation" },
    tip = "Bookmark up to 5 files for instant switching. Use for files you revisit constantly.",
  },
  ["nvim-tree.lua"] = {
    tags = { "navigation" },
    tip = "File tree explorer. Good for browsing unfamiliar project structures.",
  },
  ["flash.nvim"] = {
    tags = { "navigation", "editing" },
    tip = "Label-jump to any visible location. Faster than search for short hops.",
  },
  ["vim-tmux-navigator"] = {
    tags = { "navigation", "tmux" },
    tip = "Seamless pane navigation between tmux and Neovim splits with C-h/j/k/l.",
  },

  -- Git
  ["lazygit.nvim"] = {
    tags = { "git" },
    tip = "Full Git UI inside Neovim. Stage, commit, rebase, resolve conflicts.",
  },
  ["diffview.nvim"] = {
    tags = { "git" },
    tip = "Side-by-side diff viewer. Great for reviewing changes and file history.",
  },
  ["gitsigns.nvim"] = {
    tags = { "git" },
    tip = "Shows changed lines in the sign column. Inline git blame with <leader>gb.",
  },
  ["octo.nvim"] = {
    tags = { "git", "github" },
    tip = "Review GitHub PRs and issues without leaving Neovim.",
  },

  -- LSP & Diagnostics
  ["nvim-lspconfig"] = {
    tags = { "lsp" },
    tip = "LSP server configs. Provides go-to-definition, references, hover, and more.",
  },
  ["trouble.nvim"] = {
    tags = { "lsp", "diagnostics" },
    tip = "Pretty list for diagnostics, references, and quickfix. Better than the default lists.",
  },
  ["mason.nvim"] = {
    tags = { "lsp", "tooling" },
    tip = "Install and manage LSP servers, formatters, and linters from within Neovim.",
  },
  ["fidget.nvim"] = {
    tags = { "lsp" },
    tip = "Shows LSP progress in the corner. Know when your language server is working.",
  },
  ["nvim-cmp"] = {
    tags = { "lsp", "editing" },
    tip = "Autocompletion engine. Combines LSP, snippets, and buffer sources.",
  },

  -- Editing
  ["grug-far.nvim"] = {
    tags = { "editing", "refactoring" },
    tip = "Project-wide search and replace with preview. Supports regex.",
  },
  ["nvim-autopairs"] = {
    tags = { "editing" },
    tip = "Auto-closes brackets, quotes, and other pairs as you type.",
  },
  ["nvim-ts-autotag"] = {
    tags = { "editing", "html", "jsx", "typescript" },
    tip = "Auto-closes and auto-renames HTML/JSX tags.",
  },
  ["mini.surround"] = {
    tags = { "editing" },
    tip = "Add/delete/change surrounding characters. gsa to add, gsd to delete, gsr to replace.",
  },
  ["undotree"] = {
    tags = { "editing" },
    tip = "Visualize and navigate your entire undo history as a tree.",
  },
  ["conform.nvim"] = {
    tags = { "editing", "formatting" },
    tip = "Auto-format code on save or with <leader>mf. Supports multiple formatters per filetype.",
  },

  -- Language-specific
  ["gopher.nvim"] = {
    tags = { "go" },
    tip = "Go tooling: generate struct tags, test boilerplate, interface implementations.",
  },
  ["rust-tools.nvim"] = {
    tags = { "rust" },
    tip = "Rust-specific LSP enhancements: inlay hints, runnables, and expanded code actions.",
  },

  -- Treesitter
  ["nvim-treesitter"] = {
    tags = { "treesitter", "editing" },
    tip = "Syntax highlighting and text objects powered by tree-sitter parsing.",
  },
  ["nvim-treesitter-context"] = {
    tags = { "treesitter", "navigation" },
    tip = "Shows the function/class you're inside at the top of the screen.",
  },

  -- UI
  ["catppuccin"] = {
    tags = { "ui" },
    tip = "Your colorscheme (macchiato flavor). Integrates with most plugins automatically.",
  },
  ["alpha-nvim"] = {
    tags = { "ui" },
    tip = "Dashboard shown on startup. Quick access to recent files and common actions.",
  },
  ["lualine.nvim"] = {
    tags = { "ui" },
    tip = "Status line showing mode, file, git branch, diagnostics, and cursor position.",
  },
  ["noice.nvim"] = {
    tags = { "ui" },
    tip = "Replaces the command line and notification UI. Search, messages, and popups.",
  },
  ["indent-blankline.nvim"] = {
    tags = { "ui" },
    tip = "Shows indent guides. Helps track nesting levels in deeply indented code.",
  },
  ["neoscroll.nvim"] = {
    tags = { "ui", "navigation" },
    tip = "Smooth scrolling animations for C-d, C-u, and other scroll commands.",
  },
  ["todo-comments.nvim"] = {
    tags = { "ui", "navigation" },
    tip = "Highlights TODO/FIXME/HACK comments. Jump between them with ]t and [t.",
  },

  -- Session
  ["persistence.nvim"] = {
    tags = { "session" },
    tip = "Auto-saves sessions per directory. Restore with <leader>qs when reopening a project.",
  },

  -- Search
  ["which-key.nvim"] = {
    tags = { "navigation", "help" },
    tip = "Shows available keymaps after pressing a prefix. <leader>? for buffer keymaps.",
  },
}
