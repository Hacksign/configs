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

return proportion_resize
