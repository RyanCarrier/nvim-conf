return
{
    -- zbirenbaum copilot-cmp is very cool
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    config = function()
        require('copilot').setup({
            suggestion = {
                auto_trigger = true,
                keymap = {
                    accept = "<M-j>",
                    accept_line = "<M-l>",
                    --  accept_word = "<M-k>",
                    next = "<M-]>",
                    prev = "<M-[>",
                    dismiss = "<M-h>",
                },
            },
            panel = {
                enabled = true,
                auto_refresh = false,
                keymap = {
                    jump_prev = "[[",
                    jump_next = "]]",
                    accept = "<CR>",
                    refresh = "gr",
                    open = "<M-CR>"
                },
                layout = {
                    position = "right", -- | top | left | right
                    ratio = 0.4
                },
            },
            server_opts_overrides = {
                settings = {
                    advanced = {
                        inlineSuggestCount = 3,
                        listCount = 5,
                    }
                }
            }
        })
    end
}
