local json = require("json")

local unit_class = {
    crimson_demon = {
        sprites = {
            idle = {
                base = love.graphics.newImage("mods/konosuba/assets/megumin_idle.png"),
                color = love.graphics.newImage("assets/blank_sprite.png"),
                animation = json.decode(load_file_as_string("mods/konosuba/assets/megumin_idle.json"))
            },
            run = {
                base = love.graphics.newImage("mods/konosuba/assets/megumin_run.png"),
                color = love.graphics.newImage("assets/blank_sprite.png"),
            }
        },

        name = "Megumin",
        
        max_health = 15,
        strength = 8,
        defense = 5,
        skill = 9,
        speed = 5,
        movement = 5,

        weapon_type = "magic"
    }
}

return unit_class