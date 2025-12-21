return {
	{
		"MeanderingProgrammer/treesitter-modules.nvim",
		dependencies = { "nvim-treesitter/nvim-treesitter" },
		opts = {
			incremental_selection = {
				enable = true,
				keymaps = {
					init_selection = "<M-i>",
					node_incremental = "<M-i>",
					scope_incremental = false,
					node_decremental = "<M-o>",
				},
			},
		},
	},
}
