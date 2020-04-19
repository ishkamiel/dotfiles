#! /usr/bin/env lua
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

-- Cache results here so we don't need to repeat commands on every refresh
function conky_git_has_unstaged_changes(path)
  if git.has_unstaged_changes(path) then return 1 end
  return 0
end

function conky_git_has_staged_changes(path)
  if git.has_staged_changes(path) then return 1 end
  return 0
end

function conky_git_has_untracked_files(path)
  if git.has_untracked_files(path) then return 1 end
  return 0
end

function conky_git_is_dirty(path)
  if git.is_dirty(path) then return 1 end
  return 0
end

function conky_git_reset_cache()
  git.reset_cache()
  return ""
end

dprint("lua: %s loaded\n", string.match(debug.getinfo(1, 'S').source, "^@(.+)$"))

