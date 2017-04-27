camera = {}

function camera.create(ui)
    local self = { ui = ui }
    setmetatable(self, {__index = camera})

    self.zoom = 2
    self.min_zoom = 1
    self.max_zoom = 8
    self.mouse_scroll_for_zoom = 2

    self.translate = { x = 0, y = 0 }
    self.manual_center = { x = 0, y = 0 }
    self.translate_mode = "center_cursor"

    self.manual_move_threshold = 1/10 * love.graphics.getWidth()
    self.manual_movement_base_speed = 5

    self.screen_center_x = love.graphics.getWidth() / 2 / zoom
    self.screen_center_y = love.graphics.getHeight() / 2 / zoom

    return self
end

function camera:update()
    if self.translate_mode == "manual" then
        self:move_manual_center_with_mouse()
    end
end

function camera:move_manual_center_with_mouse()
    local x, y = love.mouse.getPosition()
    local screen_width, screen_height = love.graphics.getWidth(), love.graphics.getHeight()
    local threshold = self.manual_move_threshold
    local speed = self.manual_movement_base_speed

    local translate_movement = { x = 0, y = 0 }

    if x < threshold then
        translate_movement.x = (x - threshold) / threshold * speed
    elseif x > screen_width - threshold then
        translate_movement.x = (x - (screen_width - threshold)) / threshold * speed
    end

    if y < threshold then
        translate_movement.y = (y - threshold) / threshold * speed
    elseif y > screen_height - threshold then
        translate_movement.y = (y - (screen_height - threshold)) / threshold * speed
    end

    self.manual_center.x = self.manual_center.x + translate_movement.x
    self.manual_center.y = self.manual_center.y + translate_movement.y
end

function camera:control(event)
    -- Change translate mode according to how the player moves the cursor.
    if event.type == "key_pressed" then
        self.translate_mode = "center_cursor"
    elseif event.type == "mouse_pressed" then
        -- Set manual_center object to last center_object.
        self.manual_center = { x = self.center_object.x, y =self.center_object.y }
        self.translate_mode = "manual"
    -- Use mouse wheel to zoom
    elseif event.type == "mouse_wheel_moved" then
        self:zoom_using_mouse_wheel(event.data.x, event.data.y)
    end
end

function camera:get_tile_from_coordinate(x, y)
    local translated_x, translated_y = (x / zoom - self.translate.x) / self.zoom, (y / zoom - self.translate.y) / self.zoom
    local tile_x, tile_y = math.floor(translated_x / tile_size), math.floor(translated_y / tile_size)

    return tile_x, tile_y
end

function camera:set_translate()
    if self.translate_mode == "center_cursor" then
        self:set_translate_center_to_cursor()
    elseif self.translate_mode == "manual" then
        self:set_translate_center_manually()
    end

    self.translate = { x = self.screen_center_x - self.center_object.x * self.zoom,
                       y = self.screen_center_y - self.center_object.y * self.zoom }

    love.graphics.translate(self.translate.x, self.translate.y)
end

function camera:set_zoom()
    love.graphics.scale(self.zoom)
end

function camera:zoom_using_mouse_wheel(x, y)
    if y > self.mouse_scroll_for_zoom and self.zoom < self.max_zoom then
        self.zoom = self.zoom + 1
    elseif y < -self.mouse_scroll_for_zoom and self.zoom > self.min_zoom then
        self.zoom = self.zoom - 1
    end
end

function camera:set_translate_center_to_cursor()
    local cursor_x, cursor_y = self.ui.cursor:get_position()
    local cursor_center_x, cursor_center_y = (cursor_x + (tile_size / 2)), (cursor_y + (tile_size / 2))

    self.center_object = { x = cursor_center_x, y = cursor_center_y }
end

function camera:set_translate_center_manually()
    self.center_object = { x = self.manual_center.x, y = self.manual_center.y }
end