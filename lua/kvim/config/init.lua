_G.Kvim = require("kvim.util")

---@class KvimConfig: KvimOptions
local M = {}

M.version = "0.0.1"
Kvim.config = M

---@class KvimOptions
local defaults = {
	-- colorscheme can be a string like `catppuccin` or a function that will load the colorscheme
	---@type string|fun()
	colorscheme = function()
		require("catppuccin").load()
	end,
	-- load the default settings
	defaults = {
		autocmds = true, -- lazyvim.config.autocmds
		keymaps = true, -- lazyvim.config.keymaps
		-- kvim.config.options can't be configured here since that's loaded before kvim setup
		-- if you want to disable loading options, add `package.loaded["kvim.config.options"] = true` to the top of your init.lua
	},
	news = {
		-- When enabled, NEWS.md will be shown when changed.
		-- This only contains big new features and breaking changes.
		kvim = true,
		-- Same but for Neovim's news.txt
		neovim = false,
	},
  -- icons used by other plugins
  -- stylua: ignore
  icons = {
    misc = {
      dots = "󰇘",
    },
    ft = {
      octo = "",
    },
    dap = {
      Stopped             = { "󰁕 ", "DiagnosticWarn", "DapStoppedLine" },
      Breakpoint          = " ",
      BreakpointCondition = " ",
      BreakpointRejected  = { " ", "DiagnosticError" },
      LogPoint            = ".>",
    },
    diagnostics = {
      Error = " ",
      Warn  = " ",
      Hint  = " ",
      Info  = " ",
    },
    git = {
      added    = " ",
      modified = " ",
      removed  = " ",
    },
    kinds = {
      Array         = " ",
      Boolean       = "󰨙 ",
      Class         = " ",
      Codeium       = "󰘦 ",
      Color         = " ",
      Control       = " ",
      Collapsed     = " ",
      Constant      = "󰏿 ",
      Constructor   = " ",
      Copilot       = " ",
      Enum          = " ",
      EnumMember    = " ",
      Event         = " ",
      Field         = " ",
      File          = " ",
      Folder        = " ",
      Function      = "󰊕 ",
      Interface     = " ",
      Key           = " ",
      Keyword       = " ",
      Method        = "󰊕 ",
      Module        = " ",
      Namespace     = "󰦮 ",
      Null          = " ",
      Number        = "󰎠 ",
      Object        = " ",
      Operator      = " ",
      Package       = " ",
      Property      = " ",
      Reference     = " ",
      Snippet       = "󱄽 ",
      String        = " ",
      Struct        = "󰆼 ",
      Supermaven    = " ",
      TabNine       = "󰏚 ",
      Text          = " ",
      TypeParameter = " ",
      Unit          = " ",
      Value         = " ",
      Variable      = "󰀫 ",
    },
  },
	---@type table<string, string[]|boolean>?
	kind_filter = {
		default = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			"Package",
			"Property",
			"Struct",
			"Trait",
		},
		markdown = false,
		help = false,
		-- you can specify a different filter for each filetype
		lua = {
			"Class",
			"Constructor",
			"Enum",
			"Field",
			"Function",
			"Interface",
			"Method",
			"Module",
			"Namespace",
			-- "Package", -- remove package since luals uses it for control flow structures
			"Property",
			"Struct",
			"Trait",
		},
	},
}

local options
local lazy_clipboard

function M.setup(opts)
	options = vim.tbl_deep_extend("force", defaults, opts or {}) or {}

	-- autocmds can be loaded lazily when not opening a file
	local lazy_autocmds = vim.fn.argc(-1) == 0
	if not lazy_autocmds then
		M.load("autocmds")
	end

	local group = vim.api.nvim_create_augroup("kvim", { clear = true })
	vim.api.nvim_create_autocmd("User", {
		group = group,
		pattern = "VeryLazy",
		callback = function()
			if lazy_autocmds then
				M.load("autocmds")
			end
			M.load("keymaps")
			if lazy_clipboard ~= nil then
				vim.opt.clipboard = lazy_clipboard
			end

			Kvim.format.setup()
			-- Kvim.news.setup()
			Kvim.root.setup()

			-- vim.api.nvim_create_user_command("LazyExtras", function()
			-- 	Kvim.extras.show()
			-- end, { desc = "Manage Kvim extras" })

			vim.api.nvim_create_user_command("KHealth", function()
				vim.cmd([[Lazy! load all]])
				vim.cmd([[checkhealth]])
			end, { desc = "Load all plugins and run :checkhealth" })

			local health = require("lazy.health")
			vim.list_extend(health.valid, {
				"recommended",
				"desc",
				"vscode",
			})

			if vim.g.kvim_check_order == false then
				return
			end

			-- Check lazy.nvim import order
			local imports = require("lazy.core.config").spec.modules
			local function find(pat, last)
				for i = last and #imports or 1, last and 1 or #imports, last and -1 or 1 do
					if imports[i]:find(pat) then
						return i
					end
				end
			end
			local kvim_plugins = find("^kvim%.plugins$")
			if kvim_plugins ~= 1 then
				local msg = {
					"The order of your `lazy.nvim` imports is incorrect:",
					"- `kvim.plugins` should be first",
					"- and finally your own `plugins`",
					"",
					"If you think you know what you're doing, you can disable this check with:",
					"```lua",
					"vim.g.kvim_check_order = false",
					"```",
				}
				vim.notify(table.concat(msg, "\n"), "warn", { title = "Kvim" })
			end
		end,
	})

	Kvim.track("colorscheme")
	Kvim.try(function()
		if type(M.colorscheme) == "function" then
			M.colorscheme()
		else
			vim.cmd.colorscheme(M.colorscheme)
		end
	end, {
		msg = "Could not load your colorscheme",
		on_error = function(msg)
			Kvim.error(msg)
			vim.cmd.colorscheme("habamax")
		end,
	})
	Kvim.track()
end

---@param name "autocmds" | "options" | "keymaps"
function M.load(name)
	local function _load(mod)
		-- if require("lazy.core.cache").find(mod)[1] then
		Kvim.try(function()
			require(mod)
		end, { msg = "Failed loading " .. mod })
		-- end
	end
	local pattern = "Kvim" .. name:sub(1, 1):upper() .. name:sub(2)
	-- always load kvim, then user file
	if M.defaults[name] or name == "options" then
		_load("kvim.config." .. name)
		vim.api.nvim_exec_autocmds("User", { pattern = pattern .. "Defaults", modeline = false })
	end
	_load("config." .. name)
	if vim.bo.filetype == "lazy" then
		-- HACK: kvim may have overwritten options of the Lazy ui, so reset this here
		vim.cmd([[do VimResized]])
	end
	vim.api.nvim_exec_autocmds("User", { pattern = pattern, modeline = false })
end

M.did_init = false
function M.init()
	if M.did_init then
		return
	end
	M.did_init = true
	local plugin = require("lazy.core.config").spec.plugins.Kvim
	if plugin then
		vim.opt.rtp:append(plugin.dir)
	end

	-- load options here, before lazy init while sourcing plugin modules
	-- this is needed to make sure options will be correctly applied
	-- after installing missing plugins
	M.load("options")
	-- defer built-in clipboard handling: "xsel" and "pbcopy" can be slow
	lazy_clipboard = vim.opt.clipboard
	vim.opt.clipboard = ""

	if vim.g.deprecation_warnings == false then
		vim.deprecate = function() end
	end

	Kvim.plugin.setup()
	-- M.json.load()
end

setmetatable(M, {
	__index = function(_, key)
		if options == nil then
			return vim.deepcopy(defaults)[key]
		end
		---@cast options KvimConfig
		return options[key]
	end,
})

return M
