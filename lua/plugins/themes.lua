return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {},
    config = function()
      vim.cmd.colorscheme 'tokyonight-night'
    end
  },
  { "nyoom-engineering/oxocarbon.nvim", name = 'oxocarbon' },
  { 'rafamadriz/neon',                  name = 'neon' },
  { "catppuccin/nvim",                  name = "catppuccin" },
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    priority = 1000,
    --  config = function()
    --    vim.cmd.colorscheme 'onedark'
    --  end,
  },

}
