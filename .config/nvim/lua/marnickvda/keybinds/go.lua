vim.api.nvim_create_autocmd("FileType", {
    pattern = "go",
    group = vim.api.nvim_create_augroup("GoKeybinds", { clear = true }),
    callback = function()
        local function map(mode, lhs, rhs, desc)
            vim.keymap.set(mode, "<localleader>" .. lhs, rhs, { buffer = true, desc = desc })
        end

        map("n", "ee", "oif err != nil {<CR>}<Esc>Oreturn err<Esc>", "Go: if err return")
        map("n", "ea", 'oassert.NoError(err, "")<Esc>F";a', "Go: assert.NoError")
        map("n", "ef", 'oif err != nil {<CR>}<Esc>Olog.Fatalf("error: %s\\n", err.Error())<Esc>jj', "Go: if err log.Fatalf")
        map("n", "el", 'oif err != nil {<CR>}<Esc>O.logger.Error("error", "error", err)<Esc>F.;i', "Go: if err logger.Error")
        map("n", "ex", "<cmd>GoIfErr<CR>", "Go: if err (iferr)")

        map({ "n", "x" }, "t", ":GoTagAdd json<CR>", "Go: add json tags")
        map({ "n", "x" }, "T", ":GoTagAdd ", "Go: add tags (prompt)")
        map({ "n", "x" }, "r", ":GoTagRm ", "Go: remove tags (prompt)")
        map("n", "i", ":GoImpl ", "Go: implement interface (prompt)")
        map("n", "u", "<cmd>GoTestAdd<CR>", "Go: generate test for func")
        map("n", "U", "<cmd>GoTestsAll<CR>", "Go: generate tests for file")
        map("n", "c", "<cmd>GoCmt<CR>", "Go: doc comment")
        map("n", "m", "<cmd>!go mod tidy<CR>", "Go: mod tidy")
        map("n", "f", "<cmd>!go fix ./...<CR>", "Go: go fix (modernizers)")
    end,
})
