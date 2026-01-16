return {
	"obsidian-nvim/obsidian.nvim",
	version = "*", -- use latest release, remove to use latest commit
	init = function()
		vim.api.nvim_create_autocmd("User", {
			pattern = "ObsidianNoteEnter",
			callback = function(ev)
				local current_file = vim.api.nvim_buf_get_name(0)

				local obsidian_base = vim.fn.expand("~/Workspace/notes/")

				local vault_name = current_file:match(vim.pesc(obsidian_base) .. "([%w_-]+)/")

				if vault_name then
					local vault_root = obsidian_base .. vault_name

					if vim.fn.getcwd() ~= vault_root then
						pcall(vim.cmd.cd, vault_root)
					end
				end
			end,
		})
	end,
	keys = {
		{ "<leader>oo", "<cmd>Obsidian quick_switch<cr>", desc = "Obsidian quick search" },
		{ "<leader>o/", "<cmd>Obsidian search<cr>", desc = "Obsidian search" },
		{ "<leader>op", "<cmd>MarkdownPreviewToggle<cr>", desc = "Obsidian preview" },
		{ "<leader>od", "<cmd>Obsidian dailies<cr>", desc = "Obsidian dailies" },
		{ "<leader>on", "<cmd>Obsidian new_from_template<cr>", desc = "Obsidian new note" },
	},
	opts = {
		legacy_commands = false, -- this will be removed in the next major release
		notes_subdir = "01-Wildflowers",
		note_id_func = function(title)
			return title:gsub(" ", "-"):gsub("\\[\\^A-Za-z0-9-\\]", ""):lower()
		end,
		workspaces = {
			{
				name = "notes",
				path = "~/Workspace/notes/",
			},
		},
		templates = {
			folder = "99-extras/templates",
		},
		daily_notes = {
			folder = "00-Daily",
			date_format = "%Y/%m-%B/%Y-%m-%d-%A",
			default_tags = { "type/daily" },
			template = "daily",
		},
	},
}
