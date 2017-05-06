require("unit_info")
require("minimap")
require("combat_info")

hud = {}

function hud.create(ui)
    local self = { ui = ui, observer = ui.observer }
    setmetatable(self, {__index = hud})

    self.unit_info = unit_info.create(self.observer, self.ui, 20, 0)
    self.minimap = minimap.create(self.observer, self.ui, 20, 200)
    self.combat_info = combat_info.create(self.observer, self.ui, 20, 400)

    return self
end

function hud:draw()
    self.unit_info:draw()
    self.minimap:draw()
    self.combat_info:draw()
end