# cht-sh.nvim

A Neovim plugin that integrates [cht.sh](https://cht.sh) for quick cheat sheet lookups in a floating popup window without leaving your editor.

## Features

- Search cht.sh directly from Neovim
- Quick lookup for word under cursor with filetype context
- Floating popup window with syntax highlighting
- Visual selection and yanking capabilities
- Minimal workflow interruption

## Requirements

- Neovim >= 0.7
- `curl` (for API requests)

## Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
  'quiet-ghost/cht-sh.nvim',
  config = function()
    require('cht-sh').setup()
  end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
  'quiet-ghost/cht-sh.nvim',
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
- Use visual mode to select multiple lines and yank with `y`
- Results are syntax highlighted based on the detected language
- The popup window supports all standard Vim navigation and selection commands

## License

MIT
