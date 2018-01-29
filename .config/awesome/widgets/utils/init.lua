--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]
--
local require = require
local awful = require("awful")
local beautiful = require("beautiful")
local client = client
local util = require("awful.util")
local common = require("awful.widget.common")
local naughty = require("naughty")
local math=math
local type=type
local pairs=pairs
local error=error
local screen = screen
local string=string
local mouse=mouse
local tostring = tostring
local getmetatable = getmetatable

module("utils")



local function tasklist_label(c, args, tb)
    if not args then args = {} end
    local theme = beautiful.get()
    local align = args.align or theme.tasklist_align or "left"
    local fg_normal = util.ensure_pango_color(args.fg_normal or theme.tasklist_fg_normal or theme.fg_normal, "white")
    local bg_normal = args.bg_normal or theme.tasklist_bg_normal or theme.bg_normal or "#000000"
    local fg_focus = util.ensure_pango_color(args.fg_focus or theme.tasklist_fg_focus or theme.fg_focus, fg_normal)
    local bg_focus = args.bg_focus or theme.tasklist_bg_focus or theme.bg_focus or bg_normal
    local fg_urgent = util.ensure_pango_color(args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent, fg_normal)
    local bg_urgent = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent or bg_normal
    local fg_minimize = util.ensure_pango_color(args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize, fg_normal)
    local bg_minimize = args.bg_minimize or theme.tasklist_bg_minimize or theme.bg_minimize or bg_normal
    local bg_image_normal = args.bg_image_normal or theme.bg_image_normal
    local bg_image_focus = args.bg_image_focus or theme.bg_image_focus
    local bg_image_urgent = args.bg_image_urgent or theme.bg_image_urgent
    local bg_image_minimize = args.bg_image_minimize or theme.bg_image_minimize
    local tasklist_disable_icon = args.tasklist_disable_icon or theme.tasklist_disable_icon or false
    local font = args.font or theme.tasklist_font or theme.font or ""
    local font_focus = args.font_focus or theme.tasklist_font_focus or theme.font_focus or font or ""
    local font_minimized = args.font_minimized or theme.tasklist_font_minimized or theme.font_minimized or font or ""
    local font_urgent = args.font_urgent or theme.tasklist_font_urgent or theme.font_urgent or font or ""
    local text = ""
    local name = ""
    local bg
    local bg_image
    local shape              = args.shape or theme.tasklist_shape
    local shape_border_width = args.shape_border_width or theme.tasklist_shape_border_width
    local shape_border_color = args.shape_border_color or theme.tasklist_shape_border_color

    -- symbol to use to indicate certain client properties
    local sticky = args.sticky or theme.tasklist_sticky or "▪"
    local ontop = args.ontop or theme.tasklist_ontop or '⌃'
    local above = args.above or theme.tasklist_above or '▴'
    local below = args.below or theme.tasklist_below or '▾'
    local floating = args.floating or theme.tasklist_floating or '✈'
    local maximized = args.maximized or theme.tasklist_maximized or '+'
    local maximized_horizontal = args.maximized_horizontal or theme.tasklist_maximized_horizontal or '⬌'
    local maximized_vertical = args.maximized_vertical or theme.tasklist_maximized_vertical or '⬍'
    local minimized = args.minimized or theme.minimized or '❄'


    tb:set_align(align)

    if not theme.tasklist_plain_task_name then
        if c.sticky then name = name .. sticky end

        if c.ontop then name = name .. ontop
        elseif c.above then name = name .. above
        elseif c.below then name = name .. below end

        if c.maximized then
            name = name .. maximized
        else
            if c.maximized_horizontal then name = name .. maximized_horizontal end
            if c.maximized_vertical then name = name .. maximized_vertical end
            if c.floating then name = name .. floating end
        end
    end

    if c.minimized then
        name = name .. minimized .. (util.escape(c.icon_name) or util.escape(c.name) or util.escape("<untitled>"))
    else
        name = name .. (util.escape(c.name) or util.escape("<untitled>"))
    end

    local focused = client.focus == c
    -- Handle transient_for: the first parent that does not skip the taskbar
    -- is considered to be focused, if the real client has skip_taskbar.
    if not focused and client.focus and client.focus.skip_taskbar
        and client.focus:get_transient_for_matching(function(cl)
                                                             return not cl.skip_taskbar
                                                         end) == c then
        focused = true
    end

    if focused then
        bg = bg_focus
        text = text .. "<span color='"..fg_focus.."'>"..name.."</span>"
        bg_image = bg_image_focus
        font = font_focus

        if args.shape_focus or theme.tasklist_shape_focus then
            shape = args.shape_focus or theme.tasklist_shape_focus
        end

        if args.shape_border_width_focus or theme.tasklist_shape_border_width_focus then
            shape_border_width = args.shape_border_width_focus or theme.tasklist_shape_border_width_focus
        end

        if args.shape_border_color_focus or theme.tasklist_shape_border_color_focus then
            shape_border_color = args.shape_border_color_focus or theme.tasklist_shape_border_color_focus
        end
    elseif c.urgent then
        bg = bg_urgent
        text = text .. "<span color='"..fg_urgent.."'>"..name.."</span>"
        bg_image = bg_image_urgent
        font = font_urgent

        if args.shape_urgent or theme.tasklist_shape_urgent then
            shape = args.shape_urgent or theme.tasklist_shape_urgent
        end

        if args.shape_border_width_urgent or theme.tasklist_shape_border_width_urgent then
            shape_border_width = args.shape_border_width_urgent or theme.tasklist_shape_border_width_urgent
        end

        if args.shape_border_color_urgent or theme.tasklist_shape_border_color_urgent then
            shape_border_color = args.shape_border_color_urgent or theme.tasklist_shape_border_color_urgent
        end
    elseif c.minimized then
        bg = bg_minimize
        text = text .. "<span color='"..fg_minimize.."'>"..name.."</span>"
        bg_image = bg_image_minimize
        font = font_minimized

        if args.shape_minimized or theme.tasklist_shape_minimized then
            shape = args.shape_minimized or theme.tasklist_shape_minimized
        end

        if args.shape_border_width_minimized or theme.tasklist_shape_border_width_minimized then
            shape_border_width = args.shape_border_width_minimized or theme.tasklist_shape_border_width_minimized
        end

        if args.shape_border_color_minimized or theme.tasklist_shape_border_color_minimized then
            shape_border_color = args.shape_border_color_minimized or theme.tasklist_shape_border_color_minimized
        end
    else
        bg = bg_normal
        text = text .. "<span color='"..fg_normal.."'>"..name.."</span>"
        bg_image = bg_image_normal
    end
    tb:set_font(font)

    local other_args = {
        shape              = shape,
        shape_border_width = shape_border_width,
        shape_border_color = shape_border_color,
    }

    return text, bg, bg_image, not tasklist_disable_icon and c.icon or nil, other_args
end

function tasklist_update_function(w, buttons, label, data, clients)
    local function _label(c, tb) return tasklist_label(c, {font = beautiful.font .. "' size='large", fg_focus='#fff000', bg_focus='#000000'}, tb) end
    common.list_update(w, buttons, _label, data, clients)
end

function proportion_resize(c, cg, org_sg, new_sg)
    local _x = (cg["x"] - org_sg["x"]) / org_sg["width"]
    local _y = (cg["y"] - org_sg["y"]) / org_sg["height"]
    local _width = cg["width"] / org_sg["width"]
    local _height = cg["height"] / org_sg["height"]
    cg["x"] = new_sg["x"] + _x * new_sg["width"]
    cg["y"] = new_sg["y"] + _y * new_sg["height"]
    cg["width"] = _width * new_sg["width"]
    cg["height"] = _height * new_sg["height"]
    c:geometry(cg)
end

-- debug function used to serialize a data structure
function serialize(obj)  
	local lua = ""  
	local t = type(obj)  
    if t == nil then
        return nil
    elseif t == "number" then  
		lua = lua .. obj  
	elseif t == "boolean" then  
		lua = lua .. tostring(obj)  
	elseif t == "string" then  
		lua = lua .. string.format("%q", obj)  
	elseif t == "table" then  
		lua = lua .. "{\n"  
		for k, v in pairs(obj) do  
			lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
		end  
		local metatable = getmetatable(obj)  
		if metatable ~= nil and type(metatable.__index) == "table" then  
			for k, v in pairs(metatable.__index) do  
				lua = lua .. "[" .. serialize(k) .. "]=" .. serialize(v) .. ",\n"  
			end  
		end  
	lua = lua .. "}"  
	elseif t == "nil" then  
		return nil  
	else  
		error("can not serialize a " .. t .. " type.")  
	end  
	return lua  
end 
-- serialize function end

function unserialize(lua)  
	local t = type(lua)  
	if t == "nil" or lua == "" then  
		return nil  
	elseif t == "number" or t == "string" or t == "boolean" then  
		lua = tostring(lua)  
	else  
		error("can not unserialize a " .. t .. " type.")  
	end  
	lua = "return " .. lua  
	local func = loadstring(lua)  
	if func == nil then  
		return nil  
	end  
	return func()  
end  

function isfloats(c)
    local ret = false
    local l = awful.layout.get(c.screen)
    if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
        ret = true
    end
    return ret
end

function center_window(c)
    if isfloats(c) and c.type ~= 'desktop' then
        local screengeom = c.screen.geometry
        local cg = c:geometry()
        if (c.maximized_horizontal and c.maximized_vertical) or
           (cg.width < screengeom.width - beautiful.margin_horizontal or cg.height < screengeom.height - beautiful.margin_vertical)  or
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
            cg.width = screengeom.width - beautiful.margin_horizontal
            cg.height = screengeom.height - beautiful.margin_vertical
            c.maximized = false
            c.maximized_horizontal = false
            c.maximized_vertical = false
            c:geometry(cg)
            awful.placement.centered(c, nil)
        else
            c.maximized_horizontal = not c.maximized_horizontal
            c.maximized_vertical   = not c.maximized_vertical
            if c.maximized_horizontal == true and c.maximized_vertical == true then
                c.maximized = true
                c.border_width = 0
            else
                local manage = true
                for i,v in pairs(awful.rules.rules) do
                    if v.rule.class == c.class then
                        manage = false
                        break
                    end
                end
            end
        end
    end
end
