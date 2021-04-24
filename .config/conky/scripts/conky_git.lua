#! /usr/bin/env lua -m
-- vim: ft=lua sw=2 ts=2
--
-- conky_git.lua
-- Copyright (C) 2020 Hans Liljestrand <hans@liljestrand.dev>
--
-- Distributed under terms of the MIT license.
--
--
package.path = package.path .. string.format(";%s/.config/conky/scripts/?.lua", os.getenv('HOME'))

local git = require "git"
local utils = require "utils"

do
  local cache = {}
  local cache_limit = 5

  local get_cache = function(path, entry)
    if not cache[path] then cache[path] = {} end
    local p = cache[path]

    if not p[entry] then p[entry] = { counter = 0 } end
    local e = p[entry]

    if e.counter > cache_limit then
      e = { counter = 0 }
      p = {}
      cache[path] = p
      cache[path][entry] = e
    else
      e.counter = e.counter + 1
    end

    return e
  end

  local cache_and_return = function(d, v)
    if v then
      d.value = 1
      return 1
    end
    d.value = 0
    return 0
  end

  function conky_git_path_exists(path)
    local d = get_cache(path, 'path_exists')
    if d.value then return d.value end

    return cache_and_return(d, utils.dir_exists(path))
  end

  function conky_git_is_repo(path)
    local d = get_cache(path, 'is_repo')
    if d.value then return d.value end

    return cache_and_return(d, utils.dir_exists(path) and git.is_repo(path))
  end

  function conky_git_is_clean(path)
    local d = get_cache(path, 'is_clean')
    if d.value then return d.value end

    return cache_and_return(d, not (git.is_dirty(path) or git.is_ahead(path)))
  end

  function conky_git_has_unstaged_changes(path)
    local d = get_cache(path, 'has_unstaged_changes')
    if d.value then return d.value end

    return cache_and_return(d, git.has_unstaged_changes(path))
  end

  function conky_git_has_staged_changes(path)
    local d = get_cache(path, 'has_staged_changes')
    if d.value then return d.value end

    return cache_and_return(d, git.has_staged_changes(path))
  end

  function conky_git_has_untracked_files(path)
    local d = get_cache(path, 'has_untracked_files')
    if d.value then return d.value end

    return cache_and_return(d, git.has_untracked_files(path))
  end

  function conky_git_is_dirty(path)
    local d = get_cache(path, 'is_dirty')
    if d.value then return d.value end

    return cache_and_return(d, git.is_dirty(path))
  end

  function conky_git_is_ahead(path)
    local d = get_cache(path, 'is_ahead')
    if d.value then return d.value end

    return cache_and_return(d, git.is_ahead(path))
  end
end

-- dprint("lua: %s loaded\n", string.match(debug.getinfo(1, 'S').source, "^@(.+)$"))

