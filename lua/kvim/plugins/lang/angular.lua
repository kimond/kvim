return {
	{
		"nvim-treesitter",
		opts = function(_, opts)
			if type(opts.ensure_installed) == "table" then
				vim.list_extend(opts.ensure_installed, { "angular", "scss" })
			end
			vim.api.nvim_create_autocmd({ "BufReadPost", "BufNewFile" }, {
				pattern = { "*.component.html", "*.container.html" },
				callback = function()
					vim.treesitter.start(nil, "angular")
				end,
			})
		end,
	},

	-- angularls depends on typescript
	{ import = "kvim.plugins.lang.typescript" },

	-- LSP Servers
	{
		"neovim/nvim-lspconfig",
		opts = {
			servers = {
				angularls = {},
			},
			setup = {
				angularls = function()
					Kvim.lsp.on_attach(function(client)
						--HACK: disable angular renaming capability due to duplicate rename popping up
						client.server_capabilities.renameProvider = false
					end, "angularls")
				end,
			},
		},
	},

	-- -- Configure tsserver plugin
	-- {
	-- 	"neovim/nvim-lspconfig",
	-- 	opts = function(_, opts)
	-- 		Kvim.extend(opts.servers.vtsls, "settings.vtsls.ts_ls.globalPlugins", {
	-- 			{
	-- 				name = "@angular/language-server",
	-- 				location = Kvim.get_pkg_path("angular-language-server", "/node_modules/@angular/language-server"),
	-- 				enableForWorkspaceTypeScriptVersions = false,
	-- 			},
	-- 		})
	-- 	end,
	-- },

	-- formatting
	{
		"conform.nvim",
		opts = function(_, opts)
			opts.formatters_by_ft = opts.formatters_by_ft or {}
			opts.formatters_by_ft.htmlangular = { "prettier" }
		end,
	},
}
