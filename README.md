# vshow.nvim

Configurable Neovim plugin for showing whitespace in visual mode that abstracts away setting up autocommands (and maybe more in the future).

## Features

- Customizable list of characters to show
- Mode-specific settings

## Installation

To install with [packer.nvim](https://github.com/wbthomason/packer.nvim):

```lua
use 'oxtna/vshow.nvim'
```

To install with [vim-plug](https://github.com/junegunn/vim-plug):

```vim
Plug 'oxtna/vshow.nvim'
```

## Usage

To start using `vshow` with default settings, run setup in a lua file
or a lua heredoc [:help lua-heredoc](https://neovim.io/doc/user/lua.html)
inside a vim file:

```lua
require('vshow').setup()
```

If you're using [packer.nvim](https://github.com/wbthomason/packer.nvim),
you can setup `vshow` inside the plugin spec:

```lua
use {
  'oxtna/vshow.nvim',
  config = function()
    require('vshow').setup()
  end
}
```

To change `vshow`'s behavior, pass the configuration table to the setup function:

```lua
require('vshow').setup({
  {
    { character = { 'space', 'nbsp' }, symbol = '•' },
    { character = 'tab', symbol = '>•' },
  },
  line = {
    { character = 'multispace', symbol = '|•' },
  },
})
```

## Configuration

For the complete list of available configuration options, check [:help vshow.nvim](doc/vshow.txt)

Here is a list with all of the default options:

```lua
require('vshow').setup({
  all = {
    { character = 'eol', symbol = '' },
    { character = 'tab', symbol = '> ' },
    { character = 'space', symbol = '' },
    { character = 'multispace', symbol = '' },
    { character = 'lead', symbol = '' },
    { character = 'trail', symbol = '-' },
    { character = 'extends', symbol = '' },
    { character = 'precedes', symbol = '' },
    { character = 'precedes', symbol = '' },
    { character = 'conceal', symbol = '' },
    { character = 'nbsp', symbol = '+' },
  },
  char = {},
  line = {},
  block = {},
})
```

Mode-specific settings overwrite generic settings for all modes.

Warning:
At the moment, due to implementation details, the `1` key in the configuration table takes precedence over the `all` key, ignoring any settings in the `all` key.

