local require = require
local tonumber = tonumber
local naughty = require('naughty')
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local math = require('math')
local wibox = require('wibox')
local awful = require("awful")

module("memory")

local icon = wibox.widget {
    image = '/usr/share/icons/ultra-flat-icons/devices/scalable/media-memory.svg',
    resize = true,
    widget = wibox.widget.imagebox
}
local background = wibox.container.background(icon)

local memory_widget = wibox.widget {
    background,
    min_value = 0,
    max_value = 100,
    thickness = dpi(5),
    rounded_edge = true,
    start_angle = math.pi * 3.5,
    bg = nil, -- transparent
    paddings = dpi(8),
    widget = wibox.container.arcchart
}
local memory_container = wibox.container.margin(
    memory_widget,
    dpi(3),
    dpi(3),
    dpi(3),
    dpi(3),
    nil
)

awful.widget.watch('cat /proc/meminfo', 60,
    function(widget, stdout, stderr, exitreason, exitcode)
        local mem_total, mem_free = stdout:match('MemTotal:%s*(%d+).*MemFree:%s*(%d+)')
        local free = (1 - (mem_free / mem_total)) * 100
        widget.value = free
    end,
    memory_widget
)

return memory_container
