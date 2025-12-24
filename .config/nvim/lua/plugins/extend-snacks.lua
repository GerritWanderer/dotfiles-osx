return {
	"folke/snacks.nvim",
	keys = {
		{
			"<leader>dn", -- or whatever key you prefer
			function()
				-- Get date components
				local year = os.date("%Y")
				local month_num = os.date("%m")
				local month_name = os.date("%B")
				local day_name = os.date("%A")
				local full_date = os.date("%Y-%m-%d")

				-- Build the path matching your structure
				local notes_dir = vim.fn.expand("~/Workspace/notes")
				local daily_note = string.format(
					"%s/00-Daily/%s/%s-%s/%s-%s.md",
					notes_dir,
					year,
					month_num,
					month_name,
					full_date,
					day_name
				)

				Snacks.scratch({
					file = daily_note,
					ft = "markdown",
					name = "Daily Note",
					autowrite = true,
					filekey = {
						cwd = false,
						branch = false,
						count = false,
					},
				})
			end,
			desc = "Open Daily Note",
		},
		{
			"<leader>sr",
			function()
				Snacks.picker.resume()
			end,
			desc = "Resume Picker",
		},
		{ "<leader>sR", false },
	},
	opts = {
		gh = {
			enabled = false, -- Disable github integration
		},
		scroll = {
			enabled = false, -- Disable scrolling animations
		},
		picker = {
			win = {
				input = {
					keys = {
						["<c-n>"] = { "history_forward", mode = { "i", "n" } },
						["<c-p>"] = { "history_back", mode = { "i", "n" } },
					},
				},
			},
		},
	},
}
