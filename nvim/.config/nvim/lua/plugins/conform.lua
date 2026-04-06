return {
  "stevearc/conform.nvim",
  opts = {
    formatters_by_ft = {
      yaml = { "yamlfix" },
    },
    formatters = {
      yamlfix = {
        env = {
          YAMLFIX_WHITELINES = "1",
          YAMLFIX_COMMENTS_WHITELINES = "1",
          YAMLFIX_SEQUENCE_STYLE = "keep_style",
          YAMLFIX_PRESERVE_QUOTES = "true",
        },
      },
    },
  },
}
