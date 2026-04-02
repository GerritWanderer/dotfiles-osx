-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file installs plugins outside of MINI.
-- Custom configuration lives in 'after/plugin/40_plugins.lua'.

local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- ┌─────────────────────────┐
-- │ Tree-sitter             │
-- └─────────────────────────┘
now_if_args(function()
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  local languages = {
    'lua', 'vimdoc', 'markdown',
    'javascript', 'typescript', 'tsx',
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  Config.new_autocmd('FileType', filetypes, function(ev) vim.treesitter.start(ev.buf) end, 'Start tree-sitter')
end)

-- ┌─────────────────────────┐
-- │ Language Servers        │
-- └─────────────────────────┘
now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })
  vim.lsp.enable({
    'lua_ls',    -- Install: brew install lua-language-server
    'tsgo',      -- Install: npm install @typescript/native-preview
    -- 'ts_ls',  -- Install: npm install -g typescript typescript-language-server
    'eslint',    -- Install: npm install -g vscode-langservers-extracted
  })
end)

-- ┌─────────────────────────┐
-- │ Formatting              │
-- └─────────────────────────┘
later(function() add({ 'https://github.com/stevearc/conform.nvim' }) end)

-- ┌─────────────────────────┐
-- │ Neotree                 │
-- └─────────────────────────┘
later(function()
  add({
    'https://github.com/nvim-neo-tree/neo-tree.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
  })
end)

-- ┌─────────────────────────┐
-- │ UI enhancements         │
-- └─────────────────────────┘
-- Must be set up before first draw to intercept startup messages.
-- See 'after/plugin/40_plugins.lua' for other plugin configurations.
now(function()
  add({
    'https://github.com/folke/noice.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
  })
  require('noice').setup({
    notify = { enabled = false },
    lsp = {
      override = {
        ['vim.lsp.util.convert_input_to_markdown_lines'] = true,
        ['vim.lsp.util.stylize_markdown'] = true,
      },
    },
    presets = {
      bottom_search         = true,  -- classic bottom search bar
      command_palette       = true,  -- cmdline and popupmenu positioned together
      long_message_to_split = true,  -- long messages go to a split
    },
  })
end)

-- ┌─────────────────────────┐
-- │ Color scheme            │
-- └─────────────────────────┘
now(function()
  add({ 'https://github.com/folke/tokyonight.nvim' })
  require('tokyonight').setup({ style = 'night' })
  vim.cmd('colorscheme tokyonight')
end)

-- ┌─────────────────────────┐
-- │ Snacks                  │
-- └─────────────────────────┘
later(function() add({ 'https://github.com/folke/snacks.nvim' }) end)

-- ┌─────────────────────────┐
-- │ Smart splits            │
-- └─────────────────────────┘
later(function() add({ 'https://github.com/mrjones2014/smart-splits.nvim' }) end)

-- ┌─────────────────────────┐
-- │ Completion              │
-- └─────────────────────────┘
later(function() add({ { src = 'https://github.com/Saghen/blink.cmp', version = 'v1.10.0' } }) end)

-- ┌─────────────────────────┐
-- │ Jump / navigation       │
-- └─────────────────────────┘
later(function() add({ 'https://github.com/folke/flash.nvim' }) end)
