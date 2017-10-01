require("map_info")
require("unit_info")
require("minimap")
require("combat_info")

hud = {}

function hud.create(ui)
    local self = { ui = ui, observer = ui.observer }
    setmetatable(self, {__index = hud})

    self.map_info = map_info.create(self.observer, self.ui, 20, 20)
    self.unit_info = unit_info.create(self.observer, self.ui, 20, 60)
    self.minimap = minimap.create(self.observer, self.ui, 20, 280)
    self.combat_info = combat_info.create(self.observer, self.ui, 20, 400)

    return self
end

function hud:destroy()
    self.map_info:destroy()
    self.unit_info:destroy()
    self.minimap:destroy()
    self.combat_info:destroy()
end

function hud:draw()
    self.map_info:draw()
    self.unit_info:draw()
    self.minimap:draw()
    self.combat_info:draw()
end