--[[
load and configure gemini stuff
--]]

return {
  {
    'folke/sidekick.nvim',
    opts = {
      -- add any options here
      cli = {
        mux = {
          backend = 'tmux',
          enabled = true,
        },
      },
    },
    keys = {
      {
        '<leader>aa',
        function()
          require('sidekick.cli').toggle { focus = true }
        end,
        desc = 'Sidekick Toggle CLI',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ag',
        function()
          require('sidekick.cli').toggle { name = 'gemini', focus = true }
        end,
        desc = 'Sidekick Gemini Toggle',
        mode = { 'n', 'v' },
      },
      {
        '<leader>ap',
        function()
          require('sidekick.cli').select_prompt()
        end,
        desc = 'Sidekick Ask Prompt',
        mode = { 'n', 'v' },
      },
    },
  },
  {
    dir = '~/as/Projekte/2025-09-28_nvim_plugins/gemini.nvim/',
    config = function()
      local gemini = require 'gemini'
      gemini.setup {
        general = { mini_statusline = true },
        model = { model_id = 'gemini-2.0-flash' },
        completion = { enabled = false, },
      }

      vim.keymap.set('n', '<leader>ac', function()
        gemini.toggle_enabled()
        vim.api.nvim_command 'redraw!'
      end, { desc = 'Toggle Gemini [a]uto[c]ompletion' })
    end,
  },
}
