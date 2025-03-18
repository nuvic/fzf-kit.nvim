-- Folder-related functionality for fzf-kit

local M = {}

-- Get utils module
local utils = require("fzf-kit.utils")

-- Get configuration
local function get_config()
	-- Access config from the main module
	local main = require("fzf-kit")
	return main.config and main.config.folder or {}
end

-- Folder grep function
-- Allows selecting a folder and running grep in it
-- @return nil
function M.folder_grep()
	-- Get configuration
	local config = get_config()

	-- Check if fd command exists
	if not utils.check_cmd_exists("fd") then
		return utils.dependency_error("fd")
	end

	-- Check if fzf-lua is available
	local fzf_lua = utils.safe_require("fzf-lua")
	if not fzf_lua then
		return
	end

	-- Prepare fd command with arguments
	local fd_command = config.fd_command or "fd --type d"
	if config.fd_args and #config.fd_args > 0 then
		fd_command = fd_command .. " " .. table.concat(config.fd_args, " ")
	end

	-- Use fzf-lua to list directories and allow selection
	fzf_lua.fzf_exec(fd_command, {
		prompt = "Select folder > ",
		actions = {
			["default"] = function(selected)
				if selected and #selected > 0 then
					-- Run live grep in the selected directory
					fzf_lua.live_grep({ cwd = selected[1] })
				end
			end,
		},
	})
end

return M
