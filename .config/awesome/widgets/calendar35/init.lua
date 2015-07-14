--
-- Calendar module for Awesome 3.5 WM
-- 
-- Based on: https://github.com/cdump/awesome-calendar 
-- Modified by: Hacksign <evilsign_at_gmail.com>
--
-- Add to rc.lua:
-- local calendar = require("calendar35")
-- ..
-- calendar.addCalendarToWidget(widget_datetime[,position[,day format]])
-- position: "top_left"/"top_right"/"bottom_left"/"bottom_right
--	default position is "top_right"
--

local string = string
local tostring = tostring
local os = os
local capi = {
    mouse = mouse,
    screen = screen
}
local awful = require("awful")
local naughty = require("naughty")
module("calendar35")

local calendar = {}
local calendar_position = "top_right"
local current_day_format = '<span color="#ee7777"><b>%02d</b></span>'

function translate(transString)
	if transString ~= nil then
		--month
		transString = string.gsub(transString, "January", "一月")
		transString = string.gsub(transString, "February", "二月")
		transString = string.gsub(transString, "March", "三月")
		transString = string.gsub(transString, "April", "四月")
		transString = string.gsub(transString, "May", "五月")
		transString = string.gsub(transString, "June", "六月")
		transString = string.gsub(transString, "July", "七月")
		transString = string.gsub(transString, "August", "八月")
		transString = string.gsub(transString, "September", "九月")
		transString = string.gsub(transString, "October", "十月")
		transString = string.gsub(transString, "November", "十一月")
		transString = string.gsub(transString, "December", "十二月")

		--weakname
		transString = string.gsub(transString, "Mon", " 1 ")
		transString = string.gsub(transString, "Tue", " 2 ")
		transString = string.gsub(transString, "Wed", " 3 ")
		transString = string.gsub(transString, "Thu", " 4 ")
		transString = string.gsub(transString, "Fri", " 5 ")
		transString = string.gsub(transString, "Sat", " 6 ")
		transString = string.gsub(transString, "Sun", " 7 ")
	end
	return transString
end

function displayMonth(month,year,weekStart)
    local t,wkSt=os.time{year=year, month=month+1, day=0},weekStart or 1
    local d=os.date("*t",t)
    local mthDays,stDay=d.day,(d.wday-d.day-wkSt+1)%7

    local lines = " "

    for x=0,6 do
        lines = lines .. os.date("<b>%a</b>",os.time{year=2006,month=1,day=x+wkSt-1})
    end

    lines = lines .. "\n"

    local writeLine = 1
    while writeLine <= (stDay + 1) do
        lines = lines .. "   "
        writeLine = writeLine + 1
    end

    for d=1,mthDays do
        local x = d
        local t = os.time{year=year,month=month,day=d}
        if writeLine == 8 then
            writeLine = 1
            lines = lines .. "\n"
        end
        if os.date("%Y-%m-%d") == os.date("%Y-%m-%d", t) then
            x = string.format(current_day_format, d)
				else
						x = string.format("%02d", d)
        end
				x = " " .. x
        lines = lines .. x
        writeLine = writeLine + 1
    end
    local header = "<b><i>" .. os.date("%B, %Y", os.time{year=year,month=month,day=1}) .. "</i></b>\n"
		header = translate(header)
		lines = translate(lines)

    return header .. "\n" .. lines
end

function switchNaughtyMonth(switchMonths)
    if (#calendar < 3) then return end
    local swMonths = switchMonths or 1
    calendar[1] = calendar[1] + swMonths

    calendar_new = { calendar[1], calendar[2],
    naughty.notify({
        text = string.format('<span font_desc="%s">%s</span>', "Terminal", displayMonth(calendar[1], calendar[2], 2)),
        timeout = 0,
				position = calendar_position,
        hover_timeout = 0.5,
        screen = capi.mouse.screen,
        replaces_id = calendar[3].id
    })}
    calendar = calendar_new
end

function switchNaughtyGoToToday()
    if (#calendar < 3) then return end
    local swMonths = switchMonths or 1
    calendar[1] = os.date("*t").month
    calendar[2] = os.date("*t").year
    switchNaughtyMonth(0)
end

function addCalendarToWidget(mywidget, myposition, custom_current_day_format)
    if custom_current_day_format then current_day_format = custom_current_day_format end
    if myposition == nil then myposition = 'top_right' end
		calendar_position = myposition

    mywidget:connect_signal('mouse::enter', function ()
			local month, year = os.date('%m'), os.date('%Y')
			calendar = { month, year,
				naughty.notify({
						text = string.format('<span font_desc="%s">%s</span>', "Terminal", displayMonth(month, year, 2)),
						timeout = 0,
						position = calendar_position,
						hover_timeout = 0.5,
						screen = capi.mouse.screen
				})
			}
		end)
	mywidget:connect_signal('mouse::leave', function () naughty.destroy(calendar[3]) end)

	mywidget:buttons(awful.util.table.join(
	awful.button({ }, 1, function()
			switchNaughtyMonth(-1)
	end),
	awful.button({ }, 2, switchNaughtyGoToToday),
	awful.button({ }, 3, function()
			switchNaughtyMonth(1)
	end),
	awful.button({ }, 4, function()
			switchNaughtyMonth(-1)
	end),
	awful.button({ }, 5, function()
			switchNaughtyMonth(1)
	end),
	awful.button({ 'Shift' }, 1, function()
			switchNaughtyMonth(-12)
	end),
	awful.button({ 'Shift' }, 3, function()
			switchNaughtyMonth(12)
	end),
	awful.button({ 'Shift' }, 4, function()
			switchNaughtyMonth(-12)
	end),
	awful.button({ 'Shift' }, 5, function()
			switchNaughtyMonth(12)
	end)
	))
end

return {init = addCalendarToWidget}
