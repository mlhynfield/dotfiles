-- set leader key to space
vim.g.mapleader = " "

local keymap = vim.keymap -- for conciseness

---------------------
-- General Keymaps -------------------

-- use jk to exit insert mode
keymap.set("i", "jk", "<ESC>", { desc = "Exit insert mode with jk" })

-- clear search highlights
keymap.set("n", "<leader>nh", ":nohl<CR>", { desc = "Clear search highlights" })

-- save file without formatting
keymap.set({ "i", "x", "n", "s" }, "<C-A-s>", "<cmd>noau w<CR><ESC>", { desc = "Save file without formatting" })
