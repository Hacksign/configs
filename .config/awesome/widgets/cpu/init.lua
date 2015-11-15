
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local awful = require("awful")
local io = require("io")
local naughty		= require("naughty")
local string = require("string")
local capi = {
    mouse = mouse,
    screen = screen
}

module("cpu")

local cpuwidget = awful.widget.graph()
local disk_naughty
cpuwidget:set_width(250)
cpuwidget:set_background_color("#000000")
cpuwidget:set_color("#FF5656")
cpuwidget:connect_signal('mouse::enter', function ()
	local cmd = "ps -o pid,uname,comm,psr,args,start_time,etimes,pcpu,pmem --sort=-pcpu,-size|head -20"
	local f = io.popen(cmd)
	local blk = f:read("*a")
	f:close()
	disk_naughty = naughty.notify({
			text = string.format('<span font_desc="%s">%s</span>', "Terminal", blk),
			timeout = 0,
			position = box_position,
			hover_timeout = 0.5,
			screen = capi.mouse.screen
	})
end)
cpuwidget:connect_signal('mouse::leave', function ()
	if disk_naughty ~= nil then
		naughty.destroy(disk_naughty)
		disk_naughty = nil
	end
end)

return cpuwidget
