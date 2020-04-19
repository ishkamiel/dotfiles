#! /usr/bin/env lua
-- vim: ft=lua sw=2 ts=2
--
-- git_scripts.lua
-- Copyright (C) 2020 Hans Liljestrand <hans@liljestrand.dev>
--
-- Distributed under terms of the MIT license.

-- require "utils"

local git = {}
local utils = require "utils"

do
  local repo_cache

  local cmd_is_repo = [[
git rev-parse --is-inside-work-tree > /dev/null 2>&1]]

  local cmd_unsaged_chagnes = [[
git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code 2> /dev/null]]

  local cmd_verify_head = [[
git rev-parse --quiet --verify HEAD > /dev/null]]

  local cmd_has_staged_changes_HEAD = [[
git diff-index --cached --quiet --ignore-submodules=dirty HEAD 2> /dev/null]]

  local cmd_has_staged_changes_empty_tree = [[
git diff-index --cached --quiet --ignore-submodules=dirty 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2> /dev/null]]

  local cmd_has_untracked_files = [[
[ -n "$(git ls-files --other --exclude-standard | sed q)" ] ]]

  local update_counter = 0
  local DEFAULT_update_interval = 3
  local cache_hit_counter = 0

  function run_cmd(cmd, path)
    assert(path)
    if repo_cache then
      if not repo_cache[cmd] then repo_cache[cmd] = {} end
      if not repo_cache[cmd][path] then
        -- print(string.format("Cache MISS! %s -> %s", path, cmd))
        repo_cache[cmd][path] = os.execute(string.format([[cd "%s"; %s]], path, cmd))
      else
        -- print(string.format("Cache hit! %s -> %s", path, cmd))
        cache_hit_counter = cache_hit_counter + 1
      end
      return repo_cache[cmd][path]
    end
    return os.execute(string.format([[cd "%s"; %s]], path, cmd))
  end

  function git.is_repo(path)
    return 0 == run_cmd(cmd_is_repo, path)
  end

  function git.has_unstaged_changes(path)
    return 0 ~= run_cmd(cmd_unsaged_chagnes, path)
  end

  function git.has_staged_changes(path)
    local r
    if 0 == run_cmd(cmd_verify_head, path) then
      r = run_cmd(cmd_has_staged_changes_HEAD, path)
    else
      r = run_cmd(cmd_has_staged_changes_empty_tree, path)
    end

    return r ~= 0 and r ~=128
  end

  function git.has_untracked_files(path)
    return 0 == run_cmd(cmd_has_untracked_files, path)
  end

  function git.is_dirty(path)
    assert(path)
    return git.has_unstaged_changes(path) or
      git.has_staged_changes(path) or
      git.has_untracked_files(path)
  end

  function git.reset_cache(update_interval)
    if not update_interval then update_interval = DEFAULT_update_interval end
    update_counter = update_counter + 1
    if (update_counter < update_interval) then return end
    -- print(string.format("reset! (%d < %d, hits: %d) -----------------",
    --   update_counter, update_interval, cache_hit_counter))
    update_counter = 0
    cache_hit_counter = 0
    repo_cache = {}
  end

  function git.generate_repository_string(name, path)
    local res = ""
    if not utils.dir_exists(path) then
      res = res .. utils.replace([[
${goto 20} ${color9}##excalamation_triangle## not found! ${alignr} ##NAME##${color}
]], { NAME = name, PATH = path })
    elseif not git.is_repo(path) then
      res = res .. utils.replace([[
${goto 20} ${color9}##excalamation_triangle## not a Git repo! ${alignr} ##NAME##${color}
]], { NAME = name, PATH = path })
    else

      local MODE = utils.replace([[
${execi ##EXECI_INTERVAL##
cd "##PATH##";
if [ -e "##PATH##/.git/BISECT_LOG" ]; then echo -n " <B>"
elif [ -e "##PATH##/.git/MERGE_HEAD" ]; then echo -n " >M<"
elif [ -e "##PATH##/.git/rebase" ] ||
     [ -e "##PATH##/.git/rebase-apply" ] ||
     [ -e "${repo_path}/rebase-merge" ] ||
     [ -e "${repo_path}/../.dotest" ]; then echo -n " >R>"
fi
}]], { NAME = name, PATH = path })

      res = res .. utils.replace([[
${if_match "1"=="${lua_parse git_is_dirty ##PATH##}"}${color 00FF00}${endif}\
${goto 20} ##code_fork## \
${if_match "1"=="${lua_parse git_has_staged_changes ##PATH##}"}C${else} ${endif}\
${if_match "1"=="${lua_parse git_has_unstaged_changes ##PATH##}"}S${else} ${endif}\
${if_match "1"=="${lua_parse git_has_untracked_files ##PATH##}"}U${else} ${endif}\
${alignr}##NAME##${color}
]], {
          NAME = name,
          PATH = path,
          })
    end
    return res
  end
end

return git
