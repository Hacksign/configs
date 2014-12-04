-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
awful.rules = require("awful.rules")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local vicious = require("vicious")
local alttab	= require("alttab")

-- helper function to detect a client is floated and current mode is float
function floats(c)
	local ret = false
	local l = awful.layout.get(c.screen)
	if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
		ret = true
	end
	return ret
end

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({ preset = naughty.config.presets.critical,
                     title = "Oops, there were errors during startup!",
                     text = awesome.startup_errors })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function (err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({ preset = naughty.config.presets.critical,
                         title = "Oops, an error happened!",
                         text = err })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, and wallpapers
beautiful.init("/usr/share/awesome/themes/arch/theme.lua")

local terminal = "terminator"
local editor = os.getenv("EDITOR") or "nano"

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
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
-- }}}

-- {{{ Wallpaper
if beautiful.wallpaper then
    for s = 1, screen.count() do
        gears.wallpaper.maximized(beautiful.wallpaper, s, true)
    end
end
-- }}}

-- {{{ Tags
-- Define a tag table which hold all screen tags.
tags = {
	names = {"网络", "工作"},
	layout = {layouts[1], layouts[1], layouts[1]}
}
for s = 1, screen.count() do
    -- Each screen has its own tag table.
    tags[s] = awful.tag(tags.names, s, tags.layout)
end
-- }}}

-- {{{ Menu
-- Create a laucher widget and a main menu
myawesomemenu = {
   { "restart", awesome.restart },
   { "quit", awesome.quit }
}

mymainmenu = awful.menu({ items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
                                  }
                        })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- {{{ Wibox
-- Create a textclock widget
local mytextclock = awful.widget.textclock("%F %H:%M")
local calendar = require("calendar35")
calendar.addCalendarToWidget(mytextclock, "bottom_right")

-- Create a wibox for each screen and add it
bottomwibox = {}
mypromptbox = {}
mylayoutbox = {}
mytaglist = {}
mytaglist.buttons = awful.util.table.join(
                    awful.button({ }, 1, awful.tag.viewonly),
                    awful.button({ modkey }, 1, awful.client.movetotag),
                    awful.button({ }, 3, awful.tag.viewtoggle),
                    awful.button({ modkey }, 3, awful.client.toggletag),
                    awful.button({ }, 4, function(t) awful.tag.viewnext(awful.tag.getscreen(t)) end),
                    awful.button({ }, 5, function(t) awful.tag.viewprev(awful.tag.getscreen(t)) end)
                    )
mytasklist = {}
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
                                          end),
                     awful.button({ }, 3, function ()
                                              if instance then
                                                  instance:hide()
                                                  instance = nil
                                              else
                                                  instance = awful.menu.clients({ width=250 })
                                              end
                                          end),
                     awful.button({ }, 4, function ()
                                              awful.client.focus.byidx(1)
                                              if client.focus then client.focus:raise() end
                                          end),
                     awful.button({ }, 5, function ()
                                              awful.client.focus.byidx(-1)
                                              if client.focus then client.focus:raise() end
                                          end))
-- mouse event handler end																					

-- top & battom bar widgets
--	left bottom corner:cpu/memory/battery(if exists) widgets
local cpuwidget = awful.widget.graph()
cpuwidget:set_width(150)
cpuwidget:set_background_color("#494B4F")
cpuwidget:set_color("#FF5656")
vicious.register(cpuwidget, vicious.widgets.cpu, "$1")

local memwidget = awful.widget.progressbar()
memwidget:set_width(10)
memwidget:set_height(10)
memwidget:set_vertical(true)
memwidget:set_background_color("#494B4F")
memwidget:set_border_color(nil)
memwidget:set_color("#AECF96")
vicious.register(memwidget, vicious.widgets.mem, "$1", 13)

-- Need install acpi package
--		pacman -S apci
local acpi_info = assert(io.popen("acpi", "r"))
local battery_info = acpi_info:read("*l")
if battery_info then
	batterywidget = awful.widget.progressbar()
	batterywidget:set_width(10)
	batterywidget:set_height(10)
	batterywidget:set_vertical(true)
	batterywidget:set_background_color("#494B4F")
	batterywidget:set_border_color(nil)
	batterywidget:set_color("#FF5656")
	batterywidget:set_max_value(100)
	batterywidgettimer = timer({timeout = 5})
	batterywidgettimer:connect_signal("timeout",
			function()
				local fh = assert(io.popen("acpi | cut -d' ' -f 4 -|cut -d, -f 1 -|cut -d% -f 1 -", "r"))
				local percent = fh:read("*l")
				percent = string.sub(percent, 0, string.len(percent))
				percent = tonumber(percent)
				batterywidget:set_value(percent)
				fh:close()
			end
	 )
	batterywidgettimer:start()
end
--	now deal ervery screen
for s = 1, screen.count() do
    -- Create a promptbox for each screen
    mypromptbox[s] = awful.widget.prompt()
    -- Create an imagebox widget which will contains an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    mylayoutbox[s] = awful.widget.layoutbox(s)
    mylayoutbox[s]:buttons(awful.util.table.join(
                           awful.button({ }, 1, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 3, function () awful.layout.inc(layouts, -1) end),
                           awful.button({ }, 4, function () awful.layout.inc(layouts, 1) end),
                           awful.button({ }, 5, function () awful.layout.inc(layouts, -1) end)))
    -- Create a taglist widget
    mytaglist[s] = awful.widget.taglist(s, awful.widget.taglist.filter.all, mytaglist.buttons)

    -- Create a tasklist widget
    mytasklist[s] = awful.widget.tasklist(s, awful.widget.tasklist.filter.currenttags, mytasklist.buttons)

    -- Create the wibox
		local mywibox = {}
    mywibox[s] = awful.wibox({ position = "top", screen = s })
		bottomwibox[s] = awful.wibox({position = "bottom", screen = s})


		local blankwidget = wibox.widget.textbox()
		blankwidget:set_markup(" ")

    -- Widgets that are aligned to the left
    local left_layout = wibox.layout.fixed.horizontal()
    left_layout:add(mytaglist[s])
    left_layout:add(mypromptbox[s])
		local bottom_left_layout = wibox.layout.fixed.horizontal()
		bottom_left_layout:add(cpuwidget)
		bottom_left_layout:add(blankwidget)
		bottom_left_layout:add(memwidget)
		bottom_left_layout:add(blankwidget)
		if batterywidget then
			bottom_left_layout:add(batterywidget)
			bottom_left_layout:add(blankwidget)
		end

    -- Widgets that are aligned to the right
    local right_layout = wibox.layout.fixed.horizontal()
    if s == 1 then right_layout:add(wibox.widget.systray()) end
    right_layout:add(mylayoutbox[s])
		local bottom_right_layout = wibox.layout.fixed.horizontal()
    bottom_right_layout:add(mytextclock)

    -- Now bring it all together (with the tasklist in the middle)
    local layout = wibox.layout.align.horizontal()
    layout:set_left(left_layout)
    layout:set_right(right_layout)
		local bottom_layout = wibox.layout.align.horizontal()
		bottom_layout:set_left(bottom_left_layout)
    bottom_layout:set_middle(mytasklist[s])
		bottom_layout:set_right(bottom_right_layout)

    mywibox[s]:set_widget(layout)
		bottomwibox[s]:set_widget(bottom_layout)
end
-- }}}

-- {{{ Mouse bindings
root.buttons(awful.util.table.join(
    awful.button({ }, 3, function () mymainmenu:toggle() end),
    awful.button({ }, 4, awful.tag.viewnext),
    awful.button({ }, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
local dt_move = 15
globalkeys = awful.util.table.join(
		-- window navigation
		-- Toggle show desktop (for current tag(s))
    awful.key({ modkey,           }, "d",  function ()
			local curtag
			local curtags = awful.tag.selectedlist()
			local client
			local clients
			local allminimized
			for x, curtag in pairs(curtags) do
				clients = curtag:clients()
				for y, client in pairs(clients) do
					if client.minimized == false then
						allminimized = false
						break
					else
						allminimized = true
					end
				end

				-- If at least one client isn't minimized, minimize all clients
				for y, client in pairs(clients) do
					-- ignore desktop window such as:xfdesktop
					if(client.type ~= "desktop") then
						if allminimized == false then
							client.minimized = true 
							-- Otherwise unminimize all clients
						elseif allminimized == true then
							client.minimized = false 
						end
					end
				end
			end
		end),
		-- Move window position vim-like
		awful.key({modkey,						}, "h", function()
			if floats(client.focus) then
				local g = client.focus:geometry()
				g.x = g.x - dt_move
				client.focus:geometry(g)
			end
		end),
		awful.key({modkey,						}, "l", function()
			if floats(client.focus) then
				local g = client.focus:geometry()
				g.x = g.x + dt_move
				client.focus:geometry(g)
			end
		end),
		awful.key({modkey,						}, "j", function()
			if floats(client.focus) then
				local g = client.focus:geometry()
				g.y = g.y + dt_move
				client.focus:geometry(g)
			end
		end),
		awful.key({modkey,						}, "k", function()
			if floats(client.focus) then
				local g = client.focus:geometry()
				g.y = g.y - dt_move
				client.focus:geometry(g)
			end
		end),
		awful.key({modkey,						}, "c", function()
			if floats(client.focus) then
				awful.placement.centered(client.focus)
			end
		end),
		------------------------------------------------------------------------------
    awful.key({ modkey,           }, "Left",   awful.tag.viewprev       ),
    awful.key({ modkey,           }, "Right",  awful.tag.viewnext       ),
    awful.key({ modkey,           }, "Escape", awful.tag.history.restore),
    awful.key({ modkey,           }, "w", function () mymainmenu:show() end),
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
    -- Layout manipulation
    awful.key({ modkey, "Shift"   }, "j", function () awful.client.swap.byidx(  1)    end),
    awful.key({ modkey, "Shift"   }, "k", function () awful.client.swap.byidx( -1)    end),
    awful.key({ modkey, "Control" }, "j", function () awful.screen.focus_relative( 1) end),
    awful.key({ modkey, "Control" }, "k", function () awful.screen.focus_relative(-1) end),
    awful.key({ modkey,           }, "u", awful.client.urgent.jumpto),
    -- Standard program
    awful.key({ modkey,           }, "Return",
							function ()
								screengeom = screen[mouse.screen].geometry
								local terminal = "terminator --geometry="..(screengeom.width - 40).."x"..(screengeom.height - 250).."+20+125"
								awful.util.spawn(terminal) 
							end),
		-- change layout
    awful.key({ modkey,           }, "space", function () awful.layout.inc(layouts,  1) end),
    awful.key({ modkey, "Shift"   }, "space", function () awful.layout.inc(layouts, -1) end),
		-- restart & quit awesome
    awful.key({ modkey, "Control" }, "r", awesome.restart),
    awful.key({ modkey, "Shift"   }, "q", awesome.quit),
		-- User Defined Hot Key
		awful.key({ modkey}, "e", function () awful.util.spawn_with_shell("thunar") end), -- yaourt -S thunar
		awful.key({ modkey}, "s", function () awful.util.spawn_with_shell("xfce4-screenshooter") end), -- yaourt -S xfce4-screenshooter
		awful.key({ modkey}, "i", function () awful.util.spawn_with_shell("firefox") end), -- yaourt -S firefox
		awful.key({ modkey}, "o", function () awful.util.spawn_with_shell("terminator -e top") end), -- open 'task manger' ;)
		awful.key({ modkey}, "y", function () awful.util.spawn_with_shell("galculator") end), -- an GUI caculate, yaourt -S galculator
		awful.key({ modkey}, "p", function () awful.util.spawn_with_shell("lxrandr") end), -- multi monitor selector like windows hotkey, yaourt -S lxrandr
		awful.key({ "Control", "Shift"}, "l", function () awful.util.spawn_with_shell("slimlock") end) -- yaourt -S slimlock
)

clientkeys = awful.util.table.join(
    awful.key({ modkey,           }, "f",      function (c) c.fullscreen = not c.fullscreen  end),
    awful.key({ modkey,           }, "z",      function (c) c:kill()                         end),
    awful.key({ modkey, "Control" }, "space",  awful.client.floating.toggle                     ),
    awful.key({ modkey, "Control" }, "Return", function (c) c:swap(awful.client.getmaster()) end),
    awful.key({ modkey,           }, "o",      awful.client.movetoscreen                        ),
    awful.key({ modkey,           }, "t",      function (c) c.ontop = not c.ontop            end),
    awful.key({ modkey,           }, "m",
        function (c)
					if c.type ~= 'desktop' then
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
						if c.maximized_horizontal == true and c.maximized_vertical == true then
							c.border_width = "0"
						else
							local manage = true
							for i,v in pairs(awful.rules.rules) do
								if v.rule.class == c.class then
									manage = false
									break
								end
							end
							if manage then c.border_width = beautiful.border_width end
						end
					end
        end)
)

-- Compute the maximum number of digit we need, limited to 9
keynumber = 0
for s = 1, screen.count() do
   keynumber = math.min(9, math.max(#tags[s], keynumber))
end

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it works on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, keynumber do
    globalkeys = awful.util.table.join(globalkeys,
        awful.key({ modkey }, "#" .. i + 9,
                  function ()
                        local screen = mouse.screen
                        if tags[screen][i] then
                            awful.tag.viewonly(tags[screen][i])
                        end
                  end),
        awful.key({ modkey, "Control" }, "#" .. i + 9,
                  function ()
                      local screen = mouse.screen
                      if tags[screen][i] then
                          awful.tag.viewtoggle(tags[screen][i])
                      end
                  end),
        awful.key({ modkey, "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.movetotag(tags[client.focus.screen][i])
                      end
                  end),
        awful.key({ modkey, "Control", "Shift" }, "#" .. i + 9,
                  function ()
                      if client.focus and tags[client.focus.screen][i] then
                          awful.client.toggletag(tags[client.focus.screen][i])
                      end
                  end))
end

clientbuttons = awful.util.table.join(
    awful.button({ }, 1, function (c) client.focus = c; c:raise() end),
    awful.button({ modkey }, 1, awful.mouse.client.move),
    awful.button({ modkey }, 3, awful.mouse.client.resize))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
awful.rules.rules = {
    -- All clients will match this rule.
    { rule = { },
      properties = { border_width = beautiful.border_width,
                     border_color = beautiful.border_normal,
                     focus = awful.client.focus.filter,
                     keys = clientkeys,
                     buttons = clientbuttons } },
    { rule = { class = "MPlayer" },
      properties = { floating = true } },
    { rule = { class = "Insight3.exe" },
      properties = { floating = true, focus = true } },
    { rule = { class = "Launchy" },
      properties = { border_width = 0, floating = true } },
    { rule = { class = "Terminator" },
      properties = { border_width = 1, floating = true } },
    { rule = { class = "pinentry" },
      properties = { floating = true } },
    { rule = { class = "Xfdesktop" },
			except = {class = "Xfdesktop-settings"},
      properties = { border_width = 0, maximized = true, sticky = true, focusable = false } },
    { rule = { class = "Bcloud-gui" },
      properties = { border_width = 0, floating = true } },
    { rule = { class = "gimp" },
      properties = { floating = true } },
    { rule = { class = "File-roller" },
      properties = { floating = true, border_width = 0 } },
    { rule = { class = "Evince" },
      properties = { floating = true, border_width = 0 } },
		-- fix problem of Wine program move slowly to right-bottom of the corner
		-- http://www.youtube.com/watch?v=3Q91HjEaBD8
		-- https://awesome.naquadah.org/bugs/index.php?do=details&task_id=1030
    { rule = { class = "Wine" },
      properties = { floating = true, border_width = 0 } },
    -- Set Firefox to always map on tags number 2 of screen 1.
    -- { rule = { class = "Firefox" },
    --   properties = { tag = tags[1][2] } },
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function (c, startup)
    -- Enable sloppy focus
    --	focus window with mouse move
    -- c:connect_signal("mouse::enter", function(c)
    --     if awful.layout.get(c.screen) ~= awful.layout.suit.magnifier
    --         and awful.client.focus.filter(c) then
    --         client.focus = c
    --     end
    -- end)

    if not startup then
        -- Set the windows at the slave,
        -- i.e. put it at the end of others instead of setting it master.
        -- awful.client.setslave(c)

        -- Put windows in a smart way, only if they does not set an initial position.
        if not c.size_hints.user_position and not c.size_hints.program_position then
            awful.placement.no_overlap(c)
            awful.placement.no_offscreen(c)
            awful.placement.centered(c)
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
--
--
-- my stuff

awful.util.spawn_with_shell("/usr/bin/perl /home/hacksign/.config/awesome/autostart.pl&")
