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
-- │ Completion              │
-- └─────────────────────────┘
later(function()
  require('blink.cmp').setup({
    -- Use blink's built-in snippet handling (LSP snippets + friendly-snippets)
    snippets = { preset = 'default' },

    appearance = {
      -- Correct icon alignment for Nerd Font Mono
      nerd_font_variant = 'mono',
    },

    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
    },

    keymap = {
      -- <CR> confirms, <Tab>/<S-Tab> navigate — matches old mini.completion behavior
      preset = 'enter',
      -- Also allow <C-y> to confirm (vim-native muscle memory)
      ['<C-y>'] = { 'select_and_accept' },
    },

    completion = {
      menu = {
        draw = {
          -- Treesitter-based syntax highlighting in completion menu for LSP items
          treesitter = { 'lsp' },
        },
      },
      -- Show documentation popup alongside the completion menu
      documentation = { auto_show = true, auto_show_delay_ms = 200 },
      -- No ghost text
      ghost_text = { enabled = false },
    },
    fuzzy = { implementation = "lua" },
    cmdline = {
      enabled = true,
      keymap = { preset = 'cmdline' },
      completion = {
        list = { selection = { preselect = false } },
        -- Only auto-show menu for : commands, not / or ?
        menu = {
          auto_show = function(ctx) return vim.fn.getcmdtype() == ':' end,
        },
      },
    },

    -- Advertise blink.cmp capabilities to LSP servers
    -- (replaces MiniCompletion.get_lsp_capabilities())
  })

  -- Register blink.cmp capabilities with all LSP servers
  vim.lsp.config('*', { capabilities = require('blink.cmp').get_lsp_capabilities() })
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
-- │ Snacks                  │
-- └─────────────────────────┘
later(function()
  require('snacks').setup({
    lazygit  = { enabled = true },
    notify   = { enabled = true },
    scratch  = { enabled = true },
    terminal = { enabled = true },
    toggle   = { enabled = true },
    zen      = { enabled = true, toggles = { dim = false } },
    styles   = {
      zen = {
        width = 160,
        backdrop = { transparent = false },
      },
    },
    picker = {
      enabled = true,
      sources = {
        files = { hidden = true },
        grep  = { hidden = true },
      },
      win = {
        input = {
          keys = {
            ['<C-n>'] = { 'history_back',    mode = { 'i', 'n' } },
            ['<C-p>'] = { 'history_forward', mode = { 'i', 'n' } },
          },
        },
      },
    },
    -- disable all other snacks modules
    bigfile      = { enabled = false },
    bufdelete    = { enabled = false },
    dashboard    = { enabled = false },
    debug        = { enabled = false },
    dim          = { enabled = false },
    explorer     = { enabled = false },
    git          = { enabled = false },
    gitbrowse    = { enabled = false },
    image        = { enabled = false },
    indent       = { enabled = false },
    input        = { enabled = false },
    layout       = { enabled = false },
    notifier     = { enabled = false },
    profiler     = { enabled = false },
    quickfile    = { enabled = false },
    rename       = { enabled = false },
    scope        = { enabled = false },
    scroll       = { enabled = false },
    statuscolumn = { enabled = false },
    win          = { enabled = false },
    words        = { enabled = false },
  })
  Config.open_lazygit = function() require('snacks').lazygit() end
  Config.open_scratch = function() require('snacks').scratch() end
  Config.toggle_zen = function() require('snacks').zen() end
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

