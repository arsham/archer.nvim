---Add/remove char at the end of a line at the `loc` location.
---@param loc number line number to add the char at.
---@param content string current content of the line.
---@param char string char to add.
---@param remove boolean if false, the char is added, otherwise the last
---character is removed.
local function end_of_line(loc, content, char, remove) --{{{2
  if remove and (content:sub(-1) ~= char) then
    return
  end
  if remove and #content > 0 then
    content = content:sub(1, -2)
  elseif not remove then
    content = content .. char
  end
  vim.api.nvim_buf_set_lines(0, loc - 1, loc, false, { content })
end --}}}

---Add the char at the end of the line, or the visually selected area.
---@param char string char to add.
---@param remove boolean if false, the char is added, otherwise the last
---character is removed.
local function change_line_ends(char, remove) --{{{2
  local mode = vim.api.nvim_get_mode().mode
  if mode == "n" or mode == "i" then
    local loc = vim.api.nvim_win_get_cursor(0)
    local line = vim.api.nvim_get_current_line()
    end_of_line(loc[1], line, char, remove)
  elseif mode == "V" or mode == "CTRL-V" or mode == "v" then
    local start = vim.fn.getpos("v")[2]
    local finish = vim.fn.getcurpos()[2]
    if finish < start then
      start, finish = finish, start
    end
    start = start - 1
    local lines = vim.api.nvim_buf_get_lines(0, start, finish, false)

    for k, line in ipairs(lines) do
      end_of_line(start + k, line, char, remove)
    end
  end
end --}}}

local last_key = ""
-- selene: allow(global_usage)
function _G.add_to_line_end()
  change_line_ends(last_key, false)
end
function _G.remove_from_line_end()
  change_line_ends(last_key, true)
end

---Inserts empty lines near the cursor.
---@param count number  Number of lines to insert.
---@param add number 0 to insert below current line, -1 to insert above current
-- line.
local function insert_empty_lines(count, add) --{{{2
  if count == 0 then
    count = 1
  end
  local lines = {}
  for i = 1, count do
    lines[i] = ""
  end
  local pos = vim.api.nvim_win_get_cursor(0)
  vim.api.nvim_buf_set_lines(0, pos[1] + add, pos[1] + add, false, lines)
end --}}}

-- selene: allow(global_usage)
function _G.empty_line_below()
  insert_empty_lines(vim.v.count, 0)
end
function _G.empty_line_above()
  insert_empty_lines(vim.v.count, -1)
end

local string_type = { "string", "nil", "boolean" }
local function setup_space_mappings(opts) --{{{
  vim.validate({ --{{{
    above = { opts.above, string_type, false },
    below = { opts.below, string_type, false },
  }) --}}}

  if opts.above then --{{{
    local desc = "insert [count]empty line(s) above current line"
    vim.keymap.set("n", opts.above, function()
      vim.opt.opfunc = "v:lua.empty_line_above"
      return "g@l"
    end, { noremap = true, silent = true, expr = true, desc = desc })
  end --}}}

  if opts.below then --{{{
    local desc = "insert [count]empty line(s) below current line"
    vim.keymap.set("n", opts.below, function()
      vim.opt.opfunc = "v:lua.empty_line_below"
      return "g@l"
    end, { noremap = true, silent = true, expr = true, desc = desc })
  end --}}}
end --}}}

---Add coma at the end of the line, or the visually selected area.
local function setup_ending(opts) --{{{
  vim.validate({
    modifier = { opts.modifier, "string", false },
  })
  local end_mapping = {}

  for name, val in pairs(opts) do
    end_mapping[name:upper()] = {
      add = val.add,
      remove = val.remove,
    }
  end

  for n, tuple in pairs(end_mapping) do
    -- Adding {{{
    local key1 = string.format("<%s-%s>", opts.modifier, tuple.add)
    local desc = string.format("Add %s at the end of line", n)
    local opt = { noremap = true, desc = desc }

    vim.keymap.set("n", key1, function()
      last_key = tuple.add
      vim.opt.opfunc = "v:lua.add_to_line_end"
      return "g@l"
    end, { noremap = true, expr = true, desc = desc })

    vim.keymap.set("i", key1, function()
      change_line_ends(tuple.add, false)
    end, opt)

    vim.keymap.set("v", key1, function()
      change_line_ends(tuple.add, false)
    end, opt)
    --}}}

    -- Deleting {{{
    local key2 = string.format("<%s-%s>", opts.modifier, tuple.remove)
    desc = string.format("Remove %s from the end of line", n)

    vim.keymap.set("n", key2, function()
      last_key = tuple.add
      vim.opt.opfunc = "v:lua.remove_from_line_end"
      return "g@l"
    end, { noremap = true, expr = true, desc = desc })

    vim.keymap.set("i", key2, function()
      change_line_ends(tuple.add, true)
    end, opt)

    vim.keymap.set("v", key2, function()
      change_line_ends(tuple.add, true)
    end, opt)
    --}}}
  end
end --}}}

local function augment_vim(opts)
  vim.validate({
    augment = { opts, "table", false },
    jumplist = { opts.jumplist, { "number", "boolean", "nil" }, false },
  })

  -- stylua: ignore start
  if opts.jumplist and opts.jumplist > 1 then
    vim.keymap.set("n", "k",
      string.format([[(v:count > %s ? "m'" . v:count : '') . 'k']], opts.jumplist),
      { noremap = true, expr = true, desc = "numbered motions in the jumplist" }
    )
    vim.keymap.set("n", "j",
      string.format([[(v:count > %s ? "m'" . v:count : '') . 'j']], opts.jumplist),
      { noremap = true, expr = true, desc = "numbered motions in the jumplist" }
    )
  end
  -- stylua: ignore end
end


-- stylua: ignore start
local function config(opts) --{{{
  vim.validate({
    space    = { opts.space,  { "table", "boolean", "nil" }, true },
    ending   = { opts.ending, { "table", "boolean", "nil" }, true },
    brackets = { opts.brackets, string_type, true },
  })
  if opts.space then
    setup_space_mappings(opts.space)
  end

  if opts.ending then
    setup_ending(opts.ending)
  end

  if opts.brackets then --{{{
    local opt = { noremap = true, desc = "Insert a pair of brackets and go into insert mode" }
    vim.keymap.set("i", opts.brackets, "<Esc>A {<CR>}<Esc>O", opt)
    vim.keymap.set("n", opts.brackets, "A {<CR>}<Esc>O",      opt)
  end --}}}

  if opts.augment_vim then --{{{
    augment_vim(opts.augment_vim)
  end --}}}

end --}}}
-- stylua: ignore end

return {
  config = config,
}

-- vim: fdm=marker fdl=1
