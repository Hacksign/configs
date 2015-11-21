local awful			= require("awful")
local naughty		= require("naughty")
local utils         = require("utils")
local widgets		= require("widgets")

local alttab = widgets.alttab
local last_focused_client = nil

local layouts =
{
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

-- helper function to detect a client is floated and current mode is float
function bind_move_client2tag(globalkeys)
    local keynumber = 0
    for s = 1, screen.count() do
        keynumber = math.min(9, math.max(#tags[s], keynumber))
    end
    for i = 1, keynumber do
        globalkeys = awful.util.table.join(globalkeys,
        -- move to tag
        awful.key({ modkey  }, "#" .. i + 9, function ()
            if tags[mouse.screen][i] then
                awful.tag.viewonly(tags[mouse.screen][i])
            end
        end),
        -- move current active window to specific tag
        awful.key({ modkey, "Shift"  }, "#" .. i + 9, function ()
            if client.focus and tags[client.focus.screen][i] then
                awful.client.movetotag(tags[client.focus.screen][i])
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
            if(c.type ~= "desktop") then
                if c.minimized == false then
                    allminimized = false
                    break
                else
                    allminimized = true
                end
            end
        end

        if client.focus and client.focus.type ~= "desktop" then
            last_focused_client = client.focus
        end

        -- If at least one client isn't minimized, minimize all clients
        for y, c in pairs(clients) do
            -- ignore desktop window such as:xfdesktop
            if(c.type ~= "desktop") then
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
        local current_tag = awful.tag.selected(mouse.screen)
        local all_tags = awful.tag.gettags(awful.tag.getscreen(current_tag))
        local tag_num = #all_tags + 1
        tagobj = awful.tag.add(tag_num, {layout = awful.layout.suit.tile})
        awful.tag.setscreen(tagobj, mouse.screen)
        table.insert(tags[mouse.screen], tagobj)
        bind_move_client2tag(globalkeys)
    end),
    -- remove current tag, NOTE: current tag must contains NO clients
    awful.key({ modkey,          }, "x",      function ()
        -- we can not remove last tag
        if #awful.tag.gettags(mouse.screen) ~= 1 then
            local current_tag = awful.tag.selected(mouse.screen)
            table.remove(tags[mouse.screen], awful.tag.getidx(current_tag))
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
    awful.key({ modkey,         }, "r",    function ()
        awful.prompt.run({ prompt = "当前工作区改名:", },
        mypromptbox[mouse.screen].widget,
        function (s)
            awful.tag.selected().name = s
        end)
    end),
    awful.key({ modkey,         }, "-",    function ()
        local screengeom = screen[mouse.screen].geometry
        local cg = client.focus:geometry()
        if cg['width'] > (screengeom['width']*30/100) and cg['height'] > (screengeom['height']*30/100) then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] - delta
            cg['height'] = cg['height'] - delta_height
            client.focus:geometry(cg)
            client.focus.maximized_horizontal = false
            client.focus.maximized_vertical = false
            awful.placement.centered(client.focus, nil)
        end
    end),
    awful.key({ modkey,         }, "=",    function ()
        local screengeom = screen[mouse.screen].geometry
        local cg = client.focus:geometry()
        if (cg['width']+20)<screengeom['width'] and (cg['height']+20)<screengeom['height'] then
            delta = 20
            delta_height = (delta / cg['width']) * cg['height']
            cg['width'] = cg['width'] + delta
            cg['height'] = cg['height'] + delta_height
            client.focus:geometry(cg)
            client.focus.maximized_horizontal = false
            client.focus.maximized_vertical = false
            awful.placement.centered(client.focus, nil)
        end
    end),
    -- center or maxmize a client
    awful.key({modkey,						}, "c", function()
        if utils.isfloats(client.focus) and client.focus.type ~= 'desktop' then
            local screengeom = screen[mouse.screen].geometry
            local cg = client.focus:geometry()
            if (client.focus.maximized_horizontal and client.focus.maximized_vertical) or
               (cg.width < screengeom.width - 40 or cg.height < screengeom.height - 250)  or
               (cg['x'] + cg['width']) > (screengeom['x'] + screengeom['width']) or
               (cg['y'] + cg['height']) > (screengeom['y'] + screengeom['height']) or
               (cg['x']) < screengeom['x'] or
               (cg['y']) < screengeom['y']
            then
                -- if not horizontal or window ether with or height is smaller
                -- than centered size
                -- or window is outside of current screen
                cg.x = screengeom.x
                cg.y = screengeom.y
                cg.width = screengeom.width - 40
                cg.height = screengeom.height - 250
                client.focus.maximized_horizontal = false
                client.focus.maximized_vertical = false
                client.focus:geometry(cg)
                awful.placement.centered(client.focus, nil)
            else
                client.focus.maximized_horizontal = not client.focus.maximized_horizontal
                client.focus.maximized_vertical   = not client.focus.maximized_vertical
                if client.focus.maximized_horizontal == true and client.focus.maximized_vertical == true then
                    client.focus.border_width = "0"
                else
                    local manage = true
                    for i,v in pairs(awful.rules.rules) do
                        if v.rule.class == client.focus.class then
                            manage = false
                            break
                        end
                    end
                    if manage then client.focus.border_width = beautiful.border_width end
                end
            end
        end
    end),
    ------------------------------------------------------------------------------
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "Tab",
    function ()
        awful.client.focus.history.previous()
        if client.focus then
            client.focus:raise()
        end
    end),
    awful.key({ "Mod1",            }, "Tab",                                                      
    function ()                                                                              
        alttab.switch(1, "Alt_L", "Tab", "ISO_Left_Tab")                                             
    end),                                                                                           
    awful.key({ "Mod1", "Shift"    }, "Tab",                                                      
    function ()                                                                              
        alttab.switch(-1, "Alt_L", "Tab", "ISO_Left_Tab")                                            
    end),
    -- navigate mouse cursor between screens
    awful.key({ modkey, }, "l", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, }, "h", function () awful.screen.focus_relative(-1) end),
    -- Standard program
    awful.key({ modkey,           }, "Return",
    function ()
        local screengeom = screen[mouse.screen].geometry
        local terminal = "terminator --geometry="..(math.floor(screengeom.width) - 40).."x"..(math.floor(screengeom.height) - 250).."+20+125"
        awful.util.spawn(terminal) 
    end),
    -- change layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
    -- restart & quit awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Control"   }, "q", awesome.quit),
    -- User Defined Hot Key
    awful.key({ modkey}, "e", function () awful.util.spawn_with_shell("thunar") end), -- yaourt -S thunar
    awful.key({ modkey}, "s", function () awful.util.spawn_with_shell("xfce4-screenshooter") end), -- yaourt -S xfce4-screenshooter
    awful.key({ modkey}, "i", function () awful.util.spawn_with_shell("firefox") end), -- yaourt -S firefox
    awful.key({ modkey}, "o", function () awful.util.spawn_with_shell("terminator -e top") end), -- open 'task manger'
    awful.key({ modkey}, "y", function () awful.util.spawn_with_shell("gnome-calculator") end), -- an GUI caculate, yaourt -S gnome-caculator
    awful.key({ modkey}, "p", function () awful.util.spawn_with_shell("lxrandr") end), -- multi monitor selector like windows hotkey, yaourt -S lxrandr
    awful.key({ "Mod1", "Control"}, "space", function () awful.util.spawn_with_shell("gmrun -g '+50%+50%'") end), -- start a notepad
    awful.key({ modkey}, "n", function () awful.util.spawn_with_shell("gedit") end), -- start a notepad
    awful.key({ "Control", "Shift"}, "l", function () awful.util.spawn_with_shell("slimlock") end) -- yaourt -S slimlock
)
--end of globalkeys

-- client window hotkeys
clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "z",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "t",      function (c) c.ontop = not c.ontop            end),
    -- move window to next/pre screen
    awful.key({ modkey,           }, ",",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = screen[c.screen].geometry
            if c.screen - 1 > 0 then
                awful.client.movetoscreen(c,c.screen-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = screen[c.screen].geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ",",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = screen[c.screen].geometry
            if c.screen - 1 > 0 then
                awful.client.movetoscreen(c,c.screen-1) 
            else
                awful.client.movetoscreen(c,screen.count()) 
            end
            local new_sg = screen[c.screen].geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end),
    awful.key({ modkey,           }, ".",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = screen[c.screen].geometry
            if c.screen + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen+1)
            end
            local new_sg = screen[c.screen].geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
        end
    end),
    awful.key({ modkey, "Control" }, ".",      function(c)
        if c.type ~= "desktop" then
            local mouse_coords = mouse.coords()
            local cg = c:geometry()
            local org_sg = screen[c.screen].geometry
            if c.screen + 1 > screen.count() then
                awful.client.movetoscreen(c,1)
            else
                awful.client.movetoscreen(c,c.screen+1)
            end
            local new_sg = screen[c.screen].geometry
            utils.proportion_resize(c, cg, org_sg, new_sg)
            mouse.coords(mouse_coords, true)
        end
    end)
)
--end of clientkeys

root.keys(globalkeys)
