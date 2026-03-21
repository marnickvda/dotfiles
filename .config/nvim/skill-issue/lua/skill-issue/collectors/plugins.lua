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
    -- Note: relies on lazy.nvim internals (plugin._), acceptable for local plugin
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
