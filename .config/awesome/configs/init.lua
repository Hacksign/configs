local gears			= require("gears")
local awful			= require("awful")
local wibox			= require("wibox")
local widgets		= require("widgets")
local beautiful     = require("beautiful")
local naughty       = require("naughty")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local mytaglist = {}
local mylayoutbox = {}
local mytasklist = {}

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
        gears.wallpaper.fit(beautiful.wallpaper, s, beautiful.bg_normal)
    end
end
for s in screen do
    awful.tag(
        {"Work"},
        s,
        awful.layout.suit.floating
    )
end

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



for s = 1, screen.count() do
    if screen[s] == screen.primary then
        -- We need one layoutbox per screen.
        mylayoutbox[s] = awful.widget.layoutbox(s)
        -- Create a taglist widget
        mytaglist[s] = awful.widget.taglist(
            s,
            awful.widget.taglist.filter.all,
            mytaglist.buttons
        )
        -- Create the wibox
        local topBar = {}
        topBar[s] = awful.wibar(
            {
                position = "top",
                screen = s,
                type = "desktop"
            }
        )

        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(mytaglist[s])

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()

        -- Now bring it all together (with the tasklist in the middle)
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        topBar[s]:set_widget(layout)

        gears.timer(
            {
                timeout = 0,
                autostart = true,
                single_shot = true,
                callback = function()
                    -- top & battom bar widgets
                    local cpuwidget = widgets.cpu(
                        {
                            width = 175,
                            interval = 3,
                            step_width = 2,
                            step_spacing = 1,
                            theme = beautiful,
                        }
                    )
                    local memwidget = widgets.memory
                    local batterywidget = widgets.battery
                    local networkwidget = widgets.network
                    local temperaturewidget = widgets.temperature
                    local weatherwidget = widgets.weather.init(
                        {
                            interval = 5,
                            theme = beautiful 
                        }
                    )
                    widgets.screenful.init()

                    left_layout:add(weatherwidget)

                    right_layout.spacing = dpi(2) 
                    right_layout:add(networkwidget)
                    right_layout:add(temperaturewidget)
                    if batterywidget then
                        right_layout:add(batterywidget)
                    end
                    right_layout:add(memwidget)
                    right_layout:add(cpuwidget)
                    if s == 1 then
                        right_layout:add(wibox.widget.systray())
                    end
                    right_layout:add(mylayoutbox[s])
                end
            }
        )

        -- setup desktop icons
        widgets.freedesktop.desktop.add_icons(
            {
                screen = screen[s],
                open_with = 'thunar',
                wait_for  = 'plank',
                margin = {x = dpi(10), y = (10)},
                labelsize = {width = dpi(100), height = dpi(20)},
                iconsize = {width = dpi(30), height = dpi(30)},
            }
        )
    end
end

