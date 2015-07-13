local require = require
local wibox = require("wibox")
local io = require("io")
local timer = timer
local string = require("string")
local os = require("os")
local table = require("table")
local naughty		= require("naughty")

module("weather")

local function get_weather_line(city)
	string.split = function(s, p)
			local rt= {}
			string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
			return rt
	end
	local cmd = "curl 'http://wthrcdn.etouch.cn/weather_mini?city="..city.."' 2>/dev/null | gzip -d |"..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh"
	local f = io.popen(cmd)
	ws = f:read("*a")
	f:close()

	--City
	if ws:match("city") ~= nil then
		local city_info = string.split(ws:match('%["data","city"%]%s+".-"'), '"')
		local info_line = "<span size='large'><span color='lightgreen'><b>"..city_info[6].."</b></span>"

		for s = 0, 4 do
			--Weather
			local forecast0_weather = string.split(ws:match('%["data","forecast",'..s..',"type"%]%s+".-"'), '"')
			info_line = info_line .. " <span color='red'>" .. (forecast0_weather[8]) .. '</span> '
			--Temperature high
			local forecast0_high = string.split(ws:match('%["data","forecast",'..s..',"high"%]%s+".-"'), '"')
			info_line = info_line .. "<span color='yellow'>" .. (string.split(forecast0_high[8], ' ')[2]) .. '</span>-'
			--Temperature low
			local forecast0_high = string.split(ws:match('%["data","forecast",'..s..',"low"%]%s+".-"'), '"')
			info_line = info_line .. "<span color='yellow'>" .. (string.split(forecast0_high[8], ' ')[2]) .. '</span>/'
		end
		info_line = info_line .. "</span>"
		return info_line 
	end
	return nil
end


local function init(location)
	local time_interval = 1 * 60 * 60
	weatherwidget = wibox.widget.textbox()
	local w = get_weather_line(location)
	if w ~= nil then
		weatherwidget:set_markup(w)
	end

	weatherwidgettimer = timer({timeout = time_interval})
	weatherwidgettimer:connect_signal("timeout",
		function()
			local w = get_weather_line(location)
			if w ~= nil then
				weatherwidget:set_markup(w)
			end
		end
	)
	return weatherwidget
end

return {init = init}
