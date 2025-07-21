vim.uv = vim.uv or vim.loop

local M = {}

---@param opts? KvimConfig
function M.setup(opts)
	require("kvim.config").setup(opts)
end

return M
