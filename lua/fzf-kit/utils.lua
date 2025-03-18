-- Utility functions for fzf-kit

local M = {}

-- Check if a command-line tool exists
-- @param cmd string: The command to check
-- @return boolean: True if the command exists, false otherwise
function M.check_cmd_exists(cmd)
	if not cmd or cmd == "" then
		return false
	end

	-- Use vim.fn.executable to check if the command exists
	return vim.fn.executable(cmd) == 1
end

-- Display error message with installation instructions
-- @param dependency string: The missing dependency
-- @param instructions string: Installation instructions (optional)
function M.dependency_error(dependency, instructions)
	local msg = string.format("fzf-kit: Required dependency '%s' not found.", dependency)

	if instructions then
		msg = msg .. "\n" .. instructions
	else
		-- Default installation instructions based on dependency
		if dependency == "fd" then
			msg = msg .. "\nInstall 'fd' with your package manager:"
			msg = msg .. "\n  - Debian/Ubuntu: apt install fd-find"
			msg = msg .. "\n  - macOS: brew install fd"
			msg = msg .. "\n  - Arch Linux: pacman -S fd"
		elseif dependency == "gh" then
			msg = msg .. "\nInstall GitHub CLI from https://cli.github.com/:"
			msg = msg .. "\n  - Debian/Ubuntu: apt install gh"
			msg = msg .. "\n  - macOS: brew install gh"
			msg = msg .. "\n  - Arch Linux: pacman -S github-cli"
		elseif dependency == "fzf-lua" then
			msg = msg .. "\nInstall fzf-lua with your plugin manager:"
			msg = msg .. "\n  - lazy.nvim: { 'ibhagwan/fzf-lua' } "
		end
	end

	vim.notify(msg, vim.log.levels.ERROR)
	return false
end

-- Deep merge two tables
-- @param t1 table: First table
-- @param t2 table: Second table (overrides t1)
-- @return table: Merged table
local function deep_merge(t1, t2)
	local t = t1

	for k, v in pairs(t2) do
		if type(v) == "table" and type(t[k]) == "table" then
			t[k] = deep_merge(t[k], v)
		else
			t[k] = v
		end
	end

	return t
end

-- Merge user config with defaults
-- @param defaults table: Default configuration
-- @param user_config table: User configuration (optional)
-- @return table: Merged configuration
function M.merge_config(defaults, user_config)
	if not user_config then
		return vim.deepcopy(defaults)
	end

	local config = vim.deepcopy(defaults)
	return deep_merge(config, user_config)
end

-- Check if fzf-lua is available
-- @return boolean: True if fzf-lua is available, false otherwise
function M.check_fzf_lua()
	local has_fzf_lua, _ = pcall(require, "fzf-lua")

	if not has_fzf_lua then
		return M.dependency_error("fzf-lua")
	end

	return true
end

-- Safe require a module
-- @param module string: Module name
-- @return any: Module if successful, nil otherwise
function M.safe_require(module)
	local ok, result = pcall(require, module)
	if not ok then
		vim.notify("fzf-kit: Could not require module '" .. module .. "'", vim.log.levels.ERROR)
		return nil
	end
	return result
end

-- Format error message and print it
-- @param msg string: Error message
function M.error(msg)
	vim.notify("fzf-kit: " .. msg, vim.log.levels.ERROR)
end

-- Format warning message and print it
-- @param msg string: Warning message
function M.warn(msg)
	vim.notify("fzf-kit: " .. msg, vim.log.levels.WARN)
end

-- Format info message and print it
-- @param msg string: Info message
function M.info(msg)
	vim.notify("fzf-kit: " .. msg, vim.log.levels.INFO)
end

return M
