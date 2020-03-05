-------------------------------------------------
-- CPU Widget for Awesome Window Manager
-- Shows the current CPU utilization
-- More details could be found here:
-- https://github.com/streetturtle/awesome-wm-widgets/tree/master/cpu-widget

-- @author Pavel Makhov
-- @copyright 2020 Pavel Makhov
-------------------------------------------------

local table = table
local mouse = mouse
local tonumber = tonumber
local string = require("string")
local math = require("math")
local awful = require("awful")
local wibox = require("wibox")
local gears = require("gears")
local naughty = require("naughty")

module("cpu")

local widget = {}

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local function split(string_to_split, separator)
    if separator == nil then separator = "%s" end
    local t={}

    for str in string.gmatch(string_to_split, "([^".. separator .."]+)") do
        table.insert(t, str)
    end

    return t
end

local function starts_with(str, start)
    return str:sub(1, #start) == start
end

local function cpu_widget(args)
    local args = args or {}
    local theme = args.theme or require("beautiful").get()
    local interval = args.interval or 1
    local width = args.width or 50
    local step_width = args.step_width or 2
    local step_spacing = args.step_spacing or 1
    
    local process_pid_width = 90
    local process_name_width = 350
    local process_cpu_width = 80
    local process_mem_width = 80

    local cpu_name_width = process_pid_width
    local cpu_usage_width = process_cpu_width
    local cpu_chart_width = (process_pid_width + process_name_width + process_cpu_width + process_mem_width) - (cpu_name_width + cpu_usage_width)

    local cpugraph_widget = wibox.widget {
        max_value = 100,
        background_color = theme.bg_normal,
        forced_width = width,
        step_width = step_width,
        step_spacing = step_spacing,
        widget = wibox.widget.graph,
        color = "linear:0,0:0,60:0.2," .. "#FF1D1D" .. ":0.5," .. "#FFFF66" .. ":0.8," .. "#66FF33"
    }

    local cpu_rows = {
        spacing = 4,
        layout = wibox.layout.fixed.vertical,
    }

    local is_update = true
    local process_rows = {
        spacing = 8,
        layout = wibox.layout.fixed.vertical,
    }

    local process_header = {
        {
            markup = '<b>PID</b>',
            forced_width = process_pid_width,
            align = 'left',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        {
            markup = '<b>Name</b>',
            forced_width = process_name_width,
            align = 'left',
            valign = 'center',
            widget = wibox.widget.textbox
        },
        {
            {
                markup = '<b>%CPU</b>',
                forced_width = process_cpu_width,
                align = 'left',
                valign = 'center',
                widget = wibox.widget.textbox
            },
            {
                markup = '<b>%MEM</b>',
                forced_width = process_mem_width,
                align = 'left',
                valign = 'center',
                widget = wibox.widget.textbox
            },
            layout = wibox.layout.fixed.horizontal
        },
        layout = wibox.layout.align.horizontal
    }

    local popup = awful.popup {
        ontop = true,
        visible = false,
        shape = gears.shape.rounded_rect,
        border_width = theme.border_width_thin,
        border_color = theme.fg_normal,
        maximum_width = process_pid_width + process_name_width + process_cpu_width + process_mem_width,
        offset = { y = 5 },
        widget = {}
    }

    popup:connect_signal("mouse::enter", function(c) is_update = false end)
    popup:connect_signal("mouse::leave", function(c) is_update = true end)

    cpugraph_widget:buttons(
        awful.util.table.join(
            awful.button({}, 1, function()
                if popup.visible then
                    --rows = nil
                    popup.visible = not popup.visible
                else
                    --init_popup()
                    popup:move_next_to(mouse.current_widget_geometry)
                end
            end)
        )
    )

    --- By default graph widget goes from left to right, so we mirror it and push up a bit
    local this_widget = wibox.container.margin(
        wibox.container.mirror(
            cpugraph_widget,
            { horizontal = true }
        )
        , 0, 0, 0, 2
    )

    local cpus = {}
    awful.widget.watch(
        'bash -c \'cat /proc/stat|grep "^cpu." 2>/dev/null && ps -eo "%p|%c|%C|" -o "%mem" -o "|%P" --sort=-%cpu|head -11|tail -n +2 1>&2\'',
        interval,
        function(widget, stdout, stderr, exitreason, exitcode)
            local i = 1
            local j = 1
            for cpu_usage in stdout:gmatch("[^\r\n]+") do
                if cpus[i] == nil then cpus[i] = {} end
                local name, user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice =
                    cpu_usage:match('(%w+)%s+(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)%s(%d+)')
                local total = user + nice + system + idle + iowait + irq + softirq + steal
                local diff_idle = idle - tonumber(cpus[i]['idle_prev'] == nil and 0 or cpus[i]['idle_prev'])
                local diff_total = total - tonumber(cpus[i]['total_prev'] == nil and 0 or cpus[i]['total_prev'])
                local diff_usage = (1000 * (diff_total - diff_idle) / diff_total + 5) / 10
                cpus[i]['total_prev'] = total
                cpus[i]['idle_prev'] = idle
                if i == 1 then
                    widget:add_value(diff_usage)
                end
                local row = wibox.widget
                {
                    {
                        text = name,
                        forced_width = cpu_name_width,
                        widget = wibox.widget.textbox
                    },
                    {
                        text = math.floor(diff_usage) .. '%',
                        forced_width = cpu_usage_width,
                        widget = wibox.widget.textbox
                    },
                    {
                        max_value = 100,
                        value = diff_usage,
                        forced_height = 20,
                        forced_width = cpu_chart_width,
                        paddings = 1,
                        margins = 4,
                        border_width = theme.border_width_thin,
                        border_color = theme.bg_focus,
                        background_color = theme.bg_normal,
                        bar_border_width = 1,
                        bar_border_color = theme.bg_focus,
                        color = "linear:"..cpu_chart_width..",0:0,0:0.2," .. "#FF1D1D" .. ":0.5," .. "#FFFF66" .. ":0.8," .. "#66FF33",
                        widget = wibox.widget.progressbar,
                    },
                    layout = wibox.layout.align.horizontal
                }
                cpu_rows[i] = row
                i = i + 1
            end
            for process_top in stderr:gmatch("[^\r\n]+") do
                if is_update == true then
                    local columns = split(process_top, '|')
                    local pid = trim(columns[1])
                    local comm = trim(columns[2])
                    local cpu = trim(columns[3])
                    local mem = trim(columns[4])
                    local ppid = trim(columns[5])
                    local row = wibox.widget {
                        {
                            {
                                text = pid,
                                forced_width = process_pid_width,
                                align = 'left',
                                valign = 'center',
                                widget = wibox.widget.textbox
                            },
                            {
                                text = comm,
                                forced_width = process_name_width,
                                align = 'left',
                                valign = 'center',
                                widget = wibox.widget.textbox
                            },
                            {
                                {
                                    text = cpu,
                                    forced_width = process_cpu_width,
                                    align = 'left',
                                    valign = 'center',
                                    widget = wibox.widget.textbox
                                },
                                {
                                    text = mem,
                                    forced_width = process_mem_width,
                                    align = 'left',
                                    valign = 'center',
                                    widget = wibox.widget.textbox
                                },
                                layout = wibox.layout.align.horizontal
                            },
                            layout = wibox.layout.align.horizontal
                        },
                        widget = wibox.container.background
                    }
                    -- Do not update process rows when mouse cursor is over the widget
                    row:connect_signal("mouse::enter", function(c)
                        c:set_fg(theme.fg_focus) 
                        c:set_bg(theme.bg_focus) 
                    end)
                    row:connect_signal("mouse::leave", function(c)
                        c:set_fg(theme.fg_normal) 
                        c:set_bg(theme.bg_normal) 
                    end)
                    awful.tooltip {
                        objects = { row },
                        mode = 'outside',
                        preferred_positions = {'bottom'},
                        timer_function = function()
                            return ppid .. "->" .. pid .. ":" .. comm
                        end,
                    }
                    process_rows[j] = row
                    j = j + 1
                end
            end
            popup:setup {
                {
                    cpu_rows,
                    {
                        orientation = 'horizontal',
                        forced_height = 15,
                        color = theme.bg_focus,
                        widget = wibox.widget.separator
                    },
                    process_header,
                    process_rows,
                    layout = wibox.layout.fixed.vertical,
                },
                margins = 8,
                widget = wibox.container.margin
            }
        end,
        cpugraph_widget
    )

    return this_widget
end

return cpu_widget
