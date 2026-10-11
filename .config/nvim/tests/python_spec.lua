local python = require("marnickvda.python")

local function project(files)
    local root = vim.fn.tempname()
    for path, content in pairs(files) do
        local full = vim.fs.joinpath(root, path)
        vim.fn.mkdir(vim.fs.dirname(full), "p")
        vim.fn.writefile(vim.split(content, "\n"), full)
        if path:match("bin/python$") then
            vim.fn.setfperm(full, "rwxr-xr-x")
        end
    end
    return root
end

describe("python project helpers", function()
    it("finds a venv named ve, as created by the airflow Makefile", function()
        local root = project({ ["ve/bin/python"] = "#!/bin/sh" })
        assert.equals(root .. "/ve/bin/python", python.venv_python(root))
    end)

    it("prefers .venv over other venv names", function()
        local root = project({ [".venv/bin/python"] = "#!/bin/sh", ["ve/bin/python"] = "#!/bin/sh" })
        assert.equals(root .. "/.venv/bin/python", python.venv_python(root))
    end)

    it("returns nil without a venv or VIRTUAL_ENV", function()
        local saved = vim.env.VIRTUAL_ENV
        vim.env.VIRTUAL_ENV = nil
        assert.is_nil(python.venv_python(project({ ["requirements.txt"] = "" })))
        vim.env.VIRTUAL_ENV = saved
    end)

    it("reads pythonpath entries from pytest.ini", function()
        local root = project({ ["pytest.ini"] = "[pytest]\npythonpath = . dags\n\nenv =\n    ENVIRONMENT=dev" })
        assert.same({ ".", "dags" }, python.pytest_paths(root))
    end)

    it("returns no paths without pytest.ini", function()
        assert.same({}, python.pytest_paths(project({ ["requirements.txt"] = "" })))
    end)
end)
