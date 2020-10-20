local type=type
local error=error
local pairs=pairs
local string=string
local tostring = tostring
local getmetatable = getmetatable

local function serialize(obj)  
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

return serialize
