local awful			= require("awful")
awful.rules			= require("awful.rules")
local beautiful = require("beautiful")
local utils         = require("utils")

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
        properties = { border_width = beautiful.border_width,
        border_color = beautiful.border_normal,
        focus = awful.client.focus.filter,
        screen = function(c) return awesome.startup and c.screen or awful.screen.focused() end,
        keys = clientkeys,
        buttons = clientbuttons } ,
        callback = function (c)
            local screengeom = screen[c.screen].geometry
            local cg = c:geometry()
            -- when a window is not maximized and
            -- it width or height beyonded screen border
            -- then center it to screen center
            if not (c.maximized_horizontal and c.maximized_vertical) and
               ( (cg['x'] + cg['width']) > (screengeom['x'] + screengeom['width']) or
               (cg['y'] + cg['height']) > (screengeom['y'] + screengeom['height']) or
               (cg['x']) < screengeom['x'] or
               (cg['y']) < screengeom['y'])
           then
               utils.center_window(c)
           end
        end
    },
    { 
        rule = { class = "MPlayer" },
        properties = { floating = true } 
    },
    { 
        rule = { class = "smplayer" },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },
    { 
        rule = { class = "Insight3.exe" },
        properties = { floating = true, focus = true },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },
    { 
        rule = { class = "Launchy" },
        properties = { border_width = 0, floating = true },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },
    { 
        rule = { class = "Synapse" },
        properties = { border_width = 0, floating = true },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },
    --{ 
    --	rule = { class = "Terminator" },
    --  properties = { border_width = 1, floating = true } 
    --},
    { 
        rule = { class = "pinentry" },
        properties = { floating = true } 
    },
    { 
        rule = { class = "Xfdesktop" },
        except = {class = "Xfdesktop-settings"},
        properties = { border_width = 0, maximized = true, sticky = true, focusable = false } 
    },
    { 
        rule = { class = "Bcloud-gui" },
        properties = { border_width = 0, floating = true } 
    },
    { 
        rule = { class = "gimp" },
        properties = { floating = true } 
    },
    { 
        rule = { class = "File-roller" },
        properties = { floating = true, border_width = 0 } 
    },
    { 
        rule = { class = "evince" },
        callback = function (c)
            awful.placement.centered(c,nil)
        end
    },
    -- fix problem of Wine program move slowly to right-bottom of the corner
    -- http://www.youtube.com/watch?v=3Q91HjEaBD8
    -- https://awesome.naquadah.org/bugs/index.php?do=details&task_id=1030
    {
        rule = { class = "Wine" },
        properties = { floating = true, border_width = 0 },
    },
    --Set Firefox to always map on tags number 2 of screen 1.
    --{
    --  rule = { class = "Firefox" },
    --  properties = { tag = tags[1][2] } 
    --},
}
