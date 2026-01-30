vim.filetype.add({
  extension = {
    env = "dotenv",
  },
  filename = {
    [".env"] = "dotenv",
  },
  pattern = {
    ["%.env%.[%w_.-]+"] = "dotenv",
    ["%.gitconfig%.[%w_.-]+"] = "gitconfig",
    [".*/hypr/.+%.conf"] = "hyprlang",
    [".*/waybar/config"] = "jsonc",
  },
})
vim.treesitter.language.register("bash", "dotenv")
