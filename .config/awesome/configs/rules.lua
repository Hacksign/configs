local awful			= require("awful")
awful.rules			= require("awful.rules")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local naughty		= require("naughty")
local serialize = require('utils/serialize')

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
        rule = { class = "smplayer"  },
        properties = {
            callback = function(c)
                c:connect_signal(
                    'property::size',
                    function(tc) 
                        if tc.fullscreen then
                            tc.no_border = true
                            tc.border_width = 0
                        else
                            tc.no_border = false
                            tc.border_width = beautiful.border_width
                            tc.border_color = beautiful.border_normal
                        end
                    end
                )
            end,
        }
    },
    {
        rule = { class = "org.remmina.Remmina"  },
        properties = {
            callback = function(c)
                c:connect_signal(
                    'property::size',
                    function(tc) 
                        if tc.fullscreen then
                            tc.no_border = true
                            tc.border_width = 0
                        else
                            tc.no_border = false
                            tc.border_width = beautiful.border_width
                            tc.border_color = beautiful.border_normal
                        end
                    end
                )
            end,
        }
    },
    {
        rule = { class = "Synergy"  },
        properties = {
            size_hints_honor = false,
            maximized_vertical  = true,
        }
    },
    {
        rule = { class = "sourceinsight4.exe"  },
        properties = {
            screen = screen.primary,
        }
    },
    {
        rule = { class = "Xfdesktop"  },
        properties = {
            no_border = true,
            border_width = 0,
            x = screen.primary.geometry.x,
            y = screen.primary.geometry.y,
        }
    },
    {
        rule = { class = "Plank"  },
        except = { name = "Plank Clock Calendar" },
        properties = {
            no_border = true,
            border_width = 0,
            minimized = false,
            dockable = false,
            ontop = false, -- set default value
            above = false, -- set default value
            below = true, -- set default value
            callback = function(c)
                c:connect_signal('focus', function(tc)
                    tc.ontop = true
                    tc.below = false
                    tc.above = true
                end)
                c:connect_signal('unfocus', function(tc)
                    tc.ontop = false
                    tc.below = true
                    tc.above = false
                end)
                c:connect_signal('property::minimized', function(tc) 
                    -- this client can not minized
                    tc.minimized = false
                end)
            end,
        }
    },
    { 
        rule = { class = "Pcmanfm"  },
        except = {class = ""},
        properties = {
            border_width = 0,
            maximized = true,
            sticky = true,
            focusable = false,
            floating = false,
            type = "desktop",
            screen = screen.primary,
        }
    },
    {
    	rule = { class = "Popup" },
    	properties = { border_width = 0, no_border = true },
    },
    {
    	rule = { class = "deepin-voice-recorder" },
    	properties = { border_width = 0, no_border = true },
    },
}
