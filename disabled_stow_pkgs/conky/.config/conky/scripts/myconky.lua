#! /usr/bin/env lua -m

-- Copyright (C) 2021 Hans Liljestrand <hans@liljestrand.dev>
--
-- Distributed under terms of the MIT license.

local hw = require "hw"
local utils = require "utils"

local myc = {}

-- Default configuration
local font_name = 'Fira Code'

do -- Config
  function myc.set_font_name(newname)
    font_name = newname
  end

  function myc.get_font(size)
    return string.format('%s:style=Medium:size=%d', font_name, size)
  end

  function myc.text_size(font_size, text)
    return string.format(
      '${font %s:style=Medium:pixelsize=%d}%s${font}',
      font_name, font_size, text)
  end
end

function myc.show_clock()
  return string.format([[
${alignr}%s
${voffset -25}
${alignr}%s
]],
    myc.text_size(50, '${time %H:%M}'),
    myc.text_size(16, '${time %A %d %B %Y}'))
end

function myc.show_ip_external()
  return utils.replace([[
##globe## external IP ${alignr}${exec curl -s ipinfo.io/ip}
]])
end

function myc.show_cpuinfo()
  local res = utils.replace([[
##microchip##${goto 20} ##CPU_MODEL##
${goto 20} ##thermometer_full## temp: ${hwmon 2 temp 1} °C\
${voffset 4}
]], { CPU_MODEL = hw.get_cpumodel() })

  for i in utils.range(hw.get_cpucount()+1) do res = res .. utils.replace([[
${goto 20} ##LABEL## ${cpu cpu##NUM##}%\
${alignr}${exec awk '/cpu MHz/{i++}i==##NUM##{printf "%.f",$4; exit}' /proc/cpuinfo}MHz \
${cpubar cpu##NUM## 8,100}
]], { NUM = i, LABEL = string.format('cpu%d%s', i,
          (function() if i < 10 then return ' ' else return '' end end)()) })
  end

  return res
end

function myc.show_gpu_info()
    return utils.replace([[
##cogs##${goto 20} ##GPU_NAME##
${goto 20} ##thermometer_full## temp: ${nvidia gputemp} °C ${alignr}fan: ${nvidia fanspeed}%% ${voffset 4}
${goto 20} shader ${nvidia gpuutil}% ${alignr}${nvidia gpufreqcur}MHz ${nvidiabar 8,100 gpufreqcur}
${goto 20} memory ${nvidia memutil}% ${alignr}${nvidia memfreqcur}MHz ${nvidiabar 8,100 memfreqcur}
]], { GPU_NAME = hw.get_gpuname() })
end

function myc.show_net_info(interface, symbol, label)
    return utils.replace([[
${if_match "${addr ##INTERFACE##}"!="No Address"}\
##SYMBOL## ##LABEL## (##INTERFACE##) ${alignr}${addr ##INTERFACE##}
${voffset 4}\
${offset 20}##download## download ${alignr}${downspeedf ##INTERFACE##}k/s (${totaldown ##INTERFACE##})
${voffset -06}\
${offset 20}${color3}${downspeedgraph ##INTERFACE## 50,455 555577 8888AA -t -l}${color}
${voffset -10}\
${offset 20}##upload## upload ${alignr}${upspeedf ##INTERFACE##}k/s (${totalup ##INTERFACE##})
${voffset -06}\
${offset 20}${color3}${upspeedgraph ##INTERFACE## 50,455 775555 AA8888 -t}${color}
${endif}\
]], { INTERFACE = interface, LABEL = label, SYMBOL = symbol })
end

return myc
