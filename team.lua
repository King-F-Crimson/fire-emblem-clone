team = {}

function team.create(name, color)
    local self = { name = name, color = color }
    setmetatable(self, {__index = team})

    return self
end