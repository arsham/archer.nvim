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

-- stylua: ignore start
local function config(opts)
  vim.validate({--{{{
    next_obj  = { opts.next_obj,  { "table",  "boolean", "nil" }, true },
    in_chars  = { opts.in_chars,  { "table",  "boolean", "nil" }, true },
    line      = { opts.line,      { "table",  "boolean", "nil" }, true },
    backticks = { opts.backticks, { "string", "boolean", "nil" }, true },
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
      vim.keymap.set("x", "il", function() quick.normal("xt", "g_o^") end, opt)
      vim.keymap.set("o", "il", function() quick.normal("x", "vil") end, opt)
    end

    if opts.line.a_line then
      local opt = { desc = "around current line" }
      vim.keymap.set("x", "al", function() quick.normal("xt", "$o0") end, opt)
      vim.keymap.set("o", "al", function() quick.normal("x", "val") end, opt)
    end
  end --}}}

  -- Backtick support {{{
  if opts.backtick then
    local b = opts.backtick

    local opt = { silent = true, desc = "in backticks" }
    vim.keymap.set("v", "i" .. b, function() in_backticks(false) end, opt)
    vim.keymap.set("o", "i" .. b, function() quick.normal("x", "vi" .. b) end, opt)

    opt = { silent = true, desc = "around backticks" }
    vim.keymap.set("v", "a" .. b, function() in_backticks(true) end, opt)
    vim.keymap.set("o", "a" .. b, function() quick.normal("x", "va" .. b) end, opt)
  end --}}}
end
-- stylua: ignore end

return {
  config = config,
}

-- vim: fdm=marker fdl=0
