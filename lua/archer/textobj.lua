local quick = require("arshlib.quick")

---Text object for in/around the next object.
---@param motion any
local function next_obj(motion) --{{{
  local c = vim.fn.getchar()
  local ch = vim.fn.nr2char(c)
  local step = "l"
  if ch == ")" or ch == "]" or ch == ">" or ch == "}" then
    step = "h"
  end
  local sequence = "f" .. ch .. step .. "v" .. motion .. ch
  quick.normal("x", sequence)
end --}}}

-- Backtick support
---@param include boolean if true, will remove the backticks too.
local function in_backticks(include) --{{{
  quick.normal("n", "m'")
  vim.fn.search("`", "bcsW")
  local motion = ""
  if not include then
    motion = "l"
  end

  quick.normal("x", motion .. "o")
  vim.fn.search("`", "")

  if include then
    return
  end
  quick.normal("x", "h")
end --}}}

---Number pseudo-text object (integer and float) {{{
---@param around boolean if true, remove the space after number.
local function visual_number(around)
  local last_num = [[\d\([^0-9\.]\|$\)]]
  local first_num = [[\(^\|[^0-9\.]\d\)]]
  vim.fn.search(last_num, "cW")
  vim.fn.search(first_num, "becW")
  quick.normal("xt", "o")
  vim.fn.search(last_num, "cW")
  if around then
    quick.normal("x", "l")
  end
end ---}}}

-- stylua: ignore start
local function setup(opts)
  vim.validate({--{{{
    next_obj  = { opts.next_obj,  { "table",  "boolean", "nil" }, true },
    in_chars  = { opts.in_chars,  { "table",  "boolean", "nil" }, true },
    line      = { opts.line,      { "table",  "boolean", "nil" }, true },
    numeric   = { opts.numeric,   { "table",  "boolean", "nil" }, true },
    backticks = { opts.backticks, { "string", "boolean", "nil" }, true },
    folds     = { opts.folds,     { "table",  "boolean", "nil" }, true },
  })--}}}

  -- Next object support {{{
  if opts.next_obj then
    if opts.next_obj.a_next then
      local key = opts.next_obj.a_next
      local motion = key:sub(1, 1)
      local opt = { desc = "around next pairs" }
      vim.keymap.set("x", key, function() next_obj(motion) end, opt)
      vim.keymap.set("o", key, function() next_obj(motion) end, opt)
    end

    if opts.next_obj.i_next then
      local key = opts.next_obj.i_next
      local motion = key:sub(1, 1)
      local opt = { desc = "in next pairs" }
      vim.keymap.set("x", key, function() next_obj(motion) end, opt)
      vim.keymap.set("o", key, function() next_obj(motion) end, opt)
    end
  end --}}}

  -- In random character support {{{
  if opts.in_chars then
    local chars = opts.in_chars or {}
    for _, ch in ipairs(opts.extra_in_chars or {}) do
      table.insert(chars, ch)
    end
    for _, ch in ipairs(chars) do
      local opt = { desc = "in pairs of " .. ch }
      vim.keymap.set("x", "i" .. ch, function() quick.normal("xt", "T" .. ch .. "ot" .. ch) end, opt)
      vim.keymap.set("o", "i" .. ch, function() quick.normal("x", "vi" .. ch) end, opt)

      opt = { desc = "around pairs of " .. ch }
      vim.keymap.set("x", "a" .. ch, function() quick.normal("xt", "F" .. ch .. "of" .. ch) end, opt)
      vim.keymap.set("o", "a" .. ch, function() quick.normal("x", "va" .. ch) end, opt)
    end
  end--}}}

  -- Line support {{{
  if opts.line then
    if opts.line.i_line then
      local opt = { desc = "in current line" }
      local key = opts.line.i_line
      vim.keymap.set("x", key, function() quick.normal("xt", "g_o^") end, opt)
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end

    if opts.line.a_line then
      local opt = { desc = "around current line" }
      local key = opts.line.a_line
      vim.keymap.set("x", key, function() quick.normal("xt", "$o0") end, opt)
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end
  end --}}}

  -- Numeric support {{{
  if opts.numeric then
    if opts.numeric.i_number then
      local opt = { desc = "in numeric value" }
      local key = opts.numeric.i_number
      vim.keymap.set("x", key, visual_number, { desc = "in number" })
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end

    if opts.numeric.a_number then
      local opt = { desc = "around numeric value" }
      local key = opts.numeric.a_number
      vim.keymap.set("x", key, function() visual_number(true) end, opt)
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end
  end --}}}

  -- Backtick support {{{
  if opts.backtick then
    local b = opts.backtick

    local opt = { silent = true, desc = "in backticks" }
    vim.keymap.set("x", "i" .. b, function() in_backticks(false) end, opt)
    vim.keymap.set("o", "i" .. b, function() quick.normal("x", "vi" .. b) end, opt)

    opt = { silent = true, desc = "around backticks" }
    vim.keymap.set("x", "a" .. b, function() in_backticks(true) end, opt)
    vim.keymap.set("o", "a" .. b, function() quick.normal("x", "va" .. b) end, opt)
  end --}}}

  -- Fold support {{{
  if opts.fold then
    if opts.fold.i_block then
      local opt = { silent = true, desc = "in fold block" }
      local key = opts.fold.i_block
      vim.keymap.set("x", key, function() quick.normal("xt", "[zjo]zkV") end, opt)
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end

    if opts.fold.a_block then
      local opt = { silent = true, desc = "around fold blocks" }
      local key = opts.fold.a_block
      vim.keymap.set("x", key, function() quick.normal("xt", "[zo]zV") end, opt)
      vim.keymap.set("o", key, function() quick.normal("x", "v" .. key) end, opt)
    end
  end --}}}
end
-- stylua: ignore end

return {
  setup = setup,
  config = setup,
}

-- vim: fdm=marker fdl=0
