return {
  "zbirenbaum/copilot.lua",
  opts = {
    suggestion = {
      keymap = {
        accept = "<Tab>",
        accept_word = "<S-Tab>",
        accept_line = "<M-Tab>",
      },
    },
    filetypes = {
      yaml = true,
      markdown = true,
    },
  },
}
