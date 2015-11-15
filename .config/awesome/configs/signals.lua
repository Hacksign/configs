local awful			= require("awful")
local beautiful = require("beautiful")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    --	focus window with mouse move, following mouse movement
    c:connect_signal("mouse::enter", function(c)
        if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
            and awful.client.focus.filter(c) then
            client.focus = c
        end
    end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
            awful.placement.centered(c, nil)
        end
    end

    local titlebars_enabled = false
    if titlebars_enabled and (c.type == "normal" or c.type == "dialog") then
        -- Widgets that are aligned to the left
        local left_layout = wibox.layout.fixed.horizontal()
        left_layout:add(awful.titlebar.widget.iconwidget(c))

        -- Widgets that are aligned to the right
        local right_layout = wibox.layout.fixed.horizontal()
        right_layout:add(awful.titlebar.widget.floatingbutton(c))
        right_layout:add(awful.titlebar.widget.maximizedbutton(c))
        right_layout:add(awful.titlebar.widget.stickybutton(c))
        right_layout:add(awful.titlebar.widget.ontopbutton(c))
        right_layout:add(awful.titlebar.widget.closebutton(c))

        -- The title goes in the middle
        local title = awful.titlebar.widget.titlewidget(c)
        title:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
            client.focus = c
            c:raise()
            awful.mouse.client.move(c)
        end),
        awful.button({ }, 3, function()
            client.focus = c
            c:raise()
            awful.mouse.client.resize(c)
        end)
        ))

        -- Now bring it all together
        local layout = wibox.layout.align.horizontal()
        layout:set_left(left_layout)
        layout:set_right(right_layout)
        layout:set_middle(title)

        awful.titlebar(c):set_widget(layout)
    end
end)

-- make maximized window no border
-- but except window in awful.rules.rules table
client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    local manage = true
    for i,v in pairs(awful.rules.rules) do
        if v.rule.class == c.class then
            manage = false
            break
        end
    end
    if manage == true then
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = "0"
        else
            c.border_width = beautiful.border_width
        end
    end
end)
client.connect_signal("unfocus", function(c)
    c.border_color = beautiful.border_normal
    local manage = true
    for i,v in pairs(awful.rules.rules) do
        if v.rule.class == c.class then
            manage = false
            break
        end
    end
    if manage == true then
        if c.maximized_horizontal == true and c.maximized_vertical == true then
            c.border_width = "0"
        else
            c.border_width = beautiful.border_width
        end
    end
end)
-- }}}
