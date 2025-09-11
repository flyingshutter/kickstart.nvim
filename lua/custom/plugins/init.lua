-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'tpope/vim-fugitive',
    'mfussenegger/nvim-dap',
    'nvim-neotest/nvim-nio',
    { 'rcarriga/nvim-dap-ui', opts = {} },
    {
      'mfussenegger/nvim-dap-python',
      config = function()
        require('dap-python').setup '/usr/bin/python3'
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
      end,
    },

    vim.keymap.set('n', '<F5>', require('dap').continue, { desc = 'dap continue' }),
    vim.keymap.set('n', '<F6>', require('dap').step_over, { desc = 'dap step_over' }),
    vim.keymap.set('n', '<F7>', require('dap').step_into, { desc = 'dap step into' }),
    vim.keymap.set('n', '<F8>', require('dap').step_out, { desc = 'dap step out' }),
    vim.keymap.set('n', '<F9>', require('dap').terminate, { desc = 'dap step out' }),
    vim.keymap.set('n', '<Leader>b', require('dap').toggle_breakpoint, { desc = 'Toggle [b]reakpoint' }),
    vim.keymap.set('n', '<Leader>B', require('dap').set_breakpoint, { desc = 'Set [B]reakpoint' }),
    vim.keymap.set('n', '<Leader>lp', function()
      require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
    end, { desc = 'Set [L]og [P]oint with message' }),
    vim.keymap.set('n', '<Leader>dr', require('dap').repl.open, { desc = '[D]ebug Open [r]epl' }),
    vim.keymap.set('n', '<Leader>dl', require('dap').run_last, { desc = '[D]ebug Run [L]ast' }),
    vim.keymap.set({ 'n', 'v' }, '<Leader>dh', require('dap.ui.widgets').hover, { desc = '[D]ebug [H]over' }),
    vim.keymap.set({ 'n', 'v' }, '<Leader>dp', require('dap.ui.widgets').preview, { desc = '[D]ebug [P]review' }),
    vim.keymap.set('n', '<Leader>df', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.frames)
    end, { desc = '[D]ebug [F]rames' }),
    vim.keymap.set('n', '<Leader>ds', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.scopes)
    end, { desc = '[D]ebug [S]copes' }),
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
}
