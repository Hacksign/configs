local awful = require("awful")

function is_floats(c)
    if c ~= nil then
        local ret = false
        local l = awful.layout.get(c.screen)
        if awful.layout.getname(l) == 'floating' or awful.client.floating.get(c) then
            ret = true
        end
        return ret
    end
end

return is_floats
