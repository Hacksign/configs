local require = require
local wibox = require("wibox")
local io = require("io")
local timer = timer
local string = require("string")
local os = require("os")
local table = require("table")
local naughty		= require("naughty")
local tonumber		= tonumber
local capi = {
    mouse = mouse,
    screen = screen
}
local weather_naughty

module("weather")

local function guess_city()
	local cmd = "curl 'http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json' 2>/dev/null|xargs printf"
	local f = io.popen(cmd)
	local ws = f:read("*a")
	f:close()
	local city = ws:match('city:(.-),')
	return city
end

local function get_weather_line(city)
	local weathers = {short_info = nil, full_info = nil}
	string.split = function(s, p)
			local rt= {}
			string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
			return rt
	end
	local cmd = "curl 'http://wthrcdn.etouch.cn/weather_mini?city="..city.."' 2>/dev/null | gzip -d |"..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh"
	local f = io.popen(cmd)
	local ws = f:read("*a")
	f:close()

	--City
	if ws:match("city") ~= nil then
		local city_info = ws:match('%["data","city"%]%s+"(.-)"')
		local aqi_info = ws:match('%["data","aqi"%]%s+"(.-)"')
		local aqi_color
		if tonumber(aqi_info) <= 50 then
			aqi_color = 'lightgreen'
		elseif tonumber(aqi_info) >= 51 and tonumber(aqi_info)	<= 100 then
			aqi_color = 'lightblue'
		elseif tonumber(aqi_info) >= 101 and tonumber(aqi_info)	<= 150 then
			aqi_color = 'yellow'
		elseif tonumber(aqi_info) >= 151 and tonumber(aqi_info)	<= 200 then
			aqi_color = 'orange'
		elseif tonumber(aqi_info) >= 201 then
			aqi_color = 'red'
		end
		local temperature_now = ws:match('%["data","wendu"%]%s+"(.-)"')
		weathers.short_info = "<span size='large'><span color='lightgreen'><b>"..city_info.."</b></span> <span color='pink'>"..temperature_now.."℃</span>".." <span color='"..aqi_color.."'>"..aqi_info.."</span>"
		weathers.full_info = "<span size='large'>"

		for s = 0, 4 do
			--Weather
			local forecast_weather = ws:match('%["data","forecast",'..s..',"type"%]%s+"(.-)"')
			local forecast_date = ws:match('%["data","forecast",'..s..',"date"%]%s+"(.-)"')
			if s < 2 then
				weathers.short_info = weathers.short_info.." <span color='red'>"..(forecast_weather)..'</span> '
			end
			weathers.full_info = weathers.full_info.."<span color='pink'>"..forecast_date.."</span> ".."<span color='red'>"..forecast_weather.."</span>"

			--Temperature high
			local forecast_high = ws:match('%["data","forecast",'..s..',"high"%]%s+"(.-)"')
			if s < 2 then
				weathers.short_info = weathers.short_info.."<span color='yellow'>"..(string.split(forecast_high, ' ')[2])..'</span>-'
			end
			weathers.full_info = weathers.full_info.." <span color='yellow'>"..forecast_high.."</span>"
			--Temperature low
			local forecast_low = ws:match('%["data","forecast",'..s..',"low"%]%s+"(.-)"')
			if s < 2 then
				weathers.short_info = weathers.short_info.."<span color='yellow'>"..(string.split(forecast_low, ' ')[2])..'</span>/'
			end
			weathers.full_info = weathers.full_info.." <span color='yellow'>"..forecast_low.."</span>"
			local forecast_fengli = ws:match('%["data","forecast",'..s..',"fengli"%]%s+"(.-)"')
			weathers.full_info = weathers.full_info.." <span>"..forecast_fengli.."</span>"
			local forecast_fengxiang = ws:match('%["data","forecast",'..s..',"fengxiang"%]%s+"(.-)"')
			weathers.full_info = weathers.full_info.." <span>"..forecast_fengxiang.."</span>\n"
		end
		weathers.short_info = weathers.short_info.."</span>"
		weathers.full_info = weathers.full_info.."</span>"
		return weathers 
	end
	return nil
end


local function init(location, box_position)
	local time_interval = 1 * 60 * 60
	weatherwidget = wibox.widget.textbox()
	if location == nil then
		location = guess_city()
	end
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
	weatherwidgettimer:start()
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
