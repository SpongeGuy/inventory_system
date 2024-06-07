local start_m = love.timer.getTime()

local item_utils = require("data/item_utils")
local utils = require("modules/utils")
local shaders = require("data/shaders")

local text_engine = {}

text_engine.showall = false
text_engine.debug_id = false
text_engine.designation_goggles = true

text_engine.text = {}
local active_font = utils.fonts[1]

function has_content(tbl)
    for _, value in pairs(tbl) do
        if value ~= nil then return true end
    end
    return false
end

function text_engine.initialize_box_data(game_width, game_height)
    box_x_offset = 25
    box_y_offset = 25
    window_w = game_width
    window_h = game_height
end

function text_engine.update_box_coords(x, y)
    box_x = x
    box_y = y
end

function text_engine.initialize_alternate_fps(fps)
    frame_counter = 0
    last_call_frame = 0
    target_fps = fps
    frame_interval_in_secs = 1 / target_fps
    elapsed_time_since_last_call = 0
end

function text_engine.update_at_30(dt)
    frame_counter = frame_counter + 1
    elapsed_time_since_last_call = frame_counter * dt
    if elapsed_time_since_last_call >= frame_interval_in_secs then
        -- functions here
        update_box(dt)
        frame_counter = 0
        last_call_frame = frame_counter
    end
end

-- this shit is fucking retarded god damn

text_engine.iitt_handlers = {
    ["bullet"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, "- ".. str, row, 1, 9)
            row = row + 1
        end
        return row
    end,
    ["lore"] = function(box, row, feature_data, other_data)
        for _, str in ipairs(feature_data) do
            love.graphics.setFont(utils.fonts[2])
            text_engine.iitt(box, str, row, 1, 30, 0, 2, {text_font = 2})
            row = row + 1
        end
        return row
    end,
    ["description"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            love.graphics.setFont(utils.fonts[2])
            text_engine.iitt(box, str, row, 1, 22, 0, 0, {text_font = 2})
            row = row + 1
        end
        return row
    end,
    ["name"] = function(box, row, feature_data, other_data, content_check, slot_check)
        local column = 2
        local name_color = 22
        local effect_override = other_data.effect_override or {}
        if other_data.rarity then
            name_color = item_utils.RARITY_COLORS[other_data.rarity]
            if other_data.rarity == "ultimate" and not effect_override["text_shader"] then 
                effect_override["text_shader"] = "scrolling_rainbow"
            end
        end
        if not effect_override["text_shader"] then
            effect_override["text_shader"] = "shimmer"
        end
        
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, str .. " ", row, 1, name_color, 0, 0, effect_override)
        end

        -- display markers showing if an item has an effect in a specific slot
        -- it spins around when the item is inside a specific slot
        if content_check.big_slot then 
            if slot_check.big_slot then
                text_engine.iitt(box, "¤", row, column, 6, 2, 0, {text_coordinate_transformation = {"circle", 0.2, 24}})
            else
                text_engine.iitt(box, "¤", row, column, 6, 1, 0)
            end
            column = column + 1
        end
        if content_check.slot then 
            if slot_check.slot then
                text_engine.iitt(box, "¤", row, column, 11, 2, 0, {text_coordinate_transformation = {"circle", 0.2, 24}})
            else
                text_engine.iitt(box, "¤", row, column, 11, 1, 0)
            end
            column = column + 1
        end
        if content_check.area then 
            if slot_check.area then
                text_engine.iitt(box, "¤", row, column, 19, 2, 0, {text_coordinate_transformation = {"circle", 0.2, 24}})
            else
                text_engine.iitt(box, "¤", row, column, 19, 1, 0)
            end
            column = column + 1
        end

        if text_engine.debug_id then
            text_engine.iitt(box, " ".. tostring(other_data.id), row, column, 18)
        end
        row = row + 1

        if text_engine.designation_goggles and other_data.designation then
            text_engine.iitt(box, "* ", row, 1, 9, 0, 0, {text_shader = "rainbow"})
            text_engine.iitt(box, utils.parse_descriptive_key(other_data.designation), row, 2, 22)
            text_engine.iitt(box, " *", row, 3, 9, 0, 0, {text_shader = "rainbow"})
            row = row + 1
        end
        return row
    end,
}

-- if other_data.effect_override then
--             name_color = other_data.effect_override.name_color
--             name_shader = other_data.effect_override.name_shader
--         else

text_engine.new_slot = nil

-- takes an item table and populates d_box using iitt()
function text_engine.iitt_item(box, item, slot)
    -- figure out if big_slot, slot, or area tables in item.data exist
    -- this will be relevant when iitting the item's name
    local content_check = {
        big_slot = false,
        slot = false,
        area = false,
    }
    local slot_check = {
        big_slot = false,
        slot = false,
        area = false,
    }
    for _, value in ipairs(item.data) do
        if value[1] == item_utils.SLOT_CATEGORIES[value[1]] then
            content_check[value[1]] = true
        end
    end

    item_universal_data = item.data[1][2]

    if slot.mode then
        slot_check[slot.mode] = true
    end

    -- engage the fuckening
    text = {}
    local new_slot = nil
    local row = 1
    for _, category in ipairs(item.data) do
        local category_name = category[1]
        local category_data = category[2]

        -- slot dependent stats/visuals
        
        active_font = utils.fonts[1]

        if 
            (category_name == item_utils.SLOT_CATEGORIES[category_name] and category_name == slot.mode) or 
            (category_name == item_utils.SLOT_CATEGORIES[category_name] and (slot.mode == "showoff" or text_engine.showall == true)) 
            then

            
            -- store the active slot's information here!
            if slot.uuid ~= stored_slot_uuid then
                stored_slot_uuid = slot.uuid
                new_slot = slot.mode
            end

            
            text_engine.iitt(box, item_utils.SLOT_VANITY_NAMES[category_name][1], row, 1, item_utils.SLOT_VANITY_NAMES[category_name][2], 0, 4)
            row = row + 1

            for _, feature in ipairs(category_data) do
                local feature_name = feature[1]
                local feature_data = feature[2]

                -- descriptive handle
                if feature_name == item_utils.DESC_CATEGORIES[feature_name] then
                    local handler = text_engine.iitt_handlers[feature_name]
                    if handler then
                        row = handler(box, row, feature_data, item_universal_data, content_check)
                    end
                
                -- value handle
                elseif feature_name == item_utils.STAT_CATEGORIES[feature_name] then
                    local modifier = feature_data[1]
                    local value = feature_data[2]
                    local val_str = tostring(value)
                    local mod_str = ""
                    if value >= 0 and modifier ~= "multiply" then 
                        val_str = tostring("+"..value) 
                    elseif modifier == "multiply" then
                        val_str = tostring("x"..value)
                    end
                    if modifier == "percent" then
                        mod_str = "%"
                    end
                    text_engine.iitt(box, val_str..mod_str .. " " .. utils.parse_descriptive_key(feature_name), row, 1, 22)
                    row = row + 1
                end
            end

        -- these are displayed all the time no matter which slot
        elseif category_name == item_utils.DESC_CATEGORIES[category_name] then
            local handler = text_engine.iitt_handlers[category_name]
            if handler then
                row = handler(box, row, category_data, item_universal_data, content_check, slot_check)
            end

        -- default case
        elseif slot.mode ~= item_utils.SLOT_CATEGORIES[slot.mode] and category_name == "default" then

            for _, feature in ipairs(category_data) do
                local feature_name = feature[1]
                local feature_data = feature[2]

                if feature_name == item_utils.DESC_CATEGORIES[feature_name] then
                    local handler = text_engine.iitt_handlers[feature_name]
                    if handler then
                        row = handler(box, row, feature_data)
                    end
                end
            end
        end
    end
    print()
    return new_slot
end

-- takes string and some location data
-- returns table containing the string and its x,y coordinates
-- flag is for setting a modifier to the text, like a shader or effect
function text_engine.iitt(box, str, row, column, color, x_mod, y_mod, effect_override)
    -- insert into tooltip

    text[row] = text[row] or {}
    text[row][column] = text[row][column] or {}

    -- determine x value
    if text[row] ~= nil and text[row][column-1] ~= nil then
        x = text[row][column-1][2] + active_font:getWidth(text[row][column-1][1])
    else
        x = box.x
    end

    -- determine y value
    if text[row-1] ~= nil and text[row-1][column] ~= nil then
        y = text[row-1][column][3] + active_font:getHeight()
    elseif text[row-1] ~= nil then
        y = text[row-1][1][3] + active_font:getHeight()
    else
        y = box.y
    end
    
    x = x + (x_mod or 0)
    y = y + (y_mod or 0)
    text[row][column] = {str, x, y, color, effect_override, x_mod, y_mod}
end

local stored_item_uuid = nil
local stored_slot_uuid = nil

function text_engine.fix_box_dims(box)
    -- find the max width of the whole tooltip
    -- set the variable so the render will be correct
    local str = ""
    local max_width = 0
    local x_mod = 0 -- handle box width if text has an x_mod value

    if text ~= {} then
        for row = 1, #text do
            local proper_font = utils.fonts[1]
            str = ""
            for column = 1, #text[row] do
                str = str .. text[row][column][1]
                if text[row][column][6] then
                    x_mod = x_mod + text[row][column][6]
                end

                -- if there are different fonts in the same text box, then you don't want
                -- the box to be wider than it needs to be.,,, you nincompooper
                if text[row][column][5] and text[row][column][5]["text_font"] then
                    proper_font = utils.fonts[text[row][column][5]["text_font"]]
                end
                -- it's all balanced and things
            end
            if active_font:getWidth(str) > max_width then
                if x_mod ~= 0 then
                    max_width = proper_font:getWidth(str) + (x_mod)
                else
                    max_width = proper_font:getWidth(str)
                end
            end
            -- print(str)

            
            -- print((box.x + utils.fonts[1]:getWidth(str)) - box.x)
            -- print((box.x + utils.fonts[2]:getWidth(str)) - box.x)
        end

        box.w = max_width
    end

    -- find the max height of the whole tooltip
    -- set the variable so the render will be correct
    if text[#text] ~= nil then
        box.h = text[#text][1][3] + active_font:getHeight() - box.y
    end
end

function text_engine.update_box(box, item, slot, x, y)
    local start = love.timer.getTime()
    local data = item.data
    local mode = slot.mode or "default"
    text_engine.new_slot = nil
    
    box.x = x + box_x_offset
    box.y = y + box_y_offset
    
    
    box.text = {}
    

    -- hold the box in place if it goes out of bounds in y direction
    -- im so fuckgin dumb here
    if box.y < 0 then
        box.y = 8
    end
    if box.y + box.h > window_h then
        box.y = window_h - box.h - 8
    end

    if item.uuid ~= stored_item_uuid or slot.uuid ~= stored_slot_uuid then
        box.w = 0
        box.h = 0
        text_engine.new_slot = text_engine.iitt_item(box, item, slot)
        text_engine.fix_box_dims(box)

        stored_item_uuid = item.uuid
        stored_slot_uuid = slot.uuid
    end
    
    -- reposition box if it goes out of bounds
    if box.x + box.w > window_w then
        box.x = box.x - box.w - (box_x_offset * 2)
    end
    if box.y + box.h > window_h + 50 then
        box.y = box.y - box.h - (box_y_offset * 2)
    end

    text_engine.iitt_item(box, item, slot)
    text_engine.fix_box_dims(box)
    
    -- TODO:
    -- add image support, which means ill have to find out a way to detect if it's an image
    -- - and also get the height and width of the image in pixels when needed

    -- make a tool for making item json text
    -- somehow incorporate color codes and shader codes
    local result = love.timer.getTime() - start
    print(string.format("It took %.3f milliseconds to do that shit", result * 1000))
end

text_engine.coordinate_transformation_handlers = {
    ["circle"] = function(x, y, radius, speed)
        x = x + (math.sin(love.timer.getTime() * speed) * radius)
        y = y + (math.sin(love.timer.getTime() * speed + (math.pi / 2)) * radius)
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
}

text_engine.shader_handlers = {
    ["rainbow"] = function()
        shaders.rainbow:send("time", love.timer.getTime() * 100)
        return shaders.rainbow
    end,
    ["scrolling_rainbow"] = function()
        shaders.scrolling_rainbow:send("time", love.timer.getTime() * 50)
        return shaders.scrolling_rainbow
    end,
    ["shimmer"] = function()
        shaders.shimmer:send("time", love.timer.getTime() * 2.5)
        return shaders.shimmer
    end,
}

function text_engine.render_box(box)
    local start = love.timer.getTime()
    local shadow_color = utils.colors[1]
    local box_background_color = {0, 0, 0, 0.65}
    local box_outline_offset = 4.5
    local effect_override = nil

    -- render box background
    if box.h ~= nil then
        
        love.graphics.setColor(unpack(box_background_color))
        love.graphics.rectangle('fill', math.floor(box.x) - 4.5, math.floor(box.y) - 4.5, box.w + 8, box.h + 8)
        love.graphics.setShader()
    end


    -- render the text
    for row = 1, #text do
        local str = ""
        for column = 1, #text[row] do
            local entry = text[row][column]
            local color = utils.colors[entry[4]]
            
            str = str .. entry[1]
            local x_final = math.floor(entry[2])
            local y_final = math.floor(entry[3])

            effect_override = nil

            -- get effect_override if possible
            -- this will control fucking a lot of shit, including text font, color, shader and box graphics as well
            active_font = utils.fonts[1]

            if entry[5] then
                effect_override = entry[5]
                if effect_override.text_font then
                    active_font = utils.fonts[effect_override.text_font]
                end
            end
            
            love.graphics.setFont(active_font)

            -- storage for shader effect
            local final_text_effect = nil
            -- switch on if shader does not chance colors
            local shader_transform = false

            -- each item can have an effect_override table, which applies to its name and box
            if effect_override then
                -- great reading here fuckin hell
                local coordinate_transformation_handler = nil
                if effect_override["text_coordinate_transformation"] then
                    coordinate_transformation_handler = text_engine.coordinate_transformation_handlers[effect_override["text_coordinate_transformation"][1]]
                end
                local color_override = effect_override["text_color"]
                local font_override = effect_override["text_font"]


                if coordinate_transformation_handler then
                    x_final, y_final = coordinate_transformation_handler(x_final, y_final, effect_override.text_coordinate_transformation[2], effect_override.text_coordinate_transformation[3])
                end

                if color_override then
                    color = utils.colors[color_override]
                end

                if font_override then
                    active_font = utils.fonts[font_override]
                end
            end

            -- make shadow follow text shader
            if shader_transform then
                love.graphics.setShader(final_text_effect)
            end

            -- text shadow
            love.graphics.setColor(love.math.colorFromBytes(shadow_color[1], shadow_color[2], shadow_color[3]))
            love.graphics.print(entry[1], math.floor(x_final+1), math.floor(y_final+1))

            -- reset for actual text
            love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3]))
            love.graphics.setFont(active_font)

            if effect_override then
                local shader_handler = text_engine.shader_handlers[effect_override["text_shader"]]
                if shader_handler then
                    love.graphics.setShader(shader_handler())
                end
            end
            
            -- render text
            love.graphics.print(entry[1], math.floor(x_final), math.floor(y_final))
            
            -- reset shader after render
            love.graphics.setShader()
            love.graphics.setColor(1, 1, 1, 1)
            -- set font to default font
        end
    end



    -- render outline box
    if text[#text] ~= nil then
        love.graphics.setShader(final_text_effect)

        -- effects here

        if effect_override then
            -- local coordinate_transformation_handler = nil
            -- if effect_override["box_coordinate_transformation"] then
            --     coordinate_transformation_handler = text_engine.coordinate_transformation_handlers[effect_override["box_coordinate_transformation"][1]]
            -- end
            -- local color_override = effect_override["box_color"]


            -- if coordinate_transformation_handler then
            --     x_final, y_final = coordinate_transformation_handler(x_final, y_final, effect_override["box_coordinate_transformation"][2], effect_override["box_coordinate_transformation"][3])
            -- end

            -- if color_override then
            --     color = utils.colors[color_override]
            -- end

            -- if font_override then
            --     active_font = utils.fonts[font_override]
            -- end

            -- local shader_handler = text_engine.shader_handlers[effect_override["box_shader"]]
            -- if shader_handler then
            --     love.graphics.setShader(shader_handler())
            -- end
        end

        for i = 1, 1 do
            local offset = math.floor(box_outline_offset) * 2
            love.graphics.rectangle('line', math.floor(box.x) - box_outline_offset, math.floor(box.y) - box_outline_offset, box.w + offset, text[#text][1][3] - box.y + active_font:getHeight() + offset)
            box_outline_offset = box_outline_offset + 2
        end
        love.graphics.setShader()
        love.graphics.setColor(1, 1, 1, 1)
    end


    local result = love.timer.getTime() - start
    print(string.format("It took %.3f milliseconds to render that shit", result * 1000))
    
end

local result_m = love.timer.getTime() - start_m
print(string.format("Text Engine loaded in %.3f milliseconds!", result_m * 1000))
return text_engine