local string = string
local mouse = mouse
local ipairs = ipairs
local tonumber = tonumber
local os = require("os")
local math = require('math')
local wibox = require('wibox')
local awful = require('awful')
local gears = require('gears')
local naughty = require('naughty')
local serialize = require('utils/serialize')
local json = require('utils/json')
local trim = require('utils/trim')
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local options = {
    loop = 0,
    city = nil,
    cityCode = nil,
    theme = nil,
    interval = 5,
    weather_got = false
}

local popup = awful.popup {
    ontop = true,
    visible = false,
    shape = gears.shape.rounded_rect,
    maximum_width = 900,
    offset = { y = 5 },
    widget = {}
}

local widget = wibox.widget {
    markup = '',
    align = 'center',
    valign = 'center',
    widget = wibox.widget.textbox
}

widget:buttons(
    awful.util.table.join(
        awful.button({}, 1, function()
            if popup.visible then
                --rows = nil
                popup.visible = not popup.visible
            else
                --init_popup()
                popup:move_next_to(mouse.current_widget_geometry)
            end
        end)
    )
)

local function escape_char(ch)
    ch = ch:gsub("&", "&amp;") -- this must be first
    ch = ch:gsub("<", "&lt;")
    ch = ch:gsub(">", "&gt;")
    ch = ch:gsub("'", "&#39;")
    return ch
end
local function unescape_char(ch)
    ch = ch:gsub("&amp;", "&") -- this must be first
    ch = ch:gsub("&lt;", "<")
    ch = ch:gsub("&gt;", ">")
    ch = ch:gsub("&#39;", "'")
    return ch
end

local function guess_city()
    local cmd = "curl -s 'http://whois.pconline.com.cn/ipJson.jsp?json=true'|iconv -fgb2312 -tutf8"
    awful.spawn.easy_async_with_shell(
        cmd,
        function(stdout, stderr, exitreason, exitcode)
            if trim(stdout):find("^{") ~= nil then
                local location = json:decode(trim(stdout))
                if location then
                    options.city = location.city
                    options.cityCode = location.cityCode
                end
            end
        end
    )
end
local function get_weather()
	local cmd = string.format(
        "curl --connect-timeout 1  --max-time 1 --retry-max-time 1 -s 'https://restapi.amap.com/v3/weather/weatherInfo?key=c67d588d9bad9475f33cf5427e87bdd0&city=%s&extensions=all' 2>/dev/null && curl --connect-timeout 1  --max-time 1 --retry-max-time 1 -s 'https://map.baidu.com/?qt=cur&wd=%s' 1>&2",
        options.cityCode,
        options.city
    )

    awful.spawn.easy_async_with_shell(
        cmd,
        function(stdout, stderr, exitreason, exitcode)
            local weather = json:decode(
                escape_char(
                    trim(stdout)
                )
            )
            local aqi = json:decode(
                escape_char(
                    trim(stderr)
                )
            )            
            local aqi_color
            if aqi and aqi.aqi and aqi.aqi.current_city and aqi.aqi.current_city.aqi ~= nil then
                if tonumber(aqi.aqi.current_city.aqi) <= 50 then
                    aqi_color = 'Lime'
                elseif tonumber(aqi.aqi.current_city.aqi) >= 51 and tonumber(aqi.aqi.current_city.aqi)	<= 100 then
                    aqi_color = 'ForestGreen'
                elseif tonumber(aqi.aqi.current_city.aqi) >= 101 and tonumber(aqi.aqi.current_city.aqi)	<= 150 then
                    aqi_color = 'Yellow'
                elseif tonumber(aqi.aqi.current_city.aqi) >= 151 and tonumber(aqi.aqi.current_city.aqi)	<= 200 then
                    aqi_color = 'DarkOrange'
                elseif tonumber(aqi.aqi.current_city.aqi) >= 201 then
                    aqi_color = 'Red'
                end
            else
                aqi_color = 'white'
            end
            if weather ~= nil and weather.status and aqi ~= nil and aqi.aqi then
                local rows = {
                    spacing = 5,
                    layout = wibox.layout.fixed.vertical,
                }
                if weather.status ~= nil then
                    for i, each_day in ipairs(weather.forecasts[1].casts) do
                        local row = wibox.widget {
                            {
                                markup = '<span color="SteelBlue">' .. each_day.date .. '</span>',
                                forced_width = 150,
                                widget = wibox.widget.textbox
                            },
                            {
                                markup = '<span color="Violet">'..each_day.dayweather..' '..each_day.nightweather..'</span>',
                                forced_width = 120,
                                widget = wibox.widget.textbox,
                                align = 'center'
                            },
                            {
                                {
                                    markup = '<span color="Gold">'..each_day.daytemp..' '..each_day.nighttemp..'</span>',
                                    forced_width = 100,
                                    widget = wibox.widget.textbox,
                                    align = 'center'
                                },
                                {
                                    {
                                        markup = '<span color="DeepSkyBlue">'..escape_char(each_day.daypower)..' '..escape_char(each_day.nightpower)..'</span>',
                                        forced_width = 100,
                                        widget = wibox.widget.textbox,
                                        align = 'center'
                                    },
                                    {
                                        markup = '<span color="Silver">'..each_day.daywind..' '..each_day.nightwind..'</span>',
                                        forced_width = 120,
                                        widget = wibox.widget.textbox,
                                        align = 'center'
                                    },
                                    layout = wibox.layout.align.horizontal
                                },
                                layout = wibox.layout.align.horizontal
                            },
                            layout = wibox.layout.align.horizontal
                        }
                        rows[i] = row
                    end
                    popup:setup {
                        {
                            rows,
                            layout = wibox.layout.fixed.vertical,
                        },
                        margins = 5,
                        widget = wibox.container.margin
                    }
                    local short_info = string.format(
                        "<span font_desc='%s' font_size='%spt'>"..
                            "<span color='SteelBlue'>%s</span>"..
                            "<span> </span>"..
                            "<span color='Violet'>%03s - %03s</span>"..
                            "<span> </span>"..
                            "<span color='DarkTurquoise'>%02s℃ %02s℃</span>"..
                            "<span> </span>"..
                            "<span color='%s'>%s</span>"..
                        "</span>",
                        options.theme.font,
                        options.font_size,
                        options.city,
                        weather.forecasts[1].casts[1].dayweather,
                        weather.forecasts[1].casts[1].nightweather,
                        weather.forecasts[1].casts[1].daytemp,
                        weather.forecasts[1].casts[1].nighttemp,
                        aqi_color,
                        aqi.aqi.current_city.aqi
                    )
                    widget:set_markup_silently(short_info)
                    options.weather_got = true
                end
            end
        end
    )
end

function initialize(args)
    options.font_size = args.font_size or 12
    options.theme = args.theme or require('beautiful').get()
    options.interval = args.interval or 5
    popup.border_width = options.theme.border_width_thin
    popup.border_color = options.theme.bg_focus
    widget:set_markup_silently(
        string.format(
            '<span font_desc="%s" font_size="small" >[%d] 天气获取中……</span>',
            options.theme.font,
            options.loop
        )
    )
    awful.widget.watch(
        'echo useless > /dev/null 2>&1',
        options.interval, -- execute every 10 minutes
        function(this_widget, stdout)
            if options.city == nil then
                guess_city()
            end
            if options.city ~= nil  then
                -- update every 15 minutes
                if not options.weather_got or math.fmod(options.loop * options.interval, 15 * 60) == 0 then
                    get_weather()
                    options.loop = 1
                end
                options.loop = options.loop + 1
            end
        end,
        widget
    )
    margin_wibox = wibox.container.margin(
        widget,
        dpi(5),
        dpi(5),
        dpi(5),
        dpi(5),
        nil
    )
    return margin_wibox
end

return {init = initialize}

