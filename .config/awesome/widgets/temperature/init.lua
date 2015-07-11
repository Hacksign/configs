local require = require
local timer = timer
local wibox = require("wibox")

time_interval = 5 
tempwidget = wibox.widget.textbox('')
tempwidgettimer = timer({timeout = time_interval})
local tempfile = "/sys/class/thermal/thermal_zone0/temp"

tempwidgettimer:connect_signal("timeout",
		function()
			local f = io.open(tempfile)
			local coretemp_now = ''
			if f ~= nil then
			    coretemp_now = tonumber(f:read("*a")) / 1000
			else
			    coretemp_now = "N/A"
			end
			f:close()
			tempwidget:set_markup("<span size='xx-large'><span color='#fff000'>Temp</span>:<b>" .. coretemp_now .. "</b></span>")
		end
 )
tempwidgettimer:start()

return tempwidget
