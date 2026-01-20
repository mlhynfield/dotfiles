return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { "antosha417/nvim-lsp-file-operations", config = true },
  },
  event = { "BufReadPre", "BufNewFile" },
  opts = {
    servers = {
      ["*"] = {
        keys = {
          { "<leader>rs", "<cmd>LspRestart<CR>", desc = "Restart LSP" },
        },
      },
      rust_analyzer = {
        filetypes = { "rust", "rs" },
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
      helm_ls = {
        settings = {
          ["helm-ls"] = {
            yamlls = {
              enabled = true,
              config = {
                validate = true,
                schemas = {
                  [require("kubernetes").yamlls_schema()] = "templates/**",
                },
                schemaStore = {
                  enable = false,
                  url = "",
                },
              },
            },
          },
        },
      },
      yamlls = {
        settings = {
          yaml = {
            format = { enable = false },
            schemas = {
              [require("kubernetes").yamlls_schema()] = require("kubernetes").yamlls_filetypes(),
            },
            validate = true,
          },
        },
      },
    },
  },
}
