
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local awful = require("awful")
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
