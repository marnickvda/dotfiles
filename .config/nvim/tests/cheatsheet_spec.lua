local cheatsheet = require("marnickvda.cheatsheet")

local function titles(sections)
    return vim.tbl_map(function(s) return s.title end, sections)
end

local function section(sections, title)
    for _, s in ipairs(sections) do
        if s.title == title then
            return s.entries
        end
    end
end

describe("keymap cheatsheet", function()
    before_each(function()
        vim.g.mapleader = " "
        vim.g.maplocalleader = "\\"
    end)

    it("groups keys into categories in a fixed order", function()
        local sections = cheatsheet.sections({
            { lhs = " tt", desc = "Test: nearest" },
            { lhs = "gd", desc = "Go to definition", buffer = true },
            { lhs = "\\t", desc = "Go: add json tags", buffer = true },
            { lhs = " db", desc = "Debug: toggle breakpoint" },
        })
        assert.same({ "Language actions", "Navigation (LSP)", "Tests", "Debug" }, titles(sections))
    end)

    it("shows leader keys readably", function()
        local entries = section(cheatsheet.sections({ { lhs = " mr", desc = "Code actions" } }), "Edit / LSP actions")
        assert.same({ { lhs = "<leader>mr", desc = "Code actions", mode = "" } }, entries)
    end)

    it("shows <leader><leader> instead of a bare <leader>", function()
        local entries = section(cheatsheet.sections({ { lhs = "  ", desc = "Reload Neovim config" } }), "Other")
        assert.equals("<leader><leader>", entries[1].lhs)
    end)

    it("lists the tmux navigator keys under Windows & panes", function()
        local entries = section(cheatsheet.sections({
            { lhs = "<C-H>", desc = "Move left" },
            { lhs = "<C-Bslash>", desc = "Move to previous" },
        }), "Windows & panes")
        assert.equals(2, #entries)
    end)

    it("spells out a literal space in non-leader keys", function()
        local entries = section(cheatsheet.sections({ { lhs = "[ ", desc = "Add empty line above cursor" } }), "Jump")
        assert.equals("[<Space>", entries[1].lhs)
    end)

    it("skips keys without a description, like plugin internals", function()
        assert.same({}, cheatsheet.sections({ { lhs = " x", desc = nil }, { lhs = "gd", desc = "" } }))
    end)

    it("prefers the buffer-local description over a global one", function()
        local entries = section(cheatsheet.sections({
            { lhs = "gd", desc = "global", buffer = false },
            { lhs = "gd", desc = "buffer", buffer = true },
        }), "Navigation (LSP)")
        assert.equals("buffer", entries[1].desc)
    end)

    it("puts uncategorised leader keys under Other and ignores unrelated keys", function()
        local sections = cheatsheet.sections({
            { lhs = " u", desc = "Toggle Undotree" },
            { lhs = "Q", desc = "Disable Ex mode" },
        })
        assert.same({ "Other" }, titles(sections))
    end)

    it("merges one key across modes and labels non-normal modes", function()
        local entries = section(cheatsheet.sections({
            { lhs = "s", desc = "Flash", mode = "n" },
            { lhs = "s", desc = "Flash", mode = "x" },
            { lhs = "s", desc = "Flash", mode = "o" },
        }), "Jump")
        assert.same({ { lhs = "s", desc = "Flash", mode = "n x o" } }, entries)
    end)

    it("lists treesitter text objects, which only exist in visual and operator mode", function()
        local entries = section(cheatsheet.sections({
            { lhs = "am", desc = "Select outer function", mode = "x" },
            { lhs = "am", desc = "Select outer function", mode = "o" },
        }), "Text objects (after d c y v)")
        assert.same({ { lhs = "am", desc = "Select outer function", mode = "x o" } }, entries)
    end)

    it("keeps hover on K and moving lines on visual K in separate sections", function()
        local sections = cheatsheet.sections({
            { lhs = "K", desc = "LSP: Hover documentation", mode = "n", buffer = true },
            { lhs = "K", desc = "Move selected lines up", mode = "x" },
        })
        assert.equals("LSP: Hover documentation", section(sections, "Navigation (LSP)")[1].desc)
        assert.equals("Move selected lines up", section(sections, "Edit text")[1].desc)
    end)

    it("does not treat Octo's <leader>pr as a text edit", function()
        local sections = cheatsheet.sections({
            { lhs = " pr", desc = "Octo: list PRs" },
            { lhs = " pa", desc = "Swap parameter with next" },
        })
        assert.equals("Octo: list PRs", section(sections, "Other")[1].desc)
        assert.equals("Swap parameter with next", section(sections, "Edit text")[1].desc)
    end)

    it("renders commands first and text manipulation second, even when text keys are leader keys", function()
        local lines = cheatsheet.render(cheatsheet.sections({
            { lhs = " s", desc = "Replace word under cursor" },
            { lhs = " tt", desc = "Test: nearest" },
            { lhs = "am", desc = "Select outer function", mode = "o" },
        }))
        local headings = vim.tbl_filter(function(line) return line:match("^#") end, lines)
        assert.same({
            "# COMMANDS (leader / localleader)",
            "## Tests",
            "# TEXT MANIPULATION",
            "## Edit text",
            "## Text objects (after d c y v)",
        }, headings)
    end)

    it("derives which-key groups from the categories", function()
        local spec = cheatsheet.which_key_groups()
        assert.same({ "<leader>t", group = "Tests" }, spec[3])
        assert.is_nil(vim.iter(spec):find(function(s) return s[1] == "<leader>" end))
    end)
end)
