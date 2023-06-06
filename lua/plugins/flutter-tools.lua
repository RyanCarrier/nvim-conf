return {
    'akinsho/flutter-tools.nvim',
    lazy = false,
    dependencies = {
        'nvim-lua/plenary.nvim',
        'stevearc/dressing.nvim', -- optional for vim.ui.select

    },
    config = function()
        require("telescope").load_extension("flutter")
        require("flutter-tools").setup({})
    end
}
