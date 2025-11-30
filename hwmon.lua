-- Cache hwmon sensors (read once at startup)
local hwmon_sensors = nil

-- Cache the entire output template (built once at startup)
local hwmon_output = nil

local function get_hwmon_sensors()
    if hwmon_sensors then
        return hwmon_sensors
    end
    
    print("[hwmon.lua] Reading /sys/class/hwmon/ sensors...")
    
    hwmon_sensors = {}
    
    -- Iterate through hwmon directories
    local hwmon_list = io.popen("ls -d /sys/class/hwmon/hwmon* 2>/dev/null")
    if hwmon_list then
        for hwmon_path in hwmon_list:lines() do
            -- Extract hwmon number (e.g., "hwmon0" -> 0)
            local hwmon_num = hwmon_path:match("hwmon(%d+)$")
            
            if hwmon_num then
                -- Read the name file
                local name_file = io.open(hwmon_path .. "/name", "r")
                if name_file then
                    local sensor_name = name_file:read("*line")
                    name_file:close()
                    
                    -- Skip sensors named "AC"
                    if sensor_name and sensor_name ~= "AC" then
                        table.insert(hwmon_sensors, {
                            num = tonumber(hwmon_num),
                            name = sensor_name,
                            path = hwmon_path
                        })
                        print(string.format("[hwmon.lua] hwmon%d: %s", hwmon_num, sensor_name))
                    end
                end
            end
        end
        hwmon_list:close()
    end
    
    print(string.format("[hwmon.lua] Found %d hwmon sensors", #hwmon_sensors))
    
    return hwmon_sensors
end

function conky_get_hwmon_list()
    -- Return cached output if available
    if hwmon_output then
        return hwmon_output
    end
    
    print("[hwmon.lua] Building output template...")
    
    local sensors = get_hwmon_sensors()
    
    -- Layout: two columns with margin between them (same as cpufreq.lua)
    local column_margin = 10
    local column_width = math.floor((layout.window_width - column_margin) / 2)
    local text_width = 140  -- space for sensor name
    
    local col1_temp = layout.left + text_width
    local col2_start = layout.middle + math.floor(column_margin /2)
    local col2_temp = col2_start + text_width
    
    print(string.format("[hwmon.lua] Layout: column_width=%d, col2_start=%d, col1_temp=%d, col2_temp=%d",
        column_width, col2_start, col1_temp, col2_temp))
    
    hwmon_output = ""
    local sensor_count = #sensors
    
    for i = 1, sensor_count, 2 do
        local s1 = sensors[i]
        
        -- First column
        hwmon_output = hwmon_output .. string.format(
            "%s:${goto %d}${color %s}${hwmon %d temp 1}°C${color}",
            s1.name, col1_temp, colors.value, s1.num
        )
        
        -- Second column (if exists)
        if i + 1 <= sensor_count then
            local s2 = sensors[i + 1]
            hwmon_output = hwmon_output .. string.format(
                "${goto %d}%s:${goto %d}${color %s}${hwmon %d temp 1}°C${color}",
                col2_start, s2.name, col2_temp, colors.value, s2.num
            )
        end
        
        -- Add newline except for last row
        if i + 2 <= sensor_count then
            hwmon_output = hwmon_output .. "\n"
        end
    end
    
    return hwmon_output
end
