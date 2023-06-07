return
{
    "zbirenbaum/copilot.lua",
    event = "InsertEnter",
    opts = {
        suggestion = {
            auto_trigger = true,

            keymap = {
                accept = "<C-Enter>",
                accept_line = "<C-l>",
                accept_word = "<M-k>",
                next = "<C-]>",
                prev = "<C-[>",
                dismiss = "<M-c>",
            },
        },
    },

}
