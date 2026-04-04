-- Native treesitter parser management for nvim 0.12+
-- Add/remove languages by editing the `parsers` table below.

local M = {}

M.parsers = {
  "bash", "c", "css", "dockerfile", "gitignore",
  "go", "gomod", "gosum", "gotmpl", "gowork",
  "html", "javascript", "jsdoc", "json", "lua",
  "markdown", "ron", "rust", "terraform",
  "tsx", "typescript", "vim", "vimdoc", "yaml",
}

M.install_dir = vim.fn.stdpath("data") .. "/site/parser"

-- Overrides for repos that don't follow tree-sitter/tree-sitter-{lang}
M.registry = {
  dockerfile = { repo = "camdencheek/tree-sitter-dockerfile" },
  gitignore  = { repo = "shunsambongi/tree-sitter-gitignore" },
  gomod      = { repo = "camdencheek/tree-sitter-go-mod" },
  gosum      = { repo = "amaanq/tree-sitter-go-sum" },
  gotmpl     = { repo = "ngalaiko/tree-sitter-go-template" },
  gowork     = { repo = "omertuc/tree-sitter-go-work" },
  lua        = { repo = "MunifTanjim/tree-sitter-lua" },
  markdown   = { repo = "MDeiml/tree-sitter-markdown", subdir = "tree-sitter-markdown" },
  ron        = { repo = "amaanq/tree-sitter-ron" },
  terraform  = { repo = "MichaHoffmann/tree-sitter-hcl", subdir = "dialects/terraform" },
  tsx        = { repo = "tree-sitter/tree-sitter-typescript", subdir = "tsx" },
  typescript = { repo = "tree-sitter/tree-sitter-typescript", subdir = "typescript" },
  vim        = { repo = "neovim/tree-sitter-vim" },
  vimdoc     = { repo = "neovim/tree-sitter-vimdoc" },
  yaml       = { repo = "tree-sitter-grammars/tree-sitter-yaml" },
}

local function get_repo_url(lang)
  local entry = M.registry[lang]
  local repo = entry and entry.repo or ("tree-sitter/tree-sitter-" .. lang)
  return "https://github.com/" .. repo .. ".git"
end

local function get_subdir(lang)
  local entry = M.registry[lang]
  return entry and entry.subdir or nil
end

local function is_installed(lang)
  return vim.fn.filereadable(M.install_dir .. "/" .. lang .. ".so") == 1
end

local function build_compile_cmd(src_dir, output_path)
  local files = { src_dir .. "/parser.c" }
  local compiler = "cc"

  if vim.fn.filereadable(src_dir .. "/scanner.cc") == 1 then
    table.insert(files, src_dir .. "/scanner.cc")
    compiler = "c++"
  elseif vim.fn.filereadable(src_dir .. "/scanner.c") == 1 then
    table.insert(files, src_dir .. "/scanner.c")
  end

  local cmd = { compiler, "-shared", "-fPIC", "-O2", "-I" .. src_dir }
  for _, f in ipairs(files) do
    table.insert(cmd, f)
  end
  table.insert(cmd, "-o")
  table.insert(cmd, output_path)
  return cmd
end

function M.install(lang, opts)
  opts = opts or {}
  local url = get_repo_url(lang)
  local tmp_dir = vim.fn.tempname()
  local subdir = get_subdir(lang)

  vim.fn.mkdir(M.install_dir, "p")

  vim.system(
    { "git", "clone", "--depth", "1", "--quiet", url, tmp_dir },
    {},
    function(clone_result)
      if clone_result.code ~= 0 then
        if not opts.silent then
          vim.schedule(function()
            vim.notify("TS parser clone failed: " .. lang .. "\n" .. (clone_result.stderr or ""), vim.log.levels.ERROR)
          end)
        end
        vim.system({ "rm", "-rf", tmp_dir })
        return
      end

      local src_dir = tmp_dir .. (subdir and ("/" .. subdir) or "") .. "/src"
      local output_path = M.install_dir .. "/" .. lang .. ".so"
      local compile_cmd = build_compile_cmd(src_dir, output_path)

      vim.system(compile_cmd, {}, function(compile_result)
        vim.system({ "rm", "-rf", tmp_dir })

        if compile_result.code ~= 0 then
          if not opts.silent then
            vim.schedule(function()
              vim.notify("TS parser compile failed: " .. lang .. "\n" .. (compile_result.stderr or ""), vim.log.levels.ERROR)
            end)
          end
        else
          vim.schedule(function()
            vim.treesitter.language.add(lang)
            if opts.on_success then opts.on_success() end
          end)
        end
      end)
    end
  )
end

function M.ensure_installed()
  for _, lang in ipairs(M.parsers) do
    if not is_installed(lang) then
      M.install(lang, { silent = true })
    end
  end
end

function M.update_all()
  local count = #M.parsers
  local done = 0
  vim.notify("Updating " .. count .. " treesitter parsers...", vim.log.levels.INFO)

  for _, lang in ipairs(M.parsers) do
    M.install(lang, {
      on_success = function()
        done = done + 1
        if done == count then
          vim.notify("All " .. count .. " parsers updated.", vim.log.levels.INFO)
        end
      end,
    })
  end
end

function M.clean()
  local installed = vim.fn.glob(M.install_dir .. "/*.so", false, true)
  local wanted = {}
  for _, lang in ipairs(M.parsers) do
    wanted[lang] = true
  end

  local removed = 0
  for _, path in ipairs(installed) do
    local name = vim.fn.fnamemodify(path, ":t:r")
    if not wanted[name] then
      vim.fn.delete(path)
      removed = removed + 1
    end
  end

  vim.notify("Removed " .. removed .. " unused parser(s).", vim.log.levels.INFO)
end

local function setup_highlighting()
  vim.api.nvim_create_autocmd("FileType", {
    group = vim.api.nvim_create_augroup("NativeTreesitter", { clear = true }),
    callback = function(ev)
      if vim.treesitter.language.add(vim.bo[ev.buf].filetype) then
        vim.treesitter.start(ev.buf)
      end
    end,
  })
end

local function setup_commands()
  vim.api.nvim_create_user_command("ParserInstall", function(cmd)
    for _, lang in ipairs(cmd.fargs) do
      M.install(lang)
    end
  end, { nargs = "+", desc = "Install treesitter parser(s)" })

  vim.api.nvim_create_user_command("ParserUpdate", function()
    M.update_all()
  end, { nargs = 0, desc = "Update all treesitter parsers" })

  vim.api.nvim_create_user_command("ParserClean", function()
    M.clean()
  end, { nargs = 0, desc = "Remove parsers not in the list" })
end

local function setup()
  setup_highlighting()
  setup_commands()

  vim.api.nvim_create_autocmd("VimEnter", {
    group = vim.api.nvim_create_augroup("TreesitterEnsureInstalled", { clear = true }),
    callback = function()
      M.ensure_installed()
    end,
  })
end

setup()

return M
