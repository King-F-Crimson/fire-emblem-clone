team = {}

function team.create(name, color, controller)
    local self = { name = name, color = color, controller = controller }
    setmetatable(self, {__index = team})

    return self
end

