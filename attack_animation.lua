attack_animation = {
    hit_sound = love.audio.newSource("assets/hit.wav", "static"),
    miss_sound = love.audio.newSource("assets/miss.wav", "static"),
    crit_sound = love.audio.newSource("assets/ability_activate.ogg", "static")
}

function attack_animation.create(args)
    local self = {}
    setmetatable(self, {__index = attack_animation})

    self.attacker = args.attacker
    self.target = args.target

    -- Attacker's temporary position in animation.
    self.tile_x, self.tile_y = self.attacker.tile_x, self.attacker.tile_y

    -- Hide attacker and target so it's not drawn in world:draw("units").
    self.attacker.hidden = true
    self.target.hidden = true

    self.distance_tile_x, self.distance_tile_y = self.target.tile_x - self.attacker.tile_x, self.target.tile_y - self.attacker.tile_y

    self.miss = args.miss

    if self.miss then
        self.text = "MUDA DA!"
    else
        self.text = tostring(args.damage)
    end

    self.current_frame = 1
    self.complete = false

    return self
end

function attack_animation:exit()
    self.complete = true

    -- Unhide attacker and target.
    self.attacker.hidden = false
    self.target.hidden = false
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
        if self.miss then
            self.miss_sound:play()
        else
            self.hit_sound:play()
        end
    end

    if self.current_frame >= 4 then
        self.text_visible = true
    else
        self.text_visible = false
    end

    self.current_frame = self.current_frame + 1
end

function attack_animation:draw()
    local attacker, target = self.attacker, self.target

    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)
        attacker:draw("run", self.tile_x * unit_size, self.tile_y * unit_size)
        target:draw("run", target.tile_x * unit_size, target.tile_y * unit_size)
        if self.text_visible then
            love.graphics.print(self.text, target.tile_x * unit_size, (target.tile_y - 1) * unit_size)
        end
    love.graphics.pop()
end