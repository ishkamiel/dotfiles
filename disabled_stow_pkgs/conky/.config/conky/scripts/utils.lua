#! /usr/bin/env lua
-- vim: ft=lua sw=2 ts=2
--
-- utils.lua
-- Copyright (C) 2020 Hans Liljestrand <hans@liljestrand.dev>
--
-- Distributed under terms of the MIT license.
--

local utils = {}

do
  local do_debug = true
  local a_test_widths = false
  local a_wid = ''
  local a_sym
  local extra_replace = {}

  -- from: https://stackoverflow.com/a/26071044
  --
  local bytemarkers = { {0x7FF,192}, {0xFFFF,224}, {0x1FFFFF,240} }
  local utf8 = function(decimal)
    if decimal<128 then return string.char(decimal) end
    local charbytes = {}
    for bytes,vals in ipairs(bytemarkers) do
      if decimal<=vals[1] then
        for b=bytes+1,2,-1 do
          local mod = decimal%64
          decimal = (decimal-mod)/64
          charbytes[b] = string.char(128+mod)
        end
        charbytes[1] = string.char(vals[2]+decimal)
        break
      end
    end
    return table.concat(charbytes)
  end

  local function add_sym(name, unicode, offset)
    -- toerr(name)
    a_sym[name] = string.format(
      '${voffset 3}${font forkawesome:style=Regular:size=10}%s${font}${offset %d}${voffset -3}',
      utf8(unicode), offset)
    if a_test_widths then
      a_wid = a_wid .. string.format("%s | %s\n${voffset -12}", a_sym[name], name)
    end
  end

  local function generate_symbols()
    a_sym = {}
    a_wid = ""

    -- Just an empty space for alignment
    add_sym('space', 0x020, 14)

    -- Symbols
    add_sym('at', 0xf1fa, 4)
    add_sym('bell', 0xf0f3, 3)
    add_sym('bluetooth', 0xf293, 5)
    add_sym('bluetooth_b', 0xf294, 8)
    add_sym('circle', 0xf111, 4)
    add_sym('code_fork', 0xf126, 7)
    add_sym('cogs', 0xf085, 1)
    add_sym('download', 0xf019, 3)
    add_sym('excalamation_triangle', 0xf071, 3)
    add_sym('git', 0xf1d3, 3)
    add_sym('globe', 0xf0ac, 4)
    add_sym('hdd', 0xf0a0, 4)
    add_sym('microchip', 0xf2db, 4)
    add_sym('microphone', 0xf130, 6)
    add_sym('plug', 0xf1e6, 2)
    add_sym('plus', 0xf067, 5)
    add_sym('map_marker', 0xf041, 7)
    add_sym('pin', 0xf276, 7)
    add_sym('thermometer_full', 0xf2c7, 7)
    add_sym('thumbtack', 0xf08d, 6)
    add_sym('upload', 0xf093, 3)
    add_sym('wifi', 0xf1eb, 0)

    -- Symbols that don't work :(
    add_sym('ethernet', 0xf796, 0)
    add_sym('map_marker_alt', 0xf3c5, 10)
    add_sym('memory', 0xf538, 0)
    add_sym('mouse', 0xf8cc, 0)
    add_sym('network_wired', 0xf6ff, 8)
    add_sym('temperature_high', 0xf769, 5)
    add_sym('temperature_low', 0xf76b, 5)

    if a_test_widths then
      a_wid = a_wid .. "${goto 20} |\n"
    end
  end

  function utils.dprint(s, ...)
    if do_debug then io.stderr:write(string.format(s, ...)) end
  end

  -- from: http://lua-users.org/wiki/RangeIterator
  --
  -- range(start)             returns an iterator from 1 to a (step = 1)
  -- range(start, stop)       returns an iterator from a to b (step = 1)
  -- range(start, stop, step) returns an iterator from a to b, counting by step.
  function utils.range(i, to, inc)
    if i == nil then return end -- range(--[[ no args ]]) -> return "nothing" to fail the loop in the caller

    if not to then
      to = i
      i  = to == 0 and 0 or (to > 0 and 1 or -1)
    end

    -- we don't have to do the to == 0 check
    -- 0 -> 0 with any inc would never iterate
    inc = inc or (i < to and 1 or -1)

    -- step back (once) before we start
    i = i - inc

    return function () if i == to then return nil end i = i + inc return i, i end
  end

  function utils.set_extra_replace(new_extra_replace)
    extra_replace = new_extra_replace
  end

  function utils.replace(text, other_subs, ...)
    if not a_sym then generate_symbols() end

    if ... then text = string.format(text, ...) end

    for name, value in pairs(a_sym) do
      text = string.gsub(text, string.format('##%s##', name), value)
    end

    for name, value in pairs(extra_replace) do
      text = string.gsub(text, string.format('##%s##', name), value)
    end

    if other_subs then
      for name, value in pairs(other_subs) do
        text = string.gsub(text, string.format('##%s##', name), value)
      end
    end

    return text
  end

  function utils.dir_exists(path)
    local f = io.open(path,"r")
    if f == nil then return false end
    f:close(f)
    return true
  end

  function utils.generate_symbol_width_string()
    return a_wid
  end

  function utils.get_symbol(var)
    return a_sym[var]
  end

  function utils.foldr (func, val, tbl)
    for i,v in pairs(tbl) do
      val = func(val, v, i)
    end
    return val
  end

  function utils.get_shortpath(fullpath)
    return string.gsub(fullpath, string.format('^%s', os.getenv('HOME')), '~')
  end

  utils.printf = function(f, ...)
    print(string.format(f, ...))
  end

  utils.assert = function(a, f, ...)
    if not a then
      local values = {}
      for i = 1, select('#', ...) do
        local v = select(i, ...)
        if v == nil then
          values[i] = 'nil'
        else
          values[i] = string.format("'%s'", v)
        end
      end
      print(debug.traceback())
      error(string.format(f, table.unpack(values)))
    end
    return a
  end

end

return utils
