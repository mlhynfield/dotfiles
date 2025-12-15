return {
  "mason-org/mason.nvim",
  dependencies = {
    "mason-org/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  config = function()
    -- import mason
    local mason = require("mason")

    -- import mason-lspconfig
    local mason_lspconfig = require("mason-lspconfig")

    local mason_tool_installer = require("mason-tool-installer")

    -- enable mason and configure icons
    mason.setup({
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    mason_lspconfig.setup({
      automatic_installation = true,
      -- list of servers for mason to install
      ensure_installed = {
        "helm_ls",
        "html",
        "cssls",
        "tailwindcss",
        "lua_ls",
        "pyright",
        "yamlls",
        "bashls",
        "ansiblels",
        "docker_compose_language_service",
        "dockerls",
        "gopls",
        "eslint",
        "jsonls",
        "marksman",
        "nginx_language_server",
        "sqls",
        "terraformls",
        "tflint",
        "textlsp",
        "ts_ls",
        "harper_ls",
        "vimls",
      },
    })

    mason_tool_installer.setup({
      ensure_installed = {
        "prettier", -- prettier formatter
        "stylua", -- lua formatter
        "isort", -- python formatter
        "black", -- python formatter
        "pylint", -- python linter
        "eslint_d", -- js linter
        "shellcheck", -- shell script formatter
        "tflint", -- terraform formatter
      },
    })
  end,
}
