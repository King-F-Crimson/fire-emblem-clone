colored_sprite = {
    colorize_shader = love.graphics.newShader("shaders/colorize_shader.fs"),
}

function colored_sprite.create(base_sprite, colored_part, color)
    local width, height = base_sprite:getWidth(), base_sprite:getHeight()
    local colorize_shader = colored_sprite.colorize_shader

    -- Draw to canvas to apply colorize shader.
    local sprite = love.graphics.newCanvas(width, height)
    sprite:setFilter("nearest")

    love.graphics.setColor(255, 255, 255, 255)
    love.graphics.setCanvas(sprite)
        love.graphics.draw(base_sprite)

        colorize_shader:send("tint_color", color:get_color_as_table(1))
        love.graphics.setShader(colorize_shader)
        love.graphics.draw(colored_part, 0, 0)
        love.graphics.setShader()

    love.graphics.setCanvas()

    return sprite
end