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

  local cmd_is_repo = [[git rev-parse --is-inside-work-tree > /dev/null 2>&1]]

  local cmd_no_unsaged_chagnes = [[
git diff --no-ext-diff --ignore-submodules=dirty --quiet --exit-code 2> /dev/null]]

  local cmd_verify_head = [[
git rev-parse --quiet --verify HEAD > /dev/null]]

  local cmd_has_staged_changes_HEAD = [[test -n "$(git diff-index --cached --ignore-submodules=dirty HEAD)"]]

  local cmd_has_staged_changes_empty_tree = [[
git diff-index --cached --quiet --ignore-submodules=dirty 4b825dc642cb6eb9a060e54bf8d69288fbee4904 2> /dev/null]]

  local cmd_has_untracked_files = [[
[ -n "$(git ls-files --other --exclude-standard | sed q)" ] ]]

  local cmd_is_ahead = [[
git status -sb | grep '\[ahead' > /dev/null]]

  local update_counter = 0
  local DEFAULT_update_interval = 3
  local cache_hit_counter = 0

  local function run_cmd(cmd, path)
    utils.assert(path and cmd, "Missing arguments cmd=%s, path=%s", cmd, path, "more here")
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

  function git.path_exists(path)
    assert(path)
  end

  function git.is_repo(path)
    assert(path)
    return run_cmd(cmd_is_repo, path)
  end

  function git.has_unstaged_changes(path)
    assert(path)
    return not run_cmd(cmd_no_unsaged_chagnes, path)
  end

  function git.has_staged_changes(path)
    assert(path)
    if run_cmd(cmd_verify_head, path) then
      return run_cmd(cmd_has_staged_changes_HEAD, path)
    else
      return run_cmd(cmd_has_staged_changes_empty_tree, path)
    end
  end

  function git.has_untracked_files(path)
    assert(path)
    -- return 0 == run_cmd(cmd_has_untracked_files, path)
    return run_cmd(cmd_has_untracked_files, path)
  end

  function git.is_dirty(path)
    assert(path)
    return git.has_unstaged_changes(path) or
           git.has_staged_changes(path) or
           git.has_untracked_files(path)
  end

  function git.is_ahead(path)
    assert(path)
    -- return 0 == run_cmd(cmd_is_ahead, path)
    return run_cmd(cmd_is_ahead, path)
  end

  function git.reset_cache(update_interval)
    if not update_interval then update_interval = DEFAULT_update_interval end
    update_counter = update_counter + 1
    if (update_counter < update_interval) then return end
    update_counter = 0
    cache_hit_counter = 0
    repo_cache = {}
  end

  function git.gen_strings(args)
    print("Generating git stuff")
    utils.assert(args.repos, "Must supply at least { repos = ... }")
    return utils.foldr(function(a,b,c)
      return a..git.gen_string(c,b, args)
    end, "", args.repos)
  end

  function git.gen_string(name, path, args)
    local hide_non_repos = args.hide_non_repos or false
    local hide_clean = args.hide_clean or false
    local not_found = args.not_found or [[
${goto 20} ${color9}##excalamation_triangle## not found! ${alignr} ##NAME##${color}
]]
    local not_a_repo = args.not_a_repo or [[
${goto 20} ${color9}##excalamation_triangle## not a Git repo! ${alignr} ##NAME##${color}
]]

    local is_repo = args.is_repo or [[
${if_match "1"=="${lua_parse git_is_dirty ##PATH##}"}${color 00CC66}\
${else}${if_match "1"=="${lua_parse git_is_ahead ##PATH##}"}${color 33CC33}${endif}\
${endif}\
${goto 20} ##code_fork## \
${if_match "1"=="${lua_parse git_has_staged_changes ##PATH##}"}C${else} ${endif}\
${if_match "1"=="${lua_parse git_has_unstaged_changes ##PATH##}"}S${else} ${endif}\
${if_match "1"=="${lua_parse git_has_untracked_files ##PATH##}"}U${else} ${endif}\
${if_match "1"=="${lua_parse git_is_ahead ##PATH##}"}^${else} ${endif}\
${alignr}##NAME##${color}
]]

    -- FIXME: This is not used currently!
--     local MODE = utils.replace([[
-- ${execi ##EXECI_INTERVAL##
-- cd "##PATH##";
-- if [ -e "##PATH##/.git/BISECT_LOG" ]; then echo -n " <B>"
-- elif [ -e "##PATH##/.git/MERGE_HEAD" ]; then echo -n " >M<"
-- elif [ -e "##PATH##/.git/rebase" ] ||
--      [ -e "##PATH##/.git/rebase-apply" ] ||
--      [ -e "${repo_path}/rebase-merge" ] ||
--      [ -e "${repo_path}/../.dotest" ]; then echo -n " >R>"
-- fi
-- }]], { NAME = name, PATH = path })


    local res = utils.replace(is_repo, { NAME = name, PATH = path })

    if hide_clean then
      res = utils.replace(
        [[${if_match "0"=="${lua_parse git_is_clean ##PATH##}"}%s${endif}]],
        { NAME = name, PATH = path }, res)
    end

    if hide_non_repos then
      res =  utils.replace(
        [[${if_match "1"=="${lua_parse git_is_repo ##PATH##}"}%s${endif}]],
        { NAME = name, PATH = path }, res)
    else
      res = utils.replace(
        [[${if_match "0"=="${lua_parse git_path_exists ##PATH##}"}%s${else}]] ..
        [[${if_match "0"=="${lua_parse git_is_repo ##PATH##}"}%s${else}%s${endif}${endif}]],
        { NAME = name, PATH = path }, not_found, not_a_repo, res)
    end

    return res
  end

  function git.get_repos(env_var)
    local repos_string = os.getenv(env_var)
    if not repos_string then return {} end

    local res = {}

    print ("trying to igure out repositories to use")

    res['~/notes'] = '/home/ishkamiel/notes'
    res['~/Downloads'] = '/home/ishkamiel/Downloads'
    res['~/asdf'] = '/home/ishkamiel/asdf'

    for path in string.gmatch(repos_string, "([^;)]+)") do
      print("found " .. path)
      res[utils.get_shortpath(path)] = path
    end

    return res
end

end

return git
