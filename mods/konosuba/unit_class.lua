local unit_class = {
    crimson_demon = {
        idle_base = love.graphics.newImage("mods/konosuba/assets/megumin_idle.png"),
        run_base = love.graphics.newImage("mods/konosuba/assets/megumin_run.png"),

        idle_color = love.graphics.newImage("assets/blank_sprite.png"),
        run_color = love.graphics.newImage("assets/blank_sprite.png"),

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