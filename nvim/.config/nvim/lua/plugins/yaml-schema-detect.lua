return {
  "cwrau/yaml-schema-detect.nvim",
  ---@module "yaml-schema-detect"
  ---@type YamlSchemaDetectOptions
  opts = {
    keymap = {
      refresh = "<leader>kr",
      cleanup = "<leader>kc",
      info = "<leader>ki",
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  ft = { "yaml", "helm" },
}
