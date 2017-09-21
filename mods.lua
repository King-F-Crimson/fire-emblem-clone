mods = {}

function mods.create(game)
    local self = { game = game }
    setmetatable(self, {__index = mods})

    return self
end

function mods:load(name)
    local mod = require(string.format("mods.%s.init", name))

    self[name] = mod
end