-- fzf-kit/plugin/fzf-kit.lua
-- Command registration for fzf-kit

-- Check if plugin is already loaded
if vim.g.loaded_fzf_kit == 1 then
	return
end
vim.g.loaded_fzf_kit = 1

-- Check for minimum Neovim version
if vim.fn.has("nvim-0.7") ~= 1 then
	vim.api.nvim_err_writeln("fzf-kit minimum requirement is Neovim version 0.7")
	return
end

-- Define available commands and their corresponding functions
local commands = {
	FolderGrep = function()
		require("fzf-kit").folder_grep()
	end,
	GithubPRs = function()
		require("fzf-kit").github_prs()
	end,
}

-- Create the FzfKit command
vim.api.nvim_create_user_command("FzfKit", function(opts)
	-- Get the subcommand (first argument)
	local subcommand = opts.fargs[1]

	-- Check if the subcommand exists
	if commands[subcommand] then
		-- Execute the corresponding function
		commands[subcommand]()
	else
		-- Handle unknown subcommand
		local available_cmds = "Available commands: "
		local cmd_list = {}
		for cmd, _ in pairs(commands) do
			table.insert(cmd_list, cmd)
		end
		available_cmds = available_cmds .. table.concat(cmd_list, ", ")

		vim.notify("Unknown FzfKit command: " .. (subcommand or "") .. "\n" .. available_cmds, vim.log.levels.ERROR)
	end
end, {
	nargs = 1,
	complete = function(_, _, _)
		-- Return list of available subcommands for completion
		local cmd_list = {}
		for cmd, _ in pairs(commands) do
			table.insert(cmd_list, cmd)
		end
		return cmd_list
	end,
	desc = "FzfKit commands",
})
