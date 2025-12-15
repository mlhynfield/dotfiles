return {
  "nvim-lualine/lualine.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status") -- to configure lazy pending updates count

    lualine.setup({
      options = {
        theme = "catppuccin-macchiato",
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#f3f99d" },
          },
          { "encoding" },
          { "fileformat" },
          { "filetype" },
          {
            function()
              return ("%s"):format(require("schema-companion.context").get_buffer_schema().name)
            end,
            cond = function()
              return package.loaded["schema-companion"]
            end,
          },
        },
      },
    })
  end
}
