-- Cache CPU count (read once at startup)
local cpu_count = nil

-- Cache the entire output template (built once at startup)
local cpu_output = nil

local function get_cpu_count()
    if cpu_count then
        return cpu_count
    end
    
    print("[cpufreq.lua] Reading /proc/cpuinfo to detect CPU count...")
    
    cpu_count = 0
    local file = io.open("/proc/cpuinfo", "r")
    
    if file then
        for line in file:lines() do
            if line:match("^processor%s*:") then
                cpu_count = cpu_count + 1
            end
        end
        file:close()
    end
    
    if cpu_count == 0 then
        cpu_count = 1
        print("[cpufreq.lua] Failed to detect CPUs, using fallback: " .. cpu_count)
    else
        print("[cpufreq.lua] Detected CPU count: " .. cpu_count)
    end
    
    return cpu_count
end

function conky_get_cpu_freq_bars()
    -- Return cached output if available
    if cpu_output then
        return cpu_output
    end
    
    print("[cpufreq.lua] Building output template...")
    
    local count = get_cpu_count()
    
    -- Layout: two columns with margin between them
    local column_margin = 20
    local column_width = math.floor((layout.window_width - column_margin) / 2) 
    local text_width = 120

    local bar_width = column_width - text_width
    local col1_start = layout.left
    local col1_bar = col1_start + text_width
    local col2_start = layout.middle + math.floor(column_margin / 2)
    local col2_bar = col2_start + text_width
    
    print(string.format("[cpufreq.lua] Layout: column_width=%d, column_margin=%d, bar_width=%d, text_width=%d, col2_start=%d, col1_bar=%d, col2_bar=%d",
        column_width, column_margin, bar_width, text_width, col1_start, col1_bar, col2_start, col2_bar))
    
    cpu_output = ""
    
    for i = 1, count, 2 do
        -- First column
        cpu_output = cpu_output .. string.format(
            "${color %s}${freq_g %d}${color}GHz ${color %s}${cpu cpu%d}${color}%%${color}${goto %d}${color %s}${cpubar cpu%d 6,%d}${color}",
            colors.value, i, colors.value, i, col1_bar, colors.bar, i, bar_width
        )
        
        -- Second column (if exists)
        if i + 1 <= count then
            cpu_output = cpu_output .. string.format(
                "${goto %d}${color %s}${freq_g %d}${color}GHz ${color %s}${cpu cpu%d}${color}%%${color}${goto %d}${color %s}${cpubar cpu%d 6,%d}${color}",
                col2_start, colors.value, i + 1, colors.value, i + 1, col2_bar, colors.bar, i + 1, bar_width
            )
        end
        
        cpu_output = cpu_output .. "\n"
    end
    
    cpu_output = cpu_output .. string.format("${cpugraph %d, %d -l}", layout.graph_height, layout.window_width)
    
    return cpu_output
end
