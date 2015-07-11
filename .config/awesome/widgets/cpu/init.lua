
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local awful = require("awful")

module("cpu")

local cpuwidget = awful.widget.graph()
cpuwidget:set_width(250)
cpuwidget:set_background_color("#000000")
cpuwidget:set_color("#FF5656")

return cpuwidget
