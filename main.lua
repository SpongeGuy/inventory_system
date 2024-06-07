require 'modules/error_explorer'
local anim8 = require ('modules/anim8')
local push = require ('modules/push')
local items = require("data/items")
local item_utils = require("data/item_utils")
local utils = require("modules/utils")
local shaders = require("data/shaders")
local text_engine = require("modules/text_engine")
love.graphics.setNewFont("font/nokiafc22.ttf", 8)

-- global variables
love.graphics.setDefaultFilter("nearest", "nearest")

local window_width, window_height = love.window.getDesktopDimensions()
local game_width, game_height = 960, 540
local window_scale = window_width/game_width
push:setupScreen(game_width, game_height, window_width, window_height, {windowed = true})


-- parameters
local designation_goggles = false
local debug_id_see = true


local base_character_sheet = {
	attack_damage = 50,
    minimum_attack_damage = 45,
    maximum_attack_damage = 55,
    max_health = 400,
    health_regeneration = 2.5,
    movement_speed = 250,
    pierce = 0,
    bounce = 0,
    attack_speed = 0.75,
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
}

local character_sheet = {
	attack_damage = 50,
    minimum_attack_damage = 45,
    maximum_attack_damage = 55,
    max_health = 400,
    health_regeneration = 2.5,
    movement_speed = 250,
    pierce = 0,
    bounce = 0,
    attack_speed = 0.75,
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
}

-- effects parameters
-- int color
-- shader shader
-- int font
-- int padding_y
-- int offset_x
-- int offset_y

-- text_effects parameters
-- / effects parameters
-- string align

-- box_line_effects parameters
-- / effects parameters
-- int amount

local item = {
	{
		"data",
		{
			id = 1,
			rarity = 2,
			image = love.graphics.newImage("sprites/items/torsionator.png"),
			designation = "Apparatus",
			soundfont = "plastic",
			item_effects = {
				shader = shaders.shimmer,
			},
			box_line_effects = {
				color = 10,
				shader = shaders.shimmer,
			},
			box_back_effects = {
				color = 10,
			}
		}
	},
	{
		"text",
		{
			{
				color = 28,
				shader = shaders.shimmer,
			},
			"The Torsionator",
			{
				color = 6,
				offset_x = -8,
				align = "center",
				slot_affinity = "big_slot",
			},
			"¤",
			{
				color = 11,
				offset_x = 0,
				align = "center",
				slot_affinity = "slot",
			},
			"¤",
			{
				color = 19,
				offset_x = 8,
				align = "center",
				slot_affinity = "area",
			},
			"¤",
		}
	},
	{
		"text",
		{
			{
				color = 22,
				font = 2,
				transformation = {"circle", 2, 20},
				padding_y = 4,
				offset_y = 2,
				align = "center",
			},
			"This thing will give you cramps."
		}
	},
	{
		"text",
		{
			{
				color = 22,
			},
			"Weetabix is dry as fucka dn terirbel AAAAAAAAA"
		}
	},
	{
		"text",
		{
			{
				color = 22,
			},
			"uNDERSTAND YOUR PLACE WHELP"
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 9
					},
					"- Demolishes your big sack, dealing ",
					{
						color = 22
					},
					"22 ",
					{
						color = 9
					},
					"damage."
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"add",
					-10
				}
			},
			{
				"stat",
				{
					"lifesteal",
					"add",
					10
				}
			},
			{
				"stat",
				{
					"attack_damage",
					"percent",
					10
				}
			}
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{
						color = 9
					},
					"- Demolishes your medium sack, dealing ",
					{
						color = 22
					},
					"22 ",
					{
						color = 9
					},
					"damage."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"add",
					5
				}
			},
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Wowie, my FUCK"
				}
			},
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"I'm balling, hard. Please melp he"
				}
			},
		}
	},
	{
		"area",
		{
			{
				"text",
				{
					{
						color = 9
					},
					"- Demolishes your small sack, dealing ",
					{
						color = 22
					},
					"22 ",
					{
						color = 9
					},
					"damage."
				}
			}
		}
	},
}

function print_table_in_order(tbl, ordered_keys, x, y)
	local posy = y or 0
	local posx = x or 0
	for _, key in ipairs(ordered_keys) do
		love.graphics.print(key, posx, posy)
		love.graphics.print(tostring(tbl[key]), posx + 150, posy)
		posy = posy + 10
	end
end

-- init variables

local master_x = 0
local master_y = 0

local offset_x = 0
local offset_y = 0

local padding_y = 0

function debug_print(str, x, y)
	love.graphics.print(tostring(str), x, y)
end

function set_draw_color(value)
	local color = utils.colors[value]
	love.graphics.setColor(love.math.colorFromBytes(color[1], color[2], color[3]))
end

function set_font(value)
	love.graphics.setFont(utils.fonts[value])
end

function send_to_shaders()
	shaders.shimmer:send("time", love.timer.getTime() * 2.5)
	shaders.scrolling_rainbow:send("time", love.timer.getTime() * 50)
	shaders.rainbow:send("time", love.timer.getTime() * 100)
	shaders.corrupt:send("time", love.timer.getTime() * 2.5)
	shaders.pulse:send("time", love.timer.getTime())
	shaders.ripple:send("time", love.timer.getTime() * 15)
	shaders.blink:send("time", love.timer.getTime())
end

function reset_effects()
	set_draw_color(22)
	love.graphics.setShader()
	love.graphics.setFont(utils.fonts[1])
end

function reset_values()
	offset_x = 0
	offset_y = 0
	padding_y = 0
end

local transformation_handlers = {
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

local effect_handlers = {
	["color"] = function(int)
		set_draw_color(int)
	end,
	["shader"] = function(shader)
		love.graphics.setShader(shader)
	end,
	["transformation"] = function()
	end,
	["font"] = function(int)
		love.graphics.setFont(utils.fonts[int])
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


function count_newlines(input)
	if type(input) ~= 'string' then
		return
	end
    local cleaned_string, section_sign_count = input:gsub('§', '')
    return cleaned_string, section_sign_count
end

function draw_item_box(item, posx, posy)
	local start = love.timer.getTime()

	local master_offset = 25

	local item_universal_data = item[1][2]

	local origin_x = posx + master_offset
	local origin_y = posy + master_offset
	local last_font_used = love.graphics.getFont()
	local box_width = 0
	local box_height = 0

	local slot_padding_y = 4
	local box_padding = 4
	local text_shadow = true

	local function print_text_shadow(str, x, y)
		local r, g, b, a = love.graphics.getColor()
		set_draw_color(1)
		debug_print(str, x, y)
		love.graphics.setColor(r, g, b, a)
	end
	

	local function parse_text_print(key, data)
		if #data % 2 == 1 then
			error("text_effects defined without following string at item_data index " .. index .. ": " .. tostring(base_entry_key))
		end
		for i, e in ipairs(data) do
			-- handle this shit on groups 2 at a time
			if i % 2 == 1 then
				local text_effects = data[i]
				local str, newline_count = count_newlines(data[i + 1])
				
				for category, value in pairs(text_effects) do
					local handler = effect_handlers[category]
					if handler then
						handler(value)
					end
				end

				last_font_used = love.graphics.getFont()

				local print_x = math.floor(master_x + offset_x)
				local print_y = math.floor(master_y + offset_y)

				if text_effects["align"] and text_effects["align"] == "right" then
					print_x = math.floor(origin_x + box_width - last_font_used:getWidth(str) + offset_x)
				elseif text_effects["align"] and text_effects["align"] == "center" then
					print_x = math.floor(origin_x + (box_width / 2) - math.floor(last_font_used:getWidth(str) / 2) + offset_x)
				end
				
				if text_shadow then
					print_text_shadow(str, print_x + 1, print_y + 1)
				end
				
				
				debug_print(str, print_x, print_y)
				master_y = master_y + last_font_used:getHeight(str) * (newline_count) + padding_y
				master_x = master_x + last_font_used:getWidth(str)
				reset_effects()
				reset_values()
			end

		end
	end

	local function parse_text_dims(key, data)
		if #data % 2 == 1 then
			error("text_effects defined without following string at item_data index " .. index .. ": " .. tostring(base_entry_key))
		end
		local temp_width = 0
		for i, e in ipairs(data) do
			-- handle this shit on groups 2 at a time
			if i % 2 == 1 then
				local text_effects = data[i]
				local str, newline_count = count_newlines(data[i + 1])
				for category, value in pairs(text_effects) do
					local handler = effect_handlers[category]
					if handler then
						handler(value)
					end
				end
				last_font_used = love.graphics.getFont()
				temp_width = temp_width + last_font_used:getWidth(str) + offset_x
				temp_padding_y = padding_y
				reset_effects()
			end
		end
		box_height = box_height + last_font_used:getHeight("hi") + temp_padding_y + offset_y

		if temp_width > box_width then
			box_width = temp_width
		end
		reset_values()
	end

	local function parse_stat_print(key, data, printing)
		local str = ""
		local stat = data[1]
		local modifier = data[2]
		local value = data[3]
		local active_font = love.graphics.getFont()

		last_font_used = love.graphics.getFont()
		master_y = master_y + last_font_used:getHeight("hi")

		

		local str_modifier = ""
		local str_value = ""
		local str_percent = ""
		local str_statname = ""
		
		if modifier == "add" and value > 0 then
			str_modifier = "+"
			str = str .. str_modifier
			
		elseif modifier == "percent" and value > 0 then
			str_modifier = "+"
			str = str .. str_modifier
			
		elseif modifier == "multiply" then
			str_modifier = "x"
			str = str .. str_modifier
			
		end
		
		-- print value
		str_value = tostring(value)
		str = str .. str_value
		
		
		
		if modifier == "percent" then
			str_percent = "%"
			str = str .. str_percent
			
		end
		
		-- stat name
		str_statname = " " .. utils.parse_descriptive_key(stat)
		str = str .. str_statname
		

		set_font(1)

		print_text_shadow(str, math.floor(master_x + offset_x) + 1, math.floor(master_y) + 1)

		-- conditionally set color
		if value < 0 then
			set_draw_color(28)
		else
			set_draw_color(17)
		end
		

		-- print everything
		debug_print(str_modifier, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_modifier)
		debug_print(str_value, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_value)
		debug_print(str_percent, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_percent)
		debug_print(str_statname, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_statname)

		local handler = effect_handlers["offset_x"]
		handler(0)

		-- i dont know why these have to be in this order here :/
		
		--debug_print(str, math.floor(master_x + offset_x), math.floor(master_y))
		reset_effects()
		reset_values()
	end

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
		for index, base_entry in ipairs(item) do
			local base_entry_key = base_entry[1]
			local base_entry_data = base_entry[2]
			if base_entry_key == "text" then
				parse_text_dims(base_entry_key, base_entry_data)
				if index == 2 then
					if designation_goggles then
						box_height = box_height + last_font_used:getHeight(".")
					end
				end
				
			elseif base_entry_key == "stat" then
				parse_stat_dims(base_entry_key, base_entry_data)
			elseif base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] then
				box_height = box_height + last_font_used:getHeight("hi") + slot_padding_y
				for _, entry in ipairs(base_entry_data) do
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


	

	send_to_shaders()
	reset_effects()
	find_box_dims()

	if origin_x + box_width > game_width then
		origin_x = origin_x - box_width - master_offset * 2
	end

	if origin_y + box_height > game_height then
		origin_y = origin_y - box_height - master_offset * 2
	end

	local box_line_effects = item_universal_data["box_line_effects"]
	local box_back_effects = item_universal_data["box_back_effects"]

	local lines_amount = 1

	local temp_box_padding = box_padding

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
			math.floor(box_height + (temp_box_padding * 2) + 3)
		)
		temp_box_padding = temp_box_padding + 2
	end
	
	reset_effects()

	for category, value in pairs(box_back_effects) do
		local handler = effect_handlers[category]
		handler(value)
	end
	local r, g, b = love.graphics.getColor()
	love.graphics.setColor(r, g, b, 0.5)
	love.graphics.rectangle(
		'fill', 
		math.floor(origin_x) - 0.5 - box_padding, 
		math.floor(origin_y) - 0.5 - box_padding, 
		math.floor(box_width + (box_padding * 2.5)), 
		math.floor(box_height + (box_padding * 2.5) + 3)
	)

	master_y = origin_y

	for index, base_entry in ipairs(item) do
		master_x = origin_x
		local base_entry_key = base_entry[1]
		local base_entry_data = base_entry[2]

		if base_entry_key == "data" then
			goto continue
		end

		if base_entry_key == "text" then
			parse_text_print(base_entry_key, base_entry_data)
			if index == 2 then
				-- display item id
				debug_print(item_universal_data["id"], math.floor(master_x), math.floor(master_y))

				master_x = origin_x

			
				-- display rarity
				local rarity_value = item_universal_data["rarity"]
				local str = utils.parse_descriptive_key(item_utils.RARITIES[rarity_value][1])
				local print_x = math.floor(origin_x + box_width - last_font_used:getWidth(str))
				print_text_shadow(str, math.floor(print_x + 1), math.floor(master_y + 1))
				set_draw_color(item_utils.RARITIES[rarity_value][2])
				if rarity_value == 5 then
					love.graphics.setShader(shaders.scrolling_rainbow)
				end
				debug_print(str, print_x, math.floor(master_y))
				reset_effects()
				
				
				-- display bullets


				-- display designation
				if designation_goggles then
					master_y = master_y + last_font_used:getHeight("my balls are FUCKED up")
					local print_x = master_x
					local print_y = master_y
					local designation_string = utils.parse_descriptive_key(item_universal_data["designation"])
					love.graphics.setShader(shaders.rainbow)
					debug_print("* ", math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth("* ")
					love.graphics.setShader()
					set_draw_color(9)
					debug_print(designation_string, math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth(designation_string)
					love.graphics.setShader(shaders.rainbow)
					debug_print(" *", math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth(" *")
				end

			end

		elseif base_entry_key == "stat" then
			parse_stat_print(base_entry_key, base_entry_data, true)

		elseif base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] then
			-- print slot name
			master_y = master_y + slot_padding_y
			local slot_name = item_utils.SLOT_VANITY_NAMES[base_entry_key][1]
			print_text_shadow(slot_name, math.floor(master_x) + 1, math.floor(master_y) + 1)
			set_draw_color(item_utils.SLOT_VANITY_NAMES[base_entry_key][2])
			debug_print(slot_name, math.floor(master_x), math.floor(master_y))
			last_font_used = love.graphics.getFont()
			master_y = master_y + last_font_used:getHeight(str)

			reset_effects()
			reset_values()

			for subindex, entry in ipairs(base_entry_data) do

				master_x = origin_x

				local entry_key = entry[1]
				local entry_data = entry[2]
				if entry_key == "text" then
					if subindex ~= 1 then
						-- this is a band-aid, but it works
						master_y = master_y + last_font_used:getHeight("this is bad")
					end
					parse_text_print(entry_key, entry_data)
				elseif entry_key == "stat" then
					parse_stat_print(entry_key, entry_data)
				end
				
			end
		end
		master_y = master_y + last_font_used:getHeight(str)

		-- reset effects
		reset_effects()
		reset_values()
		::continue::
	end
	print()
	local result = love.timer.getTime() - start
    print(string.format("It took %.3f milliseconds to render that shit", result * 1000))
end

function love.draw()
	local x = love.mouse.getX() / window_scale
	local y = love.mouse.getY() / window_scale
	push:start()



	print_table_in_order(character_sheet, item_utils.STAT_CATEGORIES, 700, 50)
	draw_item_box(item, x, y)
	

	push:finish()
end