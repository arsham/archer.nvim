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

---Text object for in/around the context. A context is one or more lines above
---and below the cursor.
---@param is_pending boolean to manage the visual mode.
local function context(is_pending) --{{{
  local from = vim.v.count
  local to = from * 2
  if to == 0 then
    to = 2
  end
  if not is_pending then
    to = from
  end
  local motion = string.format("%dkVo%dj", from, to)
  quick.normal("xt", motion)
end --}}}

---Backtick support
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

local function sequence(keys)
  return ":<C-u>silent! normal! " .. keys .. "<CR>"
end

local function setup(opts)
  -- stylua: ignore start
  vim.validate({--{{{
    next_obj  = { opts.next_obj,  { "table",  "boolean", "nil" }, true },
    in_chars  = { opts.in_chars,  { "table",  "boolean", "nil" }, true },
    line      = { opts.line,      { "table",  "boolean", "nil" }, true },
    numeric   = { opts.numeric,   { "table",  "boolean", "nil" }, true },
    backticks = { opts.backticks, { "string", "boolean", "nil" }, true },
    folds     = { opts.folds,     { "table",  "boolean", "nil" }, true },
    context   = { opts.context,   { "table",  "boolean", "nil" }, true },
    last_changed = { opts.last_changed, { "table", "boolean", "nil" }, true },
  })--}}}

  -- Next object support {{{
  if opts.next_obj then
    if opts.next_obj.a_next then
      local key = opts.next_obj.a_next
      local motion = key:sub(1, 1)
      local opt = { desc = "around next pairs" }
      vim.keymap.set({"x", "o"}, key, function() next_obj(motion) end, opt)
    end

    if opts.next_obj.i_next then
      local key = opts.next_obj.i_next
      local motion = key:sub(1, 1)
      local opt = { desc = "in next pairs" }
      vim.keymap.set({"x", "o"}, key, function() next_obj(motion) end, opt)
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
      vim.keymap.set({ "x", "o" }, "i" .. ch, sequence("f" .. ch .. "F" .. ch .. "lvt" .. ch), opt)

      opt = { desc = "around pairs of " .. ch }
      vim.keymap.set({ "x", "o" }, "a" .. ch, sequence("f" .. ch .. "F" .. ch .. "vf" .. ch), opt)
    end
  end --}}}

  -- Line support {{{
  if opts.line then
    if opts.line.i_line then
      local opt = { desc = "in current line" }
      local key = opts.line.i_line
      vim.keymap.set({"x", "o"}, key, sequence("g_v^"), opt)
    end

    if opts.line.a_line then
      local opt = { desc = "around current line" }
      local key = opts.line.a_line
      vim.keymap.set({"x", "o"}, key, sequence("$v0"), opt)
    end
  end --}}}

  -- Numeric support {{{
  if opts.numeric then
    if opts.numeric.i_number then
      local opt = { desc = "in numeric value" }
      local key = opts.numeric.i_number
      vim.keymap.set({"x", "o"}, key, visual_number, opt)
    end

    if opts.numeric.a_number then
      local opt = { desc = "around numeric value" }
      local key = opts.numeric.a_number
      vim.keymap.set({"x", "o"}, key, function() visual_number(true) end, opt)
    end
  end --}}}

  -- Backtick support {{{
  if opts.backtick then
    local b = opts.backtick

    local opt = { silent = true, desc = "in backticks" }
    vim.keymap.set({"x", "o"}, "i" .. b, function() in_backticks(false) end, opt)

    opt = { silent = true, desc = "around backticks" }
    vim.keymap.set({"x", "o"}, "a" .. b, function() in_backticks(true) end, opt)
  end --}}}

  -- Fold support {{{
  if opts.fold then
    if opts.fold.i_block then
      local opt = { silent = true, desc = "in fold block" }
      local key = opts.fold.i_block
      vim.keymap.set({"x", "o"}, key, sequence("[zjv]zkV"), opt)
    end

    if opts.fold.a_block then
      local opt = { silent = true, desc = "around fold blocks" }
      local key = opts.fold.a_block
      vim.keymap.set({"x", "o"}, key, sequence("[zv]zV"), opt)
    end
  end --}}}

  -- Context support {{{
  if opts.context then
    for _, key in ipairs(opts.context) do
      local opt = { desc = "in context" }
      vim.keymap.set("x", key, function() context(false) end, opt)
      vim.keymap.set("o", key, function() context(true) end, opt)
    end
  end --}}}

  -- Last changed text support {{{
  if opts.last_changed then
    for _, key in ipairs(opts.last_changed) do
      local opt = { desc = "in last changed text" }
      vim.keymap.set({"x", "o"}, key, sequence("`]v`["), opt)
    end
  end
end --}}}

-- stylua: ignore end

return {
  setup = setup,
  config = setup,
}

-- vim: fdm=marker fdl=0
