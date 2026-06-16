-- nvim-treesitter MAIN branch — required for Neovim 0.12+.
-- The legacy `master` branch was archived 2026-04-03 (locked at Neovim 0.11)
-- and is a completely different API. See main-branch README before editing.

local ensure_installed = {
    "bash",
    "vimdoc",
    "c",
    "lua",
    "rust",
    "go",
    "gomod",
    "gowork",
    "gosum",
    "gotmpl",
    "javascript",
    "jsdoc",
    "typescript",
    "tsx",
    "html",
    "css",
    "json",
    "yaml",
    "gitignore",
    "dockerfile",
    "vim",
    "markdown",
    "markdown_inline",
    "ron",
    "terraform",
}

local ts_filetypes = {
    "bash",
    "sh",
    "help",
    "c",
    "lua",
    "rust",
    "go",
    "gomod",
    "gowork",
    "gosum",
    "gotmpl",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "html",
    "css",
    "json",
    "yaml",
    "gitignore",
    "dockerfile",
    "vim",
    "markdown",
    "ron",
    "terraform",
    "terraform-vars",
}

return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false, -- main branch does not support lazy-loading
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                install_dir = vim.fn.stdpath("data") .. "/site",
            })

            require("nvim-treesitter").install(ensure_installed)

            local hl_group = vim.api.nvim_create_augroup("UserTreesitterHighlight", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = hl_group,
                pattern = ts_filetypes,
                callback = function(args)
                    local ft = vim.bo[args.buf].filetype

                    if ft == "html" then
                        return
                    end

                    local max_filesize = 500 * 1024
                    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(args.buf))
                    if ok and stats and stats.size > max_filesize then
                        vim.notify(
                            "File >500KB: Treesitter disabled",
                            vim.log.levels.WARN,
                            { title = "Treesitter" }
                        )
                        return
                    end

                    local lang = vim.treesitter.language.get_lang(ft)
                    if not lang or not pcall(vim.treesitter.language.add, lang) then
                        return
                    end

                    pcall(vim.treesitter.start, args.buf, lang)

                    if ft == "markdown" then
                        vim.bo[args.buf].syntax = "ON"
                    end
                end,
            })

            local indent_group = vim.api.nvim_create_augroup("UserTreesitterIndent", { clear = true })
            vim.api.nvim_create_autocmd("FileType", {
                group = indent_group,
                pattern = ts_filetypes,
                callback = function(args)
                    local lang = vim.treesitter.language.get_lang(vim.bo[args.buf].filetype)
                    if not lang or not pcall(vim.treesitter.language.add, lang) then
                        return
                    end
                    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
