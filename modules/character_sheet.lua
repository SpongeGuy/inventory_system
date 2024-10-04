local utils = require("modules/utils")

local character_sheet = {}

function character_sheet.print_sheet(sheet, posx, posy)
    local x = posx
    local y = posy
    local font = utils.fonts[7]
    love.graphics.setFont(font)
    for _, base_category in ipairs(character_sheet.base) do
        for category, value in pairs(sheet) do
            if base_category == category then
                local c_str = utils.parse_descriptive_key(category)
                love.graphics.print(c_str, x - font:getWidth(c_str) - 4, y)
                love.graphics.print(value, x, y)
                y = y + font:getHeight()
            end
        end
    end
end

character_sheet.base = {
    -- be careful naming new categories because they are also the names visible on item tooltips
    -- all of these stats will be given a base value per character

    -- each category in the items table will have a value that looks like this {"modifier", number}
    -- numbers may be negative or floating point values
    -- modifiers
    -- - add: a flat modifier to the stat. this is calculated first
    -- - percent: a multiplicative modifier to the stat. this is calculated second
    -- - multiply: a multiplicative modifier to the stat. this is calculated last
    -- - - multiply is basically identical to percent, where x2 == +200%.
    -- - - the only thing is that multply modifiers are applied last

    -- this moves the attack damage range up or down depending on its value.
    -- first this will be calculated, then minimum and maximum respectively.
    "attack_damage",

    "minimum_attack_damage",

    "maximum_attack_damage",

    "max_health",

    -- amount of health regenerated per second
    "health_regeneration",

    -- pixels moved per second
    "movement_speed",

    -- damage reduction
    "armor",

    -- amount of times bullets go through enemies.
    "pierce", 

    -- amount of times bullets bounce off of enemies.
    -- if pierce is greater than zero, then start bouncing after all pierces are used up.
    "bounce",

    -- attacks per hundredth of a second
    "attack_speed",

    -- healing amplification multiplier (100 = 100%)
    "healing_power",

    -- critical hit chance multiplier (100 = 100%)
    "critical_hit_chance",

    -- critical hit damage amplification multiplier (100 = 100%)
    "critical_hit_power",

    -- friends (by default) do your base damage times this multiplier (100 = 100%)
    "friend_damage",

    -- if 100%, heal for every point of damage dealt to enemies (100 = 100%)
    -- if over 100, gain a chance to heal double for a single instance of damage.
    -- for example, if lifesteal = 120, 100% to heal, 20% to heal double.
    "lifesteal",

    -- friends down here!
    "lil_gabbron",
    "wizard_sponge",
    "gangster_sponge",
    "ant",
    "bone_buddy",
    "screeming_scamper",
    "duck",
    "jim_blob",
    "bim_blob",
}

character_sheet.carmine_base = {
	attack_damage = 50,
    minimum_attack_damage = 45,
    maximum_attack_damage = 55,
    max_health = 400,
    health_regeneration = 2.5,
    movement_speed = 250,
    armor = 0,
    pierce = 0,
    bounce = 0,
    attack_speed = 75,
    healing_power = 100,
    critical_hit_chance = 0,
    critical_hit_power = 50,
    friend_damage = 100,
    lifesteal = 0,

    lil_gabbron = 0,
    wizard_sponge = 0,
    gangster_sponge = 0,
    ant = 0,
    bone_buddy = 0,
    screeming_scamper = 0,
    duck = 0
}

character_sheet.carmine = {
	attack_damage = 50,
    minimum_attack_damage = 45,
    maximum_attack_damage = 55,
    max_health = 400,
    health_regeneration = 2.5,
    movement_speed = 250,
    armor = 0,
    pierce = 0,
    bounce = 0,
    attack_speed = 75,
    healing_power = 100,
    critical_hit_chance = 0,
    critical_hit_power = 50,
    friend_damage = 100,
    lifesteal = 0,

    lil_gabbron = 0,
    wizard_sponge = 0,
    gangster_sponge = 0,
    ant = 0,
    bone_buddy = 0,
    screeming_scamper = 0,
    duck = 0
}

return character_sheet