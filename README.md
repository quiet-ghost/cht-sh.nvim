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
  'quiet-ghost/cht-sh.nvim',
  dependencies = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('cht-sh').setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'quiet-ghost/cht-sh.nvim',
  requires = { 'nvim-telescope/telescope.nvim' },
  config = function()
    require('cht-sh').setup()
  end
}
```

## Usage

### Commands

- `:ChtSh` - Open search prompt (auto-detects current language)
- `:ChtSh <query>` - Search directly for query
- `:ChtShWord` - Search for word under cursor with language context
- `:ChtShLang` - Show cheat sheet for current language

### Default Keymaps

- `<leader>ch` - Open cht.sh search (language-aware)
- `<leader>cw` - Search word under cursor
- `<leader>cL` - Show cheat sheet for current language

### In Popup Window

- **Navigation** - Use `j/k`, `<C-d>/<C-u>`, `gg/G` etc.
- **Visual mode** - Select multiple lines with `v`, `V`, or `<C-v>`
- `y` - Yank selected text in visual mode
- `yy` - Yank current line
- `Y` - Yank entire cheat sheet
- `q`, `<Esc>`, or `<C-c>` - Close popup

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
