return {
  "folke/snacks.nvim",
  opts = {
    indent = {
      indent = {
        enabled = true,
        char = "┊",
      },
    },
    picker = {
      hidden = true,
      sources = {
        explorer = {
          auto_close = true,
        },
        files = { hidden = true },
      },
    },
    scroll = { enabled = false },
    styles = {
      lazygit = { border = true },
    },
  },
}
