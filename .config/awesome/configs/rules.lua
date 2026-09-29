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
        except_any = {
            class = { "Xfce4-notifyd", "Plank" }
        },
        properties = {
            screen = awful.screen.focused,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            keys = clientkeys,
            buttons = clientbuttons,
            placement = awful.placement.no_offscreen + awful.placement.centered
        },
    },
    {
    	rule = { class = "Popup" },
    	properties = { border_width = 0, no_border = true },
    },
    {
        rule = { class = "GoldenDict-ng"  },
        properties = { placement = awful.placement.no_offscreen }
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
        rule = { class = "Xfce4-notifyd"  },
        properties = {
            no_border = true,
            border_width = 0,
        }
    },
    {
        rule = { class = "Cairo-dock"  },
        properties = {
            no_border = true,
            border_width = 0,
            minimized = false,
            dockable = false,
            ontop = false, -- set default value
            above = false, -- set default value
            below = true, -- set default value
        }
    },
    {
        rule_any = { class = {"plank", "Plank"}, instance = {"plank"} },
        except = { name = "Plank Clock Calendar" },
        properties = {
            no_border = true,
            border_width = 0,
            minimized = false,
            dockable = false,
            ontop = false, -- set default value
            above = false, -- set default value
            below = true, -- set default value
            height = 70,
            callback = function(c)
                c:connect_signal('focus', function(tc)
                    tc.ontop = true
                    tc.below = false
                    tc.above = true
                    tc.border_width = 0
                    tc.no_border = true
                end)
                c:connect_signal('unfocus', function(tc)
                    tc.ontop = false
                    tc.below = true
                    tc.above = false
                    tc.border_width = 0
                    tc.no_border = true
                end)
                c:connect_signal('property::minimized', function(tc) 
                    -- this client can not minized
                    tc.minimized = false
                end)
                --c:connect_signal('property::struts', function(tc)
                --    local struts = tc:struts()
                --    local geometry = tc:geometry()

                --    geometry.height = math.max(geometry.height, 45)
                --    tc:geometry(geometry)
                --    if struts.bottom ~= 0 then
                --        tc:struts({ left = 0, right = 0, top = 0, bottom = 0  })
                --    end
                --end)
            end,
        }
    },
    {
    	rule = { class = "deepin-voice-recorder" },
    	properties = { border_width = 0, no_border = true },
    },
    -- fix problem of Wine program move slowly to right-bottom of the corner
    -- http://www.youtube.com/watch?v=3Q91HjEaBD8
    -- https://awesome.naquadah.org/bugs/index.php?do=details&task_id=1030
    -- {
    --     rule_any = { class = "Wine" },
    --     properties = {
    --         focus = true,
    --         raise = true,
    --         screen = awful.screen.focused,
    --         placement = awful.placement.no_overlap + awful.placement.no_offscreen,
    --         -- 关键：避免平铺布局干扰
    --         floating = true,  -- 强制 Wine 窗口浮动
    --         border_width = 1
    --     },
    -- },
}
