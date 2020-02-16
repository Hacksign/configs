local awful			= require("awful")
awful.rules			= require("awful.rules")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty		= require("naughty")
local utils = require("utils")

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
        rule = { class = "org.remmina.Remmina"  },
        properties = {
            callback = function(c)
                if c.fullscreen or c.maximized then
                    c.border_width = 0
                end
            end,
        }
    },
    { 
        rule = { name = "plank"  },
        properties = {
            no_border = true,
            border_width = 0,
            floating = true,
        }
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
            type = "desktop",
            callback = function(c)
                client_geometry = c:geometry()
                client_geometry.x = 0
                client_geometry.y = c.screen.workarea.y
                client_geometry.width = c.screen.workarea.width
                client_geometry.height = c.screen.workarea.height
                c:geometry(client_geometry)
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
