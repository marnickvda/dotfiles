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
