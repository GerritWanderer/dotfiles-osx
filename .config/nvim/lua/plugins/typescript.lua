return {
	{
		"neovim/nvim-lspconfig",
		---@type PluginLspOpts
		opts = {
			servers = {
				ts_ls = {
					init_options = {
						preferences = {
							importModuleSpecifierPreference = "relative",
							importModuleSpecifierEnding = "minimal",
						},
					},
					settings = {
						typescript = {
							preferences = {
								importModuleSpecifier = "relative",
							},
						},
					},
				},
			},
		},
	},
}
