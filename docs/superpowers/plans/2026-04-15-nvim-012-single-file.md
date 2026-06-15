# Neovim 0.12 Single File Config Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [x]`) syntax for tracking.

**Goal:** Replace the current multi-file `lazy.nvim` config with one compact Neovim 0.12 `init.lua`.

**Architecture:** Move all Neovim behavior into `.config/nvim/init.lua`, grouped by section. Use `vim.pack` for the small approved plugin set and native `vim.lsp.config()` / `vim.lsp.enable()` for language servers. Remove old module files and the `lazy.nvim` lockfile after the new config starts successfully.

**Tech Stack:** Neovim 0.12.1, Lua, `vim.pack`, `blink.cmp`, `snacks.nvim`, `mini.nvim`, `conform.nvim`, `nvim-treesitter`, `tokyonight.nvim`, `vim-sleuth`.

---

### Task 1: Build The Single Config File

**Files:**
- Modify: `.config/nvim/init.lua`

- [x] **Step 1: Replace module requires with sectioned config**

Use these sections in order:

```lua
-- Basics
-- Options
-- Keymaps
-- Autocmds
-- Plugins
-- Theme
-- Mini
-- Snacks
-- Completion
-- Treesitter
-- Formatting
-- LSP
```

The `Plugins` section must use:

```lua
vim.pack.add({
  { src = 'https://github.com/folke/tokyonight.nvim' },
  { src = 'https://github.com/echasnovski/mini.nvim' },
  { src = 'https://github.com/folke/snacks.nvim' },
  { src = 'https://github.com/saghen/blink.cmp', version = 'v1' },
  { src = 'https://github.com/nvim-treesitter/nvim-treesitter', version = 'main' },
  { src = 'https://github.com/stevearc/conform.nvim' },
  { src = 'https://github.com/tpope/vim-sleuth' },
})
```

- [x] **Step 2: Run startup verification**

Run:

```bash
nvim --headless +q
```

Expected: exits with code 0.

- [x] **Step 3: Fix startup errors**

If startup fails, fix only `.config/nvim/init.lua` until `nvim --headless +q` exits with code 0.

### Task 2: Configure Plugins Compactly

**Files:**
- Modify: `.config/nvim/init.lua`

- [x] **Step 1: Configure retained plugins**

Configure:

```lua
vim.cmd.colorscheme('tokyonight-moon')
require('mini.ai').setup({ n_lines = 500 })
require('mini.surround').setup()
require('mini.pairs').setup()
require('mini.statusline').setup()
require('mini.comment').setup()
require('snacks').setup({ picker = { enabled = true }, explorer = { enabled = true }, terminal = { enabled = true }, bigfile = { enabled = true }, quickfile = { enabled = true }, indent = { enabled = true, animate = { enabled = false } } })
require('blink.cmp').setup({ keymap = { preset = 'default' }, sources = { default = { 'lsp', 'path', 'buffer' } }, signature = { enabled = true } })
local treesitter = require('nvim-treesitter')
local ts_langs = { 'bash', 'c', 'diff', 'go', 'gomod', 'gosum', 'gotmpl', 'hcl', 'html', 'lua', 'luadoc', 'markdown', 'markdown_inline', 'query', 'terraform', 'vim', 'vimdoc' }
treesitter.setup()
if vim.fn.executable('tree-sitter') == 1 and #vim.api.nvim_list_uis() > 0 then
  local installed = {}
  for _, lang in ipairs(treesitter.get_installed()) do installed[lang] = true end
  local missing = vim.tbl_filter(function(lang) return not installed[lang] end, ts_langs)
  if #missing > 0 then treesitter.install(missing) end
end
vim.api.nvim_create_autocmd('FileType', {
  pattern = ts_langs,
  callback = function()
    pcall(vim.treesitter.start)
    vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
  end,
})
```

- [x] **Step 2: Configure formatters**

Use:

```lua
require('conform').setup({
  format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
  formatters_by_ft = {
    lua = { 'stylua' },
    go = { 'goimports', 'gofumpt' },
    terraform = { 'terraform_fmt' },
    proto = { 'buf' },
  },
})
```

- [x] **Step 3: Run plugin verification**

Run:

```bash
nvim --headless +q
```

Expected: exits with code 0.

### Task 3: Configure LSP And Keymaps

**Files:**
- Modify: `.config/nvim/init.lua`

- [x] **Step 1: Add LSP attach mappings**

On `LspAttach`, map:

```lua
vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, opts)
vim.keymap.set({ 'n', 'x' }, '<leader>ca', vim.lsp.buf.code_action, opts)
vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
vim.keymap.set('n', 'gd', function() Snacks.picker.lsp_definitions() end, opts)
vim.keymap.set('n', 'gD', function() Snacks.picker.lsp_declarations() end, opts)
vim.keymap.set('n', 'gr', function() Snacks.picker.lsp_references() end, opts)
vim.keymap.set('n', 'gI', function() Snacks.picker.lsp_implementations() end, opts)
vim.keymap.set('n', 'gy', function() Snacks.picker.lsp_type_definitions() end, opts)
vim.keymap.set('n', '<leader>ss', function() Snacks.picker.lsp_symbols() end, opts)
vim.keymap.set('n', '<leader>sS', function() Snacks.picker.lsp_workspace_symbols() end, opts)
```

- [x] **Step 2: Add server configs**

Use native configs for:

```lua
vim.lsp.config('gopls', { settings = { gopls = { usePlaceholders = true, completeUnimported = true, staticcheck = true } } })
vim.lsp.config('terraformls', {})
vim.lsp.config('lua_ls', { settings = { Lua = { completion = { callSnippet = 'Replace' } } } })
vim.lsp.enable({ 'gopls', 'terraformls', 'lua_ls' })
```

- [x] **Step 3: Run LSP config verification**

Run:

```bash
nvim --headless +'lua vim.lsp.config("gopls", vim.lsp.config.gopls)' +q
```

Expected: exits with code 0.

### Task 4: Remove Old Config Files

**Files:**
- Delete: `.config/nvim/lua/config/autocommands.lua`
- Delete: `.config/nvim/lua/config/keymaps.lua`
- Delete: `.config/nvim/lua/config/lazy.lua`
- Delete: `.config/nvim/lua/config/options.lua`
- Delete: `.config/nvim/lua/plugins/autocompletion.lua`
- Delete: `.config/nvim/lua/plugins/extra.lua`
- Delete: `.config/nvim/lua/plugins/find_replace.lua`
- Delete: `.config/nvim/lua/plugins/formatting.lua`
- Delete: `.config/nvim/lua/plugins/git.lua`
- Delete: `.config/nvim/lua/plugins/go.lua`
- Delete: `.config/nvim/lua/plugins/lsp.lua`
- Delete: `.config/nvim/lua/plugins/mini.lua`
- Delete: `.config/nvim/lua/plugins/navigation.lua`
- Delete: `.config/nvim/lua/plugins/noice.lua`
- Delete: `.config/nvim/lua/plugins/snacks.lua`
- Delete: `.config/nvim/lua/plugins/theme.lua`
- Delete: `.config/nvim/lua/plugins/treesitter.lua`
- Delete: `.config/nvim/lazy-lock.json`

- [x] **Step 1: Delete old module files**

Remove all files listed above after the single `init.lua` passes startup verification.

- [x] **Step 2: Run final verification**

Run:

```bash
nvim --headless +q
nvim --headless '+checkhealth vim.pack' +q
stylua --check .config/nvim/init.lua
```

Expected: Neovim commands exit with code 0. `stylua` exits with code 0 if installed.

- [x] **Step 3: Confirm plugin surface**

Run:

```bash
rg "lazy.nvim|noice.nvim|gitsigns.nvim|diffview.nvim|fidget.nvim|go.nvim|grug-far.nvim|leap.nvim|vim-helm|friendly-snippets|mason" .config/nvim
```

Expected: no matches.
