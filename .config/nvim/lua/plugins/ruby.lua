local ruby_version = vim.fn.system("mise current ruby"):gsub("%s+", "")

return {
	recommended = function()
		return LazyVim.extras.wants({
			ft = "ruby",
			root = "Gemfile",
		})
	end,
	{
		"nvim-treesitter/nvim-treesitter",
		opts = { ensure_installed = { "ruby" } },
	},
	{
		"neovim/nvim-lspconfig",
		---@type PluginLspOpts
		opts = {
			servers = {
				ruby_lsp = {
					enabled = true,
					mason = false,
					cmd = { vim.fn.expand("~/.local/share/mise/installs/ruby/" .. ruby_version .. "/bin/ruby-lsp") },
				},
				rubocop = {
					enabled = true,
					mason = false,
				},
			},
		},
	},
	-- Disabled: relying on manually installed tools instead of Mason auto-install
	-- {
	-- 	"mason-org/mason.nvim",
	-- 	opts = { ensure_installed = { "erb-formatter", "erb-lint" } },
	-- },
	{
		"mfussenegger/nvim-dap",
		optional = true,
		dependencies = {
			"suketa/nvim-dap-ruby",
			config = function()
				require("dap-ruby").setup()
			end,
		},
	},
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				ruby = { "rubocop" },
				eruby = { "erb_format" },
			},
		},
	},
	{
		"nvim-neotest/neotest",
		optional = true,
		dependencies = {
			"olimorris/neotest-rspec",
		},
		opts = {
			adapters = {
				["neotest-rspec"] = {
					-- NOTE: By default neotest-rspec uses the system wide rspec gem instead of the one through bundler
					-- rspec_cmd = function()
					--   return vim.tbl_flatten({
					--     "bundle",
					--     "exec",
					--     "rspec",
					--   })
					-- end,
				},
			},
		},
	},
}
