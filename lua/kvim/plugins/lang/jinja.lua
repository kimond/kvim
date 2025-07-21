return {
	{
		"armyers/Vim-Jinja2-Syntax",
		ft = { "jinja", "jinja2" },
	},
	{
		"mason-org/mason.nvim",
		opts = {
			ensure_installed = { "djlint" },
		},
	},
	{
		"stevearc/conform.nvim",
		optional = true,
		opts = {
			formatters_by_ft = {
				jinja = { "djlint" },
			},
		},
	},
	{
		"mfussenegger/nvim-lint",
		optional = true,
		opts = {
			linters_by_ft = {
				jinja = { "djlint" },
			},
		},
	},
}
