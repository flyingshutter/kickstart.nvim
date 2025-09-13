print 'loading lua/custom/alois.lua'

vim.keymap.set('n', '<Leader>r', ':e<CR>', { noremap = true, silent = true, desc = 'Reload current file' })
-- Enable autoread and set up checking triggers
vim.o.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter' }, {
  command = "if mode() != 'c' | checktime | endif",
  pattern = '*',
})
