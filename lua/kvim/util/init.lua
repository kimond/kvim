local LazyUtil = require("lazy.core.util")

---@class kvim.util: LazyUtilCore
---@field config KvimConfig
---@field ui kvim.util.ui
---@field root kvim.util.root
---@field lualine kvim.util.lualine
---@field pick kvim.util.pick
---@field cmp kvim.util.cmp
---@field format kvim.util.format
---@field plugin kvim.util.plugin
---@field mini kvim.util.mini
---@field lsp kvim.util.lsp
local M = {}

setmetatable(M, {
	__index = function(t, k)
		if LazyUtil[k] then
			return LazyUtil[k]
		end
		-- if k == "lazygit" or k == "toggle" then -- HACK: special case for lazygit
		-- 	return M.deprecated[k]()
		-- end
		---@diagnostic disable-next-line: no-unknown
		t[k] = require("kvim.util." .. k)
		-- M.deprecated.decorate(k, t[k])
		return t[k]
	end,
})

function M.is_win()
	return vim.uv.os_uname().sysname:find("Windows") ~= nil
end

---@param name string
function M.get_plugin(name)
	return require("lazy.core.config").spec.plugins[name]
end

---@param plugin string
function M.has(plugin)
	return M.get_plugin(plugin) ~= nil
end

---@param fn fun()
function M.on_very_lazy(fn)
	vim.api.nvim_create_autocmd("User", {
		pattern = "VeryLazy",
		callback = function()
			fn()
		end,
	})
end

---@param name string
function M.opts(name)
	local plugin = M.get_plugin(name)
	if not plugin then
		return {}
	end
	local Plugin = require("lazy.core.plugin")
	return Plugin.values(plugin, "opts", false)
end

function M.is_loaded(name)
	local Config = require("lazy.core.config")
	return Config.plugins[name] and Config.plugins[name]._.loaded
end

---@param name string
---@param fn fun(name:string)
function M.on_load(name, fn)
	if M.is_loaded(name) then
		fn(name)
	else
		vim.api.nvim_create_autocmd("User", {
			pattern = "LazyLoad",
			callback = function(event)
				if event.data == name then
					fn(name)
					return true
				end
			end,
		})
	end
end

---@generic T
---@param list T[]
---@return T[]
function M.dedup(list)
	local ret = {}
	local seen = {}
	for _, v in ipairs(list) do
		if not seen[v] then
			table.insert(ret, v)
			seen[v] = true
		end
	end
	return ret
end

function M.deprecate(old, new)
	M.warn(("`%s` is deprecated. Please use `%s` instead"):format(old, new), {
		title = "Kvim",
		once = true,
		stacktrace = true,
		stacklevel = 6,
	})
end

-- Wrapper around vim.keymap.set that will
-- not create a keymap if a lazy key handler exists.
-- It will also set `silent` to true by default.
function M.safe_keymap_set(mode, lhs, rhs, opts)
	local keys = require("lazy.core.handler").handlers.keys
	---@cast keys LazyKeysHandler
	local modes = type(mode) == "string" and { mode } or mode

	---@param m string
	modes = vim.tbl_filter(function(m)
		return not (keys.have and keys:have(lhs, m))
	end, modes)

	-- do not create the keymap if a lazy keys handler exists
	if #modes > 0 then
		opts = opts or {}
		opts.silent = opts.silent ~= false
		if opts.remap and not vim.g.vscode then
			---@diagnostic disable-next-line: no-unknown
			opts.remap = nil
		end
		vim.keymap.set(modes, lhs, rhs, opts)
	end
end

M.CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
function M.create_undo()
	if vim.api.nvim_get_mode().mode == "i" then
		vim.api.nvim_feedkeys(M.CREATE_UNDO, "n", false)
	end
end

--- Gets a path to a package in the Mason registry.
--- Prefer this to `get_package`, since the package might not always be
--- available yet and trigger errors.
---@param pkg string
---@param path? string
---@param opts? { warn?: boolean }
function M.get_pkg_path(pkg, path, opts)
	pcall(require, "mason") -- make sure Mason is loaded. Will fail when generating docs
	local root = vim.env.MASON or (vim.fn.stdpath("data") .. "/mason")
	opts = opts or {}
	opts.warn = opts.warn == nil and true or opts.warn
	path = path or ""
	local ret = root .. "/packages/" .. pkg .. "/" .. path
	if opts.warn and not vim.loop.fs_stat(ret) and not require("lazy.core.config").headless() then
		M.warn(
			("Mason package path not found for **%s**:\n- `%s`\nYou may need to force update the package."):format(
				pkg,
				path
			)
		)
	end
	return ret
end

local cache = {} ---@type table<(fun()), table<string, any>>
---@generic T: fun()
---@param fn T
---@return T
function M.memoize(fn)
	return function(...)
		local key = vim.inspect({ ... })
		cache[fn] = cache[fn] or {}
		if cache[fn][key] == nil then
			cache[fn][key] = fn(...)
		end
		return cache[fn][key]
	end
end

return M
