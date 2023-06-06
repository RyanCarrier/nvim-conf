return {
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
    },
    config = function()
      require("tokyonight").setup({
        -- use the night style
        style = "night",
        -- disable italic for functions
        -- Change the "hint" color to the "orange" color, and make the "error" color bright red
        on_colors = function(colors)
          colors.bg = colors.black
          colors.border = colors.purple
          colors.border_highlight = colors.purple
          -- colors.bg_search = colors.orange

          --colors.bg_float = colors.red
          --side bar is the section down bottom which 'which' plugin uses
          --         colors.bg_sidebar = colors.green
          -- colors.bg_popup = colors.teal
        end,


        on_highlights = function(hl, c)
          hl.ColorColumn = { bg = "#202122" }
          c.bg_float = c.red
        end,
        styles = {
          sidebars = "dark",
          floats = "dark",
        },
        sidebars = { "qf", "help" },

        --         hl.ctermbg = {
        --           fg = colors.green,
        --           bg = colors.cyan,
        --      }
        -- end

      })
      vim.cmd.colorscheme 'tokyonight-night'
    end
  },
  { "nyoom-engineering/oxocarbon.nvim", name = 'oxocarbon' },
  { 'rafamadriz/neon',                  name = 'neon' },
  { "catppuccin/nvim",                  name = "catppuccin" },
  {
    -- Theme inspired by Atom
    'navarasu/onedark.nvim',
    --  config = function()
    --    vim.cmd.colorscheme 'onedark'
    --  end,
  },

}
