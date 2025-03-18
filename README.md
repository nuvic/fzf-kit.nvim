# README.md

# fzf-kit

A Neovim plugin that extends [fzf-lua](https://github.com/ibhagwan/fzf-lua) with additional utilities.

## Features

- **Folder-Specific Grep**: Select a folder and run live grep within it
- **GitHub PR Viewer**: List, view, and filter GitHub PRs directly from Neovim

(If you have suggestions, feel free to file an issue)

## Requirements

- Neovim >= 0.7.0
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)
- [fd](https://github.com/sharkdp/fd) (for folder-specific grep)
- [GitHub CLI](https://cli.github.com/) (for GitHub PR functionality)

## Installation


### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'nuvic/fzf-kit.nvim',
  dependencies = { 'ibhagwan/fzf-lua' },
  config = function()
    require('fzf-kit').setup({
      -- Optional configuration
    })
  end
}
```

## Usage

### Commands

fzf-kit provides the following commands:

- `:FzfKit FolderGrep` - Select a folder and run live grep within it
- `:FzfKit GithubPRs` - List and interact with GitHub PRs

### Lua API

```lua
-- Folder-specific grep
require('fzf-kit').folder_grep()

-- GitHub PR interaction
require('fzf-kit').github_prs()
```

### GitHub PR Actions

When using the GitHub PR functionality, the following actions are available:

- **Enter**: View PR details in a scratch buffer
- **Ctrl-c**: Checkout the PR
- **Ctrl-f**: Filter PRs (by assignee, author, state, etc.)
- **Ctrl-o**: Open PR in browser

## Configuration

fzf-kit can be configured by calling the `setup` function:

```lua
require('fzf-kit').setup({
  github = {
    -- GitHub configuration options
    default_filters = {}, -- Default PR filters
    buffer_position = "vsplit", -- Where to open PR view buffer ("vsplit", "split", etc.)
  },
  folder = {
    -- Folder grep configuration
    fd_command = "fd --type d", -- Command to list directories
    fd_args = {}, -- Additional arguments for fd
  }
})
```

### Default Configuration

```lua
{
  github = {
    default_filters = {},
    buffer_position = "vsplit",
  },
  folder = {
    fd_command = "fd --type d",
    fd_args = {},
  }
}
```

## Recommended Keymappings

Add these to your Neovim configuration:

```lua
-- Folder-specific grep
vim.keymap.set('n', '<leader>sf', require('fzf-kit').folder_grep, { desc = 'Grep in folder' })

-- GitHub PR interaction
vim.keymap.set('n', '<leader>gp', require('fzf-kit').github_prs, { desc = 'GitHub PRs' })
```

## Dependency Installation

### fd

- **macOS**: `brew install fd`
- **Ubuntu/Debian**: `apt install fd-find`
- **Arch Linux**: `pacman -S fd`

### GitHub CLI

- **macOS**: `brew install gh`
- **Ubuntu/Debian**: `apt install gh`
- **Arch Linux**: `pacman -S github-cli`
- **Other**: See [GitHub CLI installation](https://github.com/cli/cli#installation)

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history.

## Credits

- [@junegunn](https://github.com/junegunn/) for creating [fzf](https://github.com/junegunn/fzf)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua) - The foundation this plugin builds upon
- [fd](https://github.com/sharkdp/fd) - a simple, fast and user-friendly 'fd'
