return {
  "folke/which-key.nvim",
  event = "VeryLazy",
  init = function()
    vim.o.timeout = true
    vim.o.timeoutlen = 500
  end,
  opts = {
    spec = {
      { "<leader>h", group = "git hunk" },
      { "<leader>r", group = "lsp actions" },
      { "<leader>y", group = "yazi" },
    },
  },
}
