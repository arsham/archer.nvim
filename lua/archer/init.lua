local defaults = { --{{{1
  mappings = {
    space = { --{{{
      above = "[<space>",
      below = "]<space>",
    }, --}}}
    ending = { --{{{
      modifier = "M", -- alt
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
    }, --}}}
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
    context = { "ix", "ax" },
  },
} --}}}

local function setup(opts) --{{{
  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  -- Validations {{{
  vim.validate({
    opts = { opts, { "table", "boolean" }, false },
    mappings = { opts.mappings, { "table", "boolean", "nil" }, false },
    textobj = { opts.textobj, { "table", "boolean", "nil" }, false },
  })
  -- }}}

  if opts.mappings then
    require("archer.mappings").setup(opts.mappings)
  end
  if opts.textobj then
    require("archer.textobj").setup(opts.textobj)
  end
end --}}}

return {
  setup = setup,
  config = setup,
}

-- vim: fdm=marker fdl=1
