return {
	-- copilot
	{
		"zbirenbaum/copilot.lua",
		cmd = "Copilot",
		build = ":Copilot auth",
		event = "BufReadPost",
		opts = {
			suggestion = {
				enabled = not vim.g.ai_cmp,
				auto_trigger = true,
				hide_during_completion = vim.g.ai_cmp,
				keymap = {
					accept = false, -- handled by nvim-cmp / blink.cmp
					next = "<M-]>",
					prev = "<M-[>",
				},
			},
			panel = { enabled = false },
			filetypes = {
				markdown = true,
				help = true,
			},
		},
	},

	-- add ai_accept action
	{
		"zbirenbaum/copilot.lua",
		opts = function()
			Kvim.cmp.actions.ai_accept = function()
				if require("copilot.suggestion").is_visible() then
					Kvim.create_undo()
					require("copilot.suggestion").accept()
					return true
				end
			end
		end,
	},

	-- lualine
	{
		"nvim-lualine/lualine.nvim",
		optional = true,
		event = "VeryLazy",
		opts = function(_, opts)
			table.insert(
				opts.sections.lualine_x,
				2,
				Kvim.lualine.status(Kvim.config.icons.kinds.Copilot, function()
					local clients = package.loaded["copilot"] and Kvim.lsp.get_clients({ name = "copilot", bufnr = 0 })
						or {}
					if #clients > 0 then
						local status = require("copilot.api").status.data.status
						return (status == "InProgress" and "pending") or (status == "Warning" and "error") or "ok"
					end
				end)
			)
		end,
	},

	vim.g.ai_cmp
			and {
				-- copilot cmp source
				{
					"saghen/blink.cmp",
					optional = true,
					dependencies = { "giuxtaposition/blink-cmp-copilot" },
					opts = {
						sources = {
							default = { "copilot" },
							providers = {
								copilot = {
									name = "copilot",
									module = "blink-cmp-copilot",
									kind = "Copilot",
									score_offset = 100,
									async = true,
								},
							},
						},
					},
				},
			}
		or nil,
}
