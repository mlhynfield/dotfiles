return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      yaml = { "yamlfix" },
    },
    formatters = {
      yamlfix = {
        env = {
          YAMLFIX_PRESERVE_QUOTES = "true",
          YAMLFIX_COMMENTS_WHITELINES = "1",
          YAMLFIX_WHITELINES = "1",
        },
      },
    },
  },
}
