-- ┌─────────────────────────┐
-- │ Plugin configuration    │
-- └─────────────────────────┘
--
-- Custom configuration for plugins installed in 'plugin/40_plugins.lua'.
-- Plugins using later() have their add() there and setup() here.
-- Plugins using now() keep add() and setup() together in this file.

local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- ┌─────────────────────────┐
-- │ Tree-sitter             │
-- └─────────────────────────┘
now_if_args(function()
  require('treesitter-modules').setup({
    incremental_selection = {
      enable = true,
      keymaps = {
        init_selection    = '<A-i>',
        node_incremental  = '<A-i>',
        node_decremental  = '<A-o>',
        scope_incremental = false,
      },
    },
  })
end)

-- ┌─────────────────────────┐
-- │ Formatting              │
-- └─────────────────────────┘
later(function()
  require('conform').setup({
    default_format_opts = {
      lsp_format = 'fallback',
    },
    formatters_by_ft = {
      javascript      = { 'biome' },
      javascriptreact = { 'biome' },
      typescript      = { 'biome' },
      typescriptreact = { 'biome' },
      json            = { 'biome' },
      jsonc           = { 'biome' },
      css             = { 'prettier' },
      html            = { 'prettier' },
      markdown        = { 'prettier' },
    },
  })
end)

-- ┌─────────────────────────┐
-- │ Neotree                 │
-- └─────────────────────────┘
later(function()
  require('neo-tree').setup({
    sources = { 'filesystem', 'buffers', 'git_status' },
    open_files_do_not_replace_types = { 'terminal', 'qf' },

    filesystem = {
      bind_to_cwd = false,
      use_libuv_file_watcher = true,
      follow_current_file = { enabled = true, leave_dirs_open = true },
      filtered_items = {
        visible = true,
        show_hidden_count = true,
        hide_dotfiles = false,
        hide_gitignored = true,
        hide_by_name = { 'node_modules', 'git' },
        never_show = { '.git' },
      },
    },

    buffers = {
      follow_current_file = { enabled = true, leave_dirs_open = true },
    },

    window = {
      mappings = {
        ['<space>'] = 'none',
        ['s']       = false,
        ['h']       = 'close_node',
        ['l']       = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' then
            state.commands['toggle_node'](state)
          else
            local neo_win = vim.api.nvim_get_current_win()
            state.commands['open'](state)
            vim.api.nvim_set_current_win(neo_win)
          end
        end,
        ['<cr>']    = function(state)
          state.commands['open'](state)
          require('neo-tree.command').execute({ action = 'close' })
        end,
      },
    },

    default_component_configs = {
      indent = {
        with_expanders       = true,
        expander_collapsed   = '',
        expander_expanded    = '',
        expander_highlight   = 'NeoTreeExpander',
      },
      git_status = {
        symbols = {
          unstaged = '󰄱',
          staged   = '',
        },
      },
    },
  })
end)

-- ┌─────────────────────────┐
-- │ Jump / navigation       │
-- └─────────────────────────┘
-- Note: default flash uses `s` which conflicts with 'mini.surround', so `S` is used.
later(function()
  require('flash').setup({
    modes = {
      search = { enabled = false },
    },
  })
  local flash = require('flash')
  vim.keymap.set({ 'n', 'x', 'o' }, 'S', function() flash.jump() end, { desc = 'Flash jump' })
end)

-- ┌─────────────────────────┐
-- │ Telescope               │
-- └─────────────────────────┘
later(function()
  require('telescope').setup({
    defaults = {
      sorting_strategy = 'ascending',
      layout_config = { prompt_position = 'top' },
      mappings = {
        i = { ['<C-n>'] = 'cycle_history_next', ['<C-p>'] = 'cycle_history_prev', ['<C-g>'] = 'to_fuzzy_refine' },
      },
    },
    pickers = {
      find_files = { hidden = true },
      live_grep  = { additional_args = { '--hidden' } },
    },
    extensions = {
      fzf = {},
    },
  })
  require('telescope').load_extension('fzf')
end)

-- ┌─────────────────────────┐
-- │ Scratchpad              │
-- └─────────────────────────┘
-- A persistent floating scratch buffer, toggled with <leader>.
-- Content is saved to disk and survives across Neovim sessions.
now(function()
  local scratch_file    = vim.fn.stdpath('data') .. '/scratch.ts'
  local scratch_augroup = vim.api.nvim_create_augroup('MiniMaxScratch', { clear = true })

  Config.open_scratch = Config.make_modal({
    title = 'Scratch',
    create_buf = function(modal)
      local b = vim.fn.bufadd(scratch_file)
      vim.fn.bufload(b)
      vim.bo[b].buflisted = false
      vim.bo[b].filetype  = 'typescript'
      vim.api.nvim_create_autocmd('BufLeave', {
        group    = scratch_augroup,
        buffer   = b,
        callback = function()
          if vim.bo[b].modified then
            vim.api.nvim_buf_call(b, function() vim.cmd('silent write') end)
          end
        end,
      })
      vim.keymap.set('n', 'q', modal.close, { buffer = b, nowait = true, desc = 'Close scratch' })
      return b
    end,
  })
end)

-- ┌─────────────────────────┐
-- │ Smart splits            │
-- └─────────────────────────┘
-- Seamless navigation between Neovim splits and tmux panes.
-- Overrides mini.basics <C-hjkl> mappings set in 'plugin/30_mini.lua'.
later(function()
  local ss = require('smart-splits')
  -- Navigate between Neovim splits and tmux panes
  vim.keymap.set('n', '<C-h>', ss.move_cursor_left,  { desc = 'Navigate left' })
  vim.keymap.set('n', '<C-j>', ss.move_cursor_down,  { desc = 'Navigate down' })
  vim.keymap.set('n', '<C-k>', ss.move_cursor_up,    { desc = 'Navigate up' })
  vim.keymap.set('n', '<C-l>', ss.move_cursor_right, { desc = 'Navigate right' })
  -- Resize Neovim splits and tmux panes
  vim.keymap.set('n', '<C-M-h>', ss.resize_left,  { desc = 'Resize left' })
  vim.keymap.set('n', '<C-M-j>', ss.resize_down,  { desc = 'Resize down' })
  vim.keymap.set('n', '<C-M-k>', ss.resize_up,    { desc = 'Resize up' })
  vim.keymap.set('n', '<C-M-l>', ss.resize_right, { desc = 'Resize right' })
end)

