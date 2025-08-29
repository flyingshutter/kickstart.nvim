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
        require('dap-python').setup 'python' -- AS: windows HAS to differ in this line
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

    vim.keymap.set('n', '<F5>', function()
      require('dap').continue()
    end, { desc = 'dap continue' }),
    vim.keymap.set('n', '<F6>', function()
      require('dap').step_over()
    end, { desc = 'dap step_over' }),
    vim.keymap.set('n', '<F7>', function()
      require('dap').step_into()
    end, { desc = 'dap step into' }),
    vim.keymap.set('n', '<F8>', function()
      require('dap').step_out()
    end, { desc = 'dap step out' }),
    vim.keymap.set('n', '<Leader>b', function()
      require('dap').toggle_breakpoint()
    end, { desc = 'Toggle [b]reakpoint' }),
    vim.keymap.set('n', '<Leader>B', function()
      require('dap').set_breakpoint()
    end, { desc = 'Set [B]reakpoint' }),
    vim.keymap.set('n', '<Leader>lp', function()
      require('dap').set_breakpoint(nil, nil, vim.fn.input 'Log point message: ')
    end, { desc = 'Set [L]og [P]oint with message' }),
    vim.keymap.set('n', '<Leader>dr', function()
      require('dap').repl.open()
    end, { desc = '[D]ebug Open [r]epl' }),
    vim.keymap.set('n', '<Leader>dl', function()
      require('dap').run_last()
    end, { desc = '[D]ebug Run [L]ast' }),
    vim.keymap.set({ 'n', 'v' }, '<Leader>dh', function()
      require('dap.ui.widgets').hover()
    end, { desc = '[D]ebug [H]over' }),
    vim.keymap.set({ 'n', 'v' }, '<Leader>dp', function()
      require('dap.ui.widgets').preview()
    end, { desc = '[D]ebug [P]review' }),
    vim.keymap.set('n', '<Leader>df', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.frames)
    end, { desc = '[D]ebug [F]rames' }),
    vim.keymap.set('n', '<Leader>ds', function()
      local widgets = require 'dap.ui.widgets'
      widgets.centered_float(widgets.scopes)
    end, { desc = '[D]ebug [S]copes' }),
  },
}
