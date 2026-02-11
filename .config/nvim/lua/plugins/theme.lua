return {
  {
    'folke/tokyonight.nvim',
    lazy = false,
    priority = 1000,
    opts = {
      dim_inactive = true,
    },
    init = function()
      vim.cmd.colorscheme('tokyonight-moon')
    end,
  },
}
