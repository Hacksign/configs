local awful			= require("awful")
awful.rules			= require("awful.rules")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local naughty		= require("naughty")

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, function(c)
        awful.mouse.client.move(c)
        c:raise()
    end),
    awful.button({ modkey }, 3, awful.mouse.client.resize)
)
awful.rules.rules = {
    -- All clients will match this rule.
    { 
        rule = { },
        properties = {
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            screen = function(c)
                local current_screen = awesome.startup and c.screen or awful.screen.focused()
                local client_geometry = c:geometry()
                -- 防止client在当前屏幕之外
                if client_geometry.x > current_screen.geometry.x + current_screen.geometry.width
                    or client_geometry.x + client_geometry.width < current_screen.geometry.x
                then
                    client_geometry.x = (current_screen.geometry.x + current_screen.geometry.width) / 2 - client_geometry.width / 2
                end
                if client_geometry.y > current_screen.geometry.y + current_screen.geometry.height
                    or client_geometry.y + client_geometry.height < current_screen.geometry.y
                then
                    client_geometry.y = current_screen.geometry.y
                end
                c:geometry(client_geometry)
                return current_screen
            end,
            keys = clientkeys,
            buttons = clientbuttons 
        } ,
    },
    { 
        rule = { class = "Xfdesktop"  },
        except = {class = "Xfdesktop-settings"},
        properties = {
            border_width = 0,
            maximized = true,
            sticky = true,
            focusable = false,
            floating = false,
            screen = function(c)
                -- xfdesktop has some problem when there has more
                --  then one screen, and each screen has different
                --  resolution
                -- make xfdesktop on screen
                --  which has smaller resolution
                local index = 1
                for i = 1, screen:count(), 1 do
                    if screen[i].geometry.width < screen[index].geometry.width then
                        index = i
                    end
                end
                return screen[index]
            end,
        }
    },
    {
    	rule = { class = "Popup" },
    	properties = { border_width = 0, no_border = true },
    },
    {
    	rule = { class = "Wine" },
    	properties = { floating = true, border_width = 0, no_border = true },
    },
    {
    	rule = { class = "deepin-voice-recorder" },
    	properties = { border_width = 0, no_border = true },
    },
}
