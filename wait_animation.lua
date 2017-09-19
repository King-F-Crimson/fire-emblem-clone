wait_animation = {}

function wait_animation.create(args)
    local self = {}
    setmetatable(self, {__index = wait_animation})

    self.attacker, self.target = args.attacker, args.target

    self.attacker.hidden, self.target.hidden = true, true

    self.length = args.length
    self.current_frame = 1

    return self
end

function wait_animation:update()
    if self.current_frame == self.length then
        self.complete = true

        self.attacker.hidden, self.target.hidden = false, false
    else
        self.current_frame = self.current_frame + 1
    end
end

function wait_animation:draw()
    local attacker, target = self.attacker, self.target

    love.graphics.push()
        love.graphics.scale(tile_size / unit_size)

        attacker:draw("run", attacker.tile_x * unit_size, attacker.tile_y * unit_size)
        target:draw("run", target.tile_x * unit_size, target.tile_y * unit_size)
    love.graphics.pop()
end