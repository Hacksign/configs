local require = require
local wibox = require("wibox")
local io = require("io")
local gears = require("gears")
local string = require("string")
local os = require("os")
local table = require("table")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty		= require("naughty")
local mouse = mouse
local tonumber		= tonumber
local weather_naughty
local weather_info

module("weather")

local function guess_city()
	local cmd = "curl --connect-timeout 1 --max-time 1 --retry-max-time 1 -s 'http://whois.pconline.com.cn/ipJson.jsp?json=true' 2>/dev/null|xargs printf|iconv -fgbk -tutf8"
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
	local cmd = "curl --connect-timeout 1  --max-time 1 --retry-max-time 1 -s 'http://wthrcdn.etouch.cn/weather_mini?city="..city.."' 2>/dev/null | gzip -d | "..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh"
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
            aqi_info = '-'
        end

        local temperature_now = ws:match('%["data","wendu"%]%s+"(.-)"')
        if temperature_now ~= nil then
            weathers.short_info = ""..
                "<span size='medium'>"..
                    "<span color='lightgreen'>"..
                        "<b>"..city_info.."</b>"..
                    "</span>"..
                    "<span color='pink'>"..
                        " "..temperature_now.."℃"..
                    "</span>"..
                    "<span color='"..aqi_color.."'>"..
                        " "..aqi_info..
                    "</span>"

            weathers.full_info = ""..
                "<span size='medium'>"..
                    "<span size='small'>"..
                        "<b>获取时间</b>:"..
                            get_time..
                    "</span>"

            for s = 0, 4 do
                --Weather
                local forecast_weather = ws:match('%["data","forecast",'..s..',"type"%]%s+"(.-)"')
                local forecast_date = ws:match('%["data","forecast",'..s..',"date"%]%s+"(.-)"')
                if s < 2 then
                    weathers.short_info = weathers.short_info..
                        "<span color='red'>"..
                            " "..forecast_weather..
                        '</span>'
                end

                if string.find(forecast_date, '%d%d') then
                    weathers.full_info = weathers.full_info..
                        "<span color='pink'>"..
                            forecast_date..
                        "</span>"..
                        "<span color='red'>"..
                            " "..forecast_weather..
                        "</span>"
                else
                    weathers.full_info = weathers.full_info..
                        "<span color='pink'>"..
                            " "..forecast_date..
                        "</span>"..
                        "<span color='red'>"..
                            " "..forecast_weather..
                        "</span>"
                end

                --Temperature high
                local forecast_high = ws:match('%["data","forecast",'..s..',"high"%]%s+"(.-)"')
                if s < 2 then
                    weathers.short_info = weathers.short_info..
                        "<span color='yellow'>"..
                            " "..(string.split(forecast_high, ' ')[2])..
                        '</span>'
                end
                weathers.full_info = weathers.full_info..
                    "<span color='yellow'>"..
                        " "..forecast_high..
                    "</span>"
                --Temperature low
                local forecast_low = ws:match('%["data","forecast",'..s..',"low"%]%s+"(.-)"')
                if s < 2 then
                    weathers.short_info = weathers.short_info..
                        "<span color='yellow'>"..
                            " "..(string.split(forecast_low, ' ')[2])..
                        '</span>'
                    if s ~= 1 then weathers.short_info = weathers.short_info..' /' end
                end
                weathers.full_info = weathers.full_info..
                    "<span color='yellow'>"..
                        " "..forecast_low..
                    "</span>"
                local forecast_fengli = ws:match('%["data","forecast",'..s..',"fengli"%]%s+"(.-)"')
                weathers.full_info = weathers.full_info..
                    "<span>"..
                        " "..forecast_fengli..
                    "</span>"
                local forecast_fengxiang = ws:match('%["data","forecast",'..s..',"fengxiang"%]%s+"(.-)"')
                weathers.full_info = weathers.full_info..
                    "<span>"..
                        " "..forecast_fengxiang..
                    "</span>\n"
            end
            weathers.short_info = weathers.short_info.."</span>"
            weathers.full_info = weathers.full_info.."</span>"
            return weathers 
        end
        return nil
	end
	return nil
end


local function init(location, box_position)
	local time_interval = 5
	weatherTextBox = wibox.widget.textbox()
	weatherwidgettimer = gears.timer({timeout = time_interval})
	weatherwidgettimer:connect_signal("timeout",
		function()
			if location == nil then
				location = guess_city()
			end
			if location ~= nil then
				weather_info = get_weather_line(location)
				if weather_info ~= nil and weather_info.short_info ~= nil then
					weatherTextBox:set_markup(weather_info.short_info)
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
            else
                time_interval = 60
                weatherwidgettimer.timeout = time_interval
                weatherwidgettimer:again()
			end
		end
	)
	weatherwidgettimer:start()
	weatherTextBox:connect_signal('mouse::enter', function ()
		if weather_info ~= nil then
			weather_naughty = naughty.notify({
					text = weather_info.full_info,
					timeout = 0,
					position = box_position,
					hover_timeout = 0.5,
					screen = mouse.screen
			})
		end
	end)
	weatherTextBox:connect_signal('mouse::leave', function ()
		if weather_naughty ~= nil then
			naughty.destroy(weather_naughty)
			weather_naughty = nil
		end
	end)
    weatherWidget = wibox.container.margin(
        weatherTextBox,
        dpi(3),
        dpi(12),
        dpi(12),
        dpi(12),
        nil
    )
	return weatherWidget
end

return {init = init}
