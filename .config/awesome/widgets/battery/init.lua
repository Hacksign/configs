
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local awful = require("awful")
local io = require("io")
local timer = timer
local assert = assert
local string = string
local tonumber = tonumber
local naughty		= require("naughty")

module("battery")

-- Need install acpi package
--		pacman -S apci
local acpi_info = assert(io.popen("acpi", "r"))
local battery_info = acpi_info:read("*l")
if battery_info then
	batterywidget = awful.widget.progressbar()
	batterywidget:set_width(20)
	batterywidget:set_height(10)
	batterywidget:set_vertical(true)
	batterywidget:set_background_color("#494B4F")
	batterywidget:set_border_color(nil)
	batterywidget:set_max_value(100)
	batterywidgettimer = timer({timeout = 5})
	batterywidgettimer:connect_signal("timeout",
			function()
				local fh = assert(io.popen("acpi | cut -d' ' -f 4 -|cut -d, -f 1 -|cut -d% -f 1 -", "r"))
				local percent = fh:read("*l")
				if percent then
					percent = string.sub(percent, 0, string.len(percent))
					percent = tonumber(percent)
					local ch = assert(io.popen("acpi | cut -d' ' -f3|cut -d, -f1", "r"))
					local charge_status = ch:read("*l")
					local ac = assert(io.popen("acpi -a | cut -d':' -f2|cut -d' ' -f2", "r"))
					local ac_adapter_status = ac:read("*l")
					if charge_status == 'Charging' or charge_status == 'Full' or ac_adapter_status == 'on-line' then
						batterywidget:set_color("#3366FF")
					else
						batterywidget:set_color("#FF5656")
					end
					if percent < 15 and charge_status == "Discharging" then
						naughty.notify({ timeout = 4,
														 fg = "#ffff00",
														 bg = "#003399",
														 title = "Battery is running low !",
														 text = "Battery is running low ! Connect your adapter !" })
					end
					batterywidget:set_value(percent)
					ac:close()
					ch:close()
				end
				fh:close()
			end
	 )
	batterywidgettimer:start()
	return batterywidget
end
