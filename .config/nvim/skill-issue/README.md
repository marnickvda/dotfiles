# skill-issue

Fuzzy search your Neovim plugins and keybindings. Press `<leader>huh` when you forget what you installed or how to use
it.

## What it does

- Lists all installed plugins (via lazy.nvim) and all active keybindings in a single Telescope picker
- Shows tips and tags for each plugin in the preview pane
- Context-aware: boosts relevant entries based on filetype and git status
- Press `<CR>` on a keymap to execute it, or browse and close with `<Esc>`

## Setup

Local plugin, loaded via lazy.nvim `dir`:

```lua
{
  "skill-issue",
  dir = vim.fn.stdpath("config") .. "/skill-issue",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>huh", function() require("skill-issue").pick() end, desc = "Skill Issue: fuzzy search plugins & keymaps" },
  },
  config = function()
    require("skill-issue").setup()
  end,
}
```

## Customizing tags

Edit `lua/skill-issue/tags.lua` to add tips and tags for your plugins. Tags matching the current filetype get boosted to
the top.
