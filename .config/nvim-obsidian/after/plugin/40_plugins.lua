-- ┌─────────────────────────┐
-- │ Plugin configuration    │
-- └─────────────────────────┘
--
-- Custom configuration for plugins installed in 'plugin/40_plugins.lua'.
-- Plugins with add() + setup() in the same later() block live in plugin/40_plugins.lua.
-- Only plugins needing a separate setup phase live here.

local later = Config.later

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
  })
end)
