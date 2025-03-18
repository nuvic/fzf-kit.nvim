-- Main module file for fzf-kit

-- Module table
local M = {}

-- Version information
M.version = "0.1.0"

-- Import utils
local utils = require("fzf-kit.utils")

-- Default configuration
local default_config = {
	github = {
		-- GitHub configuration options
		default_filters = {}, -- Default PR filters
		buffer_position = "vsplit", -- Where to open PR view buffer
	},
	folder = {
		-- Folder grep configuration
		fd_command = "fd --type d", -- Command to list directories
		fd_args = {}, -- Additional arguments for fd
	},
}

-- Current configuration (starts with defaults)
M.config = vim.deepcopy(default_config)

-- Setup function to configure the plugin
-- @param opts table: User configuration (optional)
-- @return nil
function M.setup(opts)
	opts = opts or {}

	-- Merge user configuration with defaults
	M.config = utils.merge_config(default_config, opts)

	-- Load modules after configuration is set
	-- This ensures they have access to the configuration
	M.folder = require("fzf-kit.folder")
	M.github = require("fzf-kit.github")

	-- Export functions from modules
	M.folder_grep = M.folder.folder_grep
	M.github_prs = M.github.github_prs
end

-- Initialize with default configuration if setup isn't called
M.folder = require("fzf-kit.folder")
M.github = require("fzf-kit.github")

-- Export functions from modules
M.folder_grep = M.folder.folder_grep
M.github_prs = M.github.github_prs

-- Return the module
return M
