local start_m = love.timer.getTime()

local items = require("data/item_data")
local utils = require("modules/utils")
local shaders = require("data/shaders")

local text_engine = {}

text_engine.text = {}
text_engine.font_box = love.graphics.newFont("font/noki.ttf", 8)
text_engine.font_minor = love.graphics.newFont("font/bmmini.ttf", 8)


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

text_engine.iitt_handlers = {
    ["bullet"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, "- ".. str, row, 1, 9)
            row = row + 1
        end
        return row
    end,
    ["lore"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, str, row, 1, 11, 0, 2, {"lore"})
            row = row + 1
        end
        return row
    end,
    ["description"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, str, row, 1, 22, 0, 0, {"lore"})
            row = row + 1
        end
        return row
    end,
    ["name"] = function(box, row, feature_data)
        for _, str in ipairs(feature_data) do
            text_engine.iitt(box, str, row, 1, 22)
            row = row + 1
        end
        return row
    end,
}

text_engine.new_slot = nil

-- takes an item table and populates d_box using iitt()
function text_engine.iitt_item(box, item, slot)
    text = {}
    local new_slot = nil
    local row = 1
    for _, category in ipairs(item.data) do
        local category_name = category[1]
        local category_data = category[2]
        -- slot dependent stats/visuals
        if category_name == items.SLOT_CATEGORIES[category_name] and category_name == slot.mode then
            if slot.uuid ~= stored_slot_uuid then
                print("item has data for ".. slot.mode)
                stored_slot_uuid = slot.uuid
                new_slot = slot.mode
            end
            
            text_engine.iitt(box, items.SLOT_VANITY_NAMES[category_name], row, 1, 6)
            row = row + 1

            for _, feature in ipairs(category_data) do
                local feature_name = feature[1]
                local feature_data = feature[2]

                -- descriptive handle
                if feature_name == items.DESC_CATEGORIES[feature_name] then
                    local handler = text_engine.iitt_handlers[feature_name]
                    if handler then
                        row = handler(box, row, feature_data)
                    end
                
                -- value handle
                elseif feature_name == items.STAT_CATEGORIES[feature_name] then
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
        elseif category_name == items.DESC_CATEGORIES[category_name] then
            local handler = text_engine.iitt_handlers[category_name]
            if handler then
                row = handler(box, row, category_data)
            end

        -- default case
        elseif slot.mode ~= items.SLOT_CATEGORIES[slot.mode] and category_name == "default" then

            for _, feature in ipairs(category_data) do
                local feature_name = feature[1]
                local feature_data = feature[2]

                if feature_name == items.DESC_CATEGORIES[feature_name] then
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
function text_engine.iitt(box, str, row, column, color, x_mod, y_mod, flag)
    -- insert into tooltip

    text[row] = text[row] or {}
    text[row][column] = text[row][column] or {}

    -- determine x value
    if text[row] ~= nil and text[row][column-1] ~= nil then
        x = text[row][column-1][2] + text_engine.font_box:getWidth(text[row][column-1][1])
    else
        x = box.x
    end

    -- determine y value
    if text[row-1] ~= nil and text[row-1][column] ~= nil then
        y = text[row-1][column][3] + text_engine.font_box:getHeight()
    elseif text[row-1] ~= nil then
        y = text[row-1][1][3] + text_engine.font_box:getHeight()
    else
        y = box.y
    end
    
    x = x + (x_mod or 0)
    y = y + (y_mod or 0)
    text[row][column] = {str, x, y, color, flag}
end

local stored_item_uuid = nil
local stored_slot_uuid = nil

function text_engine.fix_box_dims(box)
    -- find the max width of the whole tooltip
    -- set the variable so the render will be correct
    local str = ""
    local max_width = 0
    if text ~= {} then
        for row = 1, #text do
            str = ""
            for column = 1, #text[row] do
                str = str .. text[row][column][1]
            end
            if text_engine.font_box:getWidth(str) > max_width then
                max_width = text_engine.font_box:getWidth(str)
            end
        end
        box.w = max_width
    end

    -- find the max height of the whole tooltip
    -- set the variable so the render will be correct
    if text[#text] ~= nil then
        box.h = text[#text][1][3] + text_engine.font_box:getHeight() - box.y
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
    
    print("w:",text_engine.new_slot)
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

function text_engine.render_box(box)
    local start = love.timer.getTime()
    local shadow_color = utils.colors_DB32[1]
    local box_background_color = {0, 0, 0, 0.65}
    local box_outline_offset = 4.5



    -- render box background
    if box.h ~= nil then
        
        love.graphics.setColor(unpack(box_background_color))
        love.graphics.rectangle('fill', math.floor(box.x) - 4.5, math.floor(box.y) - 4.5, box.w + 8, box.h + 8)
        love.graphics.setShader()
    end


    
    for row = 1, #text do
        local str = ""
        for column = 1, #text[row] do
            local entry = text[row][column]
            local color = utils.colors_DB32[entry[4]]
            
            str = str .. entry[1]
            local x_final = math.floor(entry[2])
            local y_final = math.floor(entry[3])

            local effect = nil
            if entry[5] then
                effect = entry[5][1]
                if effect == "lore" then
                    love.graphics.setFont(text_engine.font_minor)
                end
            end

            -- text shadow
            love.graphics.setColor(love.math.colorFromBytes(shadow_color[1], shadow_color[2], shadow_color[3]))
            love.graphics.print(entry[1], math.floor(x_final+1), math.floor(y_final+1))
            
            -- reset for actual text
            love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3]))
            
            -- apply text effects
            if entry[5] then
                local effect = entry[5][1]
                if effect == "scrolling_rainbow" then
                    love.graphics.setShader(shaders.scrolling_rainbow_shader)
                elseif effect == "displace" then
                    -- {"circle", x, y}
                    x_final = x_final + entry[5][2]
                    y_final = y_final + entry[5][3]
                elseif effect == "circle" then
                    -- {"circle", radius, speed}
                    x_final = x_final + (math.sin(time * entry[5][3]) * entry[5][2])
                    y_final = y_final + (math.sin(time * entry[5][3] + (math.pi / 2)) * entry[5][2])
                elseif effect == "bounce" then
                    -- {"bounce", intensity, speed}
                    y_final = y_final + -math.abs(math.sin(time * entry[5][3]) * entry[5][2])
                end
            end
            
            -- render text
            love.graphics.print(entry[1], math.floor(x_final), math.floor(y_final))
            
            -- reset shader after render
            love.graphics.setShader()
            love.graphics.setFont(text_engine.font_box)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end



    -- render outline box
    if text[#text] ~= nil then
        --love.graphics.setShader(shaders.scrolling_rainbow_shader)
        --love.graphics.setColor(love.math.colorFromBytes(utils.colors_DB32[20][1], utils.colors_DB32[20][2], utils.colors_DB32[20][3]))
        for i = 1, 1 do
            local boof = math.floor(box_outline_offset) * 2
            love.graphics.rectangle('line', math.floor(box.x) - box_outline_offset, math.floor(box.y) - box_outline_offset, box.w + boof, text[#text][1][3] - box.y + text_engine.font_box:getHeight() + boof)
            box_outline_offset = box_outline_offset + 2
        end
    end


    local result = love.timer.getTime() - start
    print(string.format("It took %.3f milliseconds to render that shit", result * 1000))
    
end

local result_m = love.timer.getTime() - start_m
print(string.format("Text Engine loaded in %.3f milliseconds!", result_m * 1000))
return text_engine