local anim8 = require("libs/anim8/anim8")

animated_sprite = {}

function animated_sprite.create(arg)
    local self = {}
    setmetatable(self, {__index = animated_sprite})

    self.image = arg.image
    local image_width, image_height = self.image:getWidth(), self.image:getHeight()

    self:construct_grid(arg.frame_width, arg.frame_height, image_width, image_height, arg.left, arg.top, arg.border)

    self.animation = anim8.newAnimation(self.grid('1-' .. tostring(self.row_count), 1), arg.durations)

    return self
end

function animated_sprite:construct_grid(frame_width, frame_height, image_width, image_height, left, top, border)
    local frame_height = frame_height or image_height

    -- Last three arguments can be nil and default to zero.
    self.grid = anim8.newGrid(frame_width, frame_height, image_width, image_height, left, top, border)

    self.row_count = image_width / frame_width
    print(image_width, frame_width)
    self.column_count = image_height / frame_height
end

function animated_sprite:draw(x, y)
    self.animation:draw(self.image, x, y)
end

function animated_sprite:update()
    -- Updates the animation by one frame.
    self.animation:update(1)
end