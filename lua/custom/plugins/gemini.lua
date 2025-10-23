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
      -- {
      --   '<leader>aa',
      --   function()
      --     require('sidekick.cli').toggle { focus = true }
      --   end,
      --   desc = 'Sidekick Toggle CLI',
      --   mode = { 'n', 'v' },
      -- },
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
    dir = '~/as/Projekte/2025-09-28_nvim_plugins/gemini-autocomplete.nvim/',
    config = function()
      local gemini = require 'gemini-autocomplete'
      gemini.setup {
        general = { make_statusline = require('gemini-autocomplete.external').make_mini_statusline },
        model = {
          opts = {
            model_id = require('gemini-autocomplete.api').MODELS.GEMINI_2_5_FLASH_LITE,
          }
        },
        -- I like to have it disabled on startup and manually activate when needed (free tier user, quota matters)
        completion = { enabled = false },
      }

      require('gemini-autocomplete.external').make_mini_statusline() -- show gemini in statusline and indicate (en/dis)abled

      vim.keymap.set('n', '<leader>gt', gemini.toggle_enabled, { desc = '[G]emini [T]oggle Autocompletion' })
      vim.keymap.set('n', '<leader>gg', gemini.add_gitfiles, { desc = '[G]emini add [G]itfiles' })
      vim.keymap.set('n', '<leader>ge', gemini.edit_context, { desc = '[G]emini [E]dit Context' })
      vim.keymap.set('n', '<leader>gp', gemini.prompt_code, { desc = '[G]emini [P]rompt Code' })
      vim.keymap.set('n', '<leader>gc', gemini.clear_context, { desc = '[G]emini [C]lear Context' })
      vim.keymap.set('n', '<leader>gm', gemini.choose_model, { desc = '[G]emini Choose [M]odel' })
    end,
  },
}
