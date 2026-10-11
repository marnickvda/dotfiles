local M = {}

M.root_markers = { "pyproject.toml", "setup.py", "setup.cfg", "pytest.ini", "requirements.txt", ".python-version" }

function M.root(path)
    return vim.fs.root(path or 0, M.root_markers)
end

function M.venv_python(root)
    for _, name in ipairs({ ".venv", "venv", "ve", "env" }) do
        local python = vim.fs.joinpath(root, name, "bin", "python")
        if vim.fn.executable(python) == 1 then
            return python
        end
    end
    if vim.env.VIRTUAL_ENV then
        return vim.fs.joinpath(vim.env.VIRTUAL_ENV, "bin", "python")
    end
    return nil
end

function M.pytest_paths(root)
    local ok, lines = pcall(vim.fn.readfile, vim.fs.joinpath(root, "pytest.ini"))
    if not ok then
        return {}
    end
    for _, line in ipairs(lines) do
        local value = line:match("^%s*pythonpath%s*=%s*(.-)%s*$")
        if value then
            return vim.split(value, "%s+", { trimempty = true })
        end
    end
    return {}
end

return M
