return {
  "craftzdog/solarized-osaka.nvim",
  lazy = false,
  priority = 1000,
  config = function()
    require("solarized-osaka").setup({
      styles = {
        floats = "transparent",
        sidebars = "transparent",
      },
    })
    vim.cmd([[colorscheme solarized-osaka]])
  end,
}
