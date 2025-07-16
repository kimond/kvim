require("conform").formatters.golines = {
	args = { "-m", "120" },
}

vim.api.nvim_create_user_command("Golines", function()
	return require("conform").format({
		-- async means discarded if the file is modified before the formatting is done
		async = true,
		lsp_format = "never",
		bufnr = 0,
		formatters = { "golines" },
	})
end, {})

return {
	{
		"williamboman/mason.nvim",
		opts = {
			ensure_installed = { "golangci-lint", "golines" },
		},
	},
	{
		"nvim-treesitter/nvim-treesitter",
		opts = {
			ensure_installed = { "templ" },
		},
	},
	{
		"nvimtools/none-ls.nvim",
		optional = true,
		opts = function(_, opts)
			local nls = require("null-ls")
			opts.sources = vim.list_extend(opts.sources or {}, {
				nls.builtins.diagnostics.golangci_lint,
			})
		end,
	},
}
