local start_m = love.timer.getTime()

local item_utils = require("data/item_utils")
local utils = require("modules/utils")
local shaders = require("data/shaders")

local text_engine = {}

text_engine.show_all_slots = false
text_engine.show_id = true
text_engine.show_designation = true
text_engine.show_rarity = true
text_engine.show_bullets = true

text_engine.game_height = nil
text_engine.game_width = nil

function text_engine.print_table_in_order(tbl, ordered_keys, x, y)
    local posy = y or 0
    local posx = x or 0
    for _, key in ipairs(ordered_keys) do
        love.graphics.print(key, posx, posy)
        love.graphics.print(tostring(tbl[key]), posx + 150, posy)
        posy = posy + 10
    end
end

function text_engine.visual_print(str, x, y)
    love.graphics.print(tostring(str), x, y)
end

function text_engine.set_draw_color(value)
    local color = utils.colors[value]
    love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3]))
end

function text_engine.set_font(value)
    love.graphics.setFont(utils.fonts[value])
end

function text_engine.send_to_shaders()
    shaders.shimmer:send("time", love.timer.getTime() * 2.5)
    shaders.scrolling_rainbow:send("time", love.timer.getTime() * 50)
    shaders.rainbow:send("time", love.timer.getTime() * 100)
    shaders.corrupt:send("time", love.timer.getTime() * 2.5)
    shaders.pulse:send("time", love.timer.getTime())
    shaders.ripple:send("time", love.timer.getTime() * 15)
    shaders.blink:send("time", love.timer.getTime())
end

function text_engine.count_newlines(input)
    if type(input) ~= 'string' then
        return
    end
    local cleaned_string, section_sign_count = input:gsub('§', '')
    return cleaned_string, section_sign_count
end

function text_engine.draw_item_box(item, slot, posx, posy)
    local start = love.timer.getTime()

    local transformation_handlers = {
        ["circle"] = function(x, y, radius, speed, pi_offset)
            x = x + (math.sin(love.timer.getTime() * speed) * radius)
            y = y + (math.sin(love.timer.getTime() * speed + (math.pi / 2 + pi_offset)) * radius)
            return x, y
        end,
        ["bounce"] = function(x, y, intensity, speed)
            x = x
            y = y + -math.abs(math.sin(love.timer.getTime() * speed) * intensity)
            return x, y
        end,
        ["displace"] = function(x, y, dx, dy)
            x = x + dx
            y = y + dy
            return x, y
        end,
        ["random_displace"] = function(x, y, mx, my)
            x = x + math.random(-mx, mx)
            y = y + math.random(-my, my)
            return x, y
        end,
    }

    

    -- init variables

    local master_x = 0
    local master_y = 0

    local offset_x = 0
    local offset_y = 0

    local padding_x = 0
    local padding_y = 0

    function reset_effects()
        text_engine.set_draw_color(22)
        love.graphics.setShader()
        love.graphics.setFont(utils.fonts[1])
    end

    function reset_values()
        offset_x = 0
        offset_y = 0
        padding_y = 0
        padding_x = 0
    end

    local effect_handlers = {
        ["color"] = function(int)
            text_engine.set_draw_color(int)
        end,
        ["color_override"] = function(color)
            local r, g, b, a = love.math.colorFromBytes(color[1], color[2], color[3], color[4])
            love.graphics.setColor(r, g, b, a)
        end,
        ["shader"] = function(shader)
            love.graphics.setShader(shader)
        end,
        ["transformation"] = function()
        end,
        ["font"] = function(int)
            love.graphics.setFont(utils.fonts[int])
        end,
        ["padding_x"] = function(int)
            padding_x = int
        end,
        ["padding_y"] = function(int)
            padding_y = int
        end,
        ["offset_x"] = function(int)
            offset_x = int
        end,
        ["offset_y"] = function(int)
            offset_y = int
        end,
    }

    local item_data = item.data
    
    local slot_mode = "default"
    if item.slot_uuid == slot.uuid then
        slot_mode = slot.mode
    end

    local item_slots = {
        big_slot = false,
        slot = false,
        area = false,
    }

    for _, data in ipairs(item_data) do
        if item_slots[data[1]] ~= nil then
            item_slots[data[1]] = true
        end
    end

    local master_offset = 25

    local item_universal_data = item_data[1][2]

    local origin_x = posx + master_offset
    local origin_y = posy + master_offset
    local last_font_used = love.graphics.getFont()
    local box_width = 0
    local box_height = 0

    local slot_padding_y = 4
    local box_padding = 4
    local text_shadow = true

    local function print_text_shadow(str, x, y)
        local shader = love.graphics.getShader()
        love.graphics.setShader()
        local r, g, b, a = love.graphics.getColor()
        text_engine.set_draw_color(1)
        text_engine.visual_print(str, x, y)
        love.graphics.setColor(r, g, b, a)
        love.graphics.setShader(shader)
    end
    

    local function parse_text_print(key, data)
        if #data % 2 == 1 then
            error("text_effects defined without following string at item_data index " .. index .. ": " .. tostring(base_entry_key))
        end
        local str = ""
        local newline_count = 0
        local accum_padding_y = 0
        local accum_newline_count = 1
        local print_x = math.floor(master_x + offset_x)
        local print_y = math.floor(master_y + offset_y)
        local temp_width = 0
        for i, e in ipairs(data) do
            -- handle this shit on groups 2 at a time
            if i % 2 == 1 then
                local text_effects = data[i]
                str, newline_count = text_engine.count_newlines(data[i + 1])
                local last_str = nil
                if data[i-1] and data[i-1]:find('§') then
                    last_str = data[i-1]
                    local split_string = (last_str:sub(data[i-1]:find('§') + 2))
                    temp_width = last_font_used:getWidth(split_string)
                end
                print_x = math.floor(origin_x + temp_width)

                
                for category, value in pairs(text_effects) do
                    local handler = effect_handlers[category]
                    if handler then
                        handler(value)
                    end
                end

                last_font_used = love.graphics.getFont()
                accum_padding_y = accum_padding_y + padding_y
                accum_newline_count = accum_newline_count + newline_count
                temp_width = temp_width + last_font_used:getWidth(str)

                if text_effects["align"] and text_effects["align"] == "right" then
                    print_x = math.floor(origin_x + box_width - last_font_used:getWidth(str) + offset_x)
                elseif text_effects["align"] and text_effects["align"] == "center" then
                    print_x = math.floor(origin_x + (box_width / 2) - math.floor(last_font_used:getWidth(str) / 2) + offset_x)
                end
                print_x = print_x + offset_x

                -- transformation effects
                local mod_x = print_x
                local mod_y = print_y
                for category, value in pairs(text_effects) do
                    local handler = transformation_handlers[category]
                    if handler then
                        mod_x, mod_y = handler(mod_x, mod_y, value[1], value[2], value[3])
                    end
                end

                if text_shadow then
                    print_text_shadow(str, mod_x + 1, mod_y + 1)
                end
                text_engine.visual_print(str, mod_x, mod_y)
                print_y = print_y + last_font_used:getHeight(".") * newline_count
                
                master_x = master_x + last_font_used:getWidth(str) + padding_x
                reset_effects()
                reset_values()
                print_x = math.floor(master_x)
            end
        end
        --print(master_y, last_font_used:getHeight(str), accum_newline_count, accum_padding_y)
        master_y = master_y + last_font_used:getHeight(str) * (accum_newline_count) + accum_padding_y
        return str
    end

    local function parse_text_dims(key, data)
        if #data % 2 == 1 then
            error("text_effects defined without following string at item_data index " .. index .. ": " .. tostring(base_entry_key))
        end
        local temp_width = 0
        local str = ""
        local newline_count = 0
        local accum_padding_y = 0
        local accum_newline_count = 1
        for i, e in ipairs(data) do
            -- handle this shit on groups 2 at a time
            if i % 2 == 1 then
                -- figure out how to cut off the string at a character
                local text_effects = data[i]
                str, newline_count = text_engine.count_newlines(data[i + 1])
                if data[i-1] and data[i-1]:find('§') then
                    temp_width = 0

                end
                for category, value in pairs(text_effects) do
                    local handler = effect_handlers[category]
                    if handler then
                        handler(value)
                    end
                end
                last_font_used = love.graphics.getFont()
                temp_width = temp_width + last_font_used:getWidth(str) + offset_x + padding_x
                if temp_width > box_width then
                    box_width = temp_width
                end
                accum_padding_y = accum_padding_y + padding_y
                reset_effects()
                accum_newline_count = accum_newline_count + newline_count
                reset_values()

            end
        end
        box_height = box_height + last_font_used:getHeight("hi") * (accum_newline_count) + accum_padding_y + offset_y

        
        reset_effects()
        reset_values()
        last_font_used = utils.fonts[1]
        return str
    end

    local function parse_stat_print(key, data)
        local str = ""
        local stat = data[1]
        local modifier = data[2]
        local value = data[3]
        local abs_value = math.abs(data[3])
        local active_font = love.graphics.getFont()

        last_font_used = love.graphics.getFont()
        

        
        local str_modifier = ""
        local str_value = ""
        local str_percent = ""
        local str_statname = ""
        
        if modifier == "add" or modifier == "percent" then
            if value >= 0 then
                str_modifier = "+"
            else
                str_modifier = "-"
            end
            str = str .. str_modifier
            
        elseif modifier == "multiply" then
            if value >= 0 then
                str_modifier = "x"
            else
                str_modifier = "x -"
            end
            str = str .. str_modifier
        end
        
        -- print value
        str_value = tostring(abs_value)
        str = str .. str_value
        
        
        
        if modifier == "percent" then
            str_percent = "%"
            str = str .. str_percent
            
        end
        
        -- stat name
        str_statname = " " .. utils.parse_descriptive_key(stat)
        str = str .. str_statname
        

        text_engine.set_font(1)

        print_text_shadow(str, math.floor(master_x + offset_x) + 1, math.floor(master_y) + 1)

        text_engine.set_draw_color(22)
        

        -- print everything
        text_engine.visual_print(str_modifier, math.floor(master_x + offset_x), math.floor(master_y))
        master_x = master_x + active_font:getWidth(str_modifier)
        text_engine.set_draw_color(9)
        
        text_engine.visual_print(str_value, math.floor(master_x + offset_x), math.floor(master_y))
        master_x = master_x + active_font:getWidth(str_value)
        text_engine.set_draw_color(22)
        text_engine.visual_print(str_percent, math.floor(master_x + offset_x), math.floor(master_y))
        master_x = master_x + active_font:getWidth(str_percent)
        text_engine.visual_print(str_statname, math.floor(master_x + offset_x), math.floor(master_y))
        master_x = master_x + active_font:getWidth(str_statname)

        local handler = effect_handlers["offset_x"]
        handler(0)
        
        --text_engine.visual_print(str, math.floor(master_x + offset_x), math.floor(master_y))
        reset_effects()
        reset_values()
        master_y = master_y + last_font_used:getHeight("hi")
    end

    local temp = 1

    local function parse_stat_dims(key, data)
        local str = ""
        local stat = data[1]
        local modifier = data[2]
        local value = data[3]
        local active_font = love.graphics.getFont()
        if modifier == "add" and value > 0 then
            str = str .. "+"
        elseif modifier == "percent" and value > 0 then
            str = str .. "+"
        elseif modifier == "multiply" then
            str = str .. "x"
        end
        str = str .. tostring(value)
        if modifier == "percent" then
            str = str .. "%"
        end
        str = str .. " " .. utils.parse_descriptive_key(stat)
        if active_font:getWidth(str) > box_width then
            box_width = active_font:getWidth(str)
        end
        box_height = box_height + last_font_used:getHeight("hi")
    end
    -- *
    -- fix this
    -- make string and find width of string
    local function find_box_dims()
        for index, base_entry in ipairs(item_data) do
            local base_entry_key = base_entry[1]
            local base_entry_data = base_entry[2]
            if base_entry_key == "text" then
                local last_text_str = parse_text_dims(base_entry_key, base_entry_data)
                if index == 2 then
                    if text_engine.show_designation and item_universal_data["designation"] then
                        box_height = box_height + last_font_used:getHeight(".")
                    end
                end
                
            elseif base_entry_key == "stat" then
                parse_stat_dims(base_entry_key, base_entry_data)
            elseif 
                base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and slot_mode == base_entry_key or
                base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and text_engine.show_all_slots 
                then
                last_font_used = utils.fonts[1]
                box_height = box_height + last_font_used:getHeight("hi") + slot_padding_y
                reset_effects()
                reset_values()
                for subindex, entry in ipairs(base_entry_data) do
                    local entry_key = entry[1]
                    local entry_data = entry[2]
                    if entry_key == "text" then
                        parse_text_dims(entry_key, entry_data)
                    elseif entry_key == "stat" then
                        parse_stat_dims(entry_key, entry_data)
                    end
                end
            end
        end
    end


    

    text_engine.send_to_shaders()
    reset_effects()
    find_box_dims()

    -- i don't remember what this does
    if item_data[2][2][2] then
        if type(item_data[2][2][2]) == "number" and box_width < last_font_used:getWidth(item_data[2][2][2]) + 45 + last_font_used:getWidth(item_utils.RARITIES[item_universal_data["rarity"]][1]) then
            box_width = last_font_used:getWidth(item_data[2][2][2]) + 45 + last_font_used:getWidth(item_utils.RARITIES[item_universal_data["rarity"]][1])
        end
    end

    -- fix item name and rarity string from overlapping (also makes space for bullets)
    if item_data[2][2][2] and item_data[1][2]["rarity"] then
        local name_string = item_data[2][2][2]
        local rarity_string = utils.parse_descriptive_key(item_utils.RARITIES[item_data[1][2]["rarity"]][1])
        local end_of_name_string_x = origin_x + last_font_used:getWidth(name_string)
        local begin_of_rarity_string_x = origin_x + box_width - last_font_used:getWidth(rarity_string)
        local difference = (begin_of_rarity_string_x - end_of_name_string_x)
        -- this is fucked up, probably fix this eventually
        if end_of_name_string_x + 25 > begin_of_rarity_string_x then
            box_width = box_width + last_font_used:getWidth(name_string) - (difference)
            begin_of_rarity_string_x = begin_of_rarity_string_x + last_font_used:getWidth(name_string) - (difference)
            difference = (begin_of_rarity_string_x - end_of_name_string_x)
            while difference > 40 do
                box_width = box_width - 1
                begin_of_rarity_string_x = origin_x + box_width - last_font_used:getWidth(rarity_string)
                difference = math.floor(begin_of_rarity_string_x - end_of_name_string_x)
            end
            while difference < 39 do
                box_width = box_width + 1
                begin_of_rarity_string_x = origin_x + box_width - last_font_used:getWidth(rarity_string)
                difference = math.floor(begin_of_rarity_string_x - end_of_name_string_x)
            end
            --love.graphics.rectangle('fill', 450, 450, difference, 1)
        end
    end

    -- display box

    -- coordinate fixes
    if origin_x + box_width > text_engine.game_width then
        origin_x = origin_x - box_width - master_offset * 2
    end

    if origin_y + box_height > text_engine.game_height then
        origin_y = origin_y - box_height - master_offset * 2
    end

    if origin_x - box_padding - 2 < 0 then origin_x = 0 + box_padding + 2 end


    -- effects
    local box_line_effects
    if item_universal_data["box_line_effects"] then
        box_line_effects = item_universal_data["box_line_effects"]
    else
        box_line_effects = {
            color = 22
        }
    end
    local box_back_effects
    if item_universal_data["box_back_effects"] then
        box_back_effects = item_universal_data["box_back_effects"]
    else
        box_back_effects = {
            color = 22,
        }
    end

    local lines_amount = 1

    local temp_box_padding = box_padding

    local color_overridden = false

    for category, value in pairs(box_back_effects) do
        local handler = effect_handlers[category]
        if category == "color_override" then color_overridden = true end
        handler(value)
    end
    local ar, ag, ab, aa = love.graphics.getColor()
    if not color_overridden then
        ar = ar * 0.25
        ag = ag * 0.25
        ab = ab * 0.25
        aa = 0.85
    end
    love.graphics.setColor(ar, ag, ab, aa)
    love.graphics.rectangle(
        'fill', 
        math.floor(origin_x) - 0.5 - box_padding, 
        math.floor(origin_y) - 0.5 - box_padding, 
        math.floor(box_width + (box_padding * 2.5)), 
        math.floor(box_height + (box_padding * 2.5) + 0)
    )
    reset_effects()

    for category, value in pairs(box_line_effects) do
        local handler = effect_handlers[category]
        if handler then
            handler(value)
        end
    end
    
    if box_line_effects["amount"] then
        lines_amount = box_line_effects["amount"]
    end
    for i = 1, lines_amount do
        love.graphics.rectangle(
            'line', 
            math.floor(origin_x) - 0.5 - temp_box_padding, 
            math.floor(origin_y) - 0.5 - temp_box_padding, 
            math.floor(box_width + (temp_box_padding * 2)), 
            math.floor(box_height + (temp_box_padding * 2) + 0)
        )
        temp_box_padding = temp_box_padding + 2
    end
    
    reset_effects()

    
    
    -- print stuff
    master_y = origin_y

    for index, base_entry in ipairs(item_data) do
        master_x = origin_x
        local base_entry_key = base_entry[1]
        local base_entry_data = base_entry[2]

        if base_entry_key == "data" then
            goto continue
        end

        if base_entry_key == "text" then
            local last_text_str = parse_text_print(base_entry_key, base_entry_data)
            if index == 2 then
                -- display item id
                if text_engine.show_id then
                    local id_text = item_universal_data["id"]
                    text_engine.visual_print(id_text, math.floor(origin_x + box_width - last_font_used:getWidth(id_text)), math.floor(origin_y - box_padding - 11))
                end

                master_x = origin_x

                -- display rarity
                local rarity_value = item_universal_data["rarity"]
                local rarity_str = utils.parse_descriptive_key(item_utils.RARITIES[rarity_value][1])
                local rarity_x = math.floor(origin_x + box_width - last_font_used:getWidth(rarity_str))
                if text_engine.show_rarity then
                    print_text_shadow(rarity_str, math.floor(rarity_x + 1), math.floor(origin_y + 1))
                    text_engine.set_draw_color(item_utils.RARITIES[rarity_value][2])
                    if rarity_value == 5 then
                        love.graphics.setShader(shaders.scrolling_rainbow)
                    end
                    text_engine.visual_print(rarity_str, rarity_x, math.floor(origin_y))
                    reset_effects()
                end
                
                
                -- display bullets
                
                if text_engine.show_bullets then
                    local center_x = math.floor(origin_x + math.floor(box_width / 2) - math.floor(last_font_used:getWidth("¤") / 2))
                    local big_slot_mod_x = 0
                    local big_slot_mod_y = 0
                    local slot_mod_x = 0
                    local slot_mod_y = 0
                    local area_mod_x = 0
                    local area_mod_y = 0
                    local separation_value = 8
                    local speed = 15
                    local radius = 1.1
                    if slot.mode == "big_slot" then
                        big_slot_mod_x = (math.sin(love.timer.getTime() * speed) * radius)
                        big_slot_mod_y = (math.sin(love.timer.getTime() * speed + (math.pi / 2)) * radius)
                    elseif slot.mode == "slot" then
                        slot_mod_x = (math.sin(love.timer.getTime() * speed) * 2)
                        slot_mod_y = (math.sin(love.timer.getTime() * speed + (math.pi / 2)) * radius)
                    elseif slot.mode == "area" then
                        area_mod_x = (math.sin(love.timer.getTime() * speed) * 2)
                        area_mod_y = (math.sin(love.timer.getTime() * speed + (math.pi / 2)) * radius)
                    end
                    if box_width / 2 - 18 < last_font_used:getWidth(last_text_str) then
                        
                        center_x =  (origin_x + last_font_used:getWidth(last_text_str)) - (separation_value / 2) + ((rarity_x - (origin_x + last_font_used:getWidth(last_text_str))) / 2)
                    end
                    -- draw shadows
                    if item_slots["area"] then
                        text_engine.set_draw_color(1)
                        text_engine.visual_print("¤", math.floor(center_x - separation_value + area_mod_x + 1), math.floor(origin_y + area_mod_y + 1))
                        text_engine.set_draw_color(19)
                        text_engine.visual_print("¤", math.floor(center_x - separation_value + area_mod_x), math.floor(origin_y + area_mod_y))
                    end
                    if item_slots["slot"] then
                        text_engine.set_draw_color(1)
                        text_engine.visual_print("¤", math.floor(center_x + slot_mod_x + 1), math.floor(origin_y + slot_mod_y + 1))
                        text_engine.set_draw_color(11)
                        text_engine.visual_print("¤", math.floor(center_x + slot_mod_x), math.floor(origin_y + slot_mod_y))
                    end
                    if item_slots["big_slot"] then
                        text_engine.set_draw_color(1)
                        text_engine.visual_print("¤", math.floor(center_x + separation_value + big_slot_mod_x + 1), math.floor(origin_y + big_slot_mod_y + 1))
                        text_engine.set_draw_color(6)
                        text_engine.visual_print("¤", math.floor(center_x + separation_value + big_slot_mod_x), math.floor(origin_y + big_slot_mod_y))
                    end
                end

                -- display designation
                if text_engine.show_designation and item_universal_data["designation"] then
                    --master_y = master_y + last_font_used:getHeight("my balls are FUCKED up")
                    local print_x = master_x
                    local print_y = master_y
                    local designation_string = utils.parse_descriptive_key(item_universal_data["designation"])
                    love.graphics.setShader(shaders.rainbow)
                    text_engine.visual_print("* ", math.floor(print_x), math.floor(print_y))
                    print_x = print_x + last_font_used:getWidth("* ")
                    love.graphics.setShader()
                    text_engine.set_draw_color(9)
                    text_engine.visual_print(designation_string, math.floor(print_x), math.floor(print_y))
                    print_x = print_x + last_font_used:getWidth(designation_string)
                    love.graphics.setShader(shaders.rainbow)
                    text_engine.visual_print(" *", math.floor(print_x), math.floor(print_y))
                    print_x = print_x + last_font_used:getWidth(" *")
                    master_y = master_y + last_font_used:getHeight("we're done here")
                end

            end
            --master_y = master_y + last_font_used:getHeight(str)

        elseif base_entry_key == "stat" then
            parse_stat_print(base_entry_key, base_entry_data, true)

        elseif 
            base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and slot_mode == base_entry_key or
            base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and text_engine.show_all_slots 
            then
            master_y = master_y + slot_padding_y
            local slot_name = item_utils.SLOT_VANITY_NAMES[base_entry_key][1]
            print_text_shadow(slot_name, math.floor(master_x) + 1, math.floor(master_y) + 1)
            text_engine.set_draw_color(item_utils.SLOT_VANITY_NAMES[base_entry_key][2])
            text_engine.visual_print(slot_name, math.floor(master_x), math.floor(master_y))
            last_font_used = love.graphics.getFont()
            master_y = master_y + last_font_used:getHeight(str)

            reset_effects()
            reset_values()

            for subindex, entry in ipairs(base_entry_data) do
                master_x = origin_x
                local entry_key = entry[1]
                local entry_data = entry[2]
                if entry_key == "text" then
                    parse_text_print(entry_key, entry_data)
                elseif entry_key == "stat" then
                    parse_stat_print(entry_key, entry_data)

                end
                
            end
        else
            goto continue
        end
        

        -- reset effects
        reset_effects()
        reset_values()
        ::continue::
    end
    local result = love.timer.getTime() - start
    --print(string.format("It took %.3f milliseconds to render that shit", result * 1000))
end

local result_m = love.timer.getTime() - start_m
print(string.format("Text Engine loaded in %.3f milliseconds!", result_m * 1000))
return text_engine