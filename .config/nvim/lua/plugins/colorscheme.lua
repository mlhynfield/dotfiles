return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      require("catppuccin").setup({
        integrations = {
          copilot_vim = true,
          lsp_trouble = true,
          mason = true,
          notify = true,
          nvim_surround = true,
          snacks = {
            enabled = true,
          },
          which_key = true,
        }
      })
      vim.cmd([[colorscheme catppuccin-macchiato]])
    end
  },
  {
		"LazyVim/LazyVim",
		opts = {
			colorscheme = "catppuccin-macchiato",
		},
	},
}
