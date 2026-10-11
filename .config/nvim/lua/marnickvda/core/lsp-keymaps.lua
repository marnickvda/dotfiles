local M = {}

function M.peek_inlay_hints(buf)
    if vim.lsp.inlay_hint.is_enabled({ bufnr = buf }) then
        return
    end
    vim.lsp.inlay_hint.enable(true, { bufnr = buf })
    local group = vim.api.nvim_create_augroup("InlayHintPeek" .. buf, { clear = true })
    vim.api.nvim_create_autocmd({ "CursorMoved", "InsertEnter", "BufLeave", "WinScrolled" }, {
        group = group,
        buffer = buf,
        callback = function()
            vim.api.nvim_del_augroup_by_id(group)
            vim.lsp.inlay_hint.enable(false, { bufnr = buf })
        end,
    })
end

function M.setup_keymaps(event)
    local telescope = require("telescope.builtin")
    local buf = event.buf

    local function map(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc })
    end

    map("K", vim.lsp.buf.hover, "LSP: Hover documentation")
    map("gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
    map("gd", telescope.lsp_definitions, "LSP: Go to definition")
    map("gi", telescope.lsp_implementations, "LSP: Go to implementation")
    map("go", telescope.lsp_type_definitions, "LSP: Go to type definition")
    map("gr", telescope.lsp_references, "LSP: Go to references")
    map("gK", vim.lsp.buf.signature_help, "LSP: Signature help")

    map("<leader>mR", function()
        vim.lsp.buf.code_action({ apply = true })
    end, "Apply first code action")
    map("<leader>mi", function()
        vim.lsp.buf.code_action({ context = { only = { "source.organizeImports" } }, apply = true })
    end, "Organize imports")
    map("<leader>mn", vim.lsp.buf.rename, "Rename symbol")
    map("<leader>mr", vim.lsp.buf.code_action, "Code actions")
    map("<leader>mc", vim.lsp.codelens.run, "Run code lens")
    map("<leader>mh", function()
        M.peek_inlay_hints(buf)
    end, "Peek inlay hints (until cursor moves)")
    map("<leader>mH", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = buf }), { bufnr = buf })
    end, "Toggle inlay hints")

    local client = vim.lsp.get_client_by_id(event.data.client_id)
    if client and client:supports_method("textDocument/codeLens") then
        vim.lsp.codelens.enable(true, { bufnr = buf })
    end
end

return M
