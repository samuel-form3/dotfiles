-- Fast saving
vim.keymap.set('n', '<Leader>w', ':write!<CR>', { desc = 'Write', silent = true })
vim.keymap.set('n', '<Leader>q', ':q!<CR>', { desc = 'Quit', silent = true })
-- Remove search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')
-- Exit on jj and jk
vim.keymap.set('n', 'j', 'gj')
vim.keymap.set('n', 'k', 'gk')
-- Exit on jj and jk
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('i', 'jk', '<ESC>')
-- Go back to visual mode after reindent
vim.keymap.set('v', '<', '<gv', { desc = 'Go back to visual mode after reindent' })
vim.keymap.set('v', '>', '>gv', { desc = 'Go back to visual mode after reindent' })
-- Move selection
vim.keymap.set('v', '<C-j>', ":m '>+1<CR>gv=gv", { desc = 'Move selection down', silent = true })
vim.keymap.set('v', '<C-k>', ":m '<-2<CR>gv=gv", { desc = 'Move selection up', silent = true })
-- Utils
vim.keymap.set('n', '0', '^', { desc = 'Go to first non-whitespace character of the line' })
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank til end of line' })
-- Diagnostic keymaps
vim.keymap.set('n', '<leader>dp', vim.diagnostic.goto_prev, { desc = 'Go to [P]revious Diagnostic message' })
vim.keymap.set('n', '<leader>dn', vim.diagnostic.goto_next, { desc = 'Go to [N]ext diagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setqflist, { desc = 'Load diagnostics into [Q]uickfix' })
vim.keymap.set('n', '<leader>cn', '<CMD>cnext<CR>zz', { desc = 'Forward quickfix' })
vim.keymap.set('n', '<leader>cp', '<CMD>cprev<CR>zz', { desc = 'Previous quickfix' })
vim.keymap.set('n', '<leader>cc', '<CMD>cclose<CR>zz', { desc = 'Close quickfix' })
vim.keymap.set('n', '<leader>co', '<CMD>copen<CR>zz', { desc = 'Open quickfix' })
-- Terminal keymaps
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })
-- Leap Keymaps
vim.keymap.set('n', 't', '<Plug>(leap)')
vim.keymap.set('n', 'T', '<Plug>(leap-from-window)')
vim.keymap.set({ 'x', 'o' }, 't', '<Plug>(leap-forward)')
vim.keymap.set({ 'x', 'o' }, 'T', '<Plug>(leap-backward)')
