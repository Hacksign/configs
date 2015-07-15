local require = require
local wibox = require("wibox")
local io = require("io")
local timer = timer
local string = require("string")
local os = require("os")
local table = require("table")
local naughty		= require("naughty")
local capi = {
    mouse = mouse,
    screen = screen
}
local weather_naughty

module("weather")

local function get_weather_line(city)
	local weathers = {short_info = nil, full_info = nil}
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
		local aqi_info = string.split(ws:match('%["data","aqi"%]%s+".-"'), '"')
		local temperature_now = string.split(ws:match('%["data","wendu"%]%s+".-"'), '"')
		weathers.short_info = "<span size='large'><span color='lightgreen'><b>"..city_info[6].."</b></span> <span color='pink'>" .. temperature_now[6] .. "℃</span>".. " <span>" .. aqi_info[6] .. "</span>"
		weathers.full_info = "<span size='large'>"

		for s = 0, 4 do
			--Weather
			local forecast_weather = string.split(ws:match('%["data","forecast",'..s..',"type"%]%s+".-"'), '"')
			local forecast_date = string.split(ws:match('%["data","forecast",'..s..',"date"%]%s+".-"'), '"')
			if s < 2 then
				weathers.short_info = weathers.short_info .. " <span color='red'>" .. (forecast_weather[8]) .. '</span> '
			end
			weathers.full_info = weathers.full_info .. "<span color='pink'>" .. forecast_date[8] .. "</span> " .. "<span color='red'>" .. forecast_weather[8] .. "</span>"

			--Temperature high
			local forecast_high = string.split(ws:match('%["data","forecast",'..s..',"high"%]%s+".-"'), '"')
			if s < 2 then
				weathers.short_info = weathers.short_info .. "<span color='yellow'>" .. (string.split(forecast_high[8], ' ')[2]) .. '</span>-'
			end
			weathers.full_info = weathers.full_info .. " <span color='yellow'>" .. forecast_high[8] .. "</span>"
			--Temperature low
			local forecast_low = string.split(ws:match('%["data","forecast",'..s..',"low"%]%s+".-"'), '"')
			if s < 2 then
				weathers.short_info = weathers.short_info .. "<span color='yellow'>" .. (string.split(forecast_low[8], ' ')[2]) .. '</span>/'
			end
			weathers.full_info = weathers.full_info .. " <span color='yellow'>" .. forecast_low[8] .. "</span>"
			local forecast_fengli = string.split(ws:match('%["data","forecast",'..s..',"fengli"%]%s+".-"'), '"')
			weathers.full_info = weathers.full_info .. " <span>" .. forecast_fengli[8] .. "</span>"
			local forecast_fengxiang = string.split(ws:match('%["data","forecast",'..s..',"fengxiang"%]%s+".-"'), '"')
			weathers.full_info = weathers.full_info .. " <span>" .. forecast_fengxiang[8] .. "</span>\n"
		end
		weathers.short_info = weathers.short_info .. "</span>"
		weathers.full_info = weathers.full_info .. "</span>"
		return weathers 
	end
	return nil
end


local function init(location, box_position)
	local time_interval = 1 * 60 * 60
	weatherwidget = wibox.widget.textbox()
	local w = get_weather_line(location)
	if w.short_info ~= nil then
		weatherwidget:set_markup(w.short_info)
	end

	weatherwidgettimer = timer({timeout = time_interval})
	weatherwidgettimer:connect_signal("timeout",
		function()
			local w = get_weather_line(location)
			if w.short_info ~= nil then
				weatherwidget:set_markup(w.short_info)
			end
		end
	)
	weatherwidget:connect_signal('mouse::enter', function ()
		weather_naughty = naughty.notify({
				text = string.format(w.full_info, "Terminal"),
				timeout = 0,
				position = box_position,
				hover_timeout = 0.5,
				screen = capi.mouse.screen
		})
	end)
	weatherwidget:connect_signal('mouse::leave', function () naughty.destroy(weather_naughty) end)
	return weatherwidget
end

return {init = init}
