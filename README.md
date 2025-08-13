# vshow.nvim

Configurable Neovim plugin for showing whitespace in visual mode that
abstracts away setting up autocommands (and maybe more in the future).

## Features

- Customizable list of characters to show
- Mode-specific settings

## Installation

To install with [lazy.nvim](https://github.com/folke/lazy.nvim):

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

If you're using [lazy.nvim](https://github.com/folke/lazy.nvim),
you can setup `vshow` by creating `vshow.lua` in your plugin directory
with the following content:

```lua
return {
  {
    'oxtna/vshow.nvim',
    event = 'VimEnter',
    config = function()
      require('vshow').setup()
    end,
  }
}
```

To change `vshow`'s behavior, pass the configuration table to the setup,
like so:

```lua
require('vshow').setup({
  {
    space = '•',
    nbsp = '+',
    tab = '>•',
  },
  line = {
    multispace = '|•',
    eol = '$',
  },
  user_default = true,
})
```

## Configuration

`vshow` uses Neovim's built-in *listchars*, so all characters and character
groups are the same as *listchars* keys. To see the whole list of possible keys,
see [:help listchars](https://neovim.io/doc/user/options.html#'listchars').

To use the user's *listchars* as the default base generic configuration instead
of `vshow`'s default base configuration (which is the same as Neovim's default),
set the `user_default` flag to `true` in the configuration table passed to the
`setup` function. Its value is `false` by default.

Here is a list with `vshow`'s default options:

```lua
local config = {
  {
    tab = '> ',
    trail = '-',
    nbsp = '+',
  },
}
```

Mode-specific settings overwrite generic settings for all modes.

To make a character invisible for all modes, set its assigned value to `0` in
the configuration table for all modes, like so:

```lua
require('vshow').setup({
  {
    tab = 0,
  },
})
```

To make a character invisible for a specific mode, set its assigned value to `0`
in the configuration table of that mode, like so:

```lua
require('vshow').setup({
  line = {
    tab = 0,
  },
})
```

