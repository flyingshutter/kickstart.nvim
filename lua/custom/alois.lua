--[[
some custom stuff and playground
--]]

---------------- use figlet to create ASCII ART TEXT ---------------------------
--------------------------------------------------------------------------------
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

---------------- some luasnips -------------------------------------------------
--------------------------------------------------------------------------------
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

---------------- workaround pyright bug ----------------------------------------
--------------------------------------------------------------------------------
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

---------------- Have floating windows have a border by default-----------------
--------------------------------------------------------------------------------
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'

  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

---------------- some keymaps --------------------------------------------------
--------------------------------------------------------------------------------
vim.keymap.set('n', '<leader>meh', function() vim.lsp.util.open_floating_preview({"Hi World"}) end, { desc = '[e]xample [h]over window' })

vim.keymap.set('v', '<leader>mc', ':norm g_lD0x<CR>', { desc = '[c]leanup pasted text' })
vim.keymap.set('n', '<leader>ms', ':source %<CR>', { desc = '[s]ource active buffer' })

---------------- file specific behaviour ---------------------------------------
--------------------------------------------------------------------------------
 -- Create an autocommand group to organize our autocommands
 vim.api.nvim_create_augroup('FileTypeSettings', { clear = true })
 -- Create the autocommand
 vim.api.nvim_create_autocmd('FileType', {
   group = 'FileTypeSettings',
   pattern = 'lua', -- The filetype to match
   callback = function()
     -- Set options for Lua files here
     -- 'vim.bo' is used to set buffer-local options
     vim.bo.tabstop = 2
     vim.bo.softtabstop = 2
     vim.bo.shiftwidth = 2
   end,
 })

