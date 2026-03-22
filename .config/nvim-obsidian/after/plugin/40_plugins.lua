-- ┌─────────────────────────┐
-- │ Plugin configuration    │
-- └─────────────────────────┘
--
-- Custom configuration for plugins installed in 'plugin/40_plugins.lua'.
-- Plugins with add() + setup() in the same later() block live in plugin/40_plugins.lua.
-- Only plugins needing a separate setup phase live here.

local later = Config.later

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
