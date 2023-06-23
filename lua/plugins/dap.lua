-- debug.lua
--
-- Shows how to use the DAP plugin to debug your code.
--
-- Primarily focused on configuring the debugger for Go, but can
-- be extended to other languages as well. That's why it's called
-- kickstart.nvim and not kitchen-sink.nvim ;)
return {
  -- NOTE: Yes, you can install new plugins here!
  'mfussenegger/nvim-dap',
  -- NOTE: And you can specify dependencies as well
  dependencies = {
    -- Creates a beautiful debugger UI
    'rcarriga/nvim-dap-ui',

    -- Installs the debug adapters for you
    'williamboman/mason.nvim',
    'jay-babu/mason-nvim-dap.nvim',

    -- Add your own debuggers here
    'leoluz/nvim-dap-go',
  },
  config = function()
    local dap = require('dap')
    local dapui = require('dapui')
    -- dap.adapters.dart = {
    --   type = 'executable',
    --   command = 'flutter',
    --   args = { 'debug_adapter' },
    -- }
    -- dap.configurations.dart = {
    --   {
    --     -- The first three options are required by nvim-dap
    --     type = 'dart',
    --     request = 'launch',
    --     name = 'Flutter',
    --     -- If you have a flutter project, use flutterRunDebug
    --     program = "${file}",
    --     cwd = "${workspaceFolder}",
    --     toolArgs = { "-d", "linux" }
    --     --program = 'lib/main.dart',
    --     -- flutterRunDebug is the default if no 'program' is specified
    --     -- flutterRunDebug = 'lib/main.dart',
    --   },
    -- }

    require('mason-nvim-dap').setup {
      -- Makes a best effort to setup the various debuggers with
      -- reasonable debug configurations
      automatic_setup = true,

      -- You can provide additional configuration to the handlers,
      -- see mason-nvim-dap README for more information
      handlers = {},

      -- You'll need to check that you have the required things installed
      -- online, please don't ask me how to install them :)
      ensure_installed = {
        -- Update this to ensure that you have the debuggers for the langs you want
        'delve',
      },
    }
    local nmap = function(keys, func, desc)
      if desc then desc = 'DAP: ' .. desc end
      vim.keymap.set('n', keys, func, { desc = desc })
    end

    -- Basic debugging keymaps, feel free to change to your liking!
    nmap('<F5>', dap.continue, "Continue")
    nmap('<F1>', dap.step_into, "Step into")
    nmap('<F2>', dap.step_over, "Step over")
    nmap('<F3>', dap.step_out, "Step out")
    nmap('<leader>b', dap.toggle_breakpoint, "Toggle [b]reakpoint")
    nmap('<leader>B', function()
      dap.set_breakpoint(vim.fn.input 'Breakpoint condition: ')
    end, "Conditional [B]reakpoint")

    -- Dap UI setup
    -- For more information, see |:help nvim-dap-ui|
    dapui.setup({
      -- Set icons to characters that are more likely to work in every terminal.
      --    Feel free to remove or use ones that you like more! :)
      --    Don't feel like these are good choices.
      icons = { expanded = '▾', collapsed = '▸', current_frame = '*' },
      controls = {
        icons = {
          pause = '⏸',
          play = '▶',
          step_into = '⏎',
          step_over = '⏭',
          step_out = '⏮',
          step_back = 'b',
          -- run_last = '▶▶',
          terminate = '⏹',
          disconnect = "⏏",
        },
      },
      layouts = {
        {
          -- You can change the order of elements in the sidebar
          elements = {
            -- Provide IDs as strings or tables with "id" and "size" keys
            {
              id = "scopes",
              size = 0.25, -- Can be float or integer > 1
            },
            { id = "breakpoints", size = 0.25 },
            { id = "stacks",      size = 0.25 },
            { id = "watches",     size = 0.25 },
          },
          size = 40,
          position = "left", -- Can be "left" or "right"
        },
        {
          elements = {
            "repl",
            "console",
          },
          size = 10,
          position = "bottom", -- Can be "bottom" or "top"
        },
        {
          elements = { "repl" },
          size = 20,
          position = "bottom",
        },
        {
          elements = { "repl" },
          size = 1,
          position = "bottom",
        }
      },
    })
    -- trougg = trouble+toggle+debug
    local function trouggle()
      local t = require('trouble')
      local dap = require('dap')
      -- local controls = require("dapui.controls")
      dap.repl.close()
      t.close()
      -- local View = require("trouble.view")
      -- trouble will also select buffer once complete (so the future vsplit applies)
      -- correctly
      t.open({ mode = 'document_diagnostics' })
      --have a secret small layout for a mini repl (size 1), to enable the controlls
      -- controlls will then be passed to any other repl window too
      -- there was some issue doing this before trouble, I don't remember what,
      -- no harm but it works here... just weird
      dapui.open({ layout = 4 })
      dapui.close()
      require('dap').repl.open({}, 'vsplit')
      -- need this for those little icons from dapui lmao I don't even know
      -- dapui.update_render({})
      -- local config = require("dapui.config")
      -- if config.controls.enabled and config.controls.element ~= "" then
      --   controls.enable_controls(dapui.elements[config.controls.element])
      -- end
      -- controls.refresh_control_panel()
    end

    -- toggle to see last session result. Without this ,you can't see session output in case of unhandled exception.
    nmap("<F7>", dapui.toggle, "DapUI Toggle")
    nmap("<F8>", dapui.close, "DapUI Close")
    nmap("<F6>", function()
      dapui.close()
      dapui.open({ layout = 3 })
    end, "Open default small")
    nmap("<F9>", trouggle, "Trouggle")

    -- dap.listeners.after.event_initialized['dapui_config'] = function() dapui.open({ layout = 3 }) end
    dap.listeners.after.event_initialized['dapui_config'] = trouggle
    -- require('trouble').open({ mode = 'document_diagnostics' })
    dap.listeners.before.event_terminated['dapui_config'] = dapui.close
    dap.listeners.before.event_exited['dapui_config'] = dapui.close

    -- Install golang specific config
    require('dap-go').setup()
  end,
}
