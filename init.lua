require("rcarrier")

-- [[ Highlight on yank ]]
-- See `:help vim.highlight.on_yank()`
local highlight_group = vim.api.nvim_create_augroup('YankHighlight', { clear = true })
vim.api.nvim_create_autocmd('TextYankPost', {
  callback = function()
    vim.highlight.on_yank()
  end,
  group = highlight_group,
  pattern = '*',

})

-- [[ Configure Telescope ]]
-- See `:help telescope` and `:help telescope.setup()`
local actions = require('telescope.actions')
require('telescope').setup {
  defaults = {
    mappings = {
      i = {
        ['<C-u>'] = false,
        ['<C-d>'] = false,
        ['<C-j>'] = actions.move_selection_next,
        ['<C-k>'] = actions.move_selection_previous,
      },
      -- n = {},
    },
  },
}
--require('telescope').load_extension("fzf")
--require("telescope").load_extension("flutter")
require("telescope").load_extension("file_browser")
vim.keymap.set('n', "<leader>fb", function()
  require("telescope").extensions.file_browser.file_browser({
    hidden = true,
    cwd = vim.fn.expand('%:p:h'),
  })
end, { desc = "[F]ile [B]rowser" })


-- Enable telescope fzf native, if installed
pcall(require('telescope').load_extension, 'fzf')
vim.keymap.set("n", "<leader>fl", function() require("telescope").extensions.flutter.commands() end,
  { desc = "[Fl]utter" })
-- See `:help telescope.builtin`
vim.keymap.set('n', '<leader>?', require('telescope.builtin').oldfiles, { desc = '[?] Find recently opened files' })
vim.keymap.set('n', '<leader><space>', require('telescope.builtin').buffers, { desc = '[ ] Find existing buffers' })
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to telescope to change theme, layout, etc.
  require('telescope.builtin').current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    -- winblend = 10,
    -- previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

vim.keymap.set('n', '<leader>gf', require('telescope.builtin').git_files, { desc = 'Search [G]it [F]iles' })
vim.keymap.set('n', '<leader>sf', require('telescope.builtin').find_files, { desc = '[S]earch [F]iles' })

vim.keymap.set('n', '<leader>pg', require('telescope.builtin').git_files, { desc = '[P]roject [G]it files' })
vim.keymap.set('n', '<leader>pf', require('telescope.builtin').find_files, { desc = '[P]rojcet [F]iles' })
vim.keymap.set('n', '<C-p>', require('telescope.builtin').git_files,
  { desc = "[P]ersonal preference - idk this is from vscode and I'm use to it" })

vim.keymap.set('n', '<leader>sh', require('telescope.builtin').help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sw', require('telescope.builtin').grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', require('telescope.builtin').live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', require('telescope.builtin').diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>tk', require('telescope.builtin').keymaps, { desc = '[T]elescope [K]eymaps' })


-- [[ Configure Treesitter ]]
-- See `:help nvim-treesitter`
require('nvim-treesitter.configs').setup {
  -- Add languages to be installed here that you want installed for treesitter
  ensure_installed = { 'c', 'cpp', 'go', 'lua', 'python', 'rust', 'tsx', 'typescript', 'vimdoc', 'vim', 'bash', 'dart',
    'zig', 'toml', 'yaml', 'gomod' },

  -- Autoinstall languages that are not installed. Defaults to false (but you can change for yourself! )
  auto_install = true,

  highlight = { enable = true },
  indent = { enable = true, disable = { 'python', 'dart' } },
  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection = '<c-space>',
      node_incremental = '<c-space>',
      scope_incremental = '<c-s>',
      node_decremental = '<M-space>',
    },
  },
  textobjects = {
    select = {
      enable = true,
      lookahead = true, -- Automatically jump forward to textobj, similar to targets.vim
      keymaps = {
        -- You can use the capture groups defined in textobjects.scm
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
      },
    },
    move = {
      enable = true,
      set_jumps = true, -- whether to set jumps in the jumplist
      goto_next_start = {
        [']m'] = '@function.outer',
        [']]'] = '@class.outer',
      },
      goto_next_end = {
        [']M'] = '@function.outer',
        [']['] = '@class.outer',
      },
      goto_previous_start = {
        ['[m'] = '@function.outer',
        ['[['] = '@class.outer',
      },
      goto_previous_end = {
        ['[M'] = '@function.outer',
        ['[]'] = '@class.outer',
      },
    },
    swap = {
      enable = true,
      swap_next = {
        ['<leader>a'] = '@parameter.inner',
      },
      swap_previous = {
        ['<leader>A'] = '@parameter.inner',
      },
    },
  },
}




-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous diagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next diagnostic message' })
vim.keymap.set('n', '<leader>e', vim.diagnostic.open_float, { desc = 'Open floating diagnostic message' })
--vim.keymap.set('n', '<leader>q', vim.diagnostic.setloclist, { desc = 'Open diagnostics list' })


vim.keymap.set("n", "<Leader>q", function()
  vim.diagnostic.setloclist({ open = false }) -- don't open and focus
  local window = vim.api.nvim_get_current_win()
  vim.cmd.lwindow()                           -- open+focus loclist if has entries, else close -- this is the magic toggle command
  vim.api.nvim_set_current_win(window)        -- restore focus to window you were editing (delete this if you want to stay in loclist)
end, { buffer = bufnr, desc = 'Open diagnostics list' })

-- [[ Configure LSP ]]
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end
    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
  nmap('<leader>ww', function()
    vim.lsp.buf.code_action({
      apply = true,
      filter = function(action)
        return string.find(action.title, 'Wrap with widget')
      end

    })
  end, '[W]rap [W]idget')
  nmap('<leader>fq', function()
    vim.lsp.buf.code_action({
      apply = true,
      filter = function(action)
        return string.find(action.title, 'Fix All')
      end
    })
    -- mostly cause I've gotten semi use to C-Q, and idk how much i love the trouble extension
  end, '[F]ix... [Q]uick!')
  nmap('<leader>fi', function()
    vim.lsp.buf.code_action({
      apply = true,
      filter = function(action)
        return string.find(action.title, "Import library 'package")
      end

    })
  end, '[F]ix [I]mport')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  -- nmap('gds', ':vsplit<CR<Cmd>lua vim.lsp.buf.definition()<CR>', '[G]oto [D]efinition with a [S]plit')
  nmap('gr', function()
    require('telescope.builtin').lsp_references({
      include_decleration = false,
    })
  end, '[G]oto [R]eferences')
  -- ignore this attempt to try get to the only reference that is not it's definition
  -- nmap('<leader>gR', "<cmd>lua vim.lsp.buf.references()<cr><cr>", '[G]oto [R]eferences')
  -- nmap('<leader>gR', function()
  --   vim.lsp.buf.references()
  --   vim.cmd('normal! zz')
  -- end, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')
  nmap('<leader>ff', vim.lsp.buf.format, '[FF]ormat')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  -- REMOVED to allow for j and k
  -- I don't think this does need to be removed
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')


  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

-- Enable the following language servers
--  Feel free to add/remove any LSPs that you want here. They will automatically be installed.
--
--  Add any additional override configuration in the following tables. They will be passed to
--  the `settings` field of the server config. You must look up that documentation yourself.
local servers = {
  -- clangd = {},
  -- gopls = {},
  -- pyright = {},
  -- rust_analyzer = {},
  -- tsserver = {},

  lua_ls = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
}

-- Setup neovim lua configuration
require('neodev').setup()

-- nvim-cmp supports additional completion capabilities, so broadcast that to servers
local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

-- Ensure the servers above are installed
local mason_lspconfig = require 'mason-lspconfig'

mason_lspconfig.setup {
  ensure_installed = vim.tbl_keys(servers),
}

mason_lspconfig.setup_handlers {
  function(server_name)
    require('lspconfig')[server_name].setup {
      capabilities = capabilities,
      on_attach = on_attach,
      settings = servers[server_name],
    }
  end,
}
require('flutter-tools').setup({
  lsp = {
    on_attach = on_attach,
    color = {
      enabled = true,
      virtual_text = true,
      virtual_text_str = "■",
    }
  }
})
require('rust-tools').setup({
  server = {
    on_attach = on_attach,
  },
})

local wk = require("which-key")
local chatgpt = require("chatgpt")
wk.register({
  a = {
    name = "ChatGPT",
    i = {
      function()
        chatgpt.edit_with_instructions()
      end,
      "Edit with instructions",
    },
  },
}, {
  prefix = "<leader>",
  mode = "v",
})

wk.register({
  a = {
    name = "ChatGPT",
    i = {
      function()
        chatgpt.openChat()
      end,
      "Chat with [AI]",
    },
  },
}, {
  prefix = "<leader>",
  mode = "n",
})

wk.register({
  a = {
    name = "ChatGPT",
    p = {
      function()
        chatgpt.selectAwesomePrompt()
      end,
      "Chat with [A]I [P]rompt",
    },
  },
}, {
  prefix = "<leader>",
  mode = "n",
})
-- [[ Configure nvim-cmp ]]
-- See `:help cmp`
local cmp = require('cmp')
local luasnip = require('luasnip')
-- require('luasnip.loaders.from_vscode').lazy_load()
luasnip.config.setup({})

cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
    border = 'rounded',
    scrollbar = true,
  },
  mapping = cmp.mapping.preset.insert {
    ['<C-j>'] = cmp.mapping.select_next_item(),
    ['<C-k>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete {},
    ['<CR>'] = cmp.mapping.confirm {
      -- behavior = cmp.ConfirmBehavior.Replace,
      -- select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_locally_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.locally_jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  },




  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

-- The line beneath this is called `modeline`. See `:help modeline`
-- vim: ts=2 sts=2 sw=2 et
--
-- add border to floating window
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = _border
  }
)

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(
  vim.lsp.handlers.signature_help, {
    border = _border
  }
)

vim.diagnostic.config {
  float = { border = _border }
}
-- TS file_browser
vim.keymap.set('n', '<leader>u', vim.cmd.UndotreeToggle, { noremap = true, silent = true })

-- Lua -- TROUBLE
vim.keymap.set("n", "<leader>xx", "<cmd>TroubleToggle<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xl", "<cmd>TroubleToggle loclist<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "<leader>xq", "<cmd>TroubleToggle quickfix<cr>",
  { silent = true, noremap = true }
)
vim.keymap.set("n", "gR", "<cmd>TroubleToggle lsp_references<cr>",
  { silent = true, noremap = true }
)
-- vim.api.nvim_set_keymap('i', "<C-BS>", "<C-o>db", { noremap = true })
-- vim.api.nvim_set_keymap('i', "<C-Del>", "<C-o>dw", { noremap = true })
-- ctrl backspace to delete word
vim.api.nvim_set_keymap('i', "<C-H>", "<C-W>", { noremap = true })

vim.keymap.set("n", "<leader>fml", "<cmd>CellularAutomaton make_it_rain<CR>", { desc = "Make it rain" })

vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "<C-d>", "<C-d>zz")

vim.keymap.set("x", "<leader>p", [["_dP"]])


-- need to learn about cnext and lnext
-- vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
-- vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
-- vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
-- vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")
--
-- this might be cool
vim.keymap.set("n", "<left>", "<C-w>h")
vim.keymap.set("n", "<down>", "<C-w>j")
vim.keymap.set("n", "<up>", "<C-w>k")
vim.keymap.set("n", "<right>", "<C-w>l")
