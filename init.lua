-- Load all Lua modules
local config_dir = os.getenv("HOME") .. "/.config/conky/"

-- Load colors 
dofile(config_dir .. "colors.lua")
-- Load layout
dofile(config_dir .. "layout.lua")

dofile(config_dir .. "cpufreq.lua")
dofile(config_dir .. "battery.lua")
dofile(config_dir .. "hwmon.lua")
dofile(config_dir .. "filesystems.lua")
dofile(config_dir .. "top.lua")
dofile(config_dir .. "ram.lua")
dofile(config_dir .. "network.lua")
