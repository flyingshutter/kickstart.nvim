--[[
some custom stuff and playground
--]]

vim.keymap.set('n', '<Leader>mr', ':e<CR>', { noremap = true, silent = true, desc = 'Reload current file' })
-- Enable autoread and set up checking triggers
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = '*',
})

-- use figlet to create ASCII ART text
vim.keymap.set('n', '<leader>ma', function()
  vim.ui.input({
    prompt = 'Enter your text: ',
  }, function(text)
    if text then -- user_input will be nil if the input was cancelled (e.g., by pressing Esc)
      if text ~= '' then
        local status, err = pcall(vim.cmd, ':r !figlet ' .. text .. ' | awk \'{sub(/ +$/, ""); print}\'')
        if not status then
          vim.notify('Error executing command: ' .. err, vim.log.levels.ERROR)
        end
      else
        print 'No command entered.'
      end
    else
      print 'Input cancelled.'
    end
  end)
end, { desc = 'ASCII Art Text' })

local ls = require 'luasnip'
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local fmt = require('luasnip.extras.fmt').fmt

ls.add_snippets('all', {
  s(
    'ifname',
    fmt(
      [[
      if __name__ == "__main__":
          main({})
      ]],
      { i(1, 'params') }
    )
  ),
})

-- AS as of end of September 2025, pyright causes a bug from neovim version >=0.12,
-- see https://github.com/neovim/neovim/issues/34731
-- this is a workaround
vim.lsp.config('pyright', {
  handlers = {
    -- Override the default rename handler to remove the `annotationId` from edits.
    --
    -- Pyright is being non-compliant here by returning `annotationId` in the edits, but not
    -- populating the `changeAnnotations` field in the `WorkspaceEdit`. This causes Neovim to
    -- throw an error when applying the workspace edit.
    --
    -- See:
    -- - https://github.com/neovim/neovim/issues/34731
    -- - https://github.com/microsoft/pyright/issues/10671
    [vim.lsp.protocol.Methods.textDocument_rename] = function(err, result, ctx)
      if err then
        vim.notify('Pyright rename failed: ' .. err.message, vim.log.levels.ERROR)
        return
      end

      ---@cast result lsp.WorkspaceEdit
      for _, change in ipairs(result.documentChanges or {}) do
        for _, edit in ipairs(change.edits or {}) do
          if edit.annotationId then
            edit.annotationId = nil
          end
        end
      end

      local client = assert(vim.lsp.get_client_by_id(ctx.client_id))
      vim.lsp.util.apply_workspace_edit(result, client.offset_encoding)
    end,
  },
})
vim.keymap.set('v', '<leader>mc', ':norm g_lD0x<CR>', { desc = '[c]leanup pasted text' })

vim.keymap.set('n', '+', 'zO', { desc = 'Open all Folds under cursor' })
vim.keymap.set('n', '-', 'zC', { desc = 'Close all Folds under cursor' })

vim.keymap.set('n', '<leader>ms', ':source %<CR>', { desc = '[s]ource active buffer' })

-- Have floating windows have a border by default
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'

  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end
vim.keymap.set('n', '<leader>meh', function() vim.lsp.util.open_floating_preview({"Hi World"}) end, { desc = '[e]xample [h]over window' })
