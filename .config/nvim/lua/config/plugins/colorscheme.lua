return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      integrations = {
        copilot_vim = true,
        lsp_trouble = true,
        mason = true,
        which_key = true,
      }
    })
    vim.cmd([[colorscheme catppuccin-macchiato]])
  end
}
