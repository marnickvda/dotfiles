local M = {}

M.mode_order = { "n", "x", "o", "i" }

M.parts = {
    { id = "commands", title = "COMMANDS (leader / localleader)" },
    { id = "text", title = "TEXT MANIPULATION" },
}

M.categories = {
    { title = "Language actions", prefix = "<localleader>" },
    { title = "Navigation (LSP)", keys = { "gd", "gD", "gi", "go", "gr", "K", "gK" }, modes = { "n" } },
    { title = "Edit / LSP actions", prefix = "<leader>m", group = true },
    {
        title = "Edit text",
        part = "text",
        keys = { "<leader>pa", "<leader>pA", "J", "K", "<leader>s", "<leader>S", "<C-A>", "<C-C>", "<C-S>", "<C-V>", "<C-X>" },
    },
    { title = "Text objects (after d c y v)", part = "text", pattern = "^[ailr][%w=]$", modes = { "x", "o" } },
    { title = "Surround", part = "text", prefix = "gs" },
    { title = "Jump", part = "text", keys = { "s", "S", "r", "R" }, pattern = "^[%[%]]" },
    { title = "Symbols & diagnostics", prefix = "<leader>l", group = true },
    { title = "Tests", prefix = "<leader>t", group = true },
    { title = "Debug", prefix = "<leader>d", group = true },
    { title = "Find / file", prefix = "<leader>f", group = true },
    { title = "Git", prefix = "<leader>g", group = true },
    { title = "Sessions", prefix = "<leader>q", group = true },
    { title = "Windows & panes", keys = { "<C-H>", "<C-J>", "<C-K>", "<C-L>", "<C-Bslash>" } },
    { title = "Other", prefix = "<leader>", modes = { "n" } },
}

-- Built-in Vim editing commands: no keymap object exists for these, so they are listed by hand.
M.essentials = {
    { lhs = "ciw  caw", desc = "Change inner / around word" },
    { lhs = 'ci"  ca(  cit', desc = "Change inside quotes / around parens / inside tag" },
    { lhs = "dap  yip", desc = "Delete around / yank inner paragraph" },
    { lhs = "dd  yy  cc", desc = "Delete / yank / change line" },
    { lhs = "D  C  Y", desc = "Delete / change / yank to end of line" },
    { lhs = "dt{c}  df{c}", desc = "Delete until / through character {c}" },
    { lhs = ".", desc = "Repeat last change" },
    { lhs = "u  <C-r>", desc = "Undo / redo" },
    { lhs = "~  gU{m}  gu{m}", desc = "Toggle case / uppercase / lowercase over motion" },
    { lhs = ">>  <<  ={m}", desc = "Indent / dedent / auto-indent over motion" },
    { lhs = "gJ", desc = "Join lines without adding a space" },
    { lhs = "*  #", desc = "Search word under cursor forward / backward" },
    { lhs = "cgn  then .", desc = "Change next search match, repeat on the next ones" },
    { lhs = "q{r} … q  @{r}  @@", desc = "Record macro into {r} / play it / replay last" },
    { lhs = "v  V  <C-q>", desc = "Visual char / line / block (<C-v> is remapped to paste)" },
    { lhs = "gv  o", desc = "Reselect last selection / jump to other end of selection" },
    { lhs = "cl", desc = "Substitute character (s is Flash)" },
}

function M.which_key_groups()
    local spec = {}
    for _, category in ipairs(M.categories) do
        if category.group then
            table.insert(spec, { category.prefix, group = category.title })
        end
    end
    return spec
end

local function readable(lhs)
    local leader = vim.g.mapleader or "\\"
    local localleader = vim.g.maplocalleader or "\\"
    if lhs:sub(1, #localleader) == localleader and localleader ~= leader then
        return "<localleader>" .. lhs:sub(#localleader + 1)
    end
    if lhs:sub(1, #leader) == leader then
        local rest = lhs:sub(#leader + 1)
        return "<leader>" .. (rest == leader and "<leader>" or rest)
    end
    return (lhs:gsub(" ", "<Space>"))
end

local function only_modes(entry_modes, allowed)
    for mode in pairs(entry_modes) do
        if not vim.tbl_contains(allowed, mode) then
            return false
        end
    end
    return true
end

local function category_for(entry)
    for _, category in ipairs(M.categories) do
        local matches = (category.keys and vim.tbl_contains(category.keys, entry.lhs))
            or (category.prefix and entry.lhs:sub(1, #category.prefix) == category.prefix)
            or (category.pattern and entry.lhs:match(category.pattern))
        if matches and (not category.modes or only_modes(entry.modes, category.modes)) then
            return category.title
        end
    end
end

local function mode_label(modes)
    local list = vim.tbl_filter(function(mode)
        return modes[mode]
    end, M.mode_order)
    if #list == 1 and list[1] == "n" then
        return ""
    end
    return table.concat(list, " ")
end

-- maps: list of { lhs, desc, mode = "n"|"x"|"o"|"i", buffer = bool }.
-- A buffer-local map hides a global one with the same key and mode.
function M.sections(maps)
    local winners = {}
    for _, map in ipairs(maps) do
        local slot = map.lhs .. "\0" .. (map.mode or "n")
        if not winners[slot] or map.buffer then
            winners[slot] = map
        end
    end

    local entries = {}
    for _, map in pairs(winners) do
        if map.desc and map.desc ~= "" then
            local lhs = readable(map.lhs)
            local id = lhs .. "\0" .. map.desc
            entries[id] = entries[id] or { lhs = lhs, desc = map.desc, modes = {} }
            entries[id].modes[map.mode or "n"] = true
        end
    end

    local grouped = {}
    for _, entry in pairs(entries) do
        local title = category_for(entry)
        if title then
            entry.mode = mode_label(entry.modes)
            entry.modes = nil
            grouped[title] = grouped[title] or {}
            table.insert(grouped[title], entry)
        end
    end

    local sections = {}
    for _, category in ipairs(M.categories) do
        local list = grouped[category.title]
        if list then
            table.sort(list, function(a, b)
                if a.lhs:lower() ~= b.lhs:lower() then
                    return a.lhs:lower() < b.lhs:lower()
                end
                if a.lhs ~= b.lhs then
                    return a.lhs < b.lhs
                end
                return a.desc < b.desc
            end)
            table.insert(sections, { title = category.title, part = category.part or "commands", entries = list })
        end
    end
    return sections
end

local function current_maps(buf)
    local maps = {}
    for _, mode in ipairs(M.mode_order) do
        for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
            table.insert(maps, { lhs = map.lhs, desc = map.desc, mode = mode })
        end
        for _, map in ipairs(vim.api.nvim_buf_get_keymap(buf, mode)) do
            table.insert(maps, { lhs = map.lhs, desc = map.desc, mode = mode, buffer = true })
        end
    end
    return maps
end

local function render_section(lines, section, width)
    table.insert(lines, "## " .. section.title)
    for _, entry in ipairs(section.entries) do
        local pad = string.rep(" ", width - vim.fn.strdisplaywidth(entry.lhs))
        local mode = (entry.mode and entry.mode ~= "") and ("  [" .. entry.mode .. "]") or ""
        table.insert(lines, "  " .. entry.lhs .. pad .. "  " .. entry.desc .. mode)
    end
    table.insert(lines, "")
end

function M.render(sections)
    local width = 0
    for _, section in ipairs(sections) do
        for _, entry in ipairs(section.entries) do
            width = math.max(width, vim.fn.strdisplaywidth(entry.lhs))
        end
    end

    local lines = { "Modes: n normal · x visual · o after an operator (d c y) · i insert", "" }
    for _, part in ipairs(M.parts) do
        local part_sections = vim.tbl_filter(function(section)
            return (section.part or "commands") == part.id
        end, sections)
        if #part_sections > 0 then
            table.insert(lines, "# " .. part.title)
            table.insert(lines, "")
        end
        for _, section in ipairs(part_sections) do
            render_section(lines, section, width)
        end
    end
    return lines
end

function M.open()
    local source = vim.api.nvim_get_current_buf()
    local filetype = vim.bo[source].filetype
    local sections = M.sections(current_maps(source))
    table.insert(sections, { title = "Vim essentials (built-in)", part = "text", entries = M.essentials })
    local lines = M.render(sections)

    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    vim.bo[buf].modifiable = false
    vim.bo[buf].filetype = "markdown"

    local width = math.min(100, vim.o.columns - 4)
    local height = math.min(#lines, vim.o.lines - 6)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = math.floor((vim.o.lines - height) / 2),
        col = math.floor((vim.o.columns - width) / 2),
        border = "rounded",
        title = " Keymaps" .. (filetype ~= "" and (" · " .. filetype) or "") .. " ",
        title_pos = "center",
        footer = " q / <Esc> to close · / to search ",
        footer_pos = "center",
    })
    vim.wo[win].wrap = false
    vim.wo[win].number = false
    vim.wo[win].relativenumber = false

    for _, key in ipairs({ "q", "<Esc>" }) do
        vim.keymap.set("n", key, function()
            vim.api.nvim_win_close(win, true)
        end, { buffer = buf, nowait = true })
    end
end

return M
