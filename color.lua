color = {}

-- Colors are stored in 0-255 number value.
function color.create_from_rgb(r, g, b, a)
    local self = { r = r, g = g, b = b, a = a or 255 }
    setmetatable(self, {__index = color})

    return self
end

function color.create_from_hsl(h, s, l, a)
    local r, g, b, a = color.hsl_to_rgb(h, s, l, a)
    local rgb_color = color.create_from_rgb(r, g, b, a)

    return rgb_color
end

-- Converts HSL to RGB. (input and output range: 0 - 255)
function color.hsl_to_rgb(h, s, l, a)
    if s<=0 then return l,l,l,a end
    h, s, l = h/256*6, s/255, l/255
    local c = (1-math.abs(2*l-1))*s
    local x = (1-math.abs(h%2-1))*c
    local m,r,g,b = (l-.5*c), 0,0,0
    if h < 1     then r,g,b = c,x,0
    elseif h < 2 then r,g,b = x,c,0
    elseif h < 3 then r,g,b = 0,c,x
    elseif h < 4 then r,g,b = 0,x,c
    elseif h < 5 then r,g,b = x,0,c
    else              r,g,b = c,0,x
    end return (r+m)*255,(g+m)*255,(b+m)*255,a
end

function color:get_color_as_table(scale_max)
    local scale_max = scale_max or 255

    local r, g, b, a = self.r * scale_max / 255, self.g * scale_max / 255, self.b * scale_max / 255, self.a * scale_max / 255

    return { r, g, b, a }
end