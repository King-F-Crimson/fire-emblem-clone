special_animation = {}

function special_animation.create(args)
    local self = {}
    setmetatable(self, {__index = special_animation})

    self.x, self.y = args.x, args.y

    self.unit = args.unit
    self.special = args.special
    self.animation = args.special.animation

    self.length = self.animation.total_duration * 60
    
    self.current_frame = 1
    self.complete = false

    return self
end

function special_animation:update()
    self.special.animation:update()

    if self.current_frame > self.length then
        self.complete = true
    else
        self.current_frame = self.current_frame + 1
    end
end

function special_animation:draw()
    local animation = self.animation
    local scale = self.special.sprite_scale
    local x, y = self.x, self.y

    love.graphics.push()
        love.graphics.scale(scale)
        animation:draw(x * tile_size / scale, y * tile_size / scale)
    love.graphics.pop()
end