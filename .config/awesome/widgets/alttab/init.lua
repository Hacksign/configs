local cairo = require("lgi").cairo
local mouse = mouse
local screen = screen
local wibox = require('wibox')
local table = table
local timer = timer
local keygrabber = keygrabber
local math = require('math')
local awful = require('awful')
local gears = require("gears")
local client = client
awful.client = require('awful.client')

local naughty = require("naughty")
local string = string
local tostring = tostring
local tonumber = tonumber
local debug = debug
local pairs = pairs

module("alttab")

local surface = cairo.ImageSurface(cairo.Format.RGB24,20,20)
local cr = cairo.Context(surface)

local settings = { 
	preview_box = true,
	preview_box_bg = "#ddddddff",
	preview_box_border = "#22222200",
	preview_box_fps = 30,
	preview_box_delay = 150,

	client_opacity = true,
	client_opacity_value = 0.1,
	client_opacity_delay = 150,
}

-- Create a wibox to contain all the client-widgets
local preview_wbox = wibox({ width = screen[mouse.screen].geometry.width })
preview_wbox.border_width = 3
preview_wbox.ontop = true
preview_wbox.visible = false

local preview_live_timer = timer({}) --( {timeout = 1/settings.preview_box_fps} )
local preview_widgets = {}

local altTabTable = {}
local altTabIndex = 1
local applyOpacity = false

local source = string.sub(debug.getinfo(1,'S').source, 2)
local path = string.sub(source, 1, string.find(source, "/[^/]*$"))
local noicon = path .. "noicon.png"

local function preview()
	if not settings.preview_box then return end
	-- Apply settings
	preview_wbox:set_bg(settings.preview_box_bg)
	preview_wbox.border_color = settings.preview_box_border
	local preview_widgets = {}
	local n = 0
	-- Make the wibox the right size, based on the number of clients
	if(#altTabTable == 0) then
		n = 2
	else
		n = math.min(30, #altTabTable)
	end
	local textboxHeight = screen[mouse.screen].geometry.height / 50 -- window title box height
	local w = screen[mouse.screen].geometry.width * (15/100) + (2 * preview_wbox.border_width) -- widget width
	local h = textboxHeight * n + (2 * preview_wbox.border_width) -- widget height
	-- Caculate wibox Position
	local x = (screen[mouse.screen].geometry.width - w) / 2 + screen[mouse.screen].geometry.x
	local y = (screen[mouse.screen].geometry.height - h - textboxHeight) / 2 + screen[mouse.screen].geometry.y
	preview_wbox:geometry({x = x, y = y, width = w, height = h + textboxHeight})
	local leftRightTab = {}
	local nLeft
	local nRight
	if #altTabTable == 2 then
		nLeft = 0
		nRight = 2
	else
		nLeft = math.floor(#altTabTable / 2)
		nRight = math.ceil(#altTabTable / 2)
	end

	for i = 1, nLeft do
		table.insert(leftRightTab, altTabTable[#altTabTable - nLeft + i])
	end
	for i = 1, nRight do
		table.insert(leftRightTab, altTabTable[i])
	end

	-- determine fontsize -> find maximum classname-length
	local text, textWidth, textHeight, maxText
	local maxTextWidth = 0
	local maxTextHeight = 0
	local bigFont = textboxHeight / 2
	cr:set_font_size(fontSize)
	for i = 1, #leftRightTab do
		text = " - " .. leftRightTab[i].class 
		textWidth = cr:text_extents(text).width
		textHeight = cr:text_extents(text).height
		if textWidth > maxTextWidth or textHeight > maxTextHeight then
			maxTextHeight = textHeight
			maxTextWidth = textWidth
			maxText = text
		end
	end

	while true do
		cr:set_font_size(bigFont)
		textWidth = cr:text_extents(maxText).width
		textHeight = cr:text_extents(maxText).height

		if textWidth < w - textboxHeight and textHeight < textboxHeight then
			break
		end

		bigFont = bigFont - 1
	end
	local smallFont = bigFont * 0.8


	-- create all the widgets
	for i = 1, #leftRightTab do
		preview_widgets[i] = wibox.widget.base.make_widget()
		preview_widgets[i].fit = function(preview_widget, width, height)
			return w, h
		end

		preview_widgets[i].draw = function(preview_widget, preview_wbox, cr, width, height)
			if width ~= 0 and height ~= 0 then
				local c = leftRightTab[i]
				local fontSize = smallFont
				if c == altTabTable[altTabIndex] then
					fontSize = bigFont
				end
				local sx, sy, tx, ty
				-- Icons
				local icon
				if c.icon == nil then 
					icon = gears.surface(gears.surface.load(noicon))
				else
					icon = gears.surface(c.icon)
				end
				-- Draw icons
				local iconboxWidth = textboxHeight
				local iconboxHeight = iconboxWidth
				cr:translate(0, 5)
				sx = iconboxWidth / icon.width
				sy = iconboxHeight  / icon.height
				cr:scale(sx, sy)
				cr:set_source_surface(icon, 0, 0)
				cr:paint()

				-- Draw titles
				cr:select_font_face("Source Han Sans CN","YaHei Consolas Hybrid", "simsun", "sans", "italic", "normal")
				cr:set_font_face(cr:get_font_face())
				cr:set_font_size(fontSize)
				text = " - " .. c.class
				textWidth = cr:text_extents(text).width
				textHeight = cr:text_extents(text).height
				tx = 0
				ty = 0
				cr:scale(1/sx, 1/sy)
				cr:translate(tx, ty)
				tx = tx + iconboxWidth
				ty = (textboxHeight + textHeight) / 2
				cr:move_to(tx, ty)
				if(fontSize == bigFont) then
					cr:set_source_rgba(1,0,0,1)
				else
					cr:set_source_rgba(0,0,0,1)
				end
				cr:show_text(text)
				cr:stroke()
			end -- end if
		end -- end .draw function

		preview_live_timer.timeout = 1 / settings.preview_box_fps
		preview_live_timer:connect_signal("timeout", function() 
			preview_widgets[i]:emit_signal("widget::updated") 
		end)

	end
	--layout
	preview_layout = wibox.layout.flex.vertical()
	for i = 1, #leftRightTab do
		preview_layout:add(preview_widgets[i])
	end
	preview_wbox:set_widget(preview_layout)
end

local function clientOpacity(altTabTable, altTabIndex)
	if not settings.client_opacity then return end

	for i,c in pairs(altTabTable) do
		if i == altTabIndex then
			c.opacity = 1
			elseif applyOpacity then
				c.opacity = settings.client_opacity_value
			end
		end
	end


	local function cycle(altTabTable, altTabIndex, dir)
		-- Switch to next client
		altTabIndex = altTabIndex + dir
		if altTabIndex > #altTabTable then
			altTabIndex = 1 -- wrap around
			elseif altTabIndex < 1 then
				altTabIndex = #altTabTable -- wrap around
			end

			altTabTable[altTabIndex].minimized = false

			if not settings.preview_box and not settings.client_opacity then
				client.focus = altTabTable[altTabIndex]
			end

			if settings.client_opacity then
				clientOpacity(altTabTable, altTabIndex)
			end

			return altTabIndex
		end

		local function switch(dir, alt, tab, shift_tab)

			altTabTable = {}
			local altTabMinimized = {}
			local altTabOpacity = {}

			-- Get focus history for current tag
			local s = mouse.screen;
			local idx = 0
			local c = awful.client.focus.history.get(s, idx)

			while c do
				if c.type ~= 'desktop' then
					table.insert(altTabTable, c)
					table.insert(altTabMinimized, c.minimized)
					table.insert(altTabOpacity, c.opacity)
				end
				idx = idx + 1
				c = awful.client.focus.history.get(s, idx)
			end

			-- Minimized clients will not appear in the focus history
			-- Find them by cycling through all clients, and adding them to the list
			-- if not already there.
			-- This will preserve the history AND enable you to focus on minimized clients
			-- NOTE: window type which is 'desktop' (e.g.:Xfdesktop) should not be showed in the list

			local t = awful.tag.selected(s)
			local all = client.get(s)


			for i = 1, #all do
				local c = all[i]
				local ctags = c:tags();

				-- check if the client is on the current tag
				local isCurrentTag = false
				for j = 1, #ctags do
					if t == ctags[j] then
						isCurrentTag = true
						break
					end
				end

				if isCurrentTag then
					-- check if client is already in the history
					-- if not, add it
					local addToTable = true
					for k = 1, #altTabTable do
						if altTabTable[k] == c then
							addToTable = false
							break
						end
					end

					if addToTable and c.type ~= 'desktop' then
						table.insert(altTabTable, c)
						table.insert(altTabMinimized, c.minimized)
						table.insert(altTabOpacity, c.opacity)
					end
				end
			end

			if #altTabTable == 0 then
				return
				elseif #altTabTable == 1 then 
					altTabTable[1].minimized = false
					altTabTable[1]:raise()
					return
				end

				-- reset index
				altTabIndex = 1

				-- preview delay timer
				local previewDelay = settings.preview_box_delay / 1000
				local previewDelayTimer = timer({timeout = previewDelay})
				previewDelayTimer:connect_signal("timeout", function() 
					preview_wbox.visible = true
					previewDelayTimer:stop()
					preview(altTabTable, altTabIndex) 
				end)
				previewDelayTimer:start()
				preview_live_timer:start()

				-- opacity delay timer
				local opacityDelay = settings.client_opacity_delay / 1000
				local opacityDelayTimer = timer({timeout = opacityDelay})
				opacityDelayTimer:connect_signal("timeout", function() 
					applyOpacity = true
					opacityDelayTimer:stop()
					clientOpacity(altTabTable, altTabIndex)
				end)
				opacityDelayTimer:start()


				-- Now that we have collected all windows, we should run a keygrabber
				-- as long as the user is alt-tabbing:
				keygrabber.run(
				function (mod, key, event)  
					-- Stop alt-tabbing when the alt-key is released
					if key == alt or key == "Escape" and event == "release" then
						preview_wbox.visible = false
						applyOpacity = false
						preview_live_timer:stop()
						previewDelayTimer:stop()
						opacityDelayTimer:stop()

						if key == "Escape" then 
							for i,c in pairs(altTabTable) do
								c.opacity = altTabOpacity[i]
							end
							keygrabber.stop()
							return
						end

						-- Raise clients in order to restore history
						local c
						for i = 1, altTabIndex - 1 do
							c = altTabTable[altTabIndex - i]
							if not altTabMinimized[i] then
								c:raise()
								client.focus = c
							end
						end

						-- raise chosen client on top of all
						c = altTabTable[altTabIndex]
						c:raise()
						client.focus = c                  

						-- restore minimized clients
						for i = 1, #altTabTable do
							if i ~= altTabIndex and altTabMinimized[i] then 
								altTabTable[i].minimized = true
							end
							altTabTable[i].opacity = altTabOpacity[i]
						end

						keygrabber.stop()

						-- Move to next client on each Tab-press
						elseif (key == tab or key == "Down" or key == "j") and event == "press" then
							altTabIndex = cycle(altTabTable, altTabIndex, 1)

							-- Move to previous client on Shift-Tab
							elseif (key == shift_tab or key == "Up" or key == "k") and event == "press" then
								altTabIndex = cycle(altTabTable, altTabIndex, -1)
							end
						end
						)

						-- switch to next client
						altTabIndex = cycle(altTabTable, altTabIndex, dir)

					end -- function altTab

					return {switch = switch, settings = settings}
