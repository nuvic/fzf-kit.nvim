-- fzf-kit.github - GitHub-related functionality for fzf-kit

local M = {}

-- Get utils module
local utils = require("fzf-kit.utils")

--- Get configuration for github module
-- @return table: Configuration for github module
local function get_config()
	-- Access config from the main module
	local main = require("fzf-kit")
	return main.config and main.config.github or {}
end

--- Get PRs using gh pr list
-- @param cmd string: Command to execute (default: "gh pr list")
-- @return table: List of PRs or empty table if error
local function get_prs(cmd)
	cmd = cmd or "gh pr list"
	local handle = io.popen(cmd)
	local prs = {}
	if handle then
		for line in handle:lines() do
			table.insert(prs, line)
		end
		handle:close()
	end
	return prs
end

--- Extract PR number from a selected line
-- @param pr_str string: PR string from gh pr list
-- @return string|nil: PR number or nil if not found
local function extract_pr_number(pr_str)
	-- Split by tabs (or multiple spaces as fallback)
	local parts = vim.split(pr_str, "\t")
	if #parts <= 1 then
		parts = vim.split(pr_str, "%s+")
	end
	-- The PR number should be in the first column, possibly with a # prefix
	local pr_number = parts[1]:match("^#?(%d+)$")

	if not pr_number then
		utils.error("Could not extract PR number from: " .. pr_str)
		return nil
	end

	return pr_number
end

--- Create a scratch buffer with content
-- @param content table: Buffer content as a list of strings
-- @param filetype string: Buffer filetype (default: "markdown")
-- @return number: Buffer handle
local function create_scratch_buffer(content, filetype)
	-- Get configuration
	local config = get_config()
	local buffer_position = config.buffer_position or "vsplit"

	-- Create a new buffer (scratch: not a file, not listed)
	local buf = vim.api.nvim_create_buf(false, true)

	-- Create a split and set the buffer
	vim.cmd(buffer_position)
	vim.api.nvim_win_set_buf(0, buf)

	-- Process content to remove ^M characters
	local cleaned_content = {}
	for _, line in ipairs(content) do
		-- Remove carriage returns (^M)
		local cleaned_line = string.gsub(line, "\r", "")
		table.insert(cleaned_content, cleaned_line)
	end

	-- Set buffer content
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, cleaned_content)

	-- Set the fileformat to unix to avoid ^M characters
	vim.bo[buf].fileformat = "unix"

	-- Set buffer options
	vim.api.nvim_buf_set_option(buf, "filetype", filetype or "markdown")
	vim.api.nvim_buf_set_option(buf, "modifiable", false)
	vim.api.nvim_buf_set_option(buf, "buftype", "nofile") -- Not associated with a file
	vim.api.nvim_buf_set_option(buf, "bufhidden", "wipe") -- Buffer is wiped when hidden
	vim.api.nvim_buf_set_option(buf, "swapfile", false) -- No swap file
	vim.api.nvim_buf_set_option(buf, "modified", false) -- Not modified

	-- Set a buffer name to avoid "Untitled" message
	local name = "[GitHub PR View]"
	vim.api.nvim_buf_set_name(buf, name)

	return buf
end

--- Open PR details in a scratch buffer
-- @param selected_pr table: Selected PR from fzf
-- @return nil
local function open_pr(selected_pr)
	local pr_str = selected_pr[1]
	local pr_number = extract_pr_number(pr_str)

	if not pr_number then
		return
	end

	-- Execute gh pr view and capture output
	local cmd = "gh pr view " .. pr_number
	local cmd_handle = io.popen(cmd)
	local content = {}

	if cmd_handle then
		for line in cmd_handle:lines() do
			table.insert(content, line)
		end
		cmd_handle:close()
	end

	-- Create scratch buffer with content
	create_scratch_buffer(content, "markdown")
end

--- Checkout PR
-- @param selected_pr table: Selected PR from fzf
-- @return nil
local function checkout_pr(selected_pr)
	local pr_str = selected_pr[1]
	local pr_number = extract_pr_number(pr_str)

	if not pr_number then
		return
	end

	-- Notify user
	utils.info("Checking out PR #" .. pr_number)

	-- Execute gh pr checkout
	vim.cmd("!gh pr checkout " .. pr_number)
end

--- Open PR in browser
-- @param selected_pr table: Selected PR from fzf
-- @return nil
local function open_pr_in_browser(selected_pr)
	local pr_str = selected_pr[1]
	local pr_number = extract_pr_number(pr_str)

	if not pr_number then
		return
	end

	-- Execute gh pr view --web
	vim.cmd("!gh pr view " .. pr_number .. " --web")
end

--- Filter PRs
-- @return nil
local function filter_prs()
	-- Get configuration
	local config = get_config()

	-- Check if fzf-lua is available
	local fzf_lua = utils.safe_require("fzf-lua")
	if not fzf_lua then
		return
	end

	-- Define filter options
	local filter_options = {
		"Assigned to me",
		"Created by me",
		"Needs my review",
		"Draft PRs only",
		"Ready PRs only",
		"Merged PRs",
		"Closed PRs",
	}

	-- Add default filters from configuration
	if config.default_filters and #config.default_filters > 0 then
		for _, filter in ipairs(config.default_filters) do
			if not vim.tbl_contains(filter_options, filter) then
				table.insert(filter_options, filter)
			end
		end
	end

	-- Display filter options
	fzf_lua.fzf_exec(filter_options, {
		prompt = "Filter PRs > ",
		actions = {
			["default"] = function(filter)
				local cmd = "gh pr list"
				if filter[1] == "Assigned to me" then
					cmd = cmd .. " --assignee @me"
				elseif filter[1] == "Created by me" then
					cmd = cmd .. " --author @me"
				elseif filter[1] == "Needs my review" then
					cmd = cmd .. " --search 'review-requested:@me'"
				elseif filter[1] == "Draft PRs only" then
					cmd = cmd .. " --draft"
				elseif filter[1] == "Ready PRs only" then
					cmd = cmd .. " --search 'draft:false'"
				elseif filter[1] == "Merged PRs" then
					cmd = cmd .. " --state merged"
				elseif filter[1] == "Closed PRs" then
					cmd = cmd .. " --state closed"
				end

				-- Get filtered PRs
				local filtered_prs = get_prs(cmd)

				-- Display filtered PRs
				fzf_lua.fzf_exec(filtered_prs, {
					prompt = "Filtered PRs > ",
					actions = {
						["default"] = open_pr,
						["ctrl-c"] = checkout_pr,
						["ctrl-o"] = open_pr_in_browser,
					},
					fzf_opts = {
						["--delimiter"] = "\t",
						["--with-nth"] = "1,2,3",
					},
				})
			end,
		},
	})
end

--- GitHub PRs function
-- Lists and allows interaction with GitHub PRs
-- @return nil
function M.github_prs()
	-- Check if gh CLI exists
	if not utils.check_cmd_exists("gh") then
		return utils.dependency_error("gh")
	end

	-- Check if fzf-lua is available
	local fzf_lua = utils.safe_require("fzf-lua")
	if not fzf_lua then
		return
	end

	-- Get the list of PRs
	local prs = get_prs()

	-- If no PRs, show a message and return
	if #prs == 0 then
		utils.info("No pull requests found")
		return
	end

	-- Display the PRs using fzf-lua
	fzf_lua.fzf_exec(prs, {
		prompt = "GitHub PRs > ",
		actions = {
			["default"] = open_pr,
			["ctrl-c"] = checkout_pr,
			["ctrl-f"] = filter_prs,
			["ctrl-o"] = open_pr_in_browser,
		},
		fzf_opts = {
			["--delimiter"] = "\t",
			["--with-nth"] = "1,2,3",
		},
	})
end

return M
