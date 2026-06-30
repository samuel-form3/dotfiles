-- Basics
vim.g.mapleader = ' '
vim.g.maplocalleader = ','

local map = vim.keymap.set
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Options
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = 'a'
vim.opt.showmode = false
vim.opt.breakindent = true
vim.opt.undofile = true
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.signcolumn = 'yes'
vim.opt.updatetime = 250
vim.opt.timeoutlen = 300
vim.opt.ttimeoutlen = 10
vim.opt.splitright = true
vim.opt.splitbelow = true
vim.opt.termguicolors = true
vim.opt.inccommand = 'split'
vim.opt.cursorline = true
vim.opt.scrolloff = 10
vim.opt.hlsearch = true
vim.opt.cmdheight = 1
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.writebackup = false
vim.opt.wrap = true
vim.opt.expandtab = true
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.smarttab = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.joinspaces = false
vim.opt.list = true
vim.opt.listchars = { tab = '> ', extends = '>', precedes = '<', trail = '.' }
vim.opt.fillchars = { eob = ' ', fold = ' ' }
vim.opt.foldcolumn = 'auto'
vim.opt.foldmethod = 'indent'
vim.opt.foldlevel = 99
vim.opt.foldenable = false

vim.schedule(function()
  vim.opt.clipboard = 'unnamedplus'
end)

-- Keymaps
map('n', '<leader>w', '<cmd>write<cr>', { desc = 'Write' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
map('n', '<leader>x', '<cmd>x<cr>', { desc = 'Write and quit' })
map('n', '<leader>Q', '<cmd>qa<cr>', { desc = 'Quit all' })
map('n', '<esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })
map('n', 'j', 'gj', { desc = 'Down by display line' })
map('n', 'k', 'gk', { desc = 'Up by display line' })
map('i', 'jj', '<esc>', { desc = 'Normal mode' })
map('i', 'jk', '<esc>', { desc = 'Normal mode' })
map('v', '<', '<gv', { desc = 'Indent left and reselect' })
map('v', '>', '>gv', { desc = 'Indent right and reselect' })
map('v', '<c-j>', ":m '>+1<cr>gv=gv", { desc = 'Move selection down' })
map('v', '<c-k>', ":m '<-2<cr>gv=gv", { desc = 'Move selection up' })
map('n', '0', '^', { desc = 'First non-blank character' })
map('n', 'Y', 'y$', { desc = 'Yank to end of line' })
map('n', '<s-l>', '<cmd>bnext<cr>', { desc = 'Next buffer' })
map('n', '<s-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>sr', [[:%s/\<<c-r><c-w>\>//g<left><left>]], { desc = 'Replace word in buffer' })
map('n', '[d', function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = 'Previous diagnostic' })
map('n', ']d', function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = 'Next diagnostic' })
map('n', '<leader>de', vim.diagnostic.open_float, { desc = 'Diagnostic float' })
map('n', '<leader>dq', vim.diagnostic.setqflist, { desc = 'Diagnostics to quickfix' })
map('n', '<leader>dt', function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = 'Toggle diagnostics' })
map('n', '<leader>lr', '<cmd>LspRestart<cr>', { desc = 'LSP restart' })
map('n', '<leader>co', '<cmd>copen<cr>', { desc = 'Open quickfix' })
map('n', '<leader>cc', '<cmd>cclose<cr>', { desc = 'Close quickfix' })
map('n', '<leader>cn', '<cmd>cnext<cr>zz', { desc = 'Next quickfix' })
map('n', '<leader>cp', '<cmd>cprev<cr>zz', { desc = 'Previous quickfix' })
map('t', '<esc><esc>', '<c-\\><c-n>', { desc = 'Exit terminal mode' })

local function go_root_and_pkg()
  local dir = vim.fn.expand('%:p:h')
  local root = vim.fs.root(dir, { 'go.work', 'go.mod' }) or dir
  local rel = vim.fs.relpath(root, dir)
  local pkg = rel and rel ~= '' and './' .. rel or '.'
  return root, pkg
end

local function go_test(opts)
  opts = opts or {}
  local root, pkg = go_root_and_pkg()
  local cmd = { 'go', 'test', '-count=1' }
  if opts.run then
    cmd[#cmd + 1] = '-run'
    cmd[#cmd + 1] = vim.fn.shellescape(opts.run)
  end
  cmd[#cmd + 1] = opts.pkg or pkg

  vim.cmd.write()
  vim.cmd.botright('split')
  vim.cmd.terminal('cd ' .. vim.fn.shellescape(root) .. ' && ' .. table.concat(cmd, ' '))
  vim.cmd.startinsert()
end

local function go_enclosing_test_func()
  if vim.bo.filetype ~= 'go' then
    return nil
  end

  local node = vim.treesitter.get_node()
  while node do
    if node:type() == 'function_declaration' or node:type() == 'method_declaration' then
      local name_node = node:field('name')
      if name_node then
        local name = vim.treesitter.get_node_text(name_node, 0)
        if name:match('^Test') then
          return name
        end
      end
    end
    node = node:parent()
  end

  local row = vim.api.nvim_win_get_cursor(0)[1] - 1
  for i = row, 0, -1 do
    local line = vim.api.nvim_buf_get_lines(0, i, i + 1, false)[1]
    local name = line:match('^func %(?%*?[%w%.]+%)? (Test%w+)')
    if name then
      return name
    end
  end
end

local function go_test_funcs_in_file()
  local names = {}
  for _, line in ipairs(vim.api.nvim_buf_get_lines(0, 0, -1, false)) do
    local name = line:match('^func %(?%*?[%w%.]+%)? (Test%w+)')
    if name then
      names[#names + 1] = name
    end
  end
  return names
end

map('n', '<leader>Tp', function()
  go_test()
end, { desc = 'Go test package' })
map({ 'n', 'x' }, '<leader>Tt', function()
  local name = go_enclosing_test_func()
  if not name then
    vim.notify('No test function at cursor', vim.log.levels.WARN)
    return
  end
  go_test({ run = '^' .. name .. '$' })
end, { desc = 'Go test function' })
map('n', '<leader>Tf', function()
  local names = go_test_funcs_in_file()
  if #names == 0 then
    vim.notify('No test functions in file', vim.log.levels.WARN)
    return
  end
  go_test({ run = '^(' .. table.concat(names, '|') .. ')$' })
end, { desc = 'Go test file' })

-- Autocmds
autocmd('TextYankPost', {
  group = augroup('user-highlight-yank', { clear = true }),
  desc = 'Highlight yanked text',
  callback = function()
    vim.highlight.on_yank()
  end,
})

autocmd({ 'VimEnter', 'WinEnter', 'BufWinEnter', 'WinLeave', 'BufWinLeave' }, {
  group = augroup('user-cursorline', { clear = true }),
  desc = 'Cursorline only in active windows',
  callback = function(event)
    vim.opt_local.cursorline = event.event:find('Enter') ~= nil
  end,
})

-- Plugins
vim.pack.add({
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
  { src = 'https://github.com/folke/which-key.nvim' },
  { src = 'https://git.disroot.org/andyg/leap.nvim' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/tpope/vim-sleuth' },
}, { confirm = false })

-- Theme
if vim.fn.has('mac') == 1 then
  local appearance = vim.system({ 'defaults', 'read', '-g', 'AppleInterfaceStyle' }, { text = true }):wait()
  vim.o.background = appearance.stdout:match('Dark') and 'dark' or 'light'
end

vim.cmd.colorscheme('tokyonight')

-- Mini
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.statusline').setup()
require('mini.comment').setup()

-- Which-key
require('which-key').setup({
  preset = 'helix',
  spec = {
    { '<leader>b', group = 'Buffer' },
    { '<leader>c', group = 'Quickfix' },
    { '<leader>d', group = 'Diagnostics' },
    { '<leader>f', group = 'Find' },
    { '<leader>g', group = 'Git' },
    { '<leader>l', group = 'LSP' },
    { '<leader>s', group = 'Search' },
    { '<leader>T', group = 'Test' },
    { '<leader>a', group = 'Actions' },
  },
})

map('n', '<leader>?', function()
  require('which-key').show({ global = false })
end, { desc = 'Buffer keymaps' })

map({ 'n', 'x', 'o' }, 't', '<Plug>(leap)', { desc = 'Leap' })

-- Snacks
local Snacks = require('snacks')
Snacks.setup({
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { section = 'keys', gap = 1, padding = 1 },
    },
    preset = {
      keys = {
        { icon = ' ', key = 'f', desc = 'Find File', action = ':lua Snacks.dashboard.pick("files")' },
        { icon = ' ', key = 'n', desc = 'New File', action = ':ene | startinsert' },
        { icon = ' ', key = 'g', desc = 'Find Text', action = ':lua Snacks.dashboard.pick("live_grep")' },
        { icon = ' ', key = 'r', desc = 'Recent Files', action = ':lua Snacks.dashboard.pick("oldfiles")' },
        { icon = ' ', key = 'c', desc = 'Config', action = ':lua Snacks.dashboard.pick("files", {cwd = vim.fn.stdpath("config")})' },
        { icon = ' ', key = 'q', desc = 'Quit', action = ':qa' },
      },
    },
  },
  quickfile = { enabled = true },
  indent = { enabled = true, animate = { enabled = false } },
  input = { enabled = true },
  notifier = { enabled = true, timeout = 3000 },
  terminal = { enabled = true, win = { wo = { winbar = '' } } },
  picker = {
    enabled = true,
    sources = {
      explorer = {
        win = {
          list = {
            keys = {
              ['<s-i>'] = 'toggle_ignored',
              ['<s-h>'] = 'toggle_hidden',
              ['<tab>'] = 'confirm',
            },
          },
        },
      },
    },
    win = {
      input = {
        keys = {
          ['<c-i>'] = { 'toggle_ignored', mode = { 'i', 'n' } },
          ['<c-h>'] = { 'toggle_hidden', mode = { 'i', 'n' } },
        },
      },
    },
  },
  explorer = { enabled = true },
})

map('n', '<leader>e', function()
  Snacks.explorer()
end, { desc = 'Explorer' })
map('n', '<leader><space>', function()
  Snacks.picker.files()
end, { desc = 'Find files' })
map('n', '<leader>,', function()
  Snacks.picker.buffers()
end, { desc = 'Buffers' })
map('n', '<leader>/', function()
  Snacks.picker.grep()
end, { desc = 'Grep' })
map('n', '<leader>ff', function()
  Snacks.picker.files()
end, { desc = 'Find files' })
map('n', '<leader>fg', function()
  Snacks.picker.git_files()
end, { desc = 'Find git files' })
map('n', '<leader>fr', function()
  Snacks.picker.recent()
end, { desc = 'Recent files' })
map('n', '<leader>sb', function()
  Snacks.picker.lines()
end, { desc = 'Buffer lines' })
map('n', '<leader>sg', function()
  Snacks.picker.grep()
end, { desc = 'Grep' })
map({ 'n', 'x' }, '<leader>sw', function()
  Snacks.picker.grep_word()
end, { desc = 'Grep word or selection' })
map('n', '<leader>sd', function()
  Snacks.picker.diagnostics()
end, { desc = 'Diagnostics' })
map('n', '<leader>sh', function()
  Snacks.picker.help()
end, { desc = 'Help' })
map('n', '<leader>sk', function()
  Snacks.picker.keymaps()
end, { desc = 'Keymaps' })
map('n', '<leader>sq', function()
  Snacks.picker.qflist()
end, { desc = 'Quickfix' })
map('n', '<leader>gB', function()
  Snacks.gitbrowse()
end, { desc = 'Git browse' })
map('n', '<leader>gb', function()
  Snacks.git.blame_line()
end, { desc = 'Git blame line' })
map('n', '<leader>gf', function()
  Snacks.lazygit.log_file()
end, { desc = 'Lazygit file history' })
map('n', '<leader>gg', function()
  Snacks.lazygit()
end, { desc = 'Lazygit' })
map('n', '<leader>gs', function()
  Snacks.picker.git_status()
end, { desc = 'Git status' })
map('n', '<leader>gc', function()
  Snacks.picker.git_log()
end, { desc = 'Git log' })
map('n', '<leader>bd', function()
  Snacks.bufdelete()
end, { desc = 'Delete buffer' })

-- Completion
local blink = require('blink.cmp')
blink.setup({
  keymap = { preset = 'default' },
  appearance = { nerd_font_variant = 'mono' },
  sources = { default = { 'lsp', 'path', 'buffer' } },
  signature = { enabled = true },
})

-- Treesitter
local treesitter = require('nvim-treesitter')
local ts_langs = {
  'bash',
  'c',
  'diff',
  'go',
  'gomod',
  'gosum',
  'gotmpl',
  'hcl',
  'html',
  'lua',
  'luadoc',
  'markdown',
  'markdown_inline',
  'query',
  'terraform',
  'vim',
  'vimdoc',
}

treesitter.setup()

if vim.fn.executable('tree-sitter') == 1 and #vim.api.nvim_list_uis() > 0 then
  local installed = {}
  for _, lang in ipairs(treesitter.get_installed()) do
    installed[lang] = true
  end

  local missing = vim.tbl_filter(function(lang)
    return not installed[lang]
  end, ts_langs)

  if #missing > 0 then
    treesitter.install(missing)
  end
end

autocmd('FileType', {
  group = augroup('user-treesitter', { clear = true }),
  pattern = ts_langs,
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})

-- Formatting
local conform = require('conform')
conform.setup({
  notify_on_error = false,
  format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'goimports', 'gofumpt' },
    terraform = { 'terraform_fmt' },
    proto = { 'buf' },
  },
})

map('', '<leader>af', function()
  conform.format({ async = true, lsp_format = 'fallback' })
end, { desc = 'Format buffer' })

-- LSP
vim.diagnostic.config({
  virtual_text = { current_line = true },
  underline = true,
  severity_sort = true,
  float = { border = 'rounded', source = false },
})

autocmd('LspAttach', {
  group = augroup('user-lsp-attach', { clear = true }),
  callback = function(event)
    local opts = function(desc)
      return { buffer = event.buf, desc = 'LSP: ' .. desc }
    end
    local client = vim.lsp.get_client_by_id(event.data.client_id)

    map('n', '<leader>rn', vim.lsp.buf.rename, opts('Rename'))
    map({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, opts('Code action'))
    map('n', 'K', vim.lsp.buf.hover, opts('Hover'))
    map('n', 'gd', function()
      Snacks.picker.lsp_definitions()
    end, opts('Definition'))
    map('n', 'gD', function()
      Snacks.picker.lsp_declarations()
    end, opts('Declaration'))
    map('n', 'gr', function()
      Snacks.picker.lsp_references()
    end, opts('References'))
    map('n', 'gI', function()
      Snacks.picker.lsp_implementations()
    end, opts('Implementation'))
    map('n', 'gy', function()
      Snacks.picker.lsp_type_definitions()
    end, opts('Type definition'))
    map('n', '<leader>ss', function()
      Snacks.picker.lsp_symbols()
    end, opts('Document symbols'))
    map('n', '<leader>sS', function()
      Snacks.picker.lsp_workspace_symbols()
    end, opts('Workspace symbols'))

    if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_inlayHint) then
      vim.lsp.inlay_hint.enable(true, { bufnr = event.buf })
    end
  end,
})

vim.lsp.config('*', { capabilities = blink.get_lsp_capabilities() })
vim.lsp.config('gopls', {
  cmd = { 'gopls' },
  filetypes = { 'go', 'gomod', 'gowork', 'gotmpl' },
  root_markers = { 'go.work', 'go.mod', '.git' },
  settings = {
    gopls = {
      usePlaceholders = true,
      completeUnimported = true,
      staticcheck = true,
      analyses = {
        unusedparams = true,
        unreachable = true,
        fieldalignment = false,
      },
      hints = {
        assignVariableTypes = false,
        compositeLiteralFields = true,
        constantValues = true,
        rangeVariableTypes = false,
      },
      codelenses = {
        generate = true,
        gc_details = false,
        test = true,
        tidy = true,
        upgrade_dependency = true,
      },
    },
  },
})
vim.lsp.config('terraformls', {
  cmd = { 'terraform-ls', 'serve' },
  filetypes = { 'terraform', 'terraform-vars' },
  root_markers = { '.terraform', '.git' },
})
vim.lsp.config('lua_ls', {
  cmd = { 'lua-language-server' },
  filetypes = { 'lua' },
  root_markers = {
    { '.luarc.json', '.luarc.jsonc' },
    { '.luacheckrc', '.stylua.toml', 'stylua.toml', 'selene.toml', 'selene.yml' },
    { '.git' },
  },
  settings = {
    Lua = {
      completion = { callSnippet = 'Replace' },
      hint = { enable = true, semicolon = 'Disable' },
      workspace = { checkThirdParty = false },
    },
  },
})
vim.lsp.enable({ 'gopls', 'terraformls', 'lua_ls' })
