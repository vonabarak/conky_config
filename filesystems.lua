-- Cache the entire output template (built once at startup)
local fs_output = nil

-- Takes space-separated list of mountpoints as argument
-- Usage: ${lua_parse get_filesystems / /home /data}
function conky_get_filesystems(...)
    -- Return cached output if available
    if fs_output then
        return fs_output
    end
    
    print("[filesystems.lua] Building output template...")
    
    local mountpoints = {...}
    
    if #mountpoints == 0 then
        fs_output = ""
        return fs_output
    end
    
    -- Layout
    local label_width = 100
    local value_width = 120
    local window_width = layout.window_width
    local value_start = layout.left + label_width
    local bar_start = value_start + value_width
    
    print(string.format("[filesystems.lua] Layout: label_width=%d, bar_start=%d", label_width, bar_start))
    
    fs_output = ""
    
    for i, mountpoint in ipairs(mountpoints) do
        fs_output = fs_output .. string.format(
            "%s${goto %d}${color %s}${fs_used %s}/${fs_size %s}${color}${goto %d}${color %s}${fs_bar 6 %s}${color}",
            mountpoint, value_start, colors.value, mountpoint, mountpoint, bar_start, colors.bar, mountpoint
        )
        -- Add newline except for last item
        if i < #mountpoints then
            fs_output = fs_output .. "\n"
        end
        print(string.format("[filesystems.lua] Added mountpoint: %s", mountpoint))
    end
    
    return fs_output
end
