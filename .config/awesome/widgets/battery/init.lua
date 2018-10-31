local require = require
local tonumber = tonumber
local string = require("string")
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

awful.widget.watch("bash -c 'cat /sys/class/power_supply/BAT*/capacity && cat /sys/class/power_supply/BAT*/status 1>&2'", 10,
    function(widget, stdout, stderr, exitreason, exitcode)
        status_percent = trim(stdout)
        charge_status = trim(stderr)
        
        if status_percent ~= '' then
            -- some laptop has multi battery(like Thinkpad T serialize)
	    -- find minimum battery percent in all batteries
	    local percent = '100'
	    string.gsub(
		    status_percent,
		    '[^\n]+',
		    function(word)
			if tonumber(percent) > tonumber(word) then
			    percent = word
			end
		    end
	    )
	    -- check if bat is charging in all batteries
	    string.gsub(charge_status, 'Discharging', function(status)
                charge_status = status
	    end)
            if percent == '100' then
                widget.rounded_edge = false
            else
                widget.rounded_edge = true
            end
            if charge_status == 'Discharging' then
                icon.image = '/usr/share/icons/ultra-flat-icons/status/scalable/battery-caution.svg'
                widget.colors = {
                    '#ff0000'
                }
            else
                b_charging = true
                icon.image = '/usr/share/icons/ultra-flat-icons/devices/scalable/battery.svg'
                widget.colors = {
                    '#0aff0a'
                }
            end
            if tonumber(percent) <= 15 and not b_charging then
                naughty.notify({
                    timeout = 0,
                    fg = "#ffff00",
                    bg = "#003399",
                    title = "Battery is running low !",
                    text = "Battery is running low ! Connect your adapter !" 
                })
            end
            widget.value = percent
        end
    end,
    battery_widget
)

return battery_container
