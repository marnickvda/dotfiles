# Neovim Config

This Neovim configuration is built around **[Lazy.nvim](https://github.com/folke/lazy.nvim)** for modular, lazy-loaded
plugin management. It emphasizes readability, scalability, and maintainability.

---

## Folder Structure

```text
lua/marnickvda/
├── core/               # Core config (non-plugins)
│   ├── config.lua         # Central config values (e.g., ensure_installed)
│   ├── init.lua           # Loads settings, remaps, plugin manager
│   ├── plugin-manager.lua # Lazy.nvim setup
│   ├── settings.lua       # Vim options (tab size, mouse, etc.)
│   ├── keybinds.lua       # Global keymaps
│   ├── remap.lua          # Key remapping utilities
│   └── treesitter.lua     # Native treesitter parser management
├── plugins/            # Lazy.nvim plugin specs
│   ├── core/              # Foundational tools
│   │   ├── formatter.lua
│   │   ├── mason.lua
│   │   ├── trouble.lua
│   │   ├── lazygit.lua
│   │   └── which-key.lua
│   ├── editing/           # Text-editing enhancements (autopairs, surround, etc.)
│   ├── lsp/               # LSP setup (completion, keymaps, config)
│   ├── navigation/        # File/tree navigation (telescope, nvim-tree)
│   ├── ui/                # Visual and interface plugins (colorscheme, statusline, etc.)
│   └── init.lua           # Loads plugin imports from all subfolders
queries/                # Treesitter highlight queries (vendored from nvim-treesitter)
├── go/
│   ├── highlights.scm
│   ├── folds.scm
│   └── ...
├── typescript/
└── ...                 # One folder per language
```

---

## Plugin Organization

Plugins are grouped by purpose and placed in their corresponding folder:

| Folder        | Purpose                                                 |
| ------------- | ------------------------------------------------------- |
| `core/`       | Foundational tools like Mason, formatters, diagnostics  |
| `editing/`    | Code editing enhancements (e.g., autopairs, surround)   |
| `lsp/`        | Language Server Protocol setup, completion, LSP keymaps |
| `navigation/` | Navigation tools (e.g., Telescope, nvim-tree, tmux)     |
| `ui/`         | Themes, status lines, scroll animations, etc.           |

Each plugin is defined in its own file and lazy-loaded appropriately.

---

## Adding a New Plugin

1. **Pick a folder** under `plugins/` based on the plugin’s purpose.
2. **Create a new file**, e.g., `myplugin.lua`, and return a plugin spec:

```lua
-- plugins/ui/alpha-nvim.lua
return {
  "goolord/alpha-nvim",
  config = function()
    require("alpha").setup(require("alpha.themes.startify").config)
  end,
}
```

3. **Done!** It will be automatically picked up by Lazy via `plugins/init.lua`.

---

## Plugin Management

- Run `:Lazy` to open the Lazy.nvim UI
- Run `:Mason` to install LSP servers and formatters
- Run `:ParserUpdate` to recompile all treesitter parsers
- Run `:ParserInstall <lang>` to install a specific parser
- Run `:ParserClean` to remove parsers not in the configured list

---

## Treesitter

Syntax highlighting uses **native treesitter** (nvim 0.12+) instead of the `nvim-treesitter` plugin.

- **Parsers** (`.so` files) are compiled from source on first launch and stored in `~/.local/share/nvim/site/parser/`
- **Query files** (`highlights.scm`, etc.) are vendored in `queries/<lang>/` in this config repo
- To add a new language: add it to `M.parsers` in `core/treesitter.lua`, add a registry entry if the repo isn't `tree-sitter/tree-sitter-<lang>`, and add query files to `queries/<lang>/`

---

## Requirements

- Neovim ≥ 0.12
- A C compiler (`cc` or `c++`) for building treesitter parsers
- `git`, `curl`, and system utilities for Mason
- Optional: `ripgrep`, `fd`, `node`, `go`, etc. (for certain plugins)
