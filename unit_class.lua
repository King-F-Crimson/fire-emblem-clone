unit_class = {
    generic_unit = {
        sprite = love.graphics.newImage("assets/template_unit.png"),

        name = "Generic Unit",
        
        health = 10,
        strength = 4,
        speed = 4,
    },

    sword_fighter = {
        sprite = love.graphics.newImage("assets/sword_fighter.png"),

        name = "Sword Fighter",
        
        health = 16,
        strength = 5,
        speed = 10,
    },

    lance_fighter = {
        sprite = love.graphics.newImage("assets/lance_fighter.png"),

        name = "Lance Fighter",
        
        health = 18,
        strength = 7,
        speed = 7,
    },

    axe_fighter = {
        sprite = love.graphics.newImage("assets/axe_fighter.png"),

        name = "Axe Fighter",
        
        health = 20,
        strength = 10,
        speed = 5,
    },
}

-- Apply nearest filter to all
for k, class in pairs(unit_class) do
    class.sprite:setFilter("nearest")
end