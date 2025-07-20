# cht-sh.nvim

A Neovim plugin that integrates [cht.sh](https://cht.sh) with Telescope for quick cheat sheet lookups without leaving your editor.

## Features

- 🔍 Search cht.sh directly from Neovim
- 🎯 Quick lookup for word under cursor with filetype context
- 📋 Copy results to clipboard with `<Enter>` or `<C-y>`
- ⚡ Fast Telescope-based UI
- 🚀 Minimal workflow interruption

## Requirements

- Neovim >= 0.7
- [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim)
- `curl` (for API requests)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'your-username/cht-sh.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('cht-sh').setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'your-username/cht-sh.nvim',
  requires = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('cht-sh').setup()
  end
}
```

## Usage

### Commands

- `:ChtSh` - Open search prompt
- `:ChtSh <query>` - Search directly for query
- `:ChtShWord` - Search for word under cursor

### Default Keymaps

- `<leader>ch` - Open cht.sh search
- `<leader>cw` - Search word under cursor

### In Telescope Picker

- `<Enter>` - Copy selected line to clipboard and close
- `<C-y>` - Copy selected line to clipboard (stay in picker)
- `<Esc>` - Close picker

## Configuration

```lua
require('cht-sh').setup({
  base_url = "https://cht.sh/",  -- cht.sh base URL
  default_lang = nil,            -- default language for queries
  keymap = "<leader>ch",         -- main keymap
})
```

## Examples

1. **Quick language lookup**: Type `:ChtSh python/list comprehension`
2. **Context-aware search**: Place cursor on `map` in a JavaScript file and press `<leader>cw`
3. **General search**: Press `<leader>ch` and type `git rebase`

## Tips

- The plugin automatically adds filetype context when searching word under cursor
- Use `<C-y>` to yank multiple lines without closing the picker
- Results are automatically copied to the default register for easy pasting

## License

MIT