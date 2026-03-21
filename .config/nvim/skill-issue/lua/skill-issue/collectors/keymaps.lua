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
    local ok2, maps = pcall(vim.api.nvim_get_keymap, mode)
    if not ok2 then
      maps = {}
    end
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
        existing.tags = dk.tags or existing.tags
        existing.tip = dk.tip or existing.tip
      end
    end
  end

  -- Build display strings and collect
  local results = {}
  for _, entry in pairs(seen) do
    entry.display = "[keymap] " .. entry.key .. "  " .. entry.mode .. "  " .. entry.desc
    table.insert(results, entry)
  end

  return results
end

return M
