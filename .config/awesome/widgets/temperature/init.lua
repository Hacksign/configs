local require = require
local tonumber = tonumber
local naughty = require("naughty")
local io = require("io")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local math = require('math')
local wibox = require('wibox')
local awful = require("awful")
local beautiful = require("beautiful")

function trim(s)
    return (s:gsub("^%s*(.-)%s*$", "%1"))
end

local icon = wibox.widget {
    image = '/usr/share/icons/ultra-flat-icons/status/scalable/psensor_hot.svg',
    resize = true,
    widget = wibox.widget.imagebox
}

local icon_container = wibox.container.margin(
    icon,
    dpi(10),
    dpi(-5),
    dpi(10),
    dpi(10),
    nil
)

local temperature_widget = wibox.widget {
    align = 'center',
    valign = 'center',
    widget =  wibox.widget.textbox
}
local temperature_layout = wibox.widget {
    icon_container,
    temperature_widget,
    spacing = 0,
    fill_space = true,
    layout  = wibox.layout.fixed.horizontal,
}

awful.widget.watch('cat /sys/class/thermal/thermal_zone0/temp', 60,
    function(widget, stdout, stderr, exitreason, exitcode)
        stdout = trim(stdout)
        widget.markup = "<span size='xx-large' color='IndianRed'>" .. 
                            "<b>" ..
                                math.floor(tonumber(stdout) / 1000) ..
                            "</b>" ..
                        "</span>"
        stdout = trim(stdout)
    end,
    temperature_widget
)

return temperature_layout
