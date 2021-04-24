#! /usr/bin/env lua -m

-- Copyright (C) 2021 Hans Liljestrand <hans@liljestrand.dev>
--
-- Distributed under terms of the MIT license.
local hw = {}

local cpumodel
local cpucount

local function __get_cpuinfo()
  local cpu_model = nil
  local cpu_count = 0

  for line in io.lines('/proc/cpuinfo') do
    if not cpu_model then
      local i, j = string.find(line, '^model name.*:')
      if i then
        cpu_model = string.sub(line, j + 2)
      end
    end

    local i, j = string.find(line, '^processor.*:')
    if i then
      cpu_count = string.sub(line, j + 2)
    end
  end

  return cpu_model, tonumber(cpu_count)
end

function hw.get_gpuname()
  local f = assert(io.popen('nvidia-smi --query-gpu=name --format=csv | tail -n1', 'r'))
  local gpu_name = string.gsub(assert(f:read('*a')), "\n", "")
  f:close()
  return gpu_name
end

function hw.get_cpumodel()
  if not cpumodel then
    cpumodel, cpucount = __get_cpuinfo()
  end
  return cpumodel
end

function hw.get_cpucount()
  if not cpucount then
    cpumodel, cpucount = __get_cpuinfo()
  end
  return cpucount
end

return hw
