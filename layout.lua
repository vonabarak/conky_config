-- Layout configuration (window size and position)

-- Get screen resolution using xrandr
local function get_screen_resolution()
    local handle = io.popen("xrandr --current | grep '\\*' | head -1 | awk '{print $1}'")
    if handle then
        local resolution = handle:read("*line")
        handle:close()
        
        if resolution then
            local width, height = resolution:match("(%d+)x(%d+)")
            if width and height then
                print(string.format("[layout.lua] Screen resolution: %sx%s", width, height))
                return tonumber(width), tonumber(height)
            end
        end
    end
    
    -- Fallback to common resolution
    print("[layout.lua] Failed to detect screen resolution, using fallback 1920x1080")
    return 2560, 1440
end

local window_width = 420
local window_height = 10
local border_width = 1
local border_inner_margin = 10
local border_outer_margin = 10
local margin_x = 30
local margin_y = 80  -- margin from top of screen, should be enough for the top panel
local graph_height = 40

local screen_width, screen_height = get_screen_resolution()
local left = border_width + border_inner_margin + border_outer_margin
local right = window_width + border_width + border_inner_margin + border_outer_margin
local middle = math.floor(window_width / 2) + border_width + border_inner_margin + border_outer_margin

-- Layout configuration
layout = {
    screen_width = screen_width,
    screen_height = screen_height,
    
    -- Window dimensions
    window_width = window_width,
    window_height = window_height,
    border_width = border_width,
    border_inner_margin = border_inner_margin,
    border_outer_margin = border_outer_margin,

    left = left,
    right = right,
    middle = middle,

    -- Margins from screen edge
    margin_x = margin_x,
    margin_y = margin_y,

    graph_height = graph_height
}

-- Calculate gap_x for right-aligned window
layout.gap_x = screen_width - layout.window_width - layout.margin_x
layout.gap_y = layout.margin_y

print(string.format("[layout.lua] Window position: gap_x=%d, gap_y=%d", layout.gap_x, layout.gap_y))
print(string.format("[layout.lua] Window width: %d, left: %d, right: %d, middle: %d", layout.window_width, layout.left, layout.right, layout.middle))

