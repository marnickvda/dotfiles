# skill-issue: Fuzzy Search for Plugins & Keybindings

## Overview

A local Neovim plugin that provides a unified Telescope picker for fuzzy searching all installed plugins and
keybindings. Invoked with `<leader>huh`. Read-only reference tool — selecting an entry shows info but does not execute
anything.

## Data Sources

### Keymaps

Two sources, merged with deduplication:

1. **Runtime keymaps:** `vim.api.nvim_get_keymap(mode)` (global) and `vim.api.nvim_buf_get_keymap(0, mode)`
   (buffer-local) for modes `n`, `i`, `x`, `o`, `s`. Note: we use `x` (visual) and `s` (select) instead of `v` to avoid
   duplicates, since `v` covers both visual+select.
2. **Lazy.nvim declared keys:** For each plugin, extract its `keys` spec via `require("lazy").plugins()`. This captures
   keybindings from plugins that haven't loaded yet. These entries are tagged with the source plugin name.

- Buffer-local keymaps override global when same `lhs` + `mode`
- Runtime keymaps override lazy-declared keys when same `lhs` + `mode` (runtime has richer info)
- Skip entries without a `desc` field (internal/unmapped keys)
- Skip `<Plug>` mappings (internal plugin plumbing)

**Fields extracted:** `lhs` (key combo), `mode`, `desc` (description), `source_file` (see below), `plugin` (source
plugin name if known)

**Source file resolution for keymaps:**

- For keymaps with a Lua callback: use `debug.getinfo(callback, "S").source` and `.linedefined`
- For keymaps with a string `rhs`: `source_file` will be `nil`
- The previewer handles `nil` gracefully by showing description only

### Plugins

- **Source:** `require("lazy").plugins()` — returns all plugins managed by lazy.nvim, including unloaded ones
- **Fields extracted:** plugin name (short name from repo URL), enabled/disabled status, lazy-loading triggers (`keys`,
  `cmd`, `event`), spec file path

### Unified Entry Format

Both sources are normalized into:

```lua
{
  type = "keymap" | "plugin",
  display = "[keymap] <C-d>  n  Scroll down half-page" | "[plugin] telescope.nvim  Fuzzy finder",
  key = "<C-d>" | nil,
  mode = "n" | nil,
  desc = "Scroll down half-page and center" | "Fuzzy finder",
  plugin = "telescope.nvim" | nil,
  source_file = "/path/to/file.lua" | nil,
  source_line = 42 | nil,
  tags = { "navigation" } | nil,
  tip = "Use when you need to scroll quickly" | nil,
}
```

## Telescope Picker

- **Single unified list** of all keymaps and plugins
- **Display format:**
  - Keymaps: `[keymap] <C-d>  n  Scroll down half-page and center`
  - Plugins: `[plugin] telescope.nvim  Fuzzy finder`
- **Highlighting:** Type prefix (`[keymap]`/`[plugin]`) uses distinct highlight groups
- **Fuzzy matching:** Searches across all fields — key combo, description, plugin name, mode
- **Preview:** Shows source file content (scrolled to line) when `source_file` is available; shows formatted description
  when it's not. When a `tip` is available, it is displayed at the top of the preview pane
- **Action on `<CR>`:** Uses `actions.close` to close the picker (read-only reference tool)

## Context Tags

A static metadata table that enriches plugins and keybindings with contextual tips and tags. Stored in
`skill-issue/lua/skill-issue/tags.lua`. Tags are matched against current context (filetype, git status) to boost
relevant entries to the top of the picker.

### Context Detection

- **Filetype:** `vim.bo.filetype` — matches tags like `"go"`, `"rust"`, `"typescript"`
- **Git repo:** `vim.fn.finddir(".git", ".;")` — boosts `"git"` tagged entries when in a git repo

### Sorting with Context

When context is detected, entries are sorted in three tiers:
1. **Context match** — entries with tags matching current filetype or context
2. **Plugins** — all plugin entries
3. **Remaining keymaps** — everything else

Within each tier, alphabetical sorting applies.

### Tags Table

The tags table maps plugin names and keymap `lhs` values to metadata:

```lua
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
```

### Keybinding Tags

Keybindings inherit tags from their parent plugin when known. For keybindings not associated with a plugin (core
remaps), tags are inferred from the description:
- Description contains "git" → tagged `"git"`
- Description contains "LSP" → tagged `"lsp"`
- Description contains "diagnostic" → tagged `"diagnostics"`
- Buffer-local keymaps in a Go file → tagged `"go"`, etc.

This is a best-effort heuristic. Untagged keybindings get no context boost but remain searchable.

## Module Structure

```
skill-issue/                      -- top-level dir in nvim config root
└── lua/
    └── skill-issue/
        ├── init.lua              -- public API: setup() and pick()
        ├── tags.lua              -- static context tags and tips for plugins/keymaps
        ├── collectors/
        │   ├── keymaps.lua       -- gathers all keymaps into unified entries
        │   └── plugins.lua       -- gathers lazy.nvim plugin data into unified entries
        └── picker.lua            -- builds and opens the Telescope picker
```

The plugin lives at the nvim config root as `skill-issue/` with a proper `lua/` subdirectory. This is the correct
structure for lazy.nvim's `dir` option and makes future extraction to a standalone repo trivial (just move the
directory).

## Integration

- **Plugin spec:** `lua/marnickvda/plugins/navigation/skill-issue.lua`
- **Loaded by lazy.nvim** with `dir = vim.fn.stdpath("config") .. "/skill-issue"`
- **Keybinding:** `<leader>huh` mapped to `require("skill-issue").pick()`
- **Dependencies:** `telescope.nvim` (already installed)
- **`setup()` options:** None currently. Accepts an empty options table for forward compatibility: `setup(opts)` where
  `opts` defaults to `{}`

## Keymaps Collector (`collectors/keymaps.lua`)

1. Iterate modes: `{ "n", "i", "x", "o", "s" }`
2. For each mode, call `vim.api.nvim_get_keymap(mode)` and `vim.api.nvim_buf_get_keymap(0, mode)`
3. Skip entries without a `desc` field
4. Skip `<Plug>` mappings
5. For Lua callbacks, extract source file/line via `debug.getinfo`
6. Merge with lazy.nvim declared `keys` (from plugins collector)
7. Deduplicate: buffer-local > global > lazy-declared (by `lhs` + `mode`)
8. Return list of unified entries

## Plugins Collector (`collectors/plugins.lua`)

1. Call `require("lazy").plugins()`
2. For each plugin, extract:
   - `name` — short name (e.g., `telescope.nvim`)
   - `desc` — from plugin spec or fall back to repo URL
   - `source_file` — the spec file path where the plugin is configured
   - `keys` — associated keybindings from the lazy spec (returned separately for keymap merging)
3. Create one `type = "plugin"` entry per plugin
4. Also return the `keys` data for the keymaps collector to merge
5. Return both lists

## Picker (`picker.lua`)

1. Collect entries from both collectors
2. Sort: plugins first, then keymaps, alphabetically within each group
3. Build Telescope picker with:
   - `finder`: static list from collected entries
   - `sorter`: `generic_sorter` for fuzzy matching on display text
   - `previewer`: file previewer showing `source_file` content when available; falls back to description text
   - `entry_maker`: formats display with type prefix, applies highlight groups
4. Map `<CR>` to `actions.close` (explicit close, no default select action)

## Non-Goals

- Executing keybindings from the picker
- Editing keybindings or plugin configs from the picker
- Syncing with cheatsheet.md
- Supporting non-lazy.nvim plugin managers
