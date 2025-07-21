if vim.fn.has("nvim-0.9.0") == 0 then
	vim.api.nvim_echo({
		{ "Kvim requires Neovim >= 0.9.0\n", "ErrorMsg" },
		{ "Press any key to exit", "MoreMsg" },
	}, true, {})
	vim.fn.getchar()
	vim.cmd([[quit]])
	return {}
end

require("kvim.config").init()

return {
	{ "folke/lazy.nvim", version = "*" },
	{
		"kvimcrew/kvim",
		priority = 10000,
		lazy = false,
		opts = {},
		cond = true,
		version = "*",
	},
	{
		"folke/snacks.nvim",
		priority = 1000,
		lazy = false,
		opts = {},
	},
}
