return {
	{
		"olimorris/codecompanion.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		keys = {
			{
				mode = { "n", "v" },
				"<Leader>at",
				"<cmd>CodeCompanionChat Toggle<cr>",
				desc = "Toggle Chat",
			},
			{
				mode = { "n", "v" },
				"<Leader>aa",
				"<cmd>CodeCompanionActions<cr>",
				desc = "Action Palette",
			},
			{
				"<leader>ae",
				":CodeCompanion ",
				mode = "v",
				desc = "Prompt for selection",
			},
		},
		opts = {
			strategies = {
				chat = { adapter = "gemini" },
				inline = {
					adapter = "gemini",
					keymaps = {
						accept_change = {
							modes = { n = "ga" },
							description = "Accept the suggested change",
						},
						reject_change = {
							modes = { n = "gz" },
							description = "Reject the suggested change",
						},
					},
				},
				agent = { adapter = "gemini" },
			},
			adapters = {
				gemini = function()
					return require("codecompanion.adapters").extend("gemini", {
						env = { api_key = "GEMINI_API_KEY" },
						schema = {
							model = { default = "gemini-2.5-pro-preview-03-25" },
						},
					})
				end,
			},
			display = {
				chat = {
					show_settings = false,
				},
				action_palette = {
					width = 95,
					height = 10,
					prompt = "Prompt ", -- Prompt used for interactive LLM calls
					provider = "snacks", -- Can be "default", "telescope", "fzf_lua", "mini_pick" or "snacks". If not specified, the plugin will autodetect installed providers.
					opts = {
						show_default_actions = true, -- Show the default actions in the action palette?
						show_default_prompt_library = true, -- Show the default prompt library in the action palette?
					},
				},
			},
			opts = {
				-- Set debug logging
				log_level = "ERROR",
			},
		},
	},
	{
		"MeanderingProgrammer/render-markdown.nvim",
		ft = { "markdown", "codecompanion" },
	},
	{
		"folke/which-key.nvim",
		opts = {
			spec = {
				{
					mode = { "n", "v" },
					{ "<leader>a", group = "CodeCompanion" },
				},
			},
		},
	},
	{
		"nvim-lualine/lualine.nvim",
		opts = function(_, opts)
			table.insert(opts.sections.lualine_x, require("utils.codecompanion_status"))
		end,
	},
}
