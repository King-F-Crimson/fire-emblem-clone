attack_animation = {
    sound = love.audio.newSource("assets/hit.wav", "static")
}

function attack_animation.create(attacker, tile_x, tile_y)
    local self = {}
    setmetatable(self, {__index = attack_animation})

    self.attacker = attacker
    self.tile_x, self.tile_y = self.attacker.tile_x, self.attacker.tile_y

    -- Hide attacker so it's not drawn.
    self.attacker.hidden = true

    self.distance_tile_x, self.distance_tile_y = tile_x - attacker.tile_x, tile_y - attacker.tile_y

    self.current_frame = 1
    self.complete = false

    return self
end

function attack_animation:exit()
    self.complete = true

    -- Unhide attacker.
    self.attacker.hidden = false
end

function attack_animation:update()
    if self.current_frame == 20 then
        self:exit()
    end

    local displacement_x, displacement_y
    if self.current_frame < 10 then
        displacement_x = self.distance_tile_x * self.current_frame / 20
        displacement_y = self.distance_tile_y * self.current_frame / 20
    else
        displacement_x = self.distance_tile_x * (20 - self.current_frame) / 20
        displacement_y = self.distance_tile_y * (20 - self.current_frame) / 20
    end

    self.tile_x = self.attacker.tile_x + displacement_x
    self.tile_y = self.attacker.tile_y + displacement_y

    if self.current_frame == 10 then
        self.sound:play()
    end

    self.current_frame = self.current_frame + 1
end

function attack_animation:draw()
    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)
        self.attacker:draw("run", self.tile_x * unit_size, self.tile_y * unit_size)
    love.graphics.pop()
end