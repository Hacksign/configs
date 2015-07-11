
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local wibox = require("wibox")
local io = require("io")
local timer = timer
local assert = assert
local string = string
local tonumber = tonumber

module("network")


time_interval = 3
networkwidget = wibox.widget.textbox()
networkwidgettimer = timer({timeout = time_interval})
lasttime_received = 0
lasttime_sent = 0
init = true
unit = 1024 -- kb

function get_device()
    f = io.popen("ip link show | cut -d' ' -f2,9")
    ws = f:read("*a")
    f:close()
    ws = ws:match("%w+: UP") or ws:match("ppp%w+: UNKNOWN")
    if ws ~= nil then
        return ws:match("(%w+):")
    else
        return "network off"
    end
end
networkwidgettimer:connect_signal("timeout",
		function()
			local ifce = get_device()
			local fh = assert(io.popen("cat /sys/class/net/" .. ifce .. "/statistics/tx_bytes", "r"))
			local sent = fh:read("*l")
			local dh = assert(io.popen("cat /sys/class/net/" .. ifce .. "/statistics/rx_bytes", "r"))
			local received = dh:read("*l")
			local dsend,dreceived
			if sent then
				sent = string.sub(sent, 0, string.len(sent))
				sent = tonumber(sent)
				dsend = (sent - lasttime_sent) / time_interval / unit
				dsend = string.format("%.1f", dsend)
				lasttime_sent = sent
			end
			if received then
				received = string.sub(received, 0, string.len(received))
				received = tonumber(received)
				dreceived = (received - lasttime_received) / time_interval / unit
				dreceived = string.format("%.1f", dreceived)
				lasttime_received = received
			end
			local text = "<span size='xx-large'><span color='red'>Up</span>:<b>" .. dsend .. "</b> <span color='green' >Down</span>:<b>" .. dreceived .. "</b></span>"
			if init ~= true then
				networkwidget:set_markup(text)
			end
			if init then init = false end
			fh:close()
			dh:close()
		end
 )
networkwidgettimer:start()

return networkwidget
