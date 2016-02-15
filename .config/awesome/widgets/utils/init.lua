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

local function tasklist_label(c, args)
    if not args then args = {} end
    local theme = beautiful.get()
    local fg_normal = args.fg_normal or theme.tasklist_fg_normal or theme.fg_normal or "#ffffff"
    local bg_normal = args.bg_normal or theme.tasklist_bg_normal or theme.bg_normal or "#000000"
    local fg_focus = args.fg_focus or theme.tasklist_fg_focus or theme.fg_focus
    local bg_focus = args.bg_focus or theme.tasklist_bg_focus or theme.bg_focus
    local fg_urgent = args.fg_urgent or theme.tasklist_fg_urgent or theme.fg_urgent
    local bg_urgent = args.bg_urgent or theme.tasklist_bg_urgent or theme.bg_urgent
    local fg_minimize = args.fg_minimize or theme.tasklist_fg_minimize or theme.fg_minimize
    local bg_minimize = args.bg_minimize or theme.tasklist_bg_minimize or theme.bg_minimize
    local bg_image_normal = args.bg_image_normal or theme.bg_image_normal
    local bg_image_focus = args.bg_image_focus or theme.bg_image_focus
    local bg_image_urgent = args.bg_image_urgent or theme.bg_image_urgent
    local bg_image_minimize = args.bg_image_minimize or theme.bg_image_minimize
    local tasklist_disable_icon = args.tasklist_disable_icon or theme.tasklist_disable_icon or false
    local font = args.font or theme.tasklist_font or theme.font or ""
    local bg = nil
    local text = "<span font_desc='"..font.."'>"
    local name = ""
    local bg_image = nil

    -- symbol to use to indicate certain client properties
    local sticky = args.sticky or theme.tasklist_sticky or "▪"
    local ontop = args.ontop or theme.tasklist_ontop or '⌃'
    local floating = args.floating or theme.tasklist_floating or '✈'
    local maximized_horizontal = args.maximized_horizontal or theme.tasklist_maximized_horizontal or '⬌'
    local maximized_vertical = args.maximized_vertical or theme.tasklist_maximized_vertical or '⬍'
    local minimized = args.minimized or theme.minimized or '◎'

    if not theme.tasklist_plain_task_name then
        if c.sticky then name = name .. sticky end
        if c.ontop then name = name .. ontop end
        if awful.client.floating.get(c) then name = name .. floating end
        if c.maximized_horizontal then name = name .. maximized_horizontal end
        if c.maximized_vertical then name = name .. maximized_vertical end
        if c.minimized then name = name .. minimized end
    end

    if c.minimized then
        name = name .. (util.escape(c.icon_name) or util.escape(c.name) or util.escape("<untitled>"))
    else
        name = name .. (util.escape(c.name) or util.escape("<untitled>"))
    end
    if client.focus == c then
        bg = bg_focus
        bg_image = bg_image_focus
        if fg_focus then
            text = text .. "<span color='"..util.color_strip_alpha(fg_focus).."'>"..name.."</span>"
        else
            text = text .. "<span color='"..util.color_strip_alpha(fg_normal).."'>"..name.."</span>"
        end
    elseif c.urgent and fg_urgent then
        bg = bg_urgent
        text = text .. "<span color='"..util.color_strip_alpha(fg_urgent).."'>"..name.."</span>"
        bg_image = bg_image_urgent
    elseif c.minimized and fg_minimize and bg_minimize then
        bg = bg_minimize
        text = text .. "<span color='"..util.color_strip_alpha(fg_minimize).."'>"..name.."</span>"
        bg_image = bg_image_minimize
    else
        bg = bg_normal
        text = text .. "<span color='"..util.color_strip_alpha(fg_normal).."'>"..name.."</span>"
        bg_image = bg_image_normal
    end
    text = text .. "</span>"
    return text, bg, bg_image, not tasklist_disable_icon and c.icon or nil
end

function tasklist_update_function(w, buttons, label, data, clients)
    local function _label(c) return tasklist_label(c, {font = "Terminal' size='large", fg_focus='#fff000', bg_focus='#000000'}) end
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
        local screengeom = screen[mouse.screen].geometry
        local cg = c:geometry()
        if (c.maximized_horizontal and c.maximized_vertical) or
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
            c.maximized_horizontal = false
            c.maximized_vertical = false
            c:geometry(cg)
            awful.placement.centered(c, nil)
        else
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
    end
end
