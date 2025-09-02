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
}
