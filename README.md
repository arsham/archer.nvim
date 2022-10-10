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
   - [Augmentation](#augmentation)
4. [Text Objects](#text-objects)
   - [Next Object](#next-object)
   - [Pseudo Line](#pseudo-line)
   - [In and Around Backticks](#in-and-around-backticks)
   - [In and Around More Characters](#in-and-around-more-characters)
   - [In and Around Numbers](#in-and-around-numbers)
   - [In and Around Folds](#in-and-around-folds)
5. [License](#license)

## Requirements

This plugin supports [Neovim
v0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0) or newer.

This plugin depends are the following libraries. Please make sure to add them
as dependencies in your package manager:

- [arshlib.nvim](https://github.com/arsham/arshlib.nvim)

## Installation

Use your favourite package manager to install this library. Packer example:

```lua
use({
	"arsham/archer.nvim",
	requires = { "arsham/arshlib.nvim" },
	config = function()
		require("archer").config({})
	end,
})
```

### Config

By default this pluging adds all necessary commands and mappings. However you
can change or disable them to your liking.

To disable set them to `false`. For example:

```lua
require("archer").config({
	mappings = false, -- completely disable mappings
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
    augment_vim = {
      jumplist = 4, -- put in jumplist if count of j/k is more than 4
    },
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
    numeric = {
      i_number = "iN",
      a_number = "aN",
    },
    fold = {
      i_block = "iz",
      a_block = "az",
    },
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

## Augmentation

At the moment we have one augmentation. By default we hook into numbered jumps
(j and k), and if the count is greater than the value, we populate the jump
list. To change the count number:

```lua
{
  mappings = {
    augment_vim = {
      jumplist = 2,
    },
  },
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

You can do `` "di`" `` or `` "ya`" `` for multi-line backtick operations.

### In and Around More Characters

There are sets of **i\*** and **a\*** text objects, where `*` can be any of:
**\_ . : , ; | / \ \* + - #**

You can add more if you like.

### In and Around Numbers

With `iN` and `aN` you can operate on any numbers, even floating point numbers.

### In and Around Folds

`iz` and `az` matches in and around folds.

## License

Licensed under the MIT License. Check the [LICENSE](./LICENSE) file for details.

<!--
vim: foldlevel=1
-->
