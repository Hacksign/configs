local awful			= require("awful")
local naughty		= require("naughty")
local widgets		= require("widgets")
local beautiful = require("beautiful")
local is_floats = require("utils/is-floats")
local proportion_resize = require("utils/proportion-resize")
local last_focused_client = nil
local layouts = {
    awful.layout.suit.floating,
    awful.layout.suit.tile,
    awful.layout.suit.tile.left,
    awful.layout.suit.tile.bottom,
    awful.layout.suit.tile.top,
    awful.layout.suit.fair,
    awful.layout.suit.fair.horizontal,
    awful.layout.suit.spiral,
    awful.layout.suit.spiral.dwindle,
    awful.layout.suit.max,
    awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
}
local menu = widgets.freedesktop.menu.build()

-- helper function to detect a client is floated and current mode is float
function bind_move_client2tag(globalkeys)
    for i = 1, 9 do
        globalkeys = awful.util.table.join(globalkeys,
            -- move to tag
            awful.key({ modkey  }, "#" .. i + 9, function ()
                if i <= #awful.screen.focused().tags then
                    awful.screen.focused().tags[i]:view_only()
                end
            end),
            -- move current active window to specific tag
            awful.key({ modkey, "Control"  }, "#" .. i + 9, function ()
                if client.focus and awful.screen.focused().tags[i] then
                    client.focus:move_to_tag(awful.screen.focused().tags[i])
                end
            end)
        )
    end
    root.keys(globalkeys)
end

-- {{{ Key bindings
globalkeys = awful.util.table.join(
    -- window navigation
    -- Toggle show desktop (for current tag(s))
    awful.key({ modkey,           }, "d",
    function ()
        local allminimized
        local c
        local clients
        clients = client.get(mouse.screen)
        for y, c in pairs(clients) do
            if c.type ~= "desktop" and c.type ~= "dock" then
                if c.minimized == false then
                    allminimized = false
                    break
                else
                    allminimized = true
                end
            end
        end

        if client.focus and client.focus.type ~= "desktop" and client.type ~= "dock" then
            last_focused_client = client.focus
        end

        -- If at least one client isn't minimized, minimize all clients
        for y, c in pairs(clients) do
            -- ignore desktop window such as:xfdesktop
            if c.type ~= "desktop" and c.type ~= "dock" then
                if allminimized == false then
                    c.minimized = true 
                elseif allminimized == true then
                    c.minimized = false 
                end
            end
        end
        if allminimized and last_focused_client then
            client.focus = last_focused_client
            last_focused_client:raise()
            last_focused_client = nil
        end
    end),
    -- add new tag
    awful.key({ modkey,         }, "t",      function ()
        local current_tag = mouse.screen.selected_tag
        local all_tags = awful.screen.focused().tags
        local tag_num = #all_tags + 1
        tagobj = awful.tag.add(tag_num, {layout = awful.layout.suit.tile})
        awful.tag.setscreen(mouse.screen, tagobj)
        bind_move_client2tag(globalkeys)
    end),
    -- remove current tag, NOTE: current tag must contains NO clients
    awful.key({ modkey,          }, "x",      function ()
        -- we can not remove last tag
        if #awful.tag.gettags(mouse.screen) ~= 1 then
            local current_tag = mouse.screen.selected_tag
            if awful.tag.delete(current_tag) == nil then
                naughty.notify({
                    text = "当前工作区不为空!",
                    timeout = 1,
                    position = "top_left",
                    screen = mouse.screen
                })
            else
                local all_tags = awful.tag.gettags(mouse.screen)
                for s = 1, #all_tags do
                    if tonumber(all_tags[s].name) then
                        all_tags[s].name = s
                    end
                end
                bind_move_client2tag(globalkeys)
            end
        else
            naughty.notify({
                text = "不能移除最后一个工作区!",
                timeout = 1,
                position = "top_left",
                screen = mouse.screen
            })
        end
    end),
    awful.key({ modkey,         }, "-",    function ()
        local cg = client.focus:geometry()
        if cg['width'] > (client.focus.screen.geometry.width*30/100) and cg['height'] > (client.focus.screen.geometry.height*30/100) then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] - delta
            cg['height'] = cg['height'] - delta_height
            client.focus:geometry(cg)
            awful.placement.centered(client.focus, nil)
        end
    end),
    awful.key({ modkey,         }, "=",    function ()
        local cg = client.focus:geometry()
        if (cg['width']+20) < client.focus.screen.geometry.width and (cg['height']+20) < client.focus.screen.geometry.height then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] + delta
            cg['height'] = cg['height'] + delta_height
            client.focus:geometry(cg)
            awful.placement.centered(client.focus, nil)
        end
    end),
    ------------------------------------------------------------------------------
    awful.key({modkey,						}, "c", function()
        if is_floats(client.focus) and client.focus.type ~= 'desktop' and client.type ~= "dock" then
            local cg = client.focus.screen.workarea
            if client.focus.maximized then
                -- if not horizontal or window ether with or height is smaller
                -- than centered size
                -- or window is outside of current screen
                cg.width = cg.width - beautiful.margin_horizontal
                cg.height = cg.height - beautiful.margin_vertical
                cg.x = cg.x + math.floor(beautiful.margin_horizontal/2)
                cg.y = cg.y + math.floor(beautiful.margin_vertical/2)
                client.focus.maximized = false
                client.focus.maximized_horizontal = false
                client.focus.maximized_vertical = false
                client.focus:geometry(cg)
            else
                -- local manage = true
                -- for i,v in pairs(awful.rules.rules) do
                --     if v.rule.class == client.focus.class then
                --         manage = false
                --         break
                --     end
                -- end
                -- if manage then
                    client.focus.border_width = 0
                    cg.x = cg.x
                    cg.y = cg.y
                    cg.width = cg.width
                    cg.height = cg.height
                    client.focus.maximized = true
                    client.focus.maximized_horizontal = true
                    client.focus.maximized_vertical = true
                    client.focus:geometry(cg)
                -- end
            end
        end
    end),
    awful.key({ modkey, "Control"}, "c",   function()
        local cg = client.focus.screen.workarea
        cg['width'] = cg['width']/2 - client.focus.border_width * 2
        cg['height'] = cg['height'] - client.focus.border_width * 2
        cg['x'] = cg['x'] + cg['width'] / 2 + client.focus.border_width
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = true
        client.focus:geometry(cg)
    end),
    awful.key({ modkey,           }, "Left",   function()
        local cg = client.focus.screen.workarea
        cg['width'] = cg['width']/2 - client.focus.border_width * 2
        cg['height'] = cg['height'] - client.focus.border_width * 2
        cg['x'] = cg['x']
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = true
        client.focus:geometry(cg)
    end),
    awful.key({ modkey, "Shift"   }, "Left",   function()
        client.focus:relative_move(0, 0, -20, 0)
    end),
    awful.key({ modkey, "Shift", "Control"}, "Left",   function()
        client.focus:relative_move(-20, 0, 20, 0)
    end),
    awful.key({ modkey, "Control" }, "Left",   function()
        local cg = client.focus.screen.geometry
        cg['width'] = cg['width']/2 - client.focus.border_width * 2
        cg['height'] = cg['height'] - client.focus.border_width * 2
        cg['x'] = cg['x']
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = true
        client.focus:geometry(cg)
    end),
    awful.key({ modkey,           }, "Right",  function()
        local cg = client.focus.screen.workarea
        cg['width'] = cg['width']/2 - client.focus.border_width * 2
        cg['height'] = cg['height'] - client.focus.border_width * 2
        cg['x'] = cg['x'] + cg['width'] + client.focus.border_width * 2
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = true
        client.focus:geometry(cg)
    end),
    awful.key({ modkey, "Shift"   }, "Right",  function()
        client.focus:relative_move(20, 0, -20, 0)
    end),
    awful.key({ modkey, "Shift", "Control"}, "Right",  function()
        client.focus:relative_move(0, 0, 20, 0)
    end),
    awful.key({ modkey, "Control" }, "Right",  function()
        local cg = client.focus.screen.geometry
        cg['width'] = cg['width']/2 - client.focus.border_width * 2
        cg['height'] = cg['height'] - client.focus.border_width * 2
        cg['x'] = cg['x'] + cg['width'] + client.focus.border_width * 2
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = false
        client.focus.maximized_vertical = true
        client.focus:geometry(cg)
    end),
    awful.key({ modkey,           }, "Up",  function()
        local cg = client.focus.screen.workarea
        cg['width'] = cg['width'] - client.focus.border_width * 2
        cg['height'] = cg['height']/2 - client.focus.border_width * 2
        cg['x'] = cg['x']
        cg['y'] = cg['y']
        client.focus.maximized = false
        client.focus.maximized_horizontal = true
        client.focus.maximized_vertical = false
        client.focus:geometry(cg)
    end),
    awful.key({ modkey, "Shift"   }, "Up",  function()
        client.focus:relative_move(0, 0, 0, -20)
    end),
    awful.key({ modkey, "Shift", "Control"}, "Up",  function()
        client.focus:relative_move(0, -20, 0, 20)
    end),
    awful.key({ modkey,           }, "Down",  function()
        local cg = client.focus.screen.workarea
        cg['width'] = cg['width'] - client.focus.border_width * 2
        cg['height'] = cg['height']/2 - client.focus.border_width * 2
        cg['x'] = cg['x']
        cg['y'] = cg['y'] + cg['height'] + client.focus.border_width * 2
        client.focus.maximized = false
        client.focus.maximized_horizontal = true
        client.focus.maximized_vertical = false
        client.focus:geometry(cg)
    end),
    awful.key({ modkey, "Shift", "Control"}, "Down",  function()
        client.focus:relative_move(0, 0, 0, 20)
    end),
    awful.key({ modkey, "Shift"   }, "Down",  function()
        client.focus:relative_move(0, 20, 0, -20)
    end),
    ------------------------------------------------------------------------------
    awful.key({ modkey,           }, "Tab", function ()
        awful.client.focus.byidx(1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ modkey, "Shift"   }, "Tab", function ()
        awful.client.focus.byidx(-1)
        if client.focus then client.focus:raise() end
    end),
    awful.key({ "Mod1",           }, "Tab", function ()
        widgets.alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")
    end),                                                                                           
    awful.key({ "Mod1", "Shift"   }, "Tab", function ()
        widgets.alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")
    end),
    -- navigate mouse cursor between screens
    awful.key({ modkey, }, "l", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, }, "h", function () awful.screen.focus_relative(-1) end),
    -- Standard program
    awful.key({ modkey,           }, "Return", function (c)
        local cg = screen[mouse.screen].workarea
        local xoff = cg.x + math.floor(beautiful.margin_horizontal/2)
        local yoff = cg.y + math.floor(beautiful.margin_vertical/2)
        local width = cg.width - beautiful.margin_horizontal
        local height = cg.height - beautiful.margin_vertical
        -- for workarea of terminator see 'man 7 X' document
        local terminal = "terminator --geometry="..width.."x"..height.."+"..math.floor(xoff).."+"..math.floor(yoff)
        awful.spawn(terminal) 
    end),
    -- change layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -2) end),
    -- restart & quit awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control"   }, "q", awesome.quit),
    -- User Defined Hot Key
    awful.key({ modkey}, "e", function () awful.spawn("thunar") end),
    awful.key({ "Mod1", "Control"}, "x", function () awful.spawn("deepin-screen-recorder") end),
    awful.key({ modkey,           }, "s",      function (c) awful.spawn("fsearch") end),
    awful.key({ modkey}, "i", function () awful.spawn("firefox") end), -- yaourt -S firefox
    awful.key({ }, "XF86Calculator", function () awful.spawn("qalculate-gtk") end),
    awful.key({ modkey}, "y", function () awful.spawn("qalculate-gtk") end), -- an GUI caculate
    awful.key({ modkey}, "p", function () awful.spawn("arandr") end), -- multi monitor selector like windows hotkey, yaourt -S lxrandr
    awful.key({ modkey}, "q", function () menu:toggle() end),
    awful.key({ "Mod1", "Control"}, "space", function ()
        local geometry = screen[mouse.screen].geometry
        local cmd = "gmrun -g +" .. math.floor(geometry.x + geometry.width/2 - (beautiful.border_width + 500/2)) .. "+" .. math.floor(geometry.y  + geometry.height/2 - (beautiful.border_width + 76/2))
        awful.spawn(cmd)
    end),
    awful.key({ modkey}, "n", function () awful.spawn("gvim") end), -- start a notepad
    awful.key({ modkey, "Control"}, "l", function () awful.spawn.with_shell("dm-tool lock &") end) -- yaourt -S lightdm lightdm-gtk-greeter
)
--end of globalkeys

-- client window hotkeys
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "z",
        function (c)
            if c.type ~= "desktop" and c.type ~= "dock" then
                c:kill()
            end
        end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "t",      function (c) c.ontop = not c.ontop            end),
    -- move window to next/pre screen
    awful.key({ modkey,           }, ",",      function(c)
        if c.type ~= "desktop" and c.type ~= "dock" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index - 1 > 0 then
                awful.client.movetoscreen(c,c.screen.index-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = c.screen.geometry
            proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ",",      function(c)
        if c.type ~= "desktop" and c.type ~= "dock" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index - 1 > 0 then
                awful.client.movetoscreen(c,c.screen.index-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = c.screen.geometry
            proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end),
    awful.key({ modkey,           }, ".",      function(c)
        if c.type ~= "desktop" and c.type ~= "dock" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen.index+1)
            end
            local new_sg = c.screen.geometry
            proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ".",      function(c)
        if c.type ~= "desktop" and c.type ~= "dock" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = c.screen.geometry
            if c.screen.index + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen.index+1)
            end
            local new_sg = c.screen.geometry
            proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end),
    awful.key({ modkey,         }, "m",    function (c)
        c.minimized = true
    end)
)
--end of clientkeys

root.keys(globalkeys)
