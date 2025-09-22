print 'loading lua/custom/alois.lua'

vim.keymap.set('n', '<Leader>r', ':e<CR>', { noremap = true, silent = true, desc = 'Reload current file' })
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
end, { desc = 'Run a Vim command using vim.ui.input' })
