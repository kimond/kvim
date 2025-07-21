return {
	"wakatime/vim-wakatime",
	lazy = false,
	cond = function()
		return vim.g.kvim_wakatime_enabled == true
	end,
}
