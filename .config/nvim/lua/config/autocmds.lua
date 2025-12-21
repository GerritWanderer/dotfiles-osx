-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Prevent duplicate ruby_lsp clients
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("ruby_lsp_dedupe", { clear = true }),
	callback = function(args)
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		if client and client.name == "ruby_lsp" then
			-- Get all ruby_lsp clients for this buffer
			local clients = vim.lsp.get_clients({ bufnr = args.buf, name = "ruby_lsp" })

			-- If there's more than one ruby_lsp client, stop the newer ones
			if #clients > 1 then
				-- Keep the first client (lowest id), stop the rest
				table.sort(clients, function(a, b)
					return a.id < b.id
				end)

				for i = 2, #clients do
					vim.lsp.stop_client(clients[i].id)
				end
			end
		end
	end,
})
