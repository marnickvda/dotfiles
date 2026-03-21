# huh.nvim

Fuzzy search your Neovim plugins, keymaps, and commands. Press `<leader>huh` when you forget what you installed or how
to use it.

## What it does

- Lists all installed plugins (via lazy.nvim), keymaps, and commands in a single Telescope picker
- Preview pane with box-drawn cards showing keymap details, plugin attribution, and help docs
- Context-aware: boosts relevant entries based on filetype and git status
- Press `<CR>` on a keymap to execute it, on a command to run it, or browse and close with `<Esc>`

## Setup

```lua
{
  "marnickvda/huh.nvim",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>huh", function() require("huh").pick() end, desc = "huh: fuzzy search plugins, keymaps & commands" },
  },
  config = function()
    require("huh").setup()
  end,
}
```

## Context-aware sorting

Keymaps are automatically tagged based on their description (e.g., git, lsp, diagnostics). Tags matching the current
filetype or context (like being in a git repo) get boosted to the top of the results.
