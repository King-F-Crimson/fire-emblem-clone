unit_class = {
    generic_unit = {
        base_sprite = love.graphics.newImage("assets/template_unit.png"),

        name = "Generic Unit",
        
        max_health = 10,
        strength = 4,
        speed = 4,
        movement = 5,
    },

    sword_fighter = {
        idle_base = love.graphics.newImage("assets/sword_fighter_idle.png"),
        run_base = love.graphics.newImage("assets/sword_fighter_run.png"),

        name = "Sword Fighter",
        
        max_health = 16,
        strength = 5,
        speed = 10,
        movement = 5,

        weapon_type = "sword"
    },

    lance_fighter = {
        idle_base = love.graphics.newImage("assets/lance_fighter_idle.png"),
        run_base = love.graphics.newImage("assets/lance_fighter_run.png"),

        name = "Lance Fighter",
        
        max_health = 18,
        strength = 7,
        speed = 7,
        movement = 5,

        weapon_type = "lance"
    },

    axe_fighter = {
        idle_base = love.graphics.newImage("assets/axe_fighter_idle.png"),
        run_base = love.graphics.newImage("assets/axe_fighter_run.png"),

        name = "Axe Fighter",
        
        max_health = 20,
        strength = 10,
        speed = 5,
        movement = 5,

        weapon_type = "axe"
    },

    bow_fighter = {
        idle_base = love.graphics.newImage("assets/bow_fighter_idle.png"),
        run_base = love.graphics.newImage("assets/bow_fighter_run.png"),

        name = "Bow Fighter",
        
        max_health = 15,
        strength = 8,
        speed = 5,
        movement = 5,

        weapon_type = "bow"
    }
}