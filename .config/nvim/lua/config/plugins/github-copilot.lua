return {
  "zbirenbaum/copilot.lua",
  cmd = "Copilot",
  event = "InsertEnter",
  config = function()
    require("copilot").setup({
      filetypes = {
        yaml = true,
        markdown = true,
      },
      suggestion = {
        auto_trigger = true,
        keymap = {
          accept = "<Tab>",
          accept_word = "<S-Tab>",
          accept_line = "<M-Tab>",
        },
      },
    })
  end,
}
