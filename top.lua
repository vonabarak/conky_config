-- Cache the entire output template (built once at startup)
local top_output = nil

function conky_get_top_processes()
    -- Return cached output if available
    if top_output then
        return top_output
    end
    
    print("[top.lua] Building output template...")
    
    -- Layout based on window width
    local pid_width = 100
    local cpu_width = 60
    local mem_width = 60

    local window_width = layout.window_width
    local num_processes = 10
    
    -- Column positions (proportional to window width)
    local col_mem = layout.right - mem_width + 20  -- +20 becase centred on decimal dot
    local col_cpu = col_mem - cpu_width
    local col_pid = col_cpu - pid_width
    
    print(string.format("[top.lua] Layout: col_pid=%d, col_cpu=%d, col_mem=%d",
        col_pid, col_cpu, col_mem))
    
    top_output = ""
    
    -- Header
    top_output = top_output .. string.format(
        "${color %s}Name${goto %d}PID${goto %d}CPU%%${goto %d}MEM%%${color}\n",
        colors.header or "#e0a526", col_pid, col_cpu, col_mem
    )
    
    -- Process rows
    for i = 1, num_processes do
        top_output = top_output .. string.format(
            "${top name %d}${goto %d}${top pid %d}${goto %d}${top cpu %d}${goto %d}${top mem %d}\n",
            i, col_pid, i, col_cpu-20, i, col_mem-20, i
        )
    end
    
    -- Footer with process counts
    top_output = top_output .. string.format(
        "${alignr}Processes:${color %s} $processes${color} Running: ${color %s}$running_processes${color}",
        colors.value, colors.value
    )
    
    return top_output
end

