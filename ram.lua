-- Cache swap detection (check once at startup)
local has_swap = nil

-- Cache the entire output template (built once at startup)
local ram_output = nil

local function check_swap()
    if has_swap ~= nil then
        return has_swap
    end
    
    print("[ram.lua] Checking for swap...")
    
    has_swap = false
    
    -- Check /proc/swaps for active swap
    local file = io.open("/proc/swaps", "r")
    if file then
        local line_count = 0
        for _ in file:lines() do
            line_count = line_count + 1
        end
        file:close()
        
        -- More than 1 line means swap is configured (first line is header)
        if line_count > 1 then
            has_swap = true
            print("[ram.lua] Swap detected")
        else
            print("[ram.lua] No swap detected")
        end
    else
        print("[ram.lua] Could not read /proc/swaps")
    end
    
    return has_swap
end

function conky_get_ram()
    -- Return cached output if available
    if ram_output then
        return ram_output
    end
    
    print("[ram.lua] Building output template...")
    
    local swap_available = check_swap()
    
    -- Layout
    local text_width = 180

    local bar_start = layout.left + text_width
    
    print(string.format("[ram.lua] Layout: bar_start=%d, swap=%s", bar_start, tostring(swap_available)))
    
    ram_output = ""
    
    -- RAM line
    ram_output = ram_output .. string.format(
        "${color %s}$mem${color}/${color %s}$memmax${color} - ${color %s}$memperc%% ${goto %d}${color %s}${membar 6}${color}\n",
        colors.value, colors.value, colors.value, bar_start, colors.bar
    )
    
    -- Swap line (only if available)
    if swap_available then
        ram_output = ram_output .. string.format(
            "${color %s}$swap${color}/${color %s}$swapmax${color} - ${color %s}$swapperc%% ${goto %d}${color %s}${swapbar 6}${color}\n",
            colors.value, colors.value, colors.value, bar_start, colors.bar
        )
    end
  
    ram_output = ram_output .. string.format("${memgraph %d, %d -l}", layout.graph_height, layout.window_width)

    return ram_output
end

