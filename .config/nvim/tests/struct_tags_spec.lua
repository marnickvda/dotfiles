local tags = require("marnickvda.go.struct_tags")

local function labels(line)
    local out = {}
    for _, item in ipairs(tags.items(line)) do
        out[item.label] = item
    end
    return out
end

describe("struct tag completion", function()
    it("ignores lines outside a struct tag", function()
        assert.is_nil(tags.context("    UserID int"))
        assert.is_nil(tags.context('fmt.Println("x")'))
        assert.is_nil(tags.context("    UserID int `json:\"user_id\"` "))
    end)

    it("offers tag keys with the field name prefilled after the opening backtick", function()
        local items = labels("    UserID int `")
        assert.equals('json:"${1:user_id}"$0', items.json.insertText)
        assert.equals('gorm:"${1:}"$0', items.gorm.insertText)
        assert.equals('env:"${1:USER_ID}"$0', items.env.insertText)
    end)

    it("offers a second key after a completed tag", function()
        assert.is_not_nil(labels('    Name string `json:"name" ').gorm)
    end)

    it("offers snake and camel names as the first json value", function()
        local items = labels('    CreatedAt time.Time `json:"')
        assert.is_not_nil(items.created_at)
        assert.is_not_nil(items.createdAt)
        assert.is_nil(items.omitempty)
    end)

    it("splits acronyms in field names", function()
        assert.same({ "http_server_url", "httpServerUrl" }, tags.name_variants("HTTPServerURL"))
        assert.same({ "id" }, tags.name_variants("ID"))
    end)

    it("offers json options after the name", function()
        local items = labels('    Email string `json:"email,')
        assert.is_not_nil(items.omitempty)
        assert.is_not_nil(items.omitzero)
        assert.is_nil(items.email)
    end)

    it("offers gorm options immediately and after a semicolon", function()
        assert.is_not_nil(labels('    ID uint `gorm:"').primaryKey)
        assert.is_not_nil(labels('    ID uint `gorm:"primaryKey;').autoIncrement)
    end)

    it("offers validate rules after a comma", function()
        assert.is_not_nil(labels('    Email string `json:"email" validate:"required,').email)
    end)

    it("returns nothing for unknown tag keys", function()
        assert.same({}, tags.items('    X int `custom:"'))
    end)
end)
