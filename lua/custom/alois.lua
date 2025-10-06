--[[
some custom stuff and playground
--]]

---------------- USE DIFFERENT THEMES FOR BG=DARK/LIGHT --------------
----------------------------------------------------------------------
vim.api.nvim_create_user_command("DarkMode", function()
  vim.o.bg = "dark"
  vim.cmd.colorscheme("kanagawa-dragon")
  local hl = vim.tbl_deep_extend('force', {}, vim.api.nvim_get_hl(0, {name="Comment"}))
  hl.italic = nil
  vim.api.nvim_set_hl(0, "Comment", hl)
end, { desc = "Switch to dark mode" })

vim.api.nvim_create_user_command("LightMode", function()
  vim.o.bg = "light"
   vim.cmd.colorscheme("catppuccin-latte") -- Your chosen light theme
  local hl = vim.tbl_deep_extend('force', {}, vim.api.nvim_get_hl(0, {name="Comment"}))
  hl.italic = nil
  vim.api.nvim_set_hl(0, "Comment", hl)
end, { desc = "Switch to light mode" })

---------------- USE FIGLET TO CREATE ASCII ART TEXT -----------------
----------------------------------------------------------------------
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

---------------- SOME LUASNIPS ---------------------------------------
----------------------------------------------------------------------
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

---------------- WORKAROUND PYRIGHT BUG ------------------------------
----------------------------------------------------------------------
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

---------------- HAVE FLOATING WINDOWS HAVE A BORDER BY DEFAULT-------
----------------------------------------------------------------------
local orig_util_open_floating_preview = vim.lsp.util.open_floating_preview

function vim.lsp.util.open_floating_preview(contents, syntax, opts, ...)
  opts = opts or {}
  opts.border = opts.border or 'rounded'

  return orig_util_open_floating_preview(contents, syntax, opts, ...)
end

---------------- SOME KEYMAPS ----------------------------------------
----------------------------------------------------------------------
vim.keymap.set('n', '<leader>meh', function() vim.lsp.util.open_floating_preview({"Hi World"}) end, { desc = '[e]xample [h]over window' })

vim.keymap.set('v', '<leader>mc', ':norm g_lD0x<CR>', { desc = '[c]leanup pasted text' })
vim.keymap.set('n', '<leader>ms', ':source %<CR>', { desc = '[s]ource active buffer' })

---------------- FILE SPECIFIC BEHAVIOUR -----------------------------
----------------------------------------------------------------------
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

---------------- A POPUP WINDOW --------------------------------------
----------------------------------------------------------------------
local function open_popup(lines)
  lines = lines or {''}
  local function win_config()
    local width = vim.o.columns - 9
    local height = vim.o.lines - 9
    return {
      relative = 'editor',
      width = width,
      height = height,
      col = math.floor((vim.o.columns - width) / 2),
      row = math.floor((vim.o.lines - height) / 2),
      border = 'rounded',
      title = '── <Esc>: Close ',
    }
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_open_win(buf, true, win_config())
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(0, { #lines, 0 })

  vim.keymap.set('n', '<Esc>', function() vim.api.nvim_win_close(0, false) end, { buffer = buf, desc = 'Abort' })
end

-- for command output
local function edit_command_output()
  local cmd = vim.fn.input('Command to execute: ', '', 'command')
  if not cmd or cmd == '' then
    print 'Command cancelled.'
    return
  end
  local output = vim.fn.execute(cmd)
  local lines = vim.split(output, '\n')
  open_popup(lines)
end
vim.keymap.set('n', '<Leader>mec', edit_command_output, { desc = 'Edit [M]essage Output'})

-- for messages
local function edit_messages()
  local output = vim.fn.execute('messages')
  local lines = vim.split(output, '\n')
  open_popup(lines)
end
vim.keymap.set('n', '<Leader>mem', edit_messages, { desc = 'Edit [C]ommand history' })
vim.keymap.set('n', '<leader>mp', open_popup,  { desc = 'Open [P]opup' })
