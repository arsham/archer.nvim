# Archer

![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/arsham/archer.nvim)
![License](https://img.shields.io/github/license/arsham/archer.nvim)

This Neovim plugin provides key-mapping and text objects for archers. You can
add more mappings by providing keys to the config.

1. [Requirements](#requirements)
2. [Installation](#installation)
3. [Mappings](#mappings)
   - [Empty Lines](#empty-lines)
   - [End of Lines](#end-of-lines)
   - [Pair of Brackets](#pair-of-brackets)
4. [Text Objects](#text-objects)
   - [Next Object](#next-object)
   - [Pseudo Line](#pseudo-line)
   - [In and Around Backticks](#in-and-around-backticks)
   - [In and Around More Characters](#in-and-around-more-characters)
5. [License](#license)

## Requirements

At the moment it works on the development release of Neovim, and will be
officially supporting [Neovim 0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0).

This plugin depends are the following libraries. Please make sure to add them
as dependencies in your package manager:

- [arshlib.nvim](https://github.com/arsham/arshlib.nvim)
- [vim-repeat](https://github.com/tpope/vim-repeat)
- [nvim.lua](https://github.com/norcalli/nvim.lua)

## Installation

Use your favourite package manager to install this library. Packer example:

```lua
use({
  "arsham/archer.nvim",
  requires = { "arsham/arshlib.nvim", "tpope/vim-repeat", "norvalli/nvim.lua" },
  config = function() require("archer").config({}) end,
})
```

### Config

By default this pluging adds all necessary commands and mappings. However you
can change or disable them to your liking.

To disable set them to `false` or `nil` (either would work). For example:

```lua
require("archer").config({
  mappings = false,
  textobj = {
    in_char = nil,
  },
})
```

You can add your own keys to `ending` and `in_chars` by adding to the config
options. For instance if you want to have an extra `ending` mapping for `s`,
which makes `S` the removal part, or whatever else you choose:

```lua
{
  mappings = {
    ending = {
      ending_o = { -- this name is arbitrary but should be unique
        add = "o",
        remove = "O",
      },
    },
  },
  textobj = {
    extra_in_chars = { "a", "b", "c" }, -- don't replace the in_chars
  },
}
```

Here is the default settings:

```lua
{
  mappings = {
    space = {
      before = "[<space>",
      after = "]<space>",
    },
    ending = {
      period = {
        add = ".",
        remove = ">",
      },
      comma = {
        add = ",",
        remove = "lt",
      },
      semicolon = {
        add = ";",
        remove = ":",
      },
    },
    brackets = "<M-{>",
  },
  textobj = {
    next_obj = {
      i_next = "in",
      a_next = "an",
    },
    -- i_ i. i: i, i; i| i/ i\ i* i+ i- i#
    -- a_ a. a: a, a; a| a/ a\ a* a+ a- a#
    in_chars = { "_", ".", ":", ",", ";", "|", "/", "\\", "*", "+", "-", "#" },
    line = {
      i_line = "il",
      a_line = "al",
    },
    backtick = "`",
  },
}
```

## Mappings

### Empty Lines

Normal mode only:

| Mapping    | Notes                               |
| :--------- | :---------------------------------- |
| `[<space>` | Add empty line above without moving |
| `]<space>` | Add empty line below without moving |

### End of Lines

`Normal`, `insert` and `visual` mode. The idea is an opposite of adding a key
should be the same key with `shift`. The default `modifier` key is the `Alt`
key. You can change it if you need to.

To add/remove to/from a block of text, visually select them and initiate.

| Add     | Remove  | Notes     |
| :------ | :------ | :-------- |
| `<M-.>` | `<M->>` | Period    |
| `<M-,>` | `<M-<>` | Comma     |
| `<M-;>` | `<M-:>` | Semicolon |

You can add more if you want.

### Pair of Brackets

In `normal` and `insert` modes, you can hit the `<M-{>` key to add a pair of
brackets at the end of line and enter in the block on the next line:

Assuming the cursor is at `|` and you initiate `<M-{>`, before the action:

```
for a := 0|; a < 10; a++
```

After:

```
for a := 0; a < 10; a++ {
    |
}
```

## Text Objects

### Next Object

Works like normal `i` and `a`, but operates on the next pair. For example in
the following example assuming the cursor `|` is at the beginning of the line,
`cin(` will put you in the inner `()`:

Before:

```go
|tx.Query(ctx, getQuery(badNameQuery))
```

After:

```go
tx.Query(ctx, getQuery(|))
```

### Pseudo Line

`il` and `al` work for a line.

### In and Around Backticks

You can do "di`" or "ya`" for multi-line backtick operations.

### In and Around More Characters

There are sets of **i\*** and **a\*** text objects, where `*` can be any of:
**\_ . : , ; | / \ \* + - #**

You can add more if you like.

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

<!--
vim: foldlevel=1
-->