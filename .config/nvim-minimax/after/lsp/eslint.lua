-- ┌──────────────────┐
-- │ ESLint LSP config│
-- └──────────────────┘
--
-- Requires: vscode-langservers-extracted
-- Install:  npm install -g vscode-langservers-extracted
return {
	cmd = { "vscode-eslint-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "graphql" },
	root_markers = { ".eslintrc", ".eslintrc.js", ".eslintrc.json", "eslint.config.js", "eslint.config.mjs" },
	settings = {
		validate = "on",
		packageManager = vim.NIL,
		useESLintClass = false,
		experimental = { useFlatConfig = false },
		codeActionOnSave = { enable = false, mode = "all" },
		format = false,
		quiet = false,
		onIgnoredFiles = "off",
		options = {},
		rulesCustomizations = {},
		run = "onType",
		problems = { shortenToSingleLine = false },
		nodePath = "",
		workingDirectory = { mode = "location" },
		codeAction = {
			disableRuleComment = { enable = true, location = "separateLine" },
			showDocumentation = { enable = true },
		},
	},
	on_init = function(client)
		-- Register EslintFixAll as a global user command.
		-- on_init runs once per client so the command is always available.
		-- Uses request_sync so fixes are applied before the file is written.
		local function fix_all(opts)
			opts = opts or {}
			local bufnr = opts.bufnr or vim.api.nvim_get_current_buf()
			client:request_sync('workspace/executeCommand', {
				command = 'eslint.applyAllFixes',
				arguments = {{
					uri = vim.uri_from_bufnr(bufnr),
					version = vim.lsp.util.buf_versions[bufnr],
				}},
			}, nil, bufnr)
		end

		vim.api.nvim_create_user_command('EslintFixAll', function() fix_all() end, {})

		vim.api.nvim_create_autocmd('BufWritePre', {
			pattern = { '*.js', '*.jsx', '*.ts', '*.tsx' },
			command = 'silent! EslintFixAll',
		})
	end,
	before_init = function(params, config)
		-- Set the workspace folder setting for correct search of tsconfig.json files etc.
		config.settings.workspaceFolder = {
			uri = params.rootPath,
			name = vim.fn.fnamemodify(params.rootPath, ":t"),
		}
	end,
	---@type table<string, lsp.Handler>
	handlers = {
		["eslint/openDoc"] = function(_, params)
			vim.ui.open(params.url)
			return {}
		end,
		["eslint/probeFailed"] = function()
			vim.notify("LSP[eslint]: Probe failed.", vim.log.levels.WARN)
			return {}
		end,
		["eslint/noLibrary"] = function()
			vim.notify("LSP[eslint]: Unable to load ESLint library.", vim.log.levels.WARN)
			return {}
		end,
		["eslint/confirmESLintExecution"] = function(_, result)
			if not result then
				return
			end
			return 4 -- approved
		end,
	},
}
