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
    image = nil,
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

awful.widget.watch("bash -c 'cat /sys/class/power_supply/BAT0/capacity && cat /sys/class/power_supply/BAT0/status 1>&2'", 10,
    function(widget, stdout, stderr, exitreason, exitcode)
        battery_percent = trim(stdout)
        charge_status = trim(stderr)
        
        if battery_percent ~= '' then
            b_charging = false
            if battery_percent == '100' then
                widget.rounded_edge = false
            end
            if charge_status == 'Charging' or charge_status == 'Full' or charge_status == 'Unknown' then
                b_charging = true
                icon.image = '/usr/share/icons/ultra-flat-icons/devices/scalable/battery.svg'
                widget.colors = {
                    '#0aff0a'
                }
            else
                icon.image = '/usr/share/icons/ultra-flat-icons/status/scalable/battery-caution.svg'
                widget.colors = {
                    '#ff0000'
                }
            end
            if tonumber(battery_percent) <= 15 and not b_charging then
                naughty.notify({
                    timeout = 0,
                    fg = "#ffff00",
                    bg = "#003399",
                    title = "Battery is running low !",
                    text = "Battery is running low ! Connect your adapter !" 
                })
            end
            widget.value = battery_percent
        end
    end,
    battery_widget
)

return battery_container
