-- ┌─────────────────────────┐
-- │ Plugins outside of MINI │
-- └─────────────────────────┘
--
-- This file contains installation and configuration of plugins outside of MINI.
-- They significantly improve user experience in a way not yet possible with MINI.
-- These are mostly plugins that provide programming language specific behavior.
--
-- Use this file to install and configure other such plugins.

-- Make concise helpers for installing/adding plugins in two stages
local add = vim.pack.add
local now, now_if_args, later = Config.now, Config.now_if_args, Config.later

-- Tree-sitter ================================================================

-- Tree-sitter is a tool for fast incremental parsing. It converts text into
-- a hierarchical structure (called tree) that can be used to implement advanced
-- and/or more precise actions: syntax highlighting, textobjects, indent, etc.
--
-- Tree-sitter support is built into Neovim (see `:h treesitter`). However, it
-- requires two extra pieces that don't come with Neovim directly:
-- - Language parsers: programs that convert text into trees. Some are built-in
--   (like for Lua), 'nvim-treesitter' provides many others.
--   NOTE: It requires third party software to build and install parsers.
--   See the link for more info in "Requirements" section of the MiniMax README.
-- - Query files: definitions of how to extract information from trees in
--   a useful manner (see `:h treesitter-query`). 'nvim-treesitter' also provides
--   these, while 'nvim-treesitter-textobjects' provides the ones for Neovim
--   textobjects (see `:h text-objects`, `:h MiniAi.gen_spec.treesitter()`).
--
-- Add these plugins now if file (and not 'mini.starter') is shown after startup.
--
-- Troubleshooting:
-- - Run `:checkhealth vim.treesitter nvim-treesitter` to see potential issues.
-- - In case of errors related to queries for Neovim bundled parsers (like `lua`,
--   `vimdoc`, `markdown`, etc.), manually install them via 'nvim-treesitter'
--   with `:TSInstall <language>`. Be sure to have necessary system dependencies
--   (see MiniMax README section for software requirements).
now_if_args(function()
  -- Define hook to update tree-sitter parsers after plugin is updated
  local ts_update = function() vim.cmd('TSUpdate') end
  Config.on_packchanged('nvim-treesitter', { 'update' }, ts_update, ':TSUpdate')

  add({
    'https://github.com/nvim-treesitter/nvim-treesitter',
    'https://github.com/nvim-treesitter/nvim-treesitter-textobjects',
  })

  -- Define languages which will have parsers installed and auto enabled
  -- After changing this, restart Neovim once to install necessary parsers. Wait
  -- for the installation to finish before opening a file for added language(s).
  local languages = {
    -- These are already pre-installed with Neovim. Used as an example.
    'lua',
    'vimdoc',
    'markdown',
    -- Add here more languages with which you want to use tree-sitter
    -- To see available languages:
    -- - Execute `:=require('nvim-treesitter').get_available()`
    -- - Visit 'SUPPORTED_LANGUAGES.md' file at
    --   https://github.com/nvim-treesitter/nvim-treesitter/blob/main
  }
  local isnt_installed = function(lang)
    return #vim.api.nvim_get_runtime_file('parser/' .. lang .. '.*', false) == 0
  end
  local to_install = vim.tbl_filter(isnt_installed, languages)
  if #to_install > 0 then require('nvim-treesitter').install(to_install) end

  -- Enable tree-sitter after opening a file for a target language
  local filetypes = {}
  for _, lang in ipairs(languages) do
    for _, ft in ipairs(vim.treesitter.language.get_filetypes(lang)) do
      table.insert(filetypes, ft)
    end
  end
  local ts_start = function(ev) vim.treesitter.start(ev.buf) end
  Config.new_autocmd('FileType', filetypes, ts_start, 'Start tree-sitter')
end)

-- Language servers ===========================================================

-- Language Server Protocol (LSP) is a set of conventions that power creation of
-- language specific tools. It requires two parts:
-- - Server - program that performs language specific computations.
-- - Client - program that asks server for computations and shows results.
--
-- Here Neovim itself is a client (see `:h vim.lsp`). Language servers need to
-- be installed separately based on your OS, CLI tools, and preferences.
-- See note about 'mason.nvim' at the bottom of the file.
--
-- Neovim's team collects commonly used configurations for most language servers
-- inside 'neovim/nvim-lspconfig' plugin.
--
-- Add it now if file (and not 'mini.starter') is shown after startup.
now_if_args(function()
  add({ 'https://github.com/neovim/nvim-lspconfig' })

  -- Use `:h vim.lsp.enable()` to automatically enable language server based on
  -- the rules provided by 'nvim-lspconfig'.
  -- Use `:h vim.lsp.config()` or 'after/lsp/' directory to configure servers.
  -- Uncomment and tweak the following `vim.lsp.enable()` call to enable servers.
  -- vim.lsp.enable({
  --   -- For example, if `lua-language-server` is installed, use `'lua_ls'` entry
  -- })
end)

-- Formatting =================================================================

-- Programs dedicated to text formatting (a.k.a. formatters) are very useful.
-- Neovim has built-in tools for text formatting (see `:h gq` and `:h 'formatprg'`).
-- They can be used to configure external programs, but it might become tedious.
--
-- The 'stevearc/conform.nvim' plugin is a good and maintained solution for easier
-- formatting setup.
later(function()
  add({ 'https://github.com/stevearc/conform.nvim' })

  -- See also:
  -- - `:h Conform`
  -- - `:h conform-options`
  -- - `:h conform-formatters`
  require('conform').setup({
    default_format_opts = {
      -- Allow formatting from LSP server if no dedicated formatter is available
      lsp_format = 'fallback',
    },
    -- Map of filetype to formatters
    -- Make sure that necessary CLI tool is available
    -- formatters_by_ft = { lua = { 'stylua' } },
  })
end)

-- Snippets ===================================================================

-- Although 'mini.snippets' provides functionality to manage snippet files, it
-- deliberately doesn't come with those.
--
-- The 'rafamadriz/friendly-snippets' is currently the largest collection of
-- snippet files. They are organized in 'snippets/' directory (mostly) per language.
-- 'mini.snippets' is designed to work with it as seamlessly as possible.
-- See `:h MiniSnippets.gen_loader.from_lang()`.
later(function() add({ 'https://github.com/rafamadriz/friendly-snippets' }) end)

-- Telescope ==================================================================

-- telescope.nvim is a fuzzy finder used by obsidian.nvim for all picker actions
-- (searching notes, backlinks, tags, TOC, etc.)
later(function()
  add({
    'https://github.com/nvim-telescope/telescope.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/nvim-tree/nvim-web-devicons',
  })
end)

-- Obsidian ===================================================================

-- obsidian-nvim/obsidian.nvim is a community fork of the Obsidian plugin for
-- Neovim. It provides note navigation, daily notes, templates, backlinks, tags,
-- and more. Only active inside markdown files within the configured vault path.
--
-- Commands cheat sheet (all via `:Obsidian <Tab>` or the keymaps below):
--   Navigation:   <Leader>on (new from template)  <Leader>oq (quick switch)  <Leader>os (search)
--   Daily notes:  <Leader>ot (today)     <Leader>oy (yesterday)     <Leader>om (tomorrow)
--   Links:        <CR>       (smart act) [o / ]o    (prev/next link)
--   Note tools:   <Leader>ob (backlinks) <Leader>oc (toggle checkbox)
--                 <Leader>ol (links in note)  <Leader>od (daily list)
--                 <Leader>ow (switch workspace)
--   Templates:    <Leader>oi (insert template)
--   Visual:       <Leader>ox (extract selection to new note)  <Leader>ok (link selection)
later(function()
  add({ 'https://github.com/obsidian-nvim/obsidian.nvim' })

  ---@module 'obsidian'
  ---@type obsidian.config
  require('obsidian').setup({
    legacy_commands = false,

    workspaces = {
      {
        name = 'notes',
        path = '~/Documents/notes',
      },
    },

    -- New notes go into 01-Wildflowers by default
    notes_subdir = '01-Wildflowers',

    -- Slugify the title as note ID (e.g. "My Note" -> "my-note")
    note_id_func = function(title)
      return title:gsub(' ', '-'):gsub('[^A-Za-z0-9-]', ''):lower()
    end,

    -- Templates folder inside the vault
    templates = {
      folder = '99-extras/templates',
    },

    -- Use telescope for all picker actions
    picker = { name = 'telescope.nvim' },

    -- Open note in current window by default (change to 'vsplit' or 'hsplit' if preferred)
    open_notes_in = 'current',

    -- Daily notes configuration
    daily_notes = {
      folder = '00-Daily',
      date_format = '%Y/%m-%B/%Y-%m-%d-%A',
      default_tags = { 'type/daily' },
      template = 'daily',
    },

    -- Disable default UI extras (handled by treesitter in this config)
    ui = { enable = false },

    -- Keymaps: set up when entering a note buffer via ObsidianNoteEnter autocmd
    callbacks = {
      enter_note = function(_note)
        local actions = require('obsidian.actions')
        local buf = true -- buffer-local mapping

        -- Smart action: follow link / toggle checkbox / cycle fold / show tag notes
        vim.keymap.set('n', '<CR>', require('obsidian.api').smart_action, { buffer = buf, desc = 'Obsidian smart action' })

        -- Navigate between links in the note
        vim.keymap.set('n', ']o', function() actions.nav_link('next') end, { buffer = buf, desc = 'Next link' })
        vim.keymap.set('n', '[o', function() actions.nav_link('prev') end, { buffer = buf, desc = 'Previous link' })

        -- Note management
        vim.keymap.set('n', '<Leader>ob', '<Cmd>Obsidian backlinks<CR>',        { buffer = buf, desc = 'Obsidian backlinks' })
        vim.keymap.set('n', '<Leader>oc', '<Cmd>Obsidian toggle_checkbox<CR>',  { buffer = buf, desc = 'Obsidian toggle checkbox' })
        vim.keymap.set('n', '<Leader>od', '<Cmd>Obsidian dailies<CR>',          { buffer = buf, desc = 'Obsidian daily list' })
        vim.keymap.set('n', '<Leader>oi', '<Cmd>Obsidian template<CR>',         { buffer = buf, desc = 'Obsidian insert template' })
        vim.keymap.set('n', '<Leader>ol', '<Cmd>Obsidian links<CR>',            { buffer = buf, desc = 'Obsidian links in note' })
        vim.keymap.set('n', '<Leader>on', '<Cmd>Obsidian new_from_template<CR>', { buffer = buf, desc = 'Obsidian new note from template' })
        vim.keymap.set('n', '<Leader>oo', '<Cmd>Obsidian open<CR>',             { buffer = buf, desc = 'Obsidian open in app' })
        vim.keymap.set('n', '<Leader>oq', '<Cmd>Obsidian quick_switch<CR>',     { buffer = buf, desc = 'Obsidian quick switch' })
        vim.keymap.set('n', '<Leader>or', '<Cmd>Obsidian rename<CR>',           { buffer = buf, desc = 'Obsidian rename note' })
        vim.keymap.set('n', '<Leader>os', '<Cmd>Obsidian search<CR>',           { buffer = buf, desc = 'Obsidian search vault' })
        vim.keymap.set('n', '<Leader>ot', '<Cmd>Obsidian today<CR>',            { buffer = buf, desc = 'Obsidian today' })
        vim.keymap.set('n', '<Leader>om', '<Cmd>Obsidian tomorrow<CR>',         { buffer = buf, desc = 'Obsidian tomorrow' })
        vim.keymap.set('n', '<Leader>oy', '<Cmd>Obsidian yesterday<CR>',        { buffer = buf, desc = 'Obsidian yesterday' })
        vim.keymap.set('n', '<Leader>oT', '<Cmd>Obsidian toc<CR>',              { buffer = buf, desc = 'Obsidian table of contents' })
        vim.keymap.set('n', '<Leader>ow', '<Cmd>Obsidian workspace<CR>',        { buffer = buf, desc = 'Obsidian switch workspace' })
        vim.keymap.set('n', '<Leader>og', '<Cmd>Obsidian tags<CR>',             { buffer = buf, desc = 'Obsidian tags' })
        vim.keymap.set('n', '<Leader>oP', '<Cmd>Obsidian paste_img<CR>',        { buffer = buf, desc = 'Obsidian paste image' })

        -- Visual mode: link / link-to-new / extract to note
        vim.keymap.set('v', '<Leader>ok', '<Cmd>Obsidian link<CR>',        { buffer = buf, desc = 'Obsidian link selection' })
        vim.keymap.set('v', '<Leader>oK', '<Cmd>Obsidian link_new<CR>',    { buffer = buf, desc = 'Obsidian link selection to new note' })
        vim.keymap.set('v', '<Leader>ox', '<Cmd>Obsidian extract_note<CR>', { buffer = buf, desc = 'Obsidian extract to new note' })
      end,
    },
  })

  -- Global shortcuts (work outside of note buffers too, e.g. from starter)
  vim.keymap.set('n', '<Leader>on', '<Cmd>Obsidian new_from_template<CR>', { desc = 'Obsidian new note from template' })
  vim.keymap.set('n', '<Leader>oq', '<Cmd>Obsidian quick_switch<CR>', { desc = 'Obsidian quick switch' })
  vim.keymap.set('n', '<Leader>os', '<Cmd>Obsidian search<CR>',       { desc = 'Obsidian search vault' })
  vim.keymap.set('n', '<Leader>ot', '<Cmd>Obsidian today<CR>',        { desc = 'Obsidian today' })
  vim.keymap.set('n', '<Leader>oy', '<Cmd>Obsidian yesterday<CR>',    { desc = 'Obsidian yesterday' })
  vim.keymap.set('n', '<Leader>om', '<Cmd>Obsidian tomorrow<CR>',     { desc = 'Obsidian tomorrow' })
  vim.keymap.set('n', '<Leader>od', '<Cmd>Obsidian dailies<CR>',      { desc = 'Obsidian daily list' })
  vim.keymap.set('n', '<Leader>ow', '<Cmd>Obsidian workspace<CR>',    { desc = 'Obsidian switch workspace' })
end)

-- UI enhancements ============================================================

-- noice.nvim replaces the cmdline, messages, and popupmenu with a modern UI.
-- Must run at startup (now) to intercept startup messages.
-- nui.nvim is added here explicitly since noice needs it at now() time,
-- before the neotree later() block has a chance to install it.
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

-- Smart splits ===============================================================

-- Seamless navigation between Neovim splits and tmux panes.
-- See 'after/plugin/40_plugins.lua' for keymaps (overrides mini.basics <C-hjkl>).
later(function() add({ 'https://github.com/mrjones2014/smart-splits.nvim' }) end)

-- Neotree ====================================================================

-- neo-tree.nvim is a file explorer tree. Use `<Leader>e` to toggle it and
-- `<Leader>E` to reveal the current file in the tree.
-- nui.nvim is a required UI component library for neo-tree.
-- add() and setup() are in the same later() block to guarantee ordering.
later(function()
  add({
    'https://github.com/nvim-neo-tree/neo-tree.nvim',
    'https://github.com/nvim-lua/plenary.nvim',
    'https://github.com/MunifTanjim/nui.nvim',
  })

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

-- Honorable mentions =========================================================

-- 'mason-org/mason.nvim' (a.k.a. "Mason") is a great tool (package manager) for
-- installing external language servers, formatters, and linters. It provides
-- a unified interface for installing, updating, and deleting such programs.
--
-- The caveat is that these programs will be set up to be mostly used inside Neovim.
-- If you need them to work elsewhere, consider using other package managers.
--
-- You can use it like so:
-- now_if_args(function()
--   add({ 'https://github.com/mason-org/mason.nvim' })
--   require('mason').setup()
-- end)

-- Beautiful, usable, well maintained color schemes outside of 'mini.nvim' and
-- have full support of its highlight groups. Use if you don't like 'miniwinter'
-- enabled in 'plugin/30_mini.lua' or other suggested 'mini.hues' based ones.
-- Config.now(function()
--  -- Install only those that you need
--  add({
--    'https://github.com/sainnhe/everforest',
--    'https://github.com/Shatur/neovim-ayu',
--    'https://github.com/ellisonleao/gruvbox.nvim',
--  })
--
--   -- Enable only one
--   vim.cmd('color everforest')
-- end)
