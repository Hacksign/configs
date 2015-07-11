
--[[
                                                   
     Hacksign's widgets for awesome-wm configuration.
     https://github.com/Hacksign/configs.git
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013, Luke Bonham                      
                                                   
--]]

local require = require

module("widgets")

local widgets =
{
    cpu    	= require("widgets.cpu"),
    memory    	= require("widgets.memory"),
    calendar	= require("widgets.calendar35"),
    alttab	= require("widgets.alttab"),
    battery	= require("widgets.battery"),
    network	= require("widgets.network"),
    utils	= require("widgets.utils"),
    temperature	= require("widgets.temperature")
}


return widgets
