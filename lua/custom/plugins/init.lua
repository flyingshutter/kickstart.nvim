-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
_G.dapui_is_open = false
-- local args_str = ""
local is_windows = vim.uv.os_uname().sysname == 'Windows_NT'

local mason_cmd = vim.fn.stdpath 'data' .. '/mason/bin/codelldb'
local python_interpreter = '/usr/bin/python3'
local sourceMapList = nil
if is_windows then
  mason_cmd = "C:\\Users\\alois\\AppData\\Local\\nvim-data\\mason\\packages\\codelldb\\extension\\adapter\\codelldb"
  python_interpreter = "python"
  sourceMapList = { ["/e/"] = "E:\\", ["/c/"] = "C:\\", ["/d/"] = "D:\\", }
end

return {
  'tpope/vim-fugitive',
  {
    'mfussenegger/nvim-dap',
    config = function()
      local dap = require 'dap'

      -- 1. Define the adapter (How Neovim talks to the debugger)
      dap.adapters.codelldb = {
        type = 'server',
        port = '${port}',
        executable = {
          command = mason_cmd,
          args = { '--port', '${port}' },
        },
      }

      -- 2. Define the configuration (How to launch your C program)
      dap.configurations.c = {
        {
          name = 'bin/...',
          type = 'codelldb',
          request = 'launch',
          program = 'bin/' .. vim.fn.expand('%:r'),
          cwd = '${workspaceFolder}',
          sourceMap = sourceMapList,
          stopOnEntry = false,
        },
        {
          name = 'Launch file',
          type = 'codelldb',
          request = 'launch',
          program = function()
            local prog_str = vim.fn.input('Path to executable: ', vim.fn.expand('%:h') .. '/bin/' .. vim.fn.expand('%:r'), 'file')
            return prog_str
          end,
          args = function()
            local args_str = vim.fn.input('Arguments: ')
            return vim.split(args_str, " +", { trimempty = true })
          end,
          cwd = '${workspaceFolder}',
          sourceMap = sourceMapList,
          stopOnEntry = false,
          -- initCommands = { "command script import ${workspaceFolder}/debugvis.py" },
        },
        {
          name = 'Exercism',
          type = 'codelldb',
          request = 'launch',
          -- program = './tests.out',
          program = function ()
            print(vim.fn.system("make test"))
            return "./tests.out"
          end,
          cwd = '${workspaceFolder}',
          sourceMap = sourceMapList,
          stopOnEntry = false,
        },
      }
      -- Link C++ to use the same config
      dap.configurations.cpp = dap.configurations.c

      dap.adapters.cuda_gdb = {
        type = "executable",
        command = "cuda_gdb",
        args = { "--interpreter=dap", "--eval-command", "set print pretty on" }
      }

      -- 2. Define the configuration (How to launch your C program)
      dap.configurations.cuda = {
        {
          name = 'Launch file',
          type = 'codelldb',
          request = 'launch',
          program = function()
            local prog_str = vim.fn.input('Path to executable: ', vim.fn.expand('%:h') .. '/bin/' .. vim.fn.expand('%:r'), 'file')
            -- args_str = vim.fn.input('Arguments: ')
            return prog_str
          end,
          args = function()
            local args_str = vim.fn.input('Arguments: ')
            return vim.split(args_str, " +", { trimempty = true })
          end,
          cwd = '${workspaceFolder}',
          sourceMap = sourceMapList,
          stopOnEntry = false,
        },
      }

      vim.api.nvim_create_autocmd("FileType", {
        pattern = "dap-repl",
        callback = function()
          vim.keymap.set('i', '<C-n>', function()
            require('dap.repl').on_down()
          end)
          vim.keymap.set('i', '<C-p>', function()
            require('dap.repl').on_up()
          end)
        end,
      })
    end
  },
  'nvim-neotest/nvim-nio',
  { 'theHamsta/nvim-dap-virtual-text', opts = {} },
  {
    'mfussenegger/nvim-dap-python',
    config = function()
      require('dap-python').setup(python_interpreter)
      -- See https://github.com/microsoft/debugpy/wiki/Debug-configuration-settings
      table.insert(require('dap').configurations.python, {
        type = 'python',
        request = 'launch',
        name = 'debug_tools/usercustomize.py',
        program = '${file}',
        console = "integratedTerminal",
        env = {PYTHONPATH = "${workspaceFolder}/debug_tools/:${PYTHONPATH}"},
      })
    end,
  },
  {
    'rcarriga/nvim-dap-ui',
    config = function()
      require('dapui').setup()

      -- automatically open and close dapui
      local dap, dapui = require 'dap', require 'dapui'
      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end

      -- dap keymaps
      vim.keymap.set('n', '<F5>', require('dap').continue, { desc = 'dap continue' })
      vim.keymap.set('n', '<F6>', require('dap').step_over, { desc = 'dap step_over' })
      vim.keymap.set('n', '<F7>', require('dap').step_into, { desc = 'dap step into' })
      vim.keymap.set('n', '<F8>', require('dap').step_out, { desc = 'dap step out' })
      vim.keymap.set('n', '<F9>', require('dap').terminate, { desc = 'dap terminate debug session' })
      vim.keymap.set('n', '<Leader>da', require('dap').pause, { desc = 'dap p[a]use' })
      vim.keymap.set('n', '<Leader>db', require('dap').toggle_breakpoint, { desc = 'Toggle [b]reakpoint' })
      vim.keymap.set('n', '<Leader>dB', ":lua require('dap').set_breakpoint(vim.fn.input('Condition: '))<CR>", { desc = 'Set conditional [B]reakpoint' })
      vim.keymap.set('n', '<Leader>lp', function()
        require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
      end, { desc = 'Set [L]og [P]oint with message' })
      vim.keymap.set('n', '<Leader>dr', require('dap').repl.open, { desc = '[D]ebug Open [r]epl' })
      vim.keymap.set('n', '<Leader>dl', require('dap').run_last, { desc = '[D]ebug Run [L]ast' })

      -- dapui keymaps
      vim.keymap.set({ 'n' }, '<Leader>d?', function()
        require('dapui').eval(nil, { enter = true })
      end, { desc = '[D]ebug [E]val under cursor' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dh', require('dap.ui.widgets').hover, { desc = '[D]ebug [H]over' })
      vim.keymap.set({ 'n', 'v' }, '<Leader>dp', require('dap.ui.widgets').preview, { desc = '[D]ebug [P]review' })
      vim.keymap.set('n', '<Leader>df', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.frames)
      end, { desc = '[D]ebug [F]rames' })
      vim.keymap.set('n', '<Leader>ds', function()
        local widgets = require 'dap.ui.widgets'
        widgets.centered_float(widgets.scopes)
      end, { desc = '[D]ebug [S]copes' })
      vim.keymap.set('n', '<Leader>du', function()
        if _G.dapui_is_open then
          dapui.close()
        else
          dapui.open()
        end
        _G.dapui_is_open = not _G.dapui_is_open
      end, { desc = '[D]ebug Toggle [U]I' })
    end,
  },
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local harpoon = require 'harpoon'

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED

      vim.keymap.set('n', '<leader>aa', function()
        harpoon:list():add()
      end, { desc = 'H[a]rpoon [a]dd' })
      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end, { desc = 'Harpoon toggle quick menu' })

      vim.keymap.set('n', '<leader>aj', function()
        harpoon:list():select(1)
      end, { desc = 'H[a]rpoon select [1]' })
      vim.keymap.set('n', '<leader>ak', function()
        harpoon:list():select(2)
      end, { desc = 'H[a]rpoon select [2]' })
      vim.keymap.set('n', '<leader>al', function()
        harpoon:list():select(3)
      end, { desc = 'H[a]rpoon select [3]' })
      vim.keymap.set('n', '<leader>aö', function()
        harpoon:list():select(4)
      end, { desc = 'H[a]rpoon select [4]' })

      -- Toggle previous & next buffers stored within Harpoon list
      -- vim.keymap.set('n', '<C-S-P>', function()
      --   harpoon:list():prev()
      -- end)
      -- vim.keymap.set('n', '<C-S-N>', function()
      --   harpoon:list():next()
      -- end)
    end,
  },

  {
    dir = '~/as/Projekte/2025-09-28_nvim_plugins/astest.nvim',
    config = function()
      require('astest').setup()
    end,
  },
}
