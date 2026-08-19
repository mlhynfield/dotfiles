return {
  {
    "stevearc/conform.nvim",
    opts = {
      formatters_by_ft = {
        terraform = { "tofu_fmt" },
        tf = { "tofu_fmt" },
        ["terraform-vars"] = { "tofu_fmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    opts = function()
      local lint = require("lint")
      local build_linter = lint.linters.terraform_validate
      lint.linters.terraform_validate = function()
        local linter = build_linter()
        linter.cmd = "tofu"
        return linter
      end
    end,
  },
}
