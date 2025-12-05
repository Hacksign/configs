local awful			= require("awful")
local wibox			= require("wibox")
local beautiful 		= require("beautiful")
local naughty			= require("naughty")

local titlebars_enabled = false

function set_client_border(c)
    if c.type ~= 'desktop' and c.no_border ~= true then
        if c.maximized then
            c.border_width = 0
        else
            c.border_width = beautiful.border_width
        end
    end
    return c.border_width
end

function set_client_titlebar(c)
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
end

client.connect_signal("focus", function (c)
    c.border_color = beautiful.border_focus
    ---- move to current mouse screen if
    ----  focused client not in current mouse screen
    --if c.screen.index ~= mouse.screen.index then
    --    c:move_to_screen(mouse.screen.index)
    --end
end)
client.connect_signal("unfocus", function (c)
    c.border_color = beautiful.border_normal
end)

client.connect_signal("property::size", function (c, startup)
    set_client_border(c)
end)

client.connect_signal("manage", function (c)
    set_client_border(c)
    set_client_titlebar(c)
end)

