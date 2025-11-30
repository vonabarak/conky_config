-- Cache battery detection (check once at startup)
local has_battery = nil

local function check_battery()
    if has_battery ~= nil then
        return has_battery
    end
    
    print("[battery.lua] Checking for battery in /proc/acpi/battery/...")
    
    has_battery = false
    
    -- Check if /proc/acpi/battery/ directory exists
    local battery_dir = io.popen("ls /proc/acpi/battery/ 2>/dev/null")
    if battery_dir then
        local content = battery_dir:read("*all")
        battery_dir:close()
        
        -- If directory has any content (BAT0, BAT1, etc.), battery exists
        if content and content:match("%S") then
            has_battery = true
            print("[battery.lua] Battery detected")
        else
            print("[battery.lua] No battery detected")
        end
    else
        print("[battery.lua] /proc/acpi/battery/ not accessible")
    end
    
    return has_battery
end

function conky_get_battery_info()
    if check_battery() then
        return "Battery:${color #2aff2a} $battery_percent${color}  ${color #2aafff}$battery_bar${color}\n" ..
               "AC:${color #2aff2a} $acpiacadapter${color}"
    else
        return ""
    end
end

