local function toggle_diffview(cmd)
	if next(require("diffview.lib").views) == nil then
		vim.cmd(cmd)
	else
		vim.cmd("DiffviewClose")
	end
end

return {
	"sindrets/diffview.nvim",
	command = "DiffviewOpen",
	keys = {
		{
			"<leader>gv",
			function()
				toggle_diffview("DiffviewOpen")
			end,
			desc = "Diff Index",
		},
		{
			"<leader>gV",
			function()
				toggle_diffview("DiffviewOpen master..HEAD")
			end,
			desc = "Diff master",
		},
		{
			"<leader>gf",
			function()
				toggle_diffview("DiffviewFileHistory %")
			end,
			desc = "Open diffs for current File",
		},
		{
			"<leader>gF",
			function()
				toggle_diffview("DiffviewFileHistory")
			end,
			desc = "Open diffs for current Branch",
		},
		{
			"<leader>gf",
			":DiffviewFileHistory<CR>",
			mode = "v",
			desc = "Open diffs for selection",
		},
	},
}
