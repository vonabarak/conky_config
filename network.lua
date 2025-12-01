-- Cache the entire output template (built once at startup)
local net_output = nil

local ping_host = "n2.v7k.me"
local ping_port = 8000
local ifconfig_url = "http://" .. ping_host .. ":" .. tostring(ping_port) .. "/ifconfig"

-- Check if interface exists
local function interface_exists(iface)
    local path = "/sys/class/net/" .. iface
    local f = io.open(path .. "/operstate", "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Check if interface is wireless
local function is_wireless(iface)
    local wireless_path = "/sys/class/net/" .. iface .. "/wireless"
    local f = io.open(wireless_path, "r")
    if f then
        f:close()
        return true
    end
    return false
end

-- Takes space-separated list of interfaces as argument
-- Usage: ${lua_parse get_network eth0 wlan0}
function conky_get_network(...)
    -- Return cached output if available
    if net_output then
        return net_output
    end
    
    print("[network.lua] Building output template...")
    
    local interfaces = {...}
    
    if #interfaces == 0 then
        net_output = ""
        return net_output
    end
    
    -- Layout
    local label_width = 110
    local addr_width = 140
    local up_down_width = 60
    local padding = 10

    local col_down = layout.right - up_down_width
    local col_up = col_down - up_down_width - padding
    local col_addr = layout.left + label_width
    
    
    
    print(string.format("[network.lua] Layout: col_addr=%d, col_up=%d, col_down=%d", col_addr, col_up, col_down))
    
    net_output = ""
    
    -- Header
    net_output = net_output .. string.format(
        "${color %s}Net${goto %d}Addr${goto %d}Up${goto %d}Down${color}\n",
        colors.header or "#e0a526", col_addr, col_up, col_down
    )
    
    -- Each interface
    for _, iface in ipairs(interfaces) do
        -- Skip if interface doesn't exist
        if not interface_exists(iface) then
            print(string.format("[network.lua] Interface: %s (not found, skipping)", iface))
            goto continue
        end
        
        local wireless = is_wireless(iface)
        print(string.format("[network.lua] Interface: %s (wireless=%s)", iface, tostring(wireless)))
        
        -- Truncate interface name to 10 characters for display
        local iface_display = string.sub(iface, 1, 10)
        
        -- Interface line with if_up condition
        net_output = net_output .. string.format("${if_up %s}", iface)
        net_output = net_output .. string.format(
            "%s${goto %d}${color %s}${addr %s}${color}${goto %d}${upspeed %s}${goto %d}${downspeed %s}\n",
            iface_display, col_addr, colors.value, iface, col_up, iface, col_down, iface
        )
        
        -- Wireless-specific info
        if wireless then
            -- SSID (fallback to "Not connected" if disconnected)
            local ssid_command = string.format("ssid=$(iw dev %s link | sed -n 's/.*SSID: //p'); echo ${ssid:-\"Not connected\"}", iface)
            net_output = net_output .. string.format(
                "  SSID: ${goto %d}${color %s}${texeci 10 %s}${color}\n",
                col_addr, colors.value, ssid_command
            )
            -- Signal strength bar (0 if disconnected)
            local signal_command = string.format("nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | awk -F: '/^\\*/{f=1;print $2} END{if(!f)print 0}'", iface)
            net_output = net_output .. string.format(
                "  Signal:${goto %d}${color %s}${execibar 10 %s}${color}\n",
                col_addr, colors.bar, signal_command
            )
        end
        
        net_output = net_output .. "${endif}"
        
        ::continue::
    end
    
    -- External IP (cached for 5 minutes)
    net_output = net_output .. string.format(
        "\nExternal: ${color %s}${curl %s 5}${color} Ping: ${color %s}${tcp_ping %s %d}${color}ms",
        colors.value, ifconfig_url, colors.value, ping_host, ping_port
    )
    
    
    return net_output
end

