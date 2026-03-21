return {
  "skill-issue",
  name = "skill-issue",
  dir = vim.fn.stdpath("config") .. "/skill-issue",
  dependencies = { "nvim-telescope/telescope.nvim" },
  keys = {
    { "<leader>huh", function() require("skill-issue").pick() end, desc = "Skill Issue: fuzzy search plugins & keymaps" },
  },
  config = function()
    require("skill-issue").setup()
  end,
}
