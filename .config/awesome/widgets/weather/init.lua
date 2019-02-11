local require = require
local awful = require("awful")
local wibox = require("wibox")
local io = require("io")
local gears = require("gears")
local string = require("string")
local os = require("os")
local table = require("table")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty		= require("naughty")
local mouse = mouse
local tonumber		= tonumber

module("weather")

local weatherWidget = {
    weatherShort = nil,
    weatherFull = nil,
    timerInterval = 5,
    location = nil,
	textBox = wibox.widget.textbox(),
	timer = gears.timer(
        {
            timeout = 5
        }
    ),
    fullInfoPanel = nil
}

local function guess_city(widget)
	local cmd = "curl --connect-timeout 1 --max-time 1 --retry-max-time 1 -s 'http://whois.pconline.com.cn/ipJson.jsp?json=true' 2>/dev/null|xargs printf|iconv -fgbk -tutf8"
    awful.spawn.easy_async_with_shell(
        cmd,
        function(stdout, stderr, exitreason, exitcode)
            local city = stdout:match('city:(.-),')
            widget.location = city
        end
    )
end

local function get_weather_line(widget)
	if widget.location == nil then return widget end
	string.split = function(s, p)
			local rt= {}
			string.gsub(s, '[^'..p..']+', function(w) table.insert(rt, w) end )
			return rt
	end
	local cmd = "curl --connect-timeout 1  --max-time 1 --retry-max-time 1 -s 'http://wthrcdn.etouch.cn/weather_mini?city="..widget.location.."' 2>/dev/null | gzip -d | "..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh 2>/dev/null && curl --connect-timeout 1  --max-time 1 --retry-max-time 1 -s 'https://map.baidu.com/?qt=cur&wd='"..widget.location.." | "..os.getenv("HOME").."/.config/awesome/widgets/weather/JSON.sh 1>&2"
    awful.spawn.easy_async_with_shell(
        cmd,
        function(stdout, stderr, exitreason, exitcode)
            if stdout:match("city") ~= nil then
                local city_info = stdout:match('%["data","city"%]%s+"(.-)"')
                local aqi_info = stderr:match('%["aqi","current_city","aqi"%]%s+"(.-)"')
                local aqi_color
                if aqi_info ~= nil then
                    if tonumber(aqi_info) <= 50 then
                        aqi_color = 'Lime'
                    elseif tonumber(aqi_info) >= 51 and tonumber(aqi_info)	<= 100 then
                        aqi_color = 'Cyan'
                    elseif tonumber(aqi_info) >= 101 and tonumber(aqi_info)	<= 150 then
                        aqi_color = 'Yellow'
                    elseif tonumber(aqi_info) >= 151 and tonumber(aqi_info)	<= 200 then
                        aqi_color = 'DarkOrange'
                    elseif tonumber(aqi_info) >= 201 then
                        aqi_color = 'red'
                    end
                else
                    aqi_color = 'white'
                    aqi_info = '-'
                end

                local temperature_now = stdout:match('%["data","wendu"%]%s+"(.-)"')
                local short_info = string.format(
                    "<span font_desc='%s' font_size='small'>",
                    beautiful.font
                )
                local full_info = string.format("<span font_desc='%s' font_size='small'>", beautiful.font)
                if temperature_now ~= nil then
                    short_info = short_info..
                        "<span color='SteelBlue'>"..
                            "<b>"..city_info.."</b>"..
                        "</span>"..
                        "<span color='DarkTurquoise'>"..
                            " "..temperature_now.."℃"..
                        "</span>"..
                        "<span color='"..aqi_color.."'>"..
                            " "..aqi_info..
                        "</span>"

                    for s = 0, 4 do
                        --Weather
                        local forecast_weather = stdout:match('%["data","forecast",'..s..',"type"%]%s+"(.-)"')
                        local forecast_date = stdout:match('%["data","forecast",'..s..',"date"%]%s+"(.-)"')
                        if s < 2 then
                            short_info = short_info..
                                "<span color='Violet'>"..
                                    " "..forecast_weather..
                                '</span>'
                        end

                        if string.find(forecast_date, '%d%d') then
                            full_info = full_info..
                                "<span color='DeepSkyBlue'>"..
                                    forecast_date..
                                "</span>"..
                                "<span color='Violet'>"..
                                    " "..forecast_weather..
                                "</span>"
                        else
                            full_info = full_info..
                                "<span color='DeepSkyBlue'>"..
                                    " "..forecast_date..
                                "</span>"..
                                "<span color='Violet'>"..
                                    " "..forecast_weather..
                                "</span>"
                        end

                        --Temperature high
                        local forecast_high = stdout:match('%["data","forecast",'..s..',"high"%]%s+"(.-)"')
                        if s < 2 then
                            short_info = short_info..
                                "<span color='Gold'>"..
                                    " "..(string.split(forecast_high, ' ')[2])..
                                '</span>'
                        end
                        full_info = full_info..
                            "<span color='Gold'>"..
                                " "..forecast_high..
                            "</span>"
                        --Temperature low
                        local forecast_low = stdout:match('%["data","forecast",'..s..',"low"%]%s+"(.-)"')
                        if s < 2 then
                            short_info = short_info..
                                "<span color='Gold'>"..
                                    " "..(string.split(forecast_low, ' ')[2])..
                                '</span>'
                            if s ~= 1 then short_info = short_info..' /' end
                        end
                        full_info = full_info..
                            "<span color='Gold'>"..
                                " "..forecast_low..
                            "</span>"
                        local forecast_fengli = stdout:match('%["data","forecast",'..s..',"fengli"%]%s+"(.-)"')
                        full_info = full_info..
                            "<span>"..
                                " "..forecast_fengli..
                            "</span>"
                        local forecast_fengxiang = stdout:match('%["data","forecast",'..s..',"fengxiang"%]%s+"(.-)"')
                        full_info = full_info..
                            "<span color='Silver'>"..
                                " "..forecast_fengxiang..
                            "</span>"
                        if s ~= 4 then
                            full_info = full_info .. "\n"
                        end
                    end
                    short_info = short_info.."</span>"
                    full_info = full_info.."</span>"

                    widget.weatherShort = short_info
                    widget.weatherFull = full_info
                end
            end
        end
    )
	--City
end


local function init(location, box_position)
    weatherWidget.timer:connect_signal("timeout",
        function()
            if weatherWidget.location == nil then
                guess_city(weatherWidget)
            end
            if weatherWidget.location ~= nil then
                get_weather_line(weatherWidget)
                if weatherWidget.weatherShort ~= nil then
                    weatherWidget.textBox:set_markup(weatherWidget.weatherShort)
                    if weatherWidget.timerInterval <= 60 then
                        weatherWidget.timerInterval = 1 * 60 * 60
                        weatherWidget.timer.timeout = weatherWidget.timerInterval
                        weatherWidget.timer:again()
                    end
                end
            end
        end
	)
    weatherWidget.timer:start()
    weatherWidget.textBox:connect_signal('mouse::enter', function ()
        if weatherWidget.weatherFull ~= nil then
            weatherWidget.fullInfoPanel = naughty.notify({
                    text = weatherWidget.weatherFull,
                    timeout = 0,
                    position = box_position,
                    hover_timeout = 0.5,
                    screen = mouse.screen
            })
        end
    end)
    weatherWidget.textBox:connect_signal('mouse::leave', function ()
        if weatherWidget.fullInfoPanel ~= nil then
            naughty.destroy(weatherWidget.fullInfoPanel)
            weatherWidget.fullInfoPanel = nil
        end
    end)
    wibox = wibox.container.margin(
        weatherWidget.textBox,
        dpi(3),
        dpi(8),
        dpi(3),
        dpi(8),
        nil
    )
	return wibox
end

return {init = init}
