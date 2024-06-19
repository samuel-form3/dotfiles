-- Fast saving
vim.keymap.set('n', '<Leader>w', ':write!<CR>', { silent = true })
vim.keymap.set('n', '<Leader>q', ':q!<CR>', { silent = true })

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

-- Split resizes
vim.keymap.set('n', '<M-j>', ':resize -2<CR>', { desc = 'Decrease window height' })
vim.keymap.set('n', '<M-k>', ':resize +3<CR>', { desc = 'Increase window height' })
vim.keymap.set('n', '<M-h>', ':vertical resize -10<CR>', { desc = 'Decrease window width' })
vim.keymap.set('n', '<M-l>', ':vertical resize +10<CR>', { desc = 'Increase window width' })

-- Utils
vim.keymap.set('n', '0', '^', { desc = 'Go to first non-whitespace character of the line' })
vim.keymap.set('n', 'Y', 'y$', { desc = 'Yank til end of line' })

-- Diagnostic keymaps
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, { desc = 'Go to previous [D]iagnostic message' })
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, { desc = 'Go to next [D]iagnostic message' })
vim.keymap.set('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Show diagnostic [E]rror messages' })
vim.keymap.set('n', '<leader>dq', vim.diagnostic.setloclist, { desc = 'Open diagnostic [Q]uickfix list' })

-- Terminal keymaps
vim.keymap.set('t', '<Esc><Esc>', '<C-\\><C-n>', { desc = 'Exit terminal mode' })

-- Oil
vim.keymap.set('n', '<leader>-', '<CMD>Oil<CR>', { desc = 'Open parent directory' })

-- Tree
vim.keymap.set('n', '<leader>e', '<CMD>NvimTreeToggle<CR>', { silent = true, noremap = true })

-- Git keymaps
vim.keymap.set('n', '<leader>gp', '<CMD>Gitsigns preview_hunk<CR>', { desc = 'Preview git hunk' })

-- Leap Keymaps
vim.keymap.set('n', 't', '<Plug>(leap)')
vim.keymap.set('n', 'T', '<Plug>(leap-from-window)')
vim.keymap.set({ 'x', 'o' }, 't', '<Plug>(leap-forward)')
vim.keymap.set({ 'x', 'o' }, 'T', '<Plug>(leap-backward)')

-- Buffer keymaps
vim.keymap.set('n', '<leader><Tab>', '<CMD>bnext!<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader><S-Tab>', '<CMD>bprev!<CR>', { silent = true, noremap = true })
vim.keymap.set('n', '<leader><Tab>d', '<CMD>bd!<CR>', { silent = true, noremap = true })
