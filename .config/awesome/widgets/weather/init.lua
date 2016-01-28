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
local weather_info

module("weather")

local function urlencode(str)
    if (str) then
        str = string.gsub (str, "\n", "\r\n")
        str = string.gsub (str, "([^%w ])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
        str = string.gsub (str, " ", "+")
    end
    return str    
end

local function guess_city()
	local cmd = "curl --connect-timeout 2 'http://int.dpool.sina.com.cn/iplookup/iplookup.php?format=json' 2>/dev/null|xargs printf"
	local f = io.popen(cmd)
	local ws = f:read("*a")
	f:close()
	local city = ws:match('city:(.-),')
	return city
end

local function get_weather_line(city)
	local weathers = {short_info = nil, full_info = nil}
	if city == nil then return weathers end
	string.split = function(s, p)
			local rt= {}
			string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
			return rt
	end
	local cmd = "curl 'http://wthrcdn.etouch.cn/weather_mini?city="..city.."' 2>/dev/null | gzip -d |"..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh"
	local f = io.popen(cmd)
	local ws = f:read("*a")
	f:close()
	local cmd = "date +'%Y-%m-%d %H:%M'"
	local f = io.popen(cmd)
	local get_time = f:read("*a")
	f:close()

	--City
	if ws:match("city") ~= nil then
		local city_info = ws:match('%["data","city"%]%s+"(.-)"')
		local aqi_info = ws:match('%["data","aqi"%]%s+"(.-)"')
		local aqi_color
        if aqi_info ~= nil then
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
        else
            aqi_color = 'white'
            aqi_info = 'None'
        end
            local temperature_now = ws:match('%["data","wendu"%]%s+"(.-)"')
            weathers.short_info = "<span size='large'><span color='lightgreen'><b>"..city_info.."</b></span> <span color='pink'>"..temperature_now.."℃</span>".." <span color='"..aqi_color.."'>"..aqi_info.."</span>"
            weathers.full_info = "<span size='large'><span size='small'><b>获取时间</b>:"..get_time.."</span>"

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
                    weathers.short_info = weathers.short_info.."<span color='yellow'>"..(string.split(forecast_low, ' ')[2])..'</span>'
                    if s ~= 1 then weathers.short_info = weathers.short_info .. ' /' end
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
	local time_interval = 1.5
	weatherwidget = wibox.widget.textbox()
	weatherwidgettimer = timer({timeout = time_interval})
	weatherwidgettimer:connect_signal("timeout",
		function()
			if location == nil then
				location = urlencode(guess_city())
			end
			if location ~= nil then
				weather_info = get_weather_line(location)
				if weather_info ~= nil and weather_info.short_info ~= nil then
					weatherwidget:set_markup(weather_info.short_info)
					if time_interval <= 60 then
						time_interval = 1 * 60 * 60
						weatherwidgettimer.timeout = time_interval
						weatherwidgettimer:again()
					end
				else
					if time_interval > 60 then
						time_interval = 60
						weatherwidgettimer.timeout = time_interval
						weatherwidgettimer:again()
					end
				end
			end
		end
	)
	weatherwidgettimer:start()
	weatherwidget:connect_signal('mouse::enter', function ()
		if weather_info ~= nil then
			weather_naughty = naughty.notify({
					text = weather_info.full_info,
					timeout = 0,
					position = box_position,
					hover_timeout = 0.5,
					screen = capi.mouse.screen
			})
		end
	end)
	weatherwidget:connect_signal('mouse::leave', function ()
		if weather_naughty ~= nil then
			naughty.destroy(weather_naughty)
			weather_naughty = nil
		end
	end)
	return weatherwidget
end

return {init = init}
