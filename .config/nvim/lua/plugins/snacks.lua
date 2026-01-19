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
      sources = {
        recent = {
          filter = {
            paths = false,
          },
        },
      },
    },
    scroll = {
      enabled = false,
    },
    styles = {
      lazygit = {
        border = true,
      },
    },
  },
}
