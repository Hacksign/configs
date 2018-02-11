local require = require
local tonumber = tonumber
local naughty = require("naughty")
local io = require("io")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local math = require('math')
local wibox = require('wibox')
local awful = require("awful")

module("battery")

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local icon = wibox.widget {
    image = '/usr/share/icons/ultra-flat-icons/devices/scalable/gnome-dev-battery.svg',
    resize = true,
    widget = wibox.widget.imagebox
}
local background = wibox.container.background(icon)

local battery_widget = wibox.widget {
    background,
    min_value = 0,
    max_value = 100,
    rounded_edge = true,
    border_color = nil,
    border_width = dpi(0),
    start_angle = math.pi * 3.5,
    bg = nil, -- transparent
    paddings = dpi(8),
    thickness = dpi(5),
    widget = wibox.container.arcchart
}
local battery_container = wibox.container.margin(
    battery_widget,
    dpi(3),
    dpi(3),
    dpi(3),
    dpi(3),
    nil
)

awful.widget.watch('cat /sys/class/power_supply/BAT0/capacity', 60 * 5,
    function(widget, stdout, stderr, exitreason, exitcode)
        stdout = trim(stdout)
        if stdout ~= '' then
            if stdout == '100' then
                widget.rounded_edge = false
            end
            local fd = io.open("/sys/class/power_supply/BAT0/status", "r")
            if fd then
                local charge_status = fd:read("*l")
                if charge_status == 'Charging' or charge_status == 'Full' or charge_status == 'Unknown' then
                    widget.colors = {
                        '#0aff0a'
                    }
                else
                    widget.colors = {
                        '#ff0000'
                    }
                end
                fd:close()
            end
            if tonumber(stdout) <= 15 then
                naughty.notify({
                    timeout = 0,
                    fg = "#ffff00",
                    bg = "#003399",
                    title = "Battery is running low !",
                    text = "Battery is running low ! Connect your adapter !" 
                })
            end
            widget.value = stdout
        end
    end,
    battery_widget
)

return battery_container
