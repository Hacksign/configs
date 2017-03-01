
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local wibox = require("wibox")
local vicious		= require("vicious")

module("memory")

local memwidget = wibox.widget.progressbar()
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)
local container = wibox.container.rotate(memwidget, "east")
memwidget.forced_height = 20
memwidget.forced_width = 20
memwidget.color = "#AECF96"
memwidget.background_color = "#494B4F"
return container
