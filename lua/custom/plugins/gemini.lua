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
      require('gemini').setup {

        model = { model_id = 'gemini-2.0-flash' },
        completion = {
          insert_result_key = '<c-y>',
          can_complete = function()
            print(
              'ena: ',
              vim.g.gemini_complete_enabled,
              ', pum: ',
              vim.fn.pumvisible() ~= 1,
              ',  and: ',
              vim.g.gemini_complete_enabled and vim.fn.pumvisible() ~= 1
            )

            return vim.g.gemini_complete_enabled and vim.fn.pumvisible() ~= 1
          end,
        },
      }

      vim.g.gemini_complete_enabled = false

      local function toggle_gemini_autocomplete()
        vim.g.gemini_complete_enabled = not vim.g.gemini_complete_enabled
        if vim.g.gemini_complete_enabled then
          print 'Gemini: Autocomplete enabled'
        else
          print 'Gemini: Autocomplete disabled'
        end
      end
      vim.keymap.set('n', '<leader>ac', function()
        toggle_gemini_autocomplete()
        vim.api.nvim_command 'redraw!'
      end, { desc = 'Toggle Gemini [a]uto[c]ompletion' })
    end,
  },
}
