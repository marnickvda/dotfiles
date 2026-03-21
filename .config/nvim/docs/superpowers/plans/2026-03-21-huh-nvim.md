# skill-issue Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Build a local Neovim plugin that provides a unified Telescope picker for fuzzy searching all installed plugins and keybindings, with context-aware sorting.

**Architecture:** A local plugin (`skill-issue/`) at the nvim config root, loaded by lazy.nvim via `dir`. It has three layers: collectors (gather keymaps and plugins), a tags module (static metadata), and a picker (Telescope integration). The collectors normalize data into a unified entry format, the picker displays them with context-aware sorting.

**Tech Stack:** Lua, Neovim API (`vim.api.nvim_get_keymap`), lazy.nvim API (`require("lazy").plugins()`), Telescope API (`pickers`, `finders`, `previewers`, `sorters`, `actions`)

**Spec:** `docs/superpowers/specs/2026-03-21-skill-issue-design.md`

---

### Task 1: Scaffold the plugin directory and lazy.nvim integration

**Files:**
- Create: `skill-issue/lua/skill-issue/init.lua`
- Create: `lua/marnickvda/plugins/navigation/skill-issue.lua`

- [ ] **Step 1: Create the plugin entry point**

Create `skill-issue/lua/skill-issue/init.lua` with stub `setup()` and `pick()` functions:

```lua
local M = {}

M.setup = function(opts)
  M.opts = opts or {}
end

M.pick = function()
  require("skill-issue.picker").open()
end

return M
```

- [ ] **Step 2: Create the lazy.nvim plugin spec**

Create `lua/marnickvda/plugins/navigation/skill-issue.lua`:

```lua
return {
  "skill-issue",
  name = "skill-issue",
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

- [ ] **Step 3: Create a stub picker to verify loading works**

Create `skill-issue/lua/skill-issue/picker.lua`:

```lua
local M = {}

M.open = function()
  vim.notify("skill-issue: picker loaded!", vim.log.levels.INFO)
end

return M
```

- [ ] **Step 4: Verify the plugin loads**

Open Neovim, press `<leader>huh`. You should see the notification "skill-issue: picker loaded!".

- [ ] **Step 5: Commit**

```bash
git add skill-issue/ lua/marnickvda/plugins/navigation/skill-issue.lua
git commit -m "feat(skill-issue): scaffold plugin structure and lazy.nvim integration"
```

---

### Task 2: Implement the tags module

**Files:**
- Create: `skill-issue/lua/skill-issue/tags.lua`

- [ ] **Step 1: Create the tags module**

Create `skill-issue/lua/skill-issue/tags.lua` with the full curated tags table from the spec. The module returns a single table keyed by plugin name:

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

- [ ] **Step 2: Commit**

```bash
git add skill-issue/lua/skill-issue/tags.lua
git commit -m "feat(skill-issue): add curated context tags for all plugins"
```

---

### Task 3: Implement the plugins collector

**Files:**
- Create: `skill-issue/lua/skill-issue/collectors/plugins.lua`

- [ ] **Step 1: Create the plugins collector**

Create `skill-issue/lua/skill-issue/collectors/plugins.lua`:

```lua
local tags_table = require("skill-issue.tags")

local M = {}

--- Collect all plugins from lazy.nvim and return unified entries + declared keys
--- @return table[] plugin_entries, table[] declared_keymaps
M.collect = function()
  local plugins = require("lazy").plugins()
  local plugin_entries = {}
  local declared_keymaps = {}

  for _, plugin in ipairs(plugins) do
    local name = plugin.name
    local tag_info = tags_table[name] or {}
    local desc = tag_info.tip or plugin.url or name

    -- Find the spec file path: lazy stores the plugin's defining module
    local source_file = nil
    if plugin._ and plugin._.module then
      -- Resolve module name to file path
      local mod_path = plugin._.module:gsub("%.", "/")
      local candidates = vim.api.nvim_get_runtime_file("lua/" .. mod_path .. ".lua", false)
      if #candidates > 0 then
        source_file = candidates[1]
      end
    end

    table.insert(plugin_entries, {
      type = "plugin",
      display = "[plugin] " .. name .. "  " .. desc,
      key = nil,
      mode = nil,
      desc = desc,
      plugin = name,
      source_file = source_file,
      source_line = nil,
      tags = tag_info.tags or {},
      tip = tag_info.tip,
    })

    -- Extract declared keys from lazy spec for keymap merging
    if plugin.keys then
      for _, key_spec in ipairs(plugin.keys) do
        -- lazy.nvim key specs can be strings or tables
        local lhs, key_desc, mode
        if type(key_spec) == "string" then
          lhs = key_spec
        elseif type(key_spec) == "table" then
          lhs = key_spec[1] or key_spec.lhs
          key_desc = key_spec.desc
          mode = key_spec.mode
        end

        if lhs and key_desc then
          -- Normalize mode: can be string or table, default to "n"
          if type(mode) == "table" then
            for _, m in ipairs(mode) do
              table.insert(declared_keymaps, {
                lhs = lhs,
                mode = m,
                desc = key_desc,
                plugin = name,
                tags = tag_info.tags or {},
                tip = tag_info.tip,
                source_file = source_file,
              })
            end
          else
            table.insert(declared_keymaps, {
              lhs = lhs,
              mode = mode or "n",
              desc = key_desc,
              plugin = name,
              tags = tag_info.tags or {},
              tip = tag_info.tip,
              source_file = source_file,
            })
          end
        end
      end
    end
  end

  return plugin_entries, declared_keymaps
end

return M
```

- [ ] **Step 2: Smoke test in Neovim**

Open Neovim and run: `:lua print(vim.inspect(require("skill-issue.collectors.plugins").collect()))`

Verify it returns a table of plugin entries and declared keymaps. Check that known plugins like `telescope.nvim` appear with their tags and tips.

- [ ] **Step 3: Commit**

```bash
git add skill-issue/lua/skill-issue/collectors/plugins.lua
git commit -m "feat(skill-issue): implement plugins collector with lazy.nvim integration"
```

---

### Task 4: Implement the keymaps collector

**Files:**
- Create: `skill-issue/lua/skill-issue/collectors/keymaps.lua`

- [ ] **Step 1: Create the keymaps collector**

Create `skill-issue/lua/skill-issue/collectors/keymaps.lua`:

```lua
local tags_table = require("skill-issue.tags")

local M = {}

local MODES = { "n", "i", "x", "o", "s" }

-- Keyword-to-tag mapping for keymaps without a known plugin
local KEYWORD_TAGS = {
  { pattern = "git", tag = "git" },
  { pattern = "lsp", tag = "lsp" },
  { pattern = "diagnostic", tag = "diagnostics" },
  { pattern = "telescope", tag = "navigation" },
  { pattern = "harpoon", tag = "navigation" },
  { pattern = "trouble", tag = "diagnostics" },
}

--- Infer tags from a keymap description string
local function infer_tags(desc)
  if not desc then
    return {}
  end
  local lower = desc:lower()
  local inferred = {}
  for _, kw in ipairs(KEYWORD_TAGS) do
    if lower:find(kw.pattern) then
      table.insert(inferred, kw.tag)
    end
  end
  return inferred
end

--- Try to extract source file and line from a keymap's callback
local function get_source_info(keymap)
  if keymap.callback then
    local ok, info = pcall(debug.getinfo, keymap.callback, "S")
    if ok and info and info.source then
      local file = info.source:gsub("^@", "")
      return file, info.linedefined
    end
  end
  return nil, nil
end

--- Collect all keymaps from runtime + merge with lazy-declared keys
--- @param declared_keymaps table[] keymaps extracted from lazy.nvim plugin specs
--- @return table[] unified keymap entries
M.collect = function(declared_keymaps)
  -- Key: "mode|lhs" -> entry (for deduplication)
  local seen = {}
  local entries = {}

  -- 1. Collect buffer-local keymaps (highest priority)
  for _, mode in ipairs(MODES) do
    local ok, buf_maps = pcall(vim.api.nvim_buf_get_keymap, 0, mode)
    if ok then
      for _, km in ipairs(buf_maps) do
        if km.desc and km.desc ~= "" and not km.lhs:find("<Plug>") then
          local dedup_key = mode .. "|" .. km.lhs
          local source_file, source_line = get_source_info(km)
          seen[dedup_key] = {
            type = "keymap",
            key = km.lhs,
            mode = mode,
            desc = km.desc,
            source_file = source_file,
            source_line = source_line,
            plugin = nil,
            tags = infer_tags(km.desc),
            tip = nil,
          }
        end
      end
    end
  end

  -- 2. Collect global keymaps (lower priority, skip if buffer-local exists)
  for _, mode in ipairs(MODES) do
    local maps = vim.api.nvim_get_keymap(mode)
    for _, km in ipairs(maps) do
      if km.desc and km.desc ~= "" and not km.lhs:find("<Plug>") then
        local dedup_key = mode .. "|" .. km.lhs
        if not seen[dedup_key] then
          local source_file, source_line = get_source_info(km)
          seen[dedup_key] = {
            type = "keymap",
            key = km.lhs,
            mode = mode,
            desc = km.desc,
            source_file = source_file,
            source_line = source_line,
            plugin = nil,
            tags = infer_tags(km.desc),
            tip = nil,
          }
        end
      end
    end
  end

  -- 3. Merge lazy-declared keymaps (lowest priority, skip if runtime exists)
  for _, dk in ipairs(declared_keymaps or {}) do
    local dedup_key = dk.mode .. "|" .. dk.lhs
    if not seen[dedup_key] then
      seen[dedup_key] = {
        type = "keymap",
        key = dk.lhs,
        mode = dk.mode,
        desc = dk.desc,
        source_file = dk.source_file,
        source_line = nil,
        plugin = dk.plugin,
        tags = dk.tags or {},
        tip = dk.tip,
      }
    else
      -- Enrich existing entry with plugin info if missing
      local existing = seen[dedup_key]
      if not existing.plugin and dk.plugin then
        existing.plugin = dk.plugin
        local tag_info = tags_table[dk.plugin]
        if tag_info then
          existing.tags = tag_info.tags or existing.tags
          existing.tip = tag_info.tip or existing.tip
        end
      end
    end
  end

  -- Build display strings and collect
  for _, entry in pairs(seen) do
    entry.display = "[keymap] " .. entry.key .. "  " .. entry.mode .. "  " .. entry.desc
    table.insert(entries, entry)
  end

  return entries
end

return M
```

- [ ] **Step 2: Smoke test in Neovim**

Open Neovim and run:
```
:lua local _, dk = require("skill-issue.collectors.plugins").collect(); print(#require("skill-issue.collectors.keymaps").collect(dk))
```

Verify it returns a number > 0 (the count of keymaps collected).

- [ ] **Step 3: Commit**

```bash
git add skill-issue/lua/skill-issue/collectors/keymaps.lua
git commit -m "feat(skill-issue): implement keymaps collector with deduplication and tag inference"
```

---

### Task 5: Implement the Telescope picker

**Files:**
- Modify: `skill-issue/lua/skill-issue/picker.lua` (replace stub)

- [ ] **Step 1: Implement the full picker**

Replace `skill-issue/lua/skill-issue/picker.lua` with:

```lua
local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local plugins_collector = require("skill-issue.collectors.plugins")
local keymaps_collector = require("skill-issue.collectors.keymaps")

local M = {}

--- Detect current context for sorting boost
local function detect_context()
  local ctx = {}

  -- Filetype
  local ft = vim.bo.filetype
  if ft and ft ~= "" then
    ctx[ft] = true
  end

  -- Git repo
  if vim.fn.finddir(".git", ".;") ~= "" then
    ctx["git"] = true
  end

  return ctx
end

--- Check if an entry's tags match the current context
local function matches_context(entry, context)
  for _, tag in ipairs(entry.tags or {}) do
    if context[tag] then
      return true
    end
  end
  return false
end

--- Sort entries: context matches first, then plugins, then keymaps
local function sort_entries(entries, context)
  table.sort(entries, function(a, b)
    local a_ctx = matches_context(a, context)
    local b_ctx = matches_context(b, context)

    -- Tier 1: context matches first
    if a_ctx ~= b_ctx then
      return a_ctx
    end

    -- Tier 2: plugins before keymaps
    if a.type ~= b.type then
      return a.type == "plugin"
    end

    -- Tier 3: alphabetical by display
    return a.display < b.display
  end)

  return entries
end

--- Build the previewer
local function make_previewer()
  return previewers.new_buffer_previewer({
    title = "Skill Issue",
    define_preview = function(self, entry, _status)
      local lines = {}
      local e = entry.value

      -- Header: tip if available
      if e.tip then
        table.insert(lines, "Tip: " .. e.tip)
        table.insert(lines, "")
      end

      -- Tags
      if e.tags and #e.tags > 0 then
        table.insert(lines, "Tags: " .. table.concat(e.tags, ", "))
        table.insert(lines, "")
      end

      -- Type-specific info
      if e.type == "plugin" then
        table.insert(lines, "Type: Plugin")
        table.insert(lines, "Name: " .. (e.plugin or "unknown"))
      else
        table.insert(lines, "Type: Keymap")
        table.insert(lines, "Key:  " .. (e.key or ""))
        table.insert(lines, "Mode: " .. (e.mode or ""))
        if e.plugin then
          table.insert(lines, "From: " .. e.plugin)
        end
      end

      table.insert(lines, "Desc: " .. (e.desc or ""))

      if e.source_file then
        table.insert(lines, "")
        table.insert(lines, "Source: " .. e.source_file)
        if e.source_line then
          table.insert(lines, "Line:   " .. e.source_line)
        end

        -- Show file content below
        table.insert(lines, "")
        table.insert(lines, string.rep("─", 60))
        table.insert(lines, "")

        local ok, file_lines = pcall(vim.fn.readfile, e.source_file)
        if ok and file_lines then
          local start = math.max(1, (e.source_line or 1) - 5)
          local finish = math.min(#file_lines, (e.source_line or 1) + 20)
          for i = start, finish do
            table.insert(lines, string.format("%4d │ %s", i, file_lines[i]))
          end
        end
      end

      vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)
      vim.bo[self.state.bufnr].filetype = "markdown"
    end,
  })
end

--- Open the skill-issue picker
M.open = function()
  local context = detect_context()

  -- Collect all entries
  local plugin_entries, declared_keymaps = plugins_collector.collect()
  local keymap_entries = keymaps_collector.collect(declared_keymaps)

  -- Merge and sort
  local all_entries = {}
  for _, e in ipairs(plugin_entries) do
    table.insert(all_entries, e)
  end
  for _, e in ipairs(keymap_entries) do
    table.insert(all_entries, e)
  end

  sort_entries(all_entries, context)

  pickers
    .new({}, {
      prompt_title = "Skill Issue",
      finder = finders.new_table({
        results = all_entries,
        entry_maker = function(entry)
          local prefix = entry.type == "plugin" and "[plugin]" or "[keymap]"
          local hl = entry.type == "plugin" and "TelescopeResultsIdentifier" or "TelescopeResultsComment"
          local rest = entry.display:sub(#prefix + 2) -- skip prefix + space

          local displayer = entry_display.create({
            separator = " ",
            items = {
              { width = 8 },
              { remaining = true },
            },
          })

          return {
            value = entry,
            display = function()
              return displayer({
                { prefix, hl },
                rest,
              })
            end,
            ordinal = entry.display,
          }
        end,
      }),
      sorter = conf.generic_sorter({}),
      previewer = make_previewer(),
      attach_mappings = function(prompt_bufnr, map)
        actions.select_default:replace(function()
          actions.close(prompt_bufnr)
        end)
        return true
      end,
    })
    :find()
end

return M
```

- [ ] **Step 2: Verify the full picker in Neovim**

Open Neovim, press `<leader>huh`. Verify:
- The picker opens with a list of plugins and keymaps
- Fuzzy searching works (type "git" and see git-related entries)
- Preview pane shows tips, tags, and source file content
- Pressing `<CR>` closes the picker without side effects
- Context-relevant entries appear first (e.g., Go entries boosted when editing a `.go` file)

- [ ] **Step 3: Commit**

```bash
git add skill-issue/lua/skill-issue/picker.lua
git commit -m "feat(skill-issue): implement Telescope picker with context-aware sorting and preview"
```

---

### Task 6: Final integration and cleanup

**Files:**
- Verify: `skill-issue/lua/skill-issue/init.lua`
- Verify: `lua/marnickvda/plugins/navigation/skill-issue.lua`

- [ ] **Step 1: End-to-end verification**

Open Neovim and test the following scenarios:

1. Press `<leader>huh` — picker opens
2. Type "telescope" — fuzzy matches telescope plugin and its keymaps
3. Type "git" — shows lazygit, diffview, gitsigns, octo and their keymaps
4. Type "<leader>ff" — finds the Telescope find files keymap
5. Select any entry — preview shows tip, tags, source info
6. Press `<CR>` — picker closes cleanly
7. Open a `.go` file, press `<leader>huh` — Go-related entries should appear first
8. Check `:Lazy` — skill-issue shows as installed local plugin

- [ ] **Step 2: Commit final state**

```bash
git add -A skill-issue/ lua/marnickvda/plugins/navigation/skill-issue.lua
git commit -m "feat(skill-issue): complete plugin with fuzzy search for plugins and keymaps"
```
