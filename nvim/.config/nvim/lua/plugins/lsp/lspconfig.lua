return {
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<leader>rs", "<cmd>LspRestart<CR>", desc = "Restart LSP" },
        },
      },
      lua_ls = {
        settings = {
          Lua = {
            -- make the language server recognize "vim" global
            diagnostics = {
              globals = { "vim" },
            },
          },
        },
      },
      nil_ls = {
        settings = {
          ["nil"] = {
            nix = {
              flake = {
                autoArchive = false,
              },
            },
          },
        },
      },
      helm_ls = {
        settings = {
          ["helm-ls"] = {
            yamlls = {
              enabled = true,
              config = {
                schemas = {},
                validate = true,
              },
            },
          },
        },
      },
    },
  },
}
