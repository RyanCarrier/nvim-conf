return
{
    -- zbirenbaum copilot-cmp is very cool
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
        suggestion = {
            auto_trigger = true,

            keymap = {
                accept = "<M-j>",
                accept_line = "<C-l>",
                --  accept_word = "<M-k>",
                next = "<C-]>",
                prev = "<C-[>",
                dismiss = { "<M-h>", "M-c" },
            },
        },
    },


}
