
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local wibox = require("wibox")
local io = require("io")
local lfs = require("lfs")
local naughty = require("naughty")
local timer = timer
local string = string
local tonumber = tonumber
local assert = assert

module("battery")

local batterywidget =  wibox.widget.progressbar()
local container = wibox.container.rotate(batterywidget, "east")
batterywidget.max_value = 100
batterywidget.width = 20
batterywidget.height = 20
batterywidget.background_color = "#494B4F"
batterywidgettimer = timer({timeout = 5})
batterywidgettimer:connect_signal("timeout",
        function()
            local percent
            local charge_status
            local basedir = "/sys/class/power_supply"
            local dir_iter, dir_obj = lfs.dir(basedir)
            for dir in dir_iter, dir_obj do
              local fd = io.open(basedir.."/"..dir.."/capacity", "r")
              if fd then
                percent = fd:read("*a")
                percent = tonumber(percent)
                fd:close()
                fd = io.open(basedir.."/"..dir.."/status", "r")
                if fd then
                   charge_status = fd:read("*l")
                   fd:close()
                end
                dir_obj:close()
                break
              end
            end
            if percent then
                if charge_status == 'Discharging' then
                    batterywidget.color = "#FF5656"
                elseif charge_status == 'Charging' or charge_status == 'Full' then
                    batterywidget.color = "#00FFFF"
                else
                    batterywidget.color = "#FFFF00"
                end
                if percent < 15 and charge_status == "Discharging" then
                    naughty.notify({
                        timeout = 4,
                        fg = "#ffff00",
                        bg = "#003399",
                        title = "Battery is running low !",
                        text = "Battery is running low ! Connect your adapter !" 
                    })
                end
                batterywidget:set_value(percent)
                ac:close()
                ch:close()
            end
            fh:close()
        end
 )
batterywidgettimer:start()
return container
