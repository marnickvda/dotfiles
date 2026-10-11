local keymaps = require("marnickvda.core.lsp-keymaps")

describe("inlay hint peek", function()
    local buf

    before_each(function()
        buf = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_set_current_buf(buf)
        vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "a", "b", "c" })
        vim.lsp.inlay_hint.enable(false, { bufnr = buf })
    end)

    it("shows hints until the cursor moves", function()
        keymaps.peek_inlay_hints(buf)
        assert.is_true(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))

        vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
        assert.is_false(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
    end)

    it("hides hints when entering insert mode", function()
        keymaps.peek_inlay_hints(buf)
        vim.api.nvim_exec_autocmds("InsertEnter", { buffer = buf })
        assert.is_false(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
    end)

    it("does not hide hints switched on permanently after a peek ended in insert mode", function()
        keymaps.peek_inlay_hints(buf)
        vim.api.nvim_exec_autocmds("InsertEnter", { buffer = buf })

        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
        assert.is_true(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
    end)

    it("leaves permanently enabled hints alone", function()
        vim.lsp.inlay_hint.enable(true, { bufnr = buf })
        keymaps.peek_inlay_hints(buf)
        vim.api.nvim_exec_autocmds("CursorMoved", { buffer = buf })
        assert.is_true(vim.lsp.inlay_hint.is_enabled({ bufnr = buf }))
    end)
end)
