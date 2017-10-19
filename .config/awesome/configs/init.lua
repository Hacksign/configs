local gears			= require("gears")
local awful			= require("awful")
local wibox			= require("wibox")
local widgets		= require("widgets")
local beautiful     = require("beautiful")
local utils         = require("utils")

local mytaglist = {}
-- Mouse Click event
mytaglist.buttons = awful.util.table.join(
    awful.button({ }, 1, awful.tag.viewonly),
    awful.button({ }, 3, awful.tag.viewtoggle)
)
-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
editor = os.getenv("EDITOR") or "vim"
modkey = "Mod4"
-- }}}

beautiful.init(os.getenv("HOME") .. "/.config/awesome/themes/arch/theme.lua")
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.fit(beautiful.wallpaper, s, theme.bg_normal)
    end
end
for s in screen do
    awful.tag({"Work"}, s, awful.layout.suit.floating)
end

-- {{{ Wibox
-- Create a textclock widget
local mytextclock = wibox.widget.textclock("<span color='green' font_desc='"..beautiful.font.."'>%F %H:%M</span>")
local calendar = widgets.calendar.init(mytextclock, "bottom_right")

-- Create a wibox for each screen and add it
mypromptbox = {}
mylayoutbox = {}
mytasklist = {}
-- mouse click event handler
mytasklist.buttons = awful.util.table.join(
    awful.button({ }, 1, function (c)
        if c == client.focus then
            c.minimized = true
        else
            -- Without this, the following
            -- :isvisible() makes no sense
            c.minimized = false
            if not c:isvisible() then
                awful.tag.viewonly(c:tags()[1])
            end
            -- This will also un-minimize
            -- the client, if needed
            client.focus = c
            c:raise()
        end
    end)
)
-- mouse event handler end																					

-- top & battom bar widgets
local cpuwidget = widgets.cpu
local memwidget = widgets.memory
local batterywidget = widgets.battery
local networkwidget = widgets.network
local temperaturewidget = widgets.temperature
local weatherwidget = widgets.weather.init(nil, 'top_left')

--	now deal ervery screen
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    -- font = Terminal
    -- size = large
    -- focus window fg color = yellow
    -- focus background color = black
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons, nil, utils.tasklist_update_function)

    -- Create the wibox
    local mywibox = {}
    local bottomwibox = {}
    mywibox[s] = awful.wibar({ position = "top", screen = s })
    bottomwibox[s] = awful.wibar({position = "bottom", screen = s})


    local blankwidget = wibox.widget.textbox()
    blankwidget:set_markup(" ")

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
    left_layout:add(blankwidget)

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    right_layout:add(networkwidget)
    right_layout:add(blankwidget)
    right_layout:add(temperaturewidget)
    right_layout:add(blankwidget)
    if batterywidget then
        right_layout:add(batterywidget)
        right_layout:add(blankwidget)
    end
    right_layout:add(memwidget)
    right_layout:add(blankwidget)
    right_layout:add(cpuwidget)
    if s == 1 then
        right_layout:add(wibox.widget.systray())
    end
    right_layout:add(mylayoutbox[s])

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(weatherwidget)
    layout:set_right(right_layout)
    local bottom_layout = wibox.layout.align.horizontal()
    bottom_layout:set_left(left_layout)
    bottom_layout:set_middle(mytasklist[s])
    bottom_layout:set_right(mytextclock)

    mywibox[s]:set_widget(layout)
    bottomwibox[s]:set_widget(bottom_layout)
end
-- }}}
