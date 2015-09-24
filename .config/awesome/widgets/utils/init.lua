
--[[
                                                   
     Licensed under GNU General Public License v2  
      * (c) 2013,      Luke Bonham                 
      * (c) 2010-2012, Peter Hofmann               
                                                   
--]]

local require = require
local awful = require("awful")
local type=type
local pairs=pairs
local error=error
local screen = screen
local string=string
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
