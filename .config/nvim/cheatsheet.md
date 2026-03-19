# Neovim Cheatsheet

Leader key: `<Space>`

## Navigation

| Key           | Mode  | Action                             |
| ------------- | ----- | ---------------------------------- |
| `<C-d>`       | n     | Smooth scroll down (neoscroll)     |
| `<C-u>`       | n     | Smooth scroll up (neoscroll)       |
| `<C-h/j/k/l>` | n     | Navigate between tmux/nvim panes   |
| `<C-l>`       | i     | Move cursor right in insert mode   |
| `J`           | n     | Join lines, cursor stays in place  |
| `n` / `N`     | n     | Next/prev search result (centered) |
| `<leader>k`   | n     | Next location list item            |
| `<leader>j`   | n     | Previous location list item        |
| `<leader>h`   | n     | Jump back (jumplist)               |
| `<leader>l`   | n     | Jump forward (jumplist)            |
| `s`           | n/x/o | Flash: label-jump to any location  |
| `S`           | n/x/o | Flash: treesitter select           |

## Harpoon (Pinned Files)

| Key         | Mode | Action              |
| ----------- | ---- | ------------------- |
| `<leader>a` | n    | Pin current file    |
| `<leader>H` | n    | Toggle harpoon menu |
| `<leader>1` | n    | Jump to file 1      |
| `<leader>2` | n    | Jump to file 2      |
| `<leader>3` | n    | Jump to file 3      |
| `<leader>4` | n    | Jump to file 4      |
| `<leader>5` | n    | Jump to file 5      |

## File Explorer (nvim-tree)

| Key          | Mode | Action                           |
| ------------ | ---- | -------------------------------- |
| `<leader>e`  | n    | Toggle file tree                 |
| `<leader>mt` | n    | Open current directory in Finder |

## Telescope (Search)

| Key          | Mode               | Action                      |
| ------------ | ------------------ | --------------------------- |
| `<leader>ff` | n                  | Find all files              |
| `<leader>fp` | n                  | Find git project files      |
| `<leader>fg` | n                  | Live grep (search in files) |
| `<leader>fb` | n                  | Open buffers                |
| `<leader>fh` | n                  | Help tags                   |
| `<leader>fq` | n                  | Quickfix list               |
| `<C-t>`      | n/i (in telescope) | Open results in Trouble     |

## LSP (all languages)

### Go-to

| Key  | Mode | Action                |
| ---- | ---- | --------------------- |
| `gd` | n    | Go to definition      |
| `gD` | n    | Go to declaration     |
| `gi` | n    | Go to implementation  |
| `go` | n    | Go to type definition |
| `gr` | n    | Go to references      |
| `K`  | n    | Hover documentation   |
| `gK` | n    | Signature help        |

### Actions (`<leader>m`)

| Key           | Mode | Action                   |
| ------------- | ---- | ------------------------ |
| `<leader>mr`  | n    | Code actions menu        |
| `<leader>mR`  | n    | Apply first code action  |
| `<leader>mi`  | n    | Organize imports         |
| `<leader>mn`  | n    | Rename symbol            |
| `<leader>mf`  | n/v  | Format file or selection |
| `<leader>lsp` | n    | Restart LSP              |

### Info (`<leader>l`)

| Key          | Mode | Action                |
| ------------ | ---- | --------------------- |
| `<leader>ls` | n    | Document symbols      |
| `<leader>lS` | n    | Workspace symbols     |
| `<leader>ld` | n    | Document diagnostics  |
| `<leader>lD` | n    | Workspace diagnostics |

## Trouble (Diagnostics)

| Key          | Mode | Action                            |
| ------------ | ---- | --------------------------------- |
| `<leader>xx` | n    | Toggle workspace diagnostics      |
| `<leader>xX` | n    | Toggle buffer diagnostics         |
| `<leader>cs` | n    | Toggle symbols                    |
| `<leader>cl` | n    | Toggle LSP definitions/references |
| `<leader>xL` | n    | Toggle location list              |
| `<leader>xQ` | n    | Toggle quickfix list              |
| `<leader>xt` | n    | Toggle TODOs (Trouble)            |
| `]t` / `[t`  | n    | Next/prev TODO comment            |
| `<leader>ft` | n    | Telescope: find TODOs             |

## Git

| Key          | Mode | Action                 |
| ------------ | ---- | ---------------------- |
| `<leader>lg` | n    | Open LazyGit           |
| `<leader>gb` | n    | Git blame current line |
| `<leader>gv` | n    | Git diff view          |
| `<leader>gh` | n    | Git file history       |
| `<leader>gH` | n    | Git branch history     |

## Editing

### Clipboard (system clipboard always active via `unnamedplus`)

| Key       | Mode  | Action                        |
| --------- | ----- | ----------------------------- |
| `<C-s>`   | n/i   | Save file                     |
| `<C-a>`   | n/i/v | Select all                    |
| `<C-c>`   | v     | Copy to system clipboard      |
| `<C-x>`   | v     | Cut to system clipboard       |
| `<C-v>`   | i     | Paste from system clipboard   |
| `<C-v>`   | n     | Visual block mode (native)    |
| `p` / `P` | n     | Paste (uses system clipboard) |

### Surround (mini.surround)

| Key   | Mode | Action                   |
| ----- | ---- | ------------------------ |
| `gsa` | n/v  | Add surrounding          |
| `gsd` | n    | Delete surrounding       |
| `gsr` | n    | Replace surrounding      |
| `gsf` | n    | Find surrounding (right) |
| `gsF` | n    | Find surrounding (left)  |
| `gsh` | n    | Highlight surrounding    |

### Move Lines

| Key | Mode | Action                   |
| --- | ---- | ------------------------ |
| `J` | v    | Move selected lines down |
| `K` | v    | Move selected lines up   |

### Treesitter Text Objects

Select with `v` then use these in operator-pending mode:

| Key         | Action                    |
| ----------- | ------------------------- |
| `am` / `im` | Outer/inner function      |
| `ac` / `ic` | Outer/inner class         |
| `af` / `if` | Outer/inner function call |
| `aa` / `ia` | Outer/inner parameter     |
| `ai` / `ii` | Outer/inner conditional   |
| `al` / `il` | Outer/inner loop          |
| `a=` / `i=` | Outer/inner assignment    |
| `l=` / `r=` | Assignment LHS / RHS      |

### Treesitter Movement

| Key         | Action                   |
| ----------- | ------------------------ |
| `]m` / `[m` | Next/prev function start |
| `]M` / `[M` | Next/prev function end   |
| `]]` / `[[` | Next/prev class start    |
| `][` / `[]` | Next/prev class end      |

### Treesitter Swap

| Key          | Action                       |
| ------------ | ---------------------------- |
| `<leader>pa` | Swap parameter with next     |
| `<leader>pA` | Swap parameter with previous |

### Incremental Selection

| Key         | Mode | Action                        |
| ----------- | ---- | ----------------------------- |
| `<C-space>` | n    | Start selection / expand node |
| `<BS>`      | v    | Shrink selection              |

## Misc

| Key                | Mode | Action                                |
| ------------------ | ---- | ------------------------------------- |
| `<leader>s`        | n    | Search & replace word under cursor    |
| `<leader>S`        | n/v  | Search & replace (project-wide)       |
| `<leader>u`        | n    | Toggle undo tree                      |
| `<leader>mX`       | n    | Make current file executable          |
| `<leader><leader>` | n    | Source (reload) current file          |
| `<leader>nd`       | n    | Dismiss noice notification            |
| `<leader>?`        | n    | Show buffer-local keymaps (which-key) |
| `Q`                | n    | Disabled (no Ex mode)                 |
| `<C-c>`            | i    | Escape insert mode                    |

## Completion (nvim-cmp)

| Key               | Mode | Action                   |
| ----------------- | ---- | ------------------------ |
| `<C-n>`           | i    | Next completion item     |
| `<C-p>`           | i    | Previous completion item |
| `<CR>`            | i    | Confirm selection        |
| `<C-Space>`       | i    | Trigger completion       |
| `<C-u>` / `<C-d>` | i    | Scroll docs up/down      |
| `<C-k>`           | i    | Signature help           |

## Sessions (persistence.nvim)

| Key          | Mode | Action                 |
| ------------ | ---- | ---------------------- |
| `<leader>qs` | n    | Restore session (cwd)  |
| `<leader>qS` | n    | Select session         |
| `<leader>ql` | n    | Restore last session   |
| `<leader>qd` | n    | Stop session recording |

---

# Language Quick Guides

## TypeScript / React

### LSP & Tools

- **LSP**: `ts_ls` (TypeScript language server) + `eslint`
- **Formatter**: `prettier` (format with `<leader>mf`)
- **CSS**: `tailwindcss` LSP active in `.jsx`/`.tsx` files
- **Autotag**: Auto-close and rename HTML/JSX tags

### Common Workflow

```
<leader>ff          Find files in project
<leader>fg          Search across files (grep)
gd                  Jump to definition (component, hook, type)
gr                  Find all references / usages
K                   Hover to see types and docs
<leader>mr          Code actions (auto-import, quick fixes)
<leader>mi          Organize imports
<leader>mn          Rename across files
<leader>mf          Format with prettier
<leader>xx          View all diagnostics
```

### React-Specific Tips

- **JSX tags** auto-close and auto-rename via `nvim-ts-autotag`
- Use `gsa` to surround JSX with a parent element, `gsd` to unwrap
- `vam` selects the entire component function, `vim` selects the body
- `<C-space>` in JSX incrementally selects the current node (great for selecting JSX trees)
- Tailwind classes get LSP completion and hover previews

### Text Objects for JSX

```
vaf                 Select entire function call (e.g., useState())
vam                 Select entire component function
dam                 Delete entire component
cim                 Change function body
vaa                 Select a prop/parameter
```

---

## Go

### LSP & Tools

- **LSP**: `gopls` with extensive analysis (unused params, nil checks, shadow detection)
- **Formatter**: `gofmt` via `gofumpt` (stricter, configured in gopls)
- **Hints**: Inlay hints enabled (variable types, parameter names, etc.)
- **Staticcheck**: Enabled for extra linting
- **Go tools**: `gopher.nvim` for struct tags, docs, tests, interface impl
- **Linter**: `golangci-lint` available via Mason

### Common Workflow

```
<leader>ff          Find files
<leader>fg          Search across files
gd                  Jump to definition
gi                  Go to interface implementation
gr                  Find all references
K                   Hover docs
<leader>mr          Code actions (extract function, fill struct, etc.)
<leader>mi          Organize imports (add missing, remove unused)
<leader>mn          Rename (package-aware)
<leader>mf          Format with gofumpt
```

### Struct Tags (`<leader>g...`)

| Key          | Action                           |
| ------------ | -------------------------------- |
| `<leader>gj` | Add `json` struct tags           |
| `<leader>gJ` | Add `json,omitempty` struct tags |
| `<leader>gy` | Add `yaml` struct tags           |
| `<leader>gx` | Remove `json` struct tags        |

Use `:GoTagAdd db`, `:GoTagAdd xml`, etc. for other tag types.

### Documentation & Generation

| Key          | Action                             |
| ------------ | ---------------------------------- |
| `<leader>gd` | Generate doc comment for symbol    |
| `<leader>gI` | Implement interface on struct      |
| `<leader>gn` | Convert JSON to Go struct          |
| `<leader>gg` | Run `go generate` for current file |
| `<leader>gm` | Run `go mod tidy`                  |

### Tests (`<leader>g...`)

| Key          | Action                                |
| ------------ | ------------------------------------- |
| `<leader>gt` | Generate test for function at cursor  |
| `<leader>gT` | Generate tests for all functions      |
| `<leader>gE` | Generate tests for exported functions |

### Error Handling (`<leader>ge...`)

| Key           | Action                                           |
| ------------- | ------------------------------------------------ |
| `<leader>ger` | Smart if-err with correct return values (gopher) |
| `<leader>gee` | Insert `if err != nil { return err }`            |
| `<leader>gea` | Insert `assert.NoError(err, "")` (for tests)     |
| `<leader>gef` | Insert `if err != nil { log.Fatalf(...) }`       |
| `<leader>gel` | Insert `if err != nil { logger.Error(...) }`     |

### Go-Specific Tips

- gopls auto-imports packages on save/format
- Use `gi` to jump from interface to its implementations
- `<leader>gI` prompts for receiver and interface (e.g., `:GoImpl r *MyStruct io.Reader`)
- `<leader>ger` is smarter than `<leader>gee` — it generates correct zero-value returns
- `<leader>pa` / `<leader>pA` to reorder function parameters
- `vam` / `dam` to select/delete entire functions (great for refactoring)
- `:GoTagAdd json=omitempty,yaml` works for multiple tags at once

---

## Python

### LSP & Tools

- **LSP**: Uses default setup via mason-lspconfig (pyright recommended — install via Mason)
- **Formatter**: `black` (code formatter) + `isort` (import sorter)
- **Linter**: `flake8` (configured as a conform formatter for diagnostics)

### Common Workflow

```
<leader>ff          Find files
<leader>fg          Search across files
gd                  Jump to definition
gr                  Find references
K                   Hover docs / type info
<leader>mr          Code actions
<leader>mi          Organize imports (via isort)
<leader>mn          Rename symbol
<leader>mf          Format with black + isort
<leader>xx          View all diagnostics (flake8 + LSP)
```

### Python-Specific Tips

- `black` enforces consistent formatting — just write code and `<leader>mf`
- `isort` sorts imports into sections (stdlib, third-party, local)
- Use `vac` / `vic` to select outer/inner class
- Use `vam` / `vim` to select outer/inner method/function
- `]m` / `[m` to jump between functions
- `]]` / `[[` to jump between classes

---

## Rust

### LSP & Tools

- **LSP**: `rust-analyzer` managed by `rustaceanvim`
- **Formatter**: `rust-analyzer` handles formatting (rustfmt)
- **TOML**: `taplo` LSP for `Cargo.toml`

### Common Workflow

```
<leader>ff          Find files
<leader>fg          Search across files
gd                  Jump to definition
gi                  Go to trait implementation
gr                  Find references
K                   Hover docs (with rendered rustdoc)
<leader>mr          Code actions (fill match arms, extract, derive, etc.)
<leader>mn          Rename symbol
<leader>mf          Format with rustfmt
<leader>xx          View diagnostics
```

### Rust-Specific Tips

- `rustaceanvim` provides enhanced code actions (fill match arms, add missing trait impls)
- Cargo.toml editing gets completion from `taplo` LSP
- Use `vam` to select entire `fn` blocks, `dam` to delete them
- Inlay hints show types for `let` bindings and closures
- `gi` on a trait jumps to all implementations
