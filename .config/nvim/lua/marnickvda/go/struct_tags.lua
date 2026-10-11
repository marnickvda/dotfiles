local M = {}

-- sep: option separator. named: the first value is the serialized field name.
M.tags = {
    json = { sep = ",", named = true, options = { "omitempty", "omitzero", "string", "-", "embed", "case:ignore", "case:strict" } },
    yaml = { sep = ",", named = true, options = { "omitempty", "inline", "flow", "-" } },
    xml = { sep = ",", named = true, options = { "attr", "chardata", "cdata", "innerxml", "comment", "omitempty", "any", "-" } },
    toml = { sep = ",", named = true, options = { "omitempty", "inline", "-" } },
    bson = { sep = ",", named = true, options = { "omitempty", "inline", "minsize", "truncate", "-" } },
    mapstructure = { sep = ",", named = true, options = { "squash", "omitempty", "remain", "-" } },
    db = { sep = ",", named = true, options = {} },
    form = { sep = ",", named = true, options = { "omitempty", "-" } },
    query = { sep = ",", named = true, options = {} },
    uri = { sep = ",", named = true, options = {} },
    header = { sep = ",", named = true, options = {} },
    env = { sep = ",", named = true, upper = true, options = { "required", "notEmpty", "file", "expand", "unset", "init" } },
    gorm = {
        sep = ";",
        named = false,
        options = {
            "column:", "type:", "size:", "primaryKey", "unique", "uniqueIndex", "index", "autoIncrement",
            "default:", "not null", "embedded", "embeddedPrefix:", "autoCreateTime", "autoUpdateTime",
            "foreignKey:", "references:", "constraint:", "many2many:", "serializer:json", "precision:",
            "scale:", "check:", "comment:", "<-", "->", "-",
        },
    },
    validate = {
        sep = ",",
        named = false,
        options = {
            "required", "omitempty", "dive", "email", "url", "uri", "uuid", "alpha", "alphanum", "numeric",
            "len=", "min=", "max=", "eq=", "ne=", "gt=", "gte=", "lt=", "lte=", "oneof=", "required_if=",
            "required_with=", "required_without=", "excluded_if=", "eqfield=", "nefield=", "datetime=",
            "ip", "ipv4", "ipv6", "hostname", "e164", "iso3166_1_alpha2", "boolean", "unique",
        },
    },
}
M.tags.binding = M.tags.validate

local function words(field)
    local out = {}
    for word in field:gsub("(%l)(%u)", "%1 %2"):gsub("(%u)(%u%l)", "%1 %2"):gmatch("%w+") do
        table.insert(out, word)
    end
    return out
end

function M.name_variants(field, upper)
    local parts = words(field)
    if #parts == 0 then
        return {}
    end
    local lower = vim.tbl_map(string.lower, parts)
    local snake = table.concat(lower, "_")
    if upper then
        return { snake:upper() }
    end
    local camel = lower[1]
    for i = 2, #lower do
        camel = camel .. lower[i]:sub(1, 1):upper() .. lower[i]:sub(2)
    end
    if camel == snake then
        return { snake }
    end
    return { snake, camel }
end

local function count(s, char)
    return select(2, s:gsub(char, ""))
end

-- Returns nil when the cursor is not inside a struct tag, otherwise
-- { kind = "key", field = ... } or { kind = "value", key = ..., first = bool, field = ... }.
function M.context(line_before)
    if count(line_before, "`") ~= 1 then
        return nil
    end
    local field, tag = line_before:match("^%s*([%u%l_][%w_]*)%s+[^`]-`(.*)$")
    if not field then
        return nil
    end
    if count(tag, '"') % 2 == 0 then
        return { kind = "key", field = field }
    end
    local key, value = tag:match('([%w_]+):"([^"]*)$')
    if not key then
        return nil
    end
    local spec = M.tags[key]
    local first = spec == nil or not value:find(spec.sep, 1, true)
    return { kind = "value", key = key, first = first, field = field }
end

function M.items(line_before)
    local ctx = M.context(line_before)
    if not ctx then
        return {}
    end
    local kinds = vim.lsp.protocol.CompletionItemKind
    local items = {}

    if ctx.kind == "key" then
        for key, spec in pairs(M.tags) do
            local name = spec.named and M.name_variants(ctx.field, spec.upper)[1] or ""
            table.insert(items, {
                label = key,
                kind = kinds.Property,
                insertText = string.format('%s:"${1:%s}"$0', key, name),
                insertTextFormat = 2,
            })
        end
        return items
    end

    local spec = M.tags[ctx.key]
    if not spec then
        return {}
    end
    if ctx.first and spec.named then
        for _, name in ipairs(M.name_variants(ctx.field, spec.upper)) do
            table.insert(items, { label = name, kind = kinds.Field })
        end
    end
    if not ctx.first or not spec.named then
        for _, option in ipairs(spec.options) do
            table.insert(items, { label = option, kind = kinds.EnumMember })
        end
    end
    return items
end

local source = {}

function source:is_available()
    return vim.bo.filetype == "go"
end

function source:get_trigger_characters()
    return { "`", '"', ",", ";", " " }
end

function source:get_keyword_pattern()
    return [[\%([a-zA-Z0-9_:=<>-]\)*]]
end

function source:complete(params, callback)
    callback({ items = M.items(params.context.cursor_before_line), isIncomplete = false })
end

function M.register()
    require("cmp").register_source("go_struct_tags", source)
end

return M
