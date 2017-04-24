require("utility")
require("unit_class")

unit = {
    base_sprite = love.graphics.newImage("assets/template_unit.png"),
    colored_part = love.graphics.newImage("assets/template_unit_color.png"),
    colorize_shader = love.graphics.newShader("colorize_shader.fs"),
}

unit.base_sprite:setFilter("nearest")

function unit.create(class, tile_x, tile_y, data)
    local self = deepcopy(class)

    self.tile_x = tile_x
    self.tile_y = tile_y

    -- Copy extra data (weapon, starting HP, etc) if exist.
    if data then
        self.data = deepcopy(data)
    else
        self.data = {}
    end

    -- If health is not already specified then set health to max_health.
    if not self.data.health then
        self.data.health = self.max_health
    end
    
    setmetatable(self, { __index = unit })

    self:generate_sprite()

    -- Create the filter functions.
    function self.terrain_filter(terrain)
        local terrain_cost = {
            plain = 1,
            water = "impassable",
            sand = 2,
            wall = "impassable",
        }

        return terrain_cost[terrain] or "impassable"
    end

    function self.unit_filter(unit)
        if unit.data.team ~= self.data.team then
            return "impassable"
        end
    end

    return self
end

function unit:draw()
    -- Unit will be hidden during animation.
    if not self.hidden then
        love.graphics.draw(self.sprite, self.tile_x * tile_size, self.tile_y * tile_size)
        love.graphics.print(self.data.health, self.tile_x * tile_size, (self.tile_y - 1) * tile_size)
    end
end

-- Get team colorized sprite.
function unit:generate_sprite()
    -- Draw to canvas to apply colorize shader.
    self.sprite = love.graphics.newCanvas()
    self.sprite:setFilter("nearest")

    love.graphics.setCanvas(self.sprite)
        -- Draw the normal sprite.
        love.graphics.draw(self.base_sprite)

        -- Draw team-colorized part using shader.
        self.colorize_shader:send("tint_color", self:get_team_color())
        love.graphics.setShader(self.colorize_shader)
        love.graphics.draw(self.colored_part, 0, 0)
        love.graphics.setShader()

    love.graphics.setCanvas()
end

function unit:get_team_color()
    local team_color = {
        player = {0, 0, 255},
        enemy = {255, 0, 0},
        ally = {0, 255, 0},
    }

    return team_color[self.data.team]
end

function unit:move(tile_x, tile_y)
    self.tile_x, self.tile_y = tile_x, tile_y
end