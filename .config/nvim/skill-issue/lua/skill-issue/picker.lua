local pickers = require("telescope.pickers")
local finders = require("telescope.finders")
local actions = require("telescope.actions")
local previewers = require("telescope.previewers")
local entry_display = require("telescope.pickers.entry_display")
local conf = require("telescope.config").values

local plugins_collector = require("skill-issue.collectors.plugins")
local keymaps_collector = require("skill-issue.collectors.keymaps")
local commands_collector = require("skill-issue.collectors.commands")

local M = {}

local MODE_HL = {
	n = "DiagnosticInfo",
	v = "DiagnosticWarn",
	i = "DiagnosticOk",
	o = "DiagnosticError",
	s = "DiagnosticHint",
}
local INACTIVE_HL = "Comment"

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

		-- Tier 2: plugins > commands > keymaps
		if a.type ~= b.type then
			local order = { plugin = 1, command = 2, keymap = 3 }
			return (order[a.type] or 9) < (order[b.type] or 9)
		end

		-- Tier 3: alphabetical by display
		return a.display < b.display
	end)

	return entries
end

--- Find the first help doc file for a plugin
local function find_help_doc(plugin_dir)
	if not plugin_dir then
		return nil
	end
	local doc_dir = plugin_dir .. "/doc"
	local ok, files = pcall(vim.fn.glob, doc_dir .. "/*.txt", false, true)
	if ok and files and #files > 0 then
		return files[1]
	end
	return nil
end

--- Wrap text to fit within a given width, preserving a prefix on each line
local function wrap_text(text, width, prefix)
	prefix = prefix or ""
	local available = width - #prefix
	if available <= 0 or #text <= available then
		return { prefix .. text }
	end

	local wrapped = {}
	local remaining = text
	while #remaining > 0 do
		if #remaining <= available then
			table.insert(wrapped, prefix .. remaining)
			break
		end
		-- Find last space within available width
		local break_at = available
		local space_pos = remaining:sub(1, available):find("%s[^%s]*$")
		if space_pos then
			break_at = space_pos
		end
		table.insert(wrapped, prefix .. remaining:sub(1, break_at):gsub("%s+$", ""))
		remaining = remaining:sub(break_at + 1):gsub("^%s+", "")
	end
	return wrapped
end

--- Build a box-drawn card that fits the preview width
--- Returns lines and highlight metadata for coloring
local function build_card(title, fields, width)
	local inner = width - 2 -- account for │ on each side
	local lines = {}
	local highlights = {} -- { {line_idx, col_start, col_end, hl_group}, ... }

	-- Top border (use display width, not byte length, for box-drawing chars)
	local title_bar = "─ " .. title .. " "
	local title_display_width = vim.fn.strdisplaywidth(title_bar)
	local top_pad = math.max(0, inner - title_display_width)
	local top_line = "╭" .. title_bar .. string.rep("─", top_pad) .. "╮"
	table.insert(lines, top_line)
	table.insert(highlights, { #lines - 1, 0, #top_line, "FloatBorder" })

	local empty_line = "│" .. string.rep(" ", inner) .. "│"
	table.insert(lines, empty_line)
	table.insert(highlights, { #lines - 1, 0, #empty_line, "FloatBorder" })

	-- │ is 3 bytes in UTF-8
	local border_bytes = 3
	local prefix_bytes = border_bytes + 2 -- "│  "

	for _, field in ipairs(fields) do
		local wrapped = wrap_text(field, inner - 2, "")
		for _, line in ipairs(wrapped) do
			local pad = math.max(0, inner - vim.fn.strdisplaywidth(line) - 2)
			local full = "│  " .. line .. string.rep(" ", pad) .. "│"
			table.insert(lines, full)
			local row = #lines - 1
			-- Color borders
			table.insert(highlights, { row, 0, border_bytes, "FloatBorder" })
			table.insert(highlights, { row, #full - border_bytes, #full, "FloatBorder" })
			-- Color label: value pairs
			local colon_pos = line:find(":%s")
			if colon_pos then
				table.insert(highlights, { row, prefix_bytes, prefix_bytes + colon_pos, "DiagnosticInfo" })
			end
			-- Color `backtick` content (commands/keys)
			for s, e in line:gmatch("()`[^`]+()`") do
				-- Highlight the content between backticks (skip the backticks themselves)
				table.insert(
					highlights,
					{ row, prefix_bytes + s, prefix_bytes + e - 1, "TelescopeResultsSpecialComment" }
				)
			end
			-- Color mode indicators: per-char coloring for (nvios) pattern
			local mode_match = line:match("%(([nvios_]+)%)")
			if mode_match then
				local paren_start = line:find("%(([nvios_]+)%)") + 1 -- after the "("
				for idx = 1, #mode_match do
					local ch = mode_match:sub(idx, idx)
					local hl = ch == "_" and INACTIVE_HL or (MODE_HL[ch] or INACTIVE_HL)
					table.insert(
						highlights,
						{ row, prefix_bytes + paren_start + idx - 2, prefix_bytes + paren_start + idx - 1, hl }
					)
				end
			end
		end
	end

	table.insert(lines, empty_line)
	table.insert(highlights, { #lines - 1, 0, #empty_line, "FloatBorder" })

	-- Bottom border
	local bot_line = "╰" .. string.rep("─", inner) .. "╯"
	table.insert(lines, bot_line)
	table.insert(highlights, { #lines - 1, 0, #bot_line, "FloatBorder" })

	return lines, highlights
end

--- Build the previewer
local function make_previewer()
	return previewers.new_buffer_previewer({
		title = "Description",
		define_preview = function(self, entry, _status)
			local e = entry.value

			-- Get the preview window width
			local win = self.state.winid
			local width = vim.api.nvim_win_get_width(win)

			local lines = {}
			local card_hls = {}

			if e.type == "plugin" then
				local fields = { e.plugin or "unknown" }
				local card_lines, hls = build_card("Plugin", fields, width)
				vim.list_extend(lines, card_lines)
				vim.list_extend(card_hls, hls)
			elseif e.type == "command" then
				local cmd_fields = {
					"`:" .. (e.command_name or "") .. "`",
					"",
					"Args: " .. (e.nargs or "0"),
				}
				if e.plugin then
					table.insert(cmd_fields, "Source: " .. e.plugin)
				end
				if e.desc and e.desc ~= "" then
					table.insert(cmd_fields, "")
					table.insert(cmd_fields, e.desc)
				end
				local cmd_lines, cmd_hls = build_card("Command", cmd_fields, width)
				vim.list_extend(lines, cmd_lines)
				vim.list_extend(card_hls, cmd_hls)
			else
				-- Keymap card first
				local source
				if e.plugin then
					source = e.plugin
				elseif e.source_file and e.source_file:find(vim.fn.stdpath("config"), 1, true) then
					source = "User Defined"
				else
					source = "Neovim Default"
				end

				local keymap_fields = {
					"`" .. (e.key or "") .. "`  (" .. (e.mode or "") .. ")",
					e.desc or "",
					"",
					"Source: " .. source,
				}
				local km_lines, km_hls = build_card("Keymap", keymap_fields, width)
				vim.list_extend(lines, km_lines)
				vim.list_extend(card_hls, km_hls)

			end

			-- Plugin help docs
			local help_file = find_help_doc(e.plugin_dir)
			local doc_start = nil
			if help_file then
				table.insert(lines, "")
				doc_start = #lines
				local ok, doc_lines = pcall(vim.fn.readfile, help_file)
				if ok and doc_lines then
					for _, line in ipairs(doc_lines) do
						table.insert(lines, line)
					end
				end
			end

			vim.api.nvim_buf_set_lines(self.state.bufnr, 0, -1, false, lines)

			-- Apply card highlights
			local ns = vim.api.nvim_create_namespace("skill_issue_preview")
			vim.api.nvim_buf_clear_namespace(self.state.bufnr, ns, 0, -1)
			for _, hl in ipairs(card_hls) do
				vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, hl[4], hl[1], hl[2], hl[3])
			end

			-- Apply vimdoc treesitter highlighting for help docs
			if doc_start then
				local ok_ts, _ = pcall(vim.treesitter.start, self.state.bufnr, "vimdoc")
				if not ok_ts then
					-- Fallback: basic help syntax patterns
					for i = doc_start, #lines - 1 do
						local line = lines[i + 1]
						if line then
							-- Highlight *tags* and |links|
							for s, e in line:gmatch("()%*%S+%*()") do
								vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Title", i, s - 1, e - 1)
							end
							for s, e in line:gmatch("()|%S+|()") do
								vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Identifier", i, s - 1, e - 1)
							end
							-- Section headers (lines ending with ~)
							if line:match("~%s*$") then
								vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Title", i, 0, -1)
							end
							-- All-caps headers (like INTRODUCTION, COMMANDS)
							if line:match("^%u[%u%s%-]+%s*$") then
								vim.api.nvim_buf_add_highlight(self.state.bufnr, ns, "Title", i, 0, -1)
							end
						end
					end
				end
			end

			vim.wo[win].wrap = false
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

	-- Build lookups from plugin entries
	local plugin_dirs = {} -- plugin name -> install dir
	local source_to_plugin = {} -- spec source file -> { name, dir }
	for _, e in ipairs(plugin_entries) do
		if e.plugin then
			if e.plugin_dir then
				plugin_dirs[e.plugin] = e.plugin_dir
			end
			if e.source_file then
				source_to_plugin[e.source_file] = {
					name = e.plugin,
					dir = e.plugin_dir,
				}
			end
		end
	end

	-- Enrich keymaps: match source_file to plugin
	for _, e in ipairs(keymap_entries) do
		if not e.plugin and e.source_file then
			-- 1. Exact match: source_file IS a plugin spec file
			local info = source_to_plugin[e.source_file]
			if info then
				e.plugin = info.name
				e.plugin_dir = info.dir
			else
				-- 2. Prefix match: source_file is INSIDE a plugin's install dir
				-- (e.g., callback is a direct reference to a plugin function)
				for pname, pdir in pairs(plugin_dirs) do
					if e.source_file:find(pdir, 1, true) == 1 then
						e.plugin = pname
						e.plugin_dir = pdir
						break
					end
				end
			end
		end
		if e.plugin and not e.plugin_dir then
			e.plugin_dir = plugin_dirs[e.plugin]
		end
	end

	-- Collect commands and add to entries
	local command_entries = commands_collector.collect(plugin_dirs)
	for _, e in ipairs(command_entries) do
		table.insert(all_entries, e)
	end

	sort_entries(all_entries, context)

	pickers
		.new({}, {
			prompt_title = "Search keymap/plugin",
			finder = finders.new_table({
				results = all_entries,
				entry_maker = (function()
					local plugin_displayer = entry_display.create({
						separator = " ",
						items = {
							{ width = 8 }, -- [plugin]
							{ remaining = true }, -- name + desc
						},
					})

					local cmd_displayer = entry_display.create({
						separator = " ",
						items = {
							{ width = 8 }, -- [cmd]
							{ width = 20 }, -- command name
							{ remaining = true }, -- description/plugin
						},
					})

					local keymap_displayer = entry_display.create({
						separator = "",
						items = {
							{ width = 9 }, -- "[keymap] "
							{ width = 1 }, -- "["
							{ width = 1 }, -- n
							{ width = 1 }, -- v
							{ width = 1 }, -- i
							{ width = 1 }, -- o
							{ width = 1 }, -- s
							{ width = 2 }, -- "] "
							{ width = 15 }, -- key combo
							{ remaining = true }, -- description
						},
					})

					return function(entry)
						if entry.type == "plugin" then
							return {
								value = entry,
								display = function()
									return plugin_displayer({
										{ "[plugin]", "TelescopeResultsIdentifier" },
										entry.plugin .. "  " .. (entry.desc or ""),
									})
								end,
								ordinal = entry.ordinal or entry.display,
							}
						elseif entry.type == "command" then
							local desc = entry.plugin and (entry.plugin .. "  " .. entry.desc) or entry.desc or ""
							return {
								value = entry,
								display = function()
									return cmd_displayer({
										{ "[cmd]", "DiagnosticWarn" },
										{ ":" .. (entry.command_name or ""), "TelescopeResultsSpecialComment" },
										desc,
									})
								end,
								ordinal = entry.ordinal or entry.display,
							}
						else

							local mode = entry.mode or "_____"
							local function char_hl(idx)
								local ch = mode:sub(idx, idx)
								return ch == "_" and INACTIVE_HL or (MODE_HL[ch] or INACTIVE_HL)
							end

							return {
								value = entry,
								display = function()
									return keymap_displayer({
										{ "[keymap]", "TelescopeResultsComment" },
										{ "[", "Comment" },
										{ mode:sub(1, 1), char_hl(1) },
										{ mode:sub(2, 2), char_hl(2) },
										{ mode:sub(3, 3), char_hl(3) },
										{ mode:sub(4, 4), char_hl(4) },
										{ mode:sub(5, 5), char_hl(5) },
										{ "]", "Comment" },
										{ entry.key or "", "TelescopeResultsSpecialComment" },
										entry.desc or "",
									})
								end,
								ordinal = entry.ordinal or entry.display,
							}
						end
					end
				end)(),
			}),
			sorter = conf.generic_sorter({}),
			previewer = make_previewer(),
			attach_mappings = function(prompt_bufnr, map)
				actions.select_default:replace(function()
					local selection = require("telescope.actions.state").get_selected_entry()
					actions.close(prompt_bufnr)
					if selection then
						local e = selection.value
						if e.type == "keymap" then
							local keys = vim.api.nvim_replace_termcodes(e.key, true, false, true)
							vim.api.nvim_feedkeys(keys, "m", false)
						elseif e.type == "command" and e.command_name then
							if e.nargs == "0" then -- nargs is a string from nvim_get_commands
								vim.cmd[e.command_name]()
							else
								-- Open command line with the command pre-filled so user can add args
								vim.api.nvim_feedkeys(":" .. e.command_name .. " ", "n", false)
							end
						end
					end
				end)
				return true
			end,
		})
		:find()
end

return M
