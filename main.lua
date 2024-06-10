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
local show_designation = true
local show_rarity = true
local show_bullets = true
local debug_id_see = false
local debug_showall = true


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


local item_nail = {
	{
		"data",
		{
			id = 53,
			rarity = 5,
			image = nil,
			soundfont = "metal",
			box_line_effects = {
				color = 6,
				shader = shaders.shimmer,
			},
			box_back_effects = {
				color = 6,
			}
		}
	},
	{
		"text",
		{
			{
				color = 6,
				shader = shaders.shimmer,
				padding_x = 60,
				offset_y = 0,
			},
			"Gold Stainless Nail",
		}
	},
	{
		"text",
		{
			{
				color = 10,
				font = 2,
			},
			"It's been torn through the distance of man."
		}
	},
	{
		"big_slot",
		{
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Pure freedom."
				}
			},
			{
				"text",
				{
					{
						color = 9,
					},
					"§- Gain a buff on hit which swaps the values of your \n   minimum and maximum attack damage.",
					{
						color = 10,
						offset_x = -40,
					},
					-- modify the font to have an hourglass symbol and directional arrows
					"[Dur. 00:07]  ",
					{
						color = 12,
						offset_x = -40,
					},
					"[Cd. 00:10]"
				}
			},
			{
				"text",
				{
					{
						color = 9,
					},
					"- Enemies under the reign of a powerful force reject purity, becoming friendly."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					-2
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					200
				}
			},
			{
				"stat",
				{
					"critical_hit_chance",
					"add",
					45
				}
			},
			{
				"stat",
				{
					"critical_hit_power",
					"add",
					25
				}
			},
		}
	},
	{
		"slot",
		{
			{
				"text",
				{
					{
						color = 22,
						font = 2,
					},
					"Secrets are still held from you."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					1.5
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					100
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
						color = 22,
						font = 1,
					},
					"Going through the motions..."
				}
			},
			{
				"stat",
				{
					"attack_speed",
					"multiply",
					1.2
				}
			},
			{
				"stat",
				{
					"maximum_attack_damage",
					"add",
					20
				}
			},
			{
				"stat",
				{
					"healing_power",
					"add",
					10
				}
			},
		}
	}
}

local item_torsionator = {
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

function visual_print(str, x, y)
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

function count_newlines(input)
	if type(input) ~= 'string' then
		return
	end
    local cleaned_string, section_sign_count = input:gsub('§', '')
    return cleaned_string, section_sign_count
end

function draw_item_box(item, slot, posx, posy)
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
		set_draw_color(22)
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
		set_draw_color(1)
		visual_print(str, x, y)
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
		for i, e in ipairs(data) do
			-- handle this shit on groups 2 at a time
			if i % 2 == 1 then
				local text_effects = data[i]
				str, newline_count = count_newlines(data[i + 1])
				
				for category, value in pairs(text_effects) do
					local handler = effect_handlers[category]
					if handler then
						handler(value)
					end
				end

				last_font_used = love.graphics.getFont()
				accum_padding_y = accum_padding_y + padding_y
				accum_newline_count = accum_newline_count + newline_count

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
					print(category)
					if handler then
						mod_x, mod_y = handler(mod_x, mod_y, value[1], value[2], value[3])
					end
				end

				if text_shadow then
					print_text_shadow(str, mod_x + 1, mod_y + 1)
				end
				visual_print(str, mod_x, mod_y)
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
				local text_effects = data[i]
				str, newline_count = count_newlines(data[i + 1])
				for category, value in pairs(text_effects) do
					local handler = effect_handlers[category]
					if handler then
						handler(value)
					end
				end
				last_font_used = love.graphics.getFont()
				temp_width = temp_width + last_font_used:getWidth(str) + offset_x + padding_x
				accum_padding_y = accum_padding_y + padding_y
				reset_effects()
				accum_newline_count = accum_newline_count + newline_count
				reset_values()

			end
		end
		box_height = box_height + last_font_used:getHeight("hi") * (accum_newline_count) + accum_padding_y + offset_y

		if temp_width > box_width then
			box_width = temp_width
		end
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
		

		set_font(1)

		print_text_shadow(str, math.floor(master_x + offset_x) + 1, math.floor(master_y) + 1)

		set_draw_color(22)
		

		-- print everything
		visual_print(str_modifier, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_modifier)
		set_draw_color(9)
		
		visual_print(str_value, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_value)
		set_draw_color(22)
		visual_print(str_percent, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_percent)
		visual_print(str_statname, math.floor(master_x + offset_x), math.floor(master_y))
		master_x = master_x + active_font:getWidth(str_statname)

		local handler = effect_handlers["offset_x"]
		handler(0)
		
		--visual_print(str, math.floor(master_x + offset_x), math.floor(master_y))
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
					if show_designation and item_universal_data["designation"] then
						box_height = box_height + last_font_used:getHeight(".")
					end
				end
				
			elseif base_entry_key == "stat" then
				parse_stat_dims(base_entry_key, base_entry_data)
			elseif 
				base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and slot_mode == base_entry_key or
				base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and debug_showall 
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


	

	send_to_shaders()
	reset_effects()
	find_box_dims()

	-- display box

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
			math.floor(box_height + (temp_box_padding * 2) + 0)
		)
		temp_box_padding = temp_box_padding + 2
	end
	
	reset_effects()

	for category, value in pairs(box_back_effects) do
		local handler = effect_handlers[category]
		handler(value)
	end
	local r, g, b = love.graphics.getColor()
	love.graphics.setColor(r, g, b, 0.55)
	love.graphics.rectangle(
		'fill', 
		math.floor(origin_x) - 0.5 - box_padding, 
		math.floor(origin_y) - 0.5 - box_padding, 
		math.floor(box_width + (box_padding * 2.5)), 
		math.floor(box_height + (box_padding * 2.5) + 0)
	)

	
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
				if debug_id_see then
					local id_text = item_universal_data["id"]
					visual_print(id_text, math.floor(origin_x + box_width - last_font_used:getWidth(id_text)), math.floor(origin_y + last_font_used:getHeight('.')))
				end

				master_x = origin_x
			
				-- display rarity
				if show_rarity then
					local rarity_value = item_universal_data["rarity"]
					local rarity_str = utils.parse_descriptive_key(item_utils.RARITIES[rarity_value][1])
					local print_x = math.floor(origin_x + box_width - last_font_used:getWidth(rarity_str))

					print_text_shadow(rarity_str, math.floor(print_x + 1), math.floor(origin_y + 1))
					set_draw_color(item_utils.RARITIES[rarity_value][2])
					if rarity_value == 5 then
						love.graphics.setShader(shaders.scrolling_rainbow)
					end
					visual_print(rarity_str, print_x, math.floor(origin_y))
					reset_effects()
				end
				
				
				-- display bullets
				
				if show_bullets then
					local center_x = math.floor(origin_x + math.floor(box_width / 2) - math.floor(last_font_used:getWidth("¤") / 2))
					local big_slot_mod_x = 0
					local big_slot_mod_y = 0
					local slot_mod_x = 0
					local slot_mod_y = 0
					local area_mod_x = 0
					local area_mod_y = 0
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
						center_x = origin_x + last_font_used:getWidth(last_text_str) + 18
					end
					print(box_width / 2 - 18, last_font_used:getWidth(last_text_str))
					set_draw_color(19)
					visual_print("¤", math.floor(center_x - 8 + area_mod_x), math.floor(origin_y + area_mod_y))
					set_draw_color(11)
					visual_print("¤", math.floor(center_x + slot_mod_x), math.floor(origin_y + slot_mod_y))
					set_draw_color(6)
					visual_print("¤", math.floor(center_x + 8 + big_slot_mod_x), math.floor(origin_y + big_slot_mod_y))
				end

				-- display designation
				if show_designation and item_universal_data["designation"] then
					--master_y = master_y + last_font_used:getHeight("my balls are FUCKED up")
					local print_x = master_x
					local print_y = master_y
					local designation_string = utils.parse_descriptive_key(item_universal_data["designation"])
					love.graphics.setShader(shaders.rainbow)
					visual_print("* ", math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth("* ")
					love.graphics.setShader()
					set_draw_color(9)
					visual_print(designation_string, math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth(designation_string)
					love.graphics.setShader(shaders.rainbow)
					visual_print(" *", math.floor(print_x), math.floor(print_y))
					print_x = print_x + last_font_used:getWidth(" *")
					master_y = master_y + last_font_used:getHeight("we're done here")
				end

			end
			--master_y = master_y + last_font_used:getHeight(str)

		elseif base_entry_key == "stat" then
			parse_stat_print(base_entry_key, base_entry_data, true)

		elseif 
			base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and slot_mode == base_entry_key or
			base_entry_key == item_utils.SLOT_CATEGORIES[base_entry_key] and debug_showall 
			then
			master_y = master_y + slot_padding_y
			local slot_name = item_utils.SLOT_VANITY_NAMES[base_entry_key][1]
			print_text_shadow(slot_name, math.floor(master_x) + 1, math.floor(master_y) + 1)
			set_draw_color(item_utils.SLOT_VANITY_NAMES[base_entry_key][2])
			visual_print(slot_name, math.floor(master_x), math.floor(master_y))
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
	print()
	local result = love.timer.getTime() - start
    print(string.format("It took %.3f milliseconds to render that shit", result * 1000))
end

local slot = {
	uuid = 4,
	mode = "big_slot"
}

local item = {
	slot_uuid = 4,
	data = item_nail,
}

function love.draw()
	local x = love.mouse.getX() / window_scale
	local y = love.mouse.getY() / window_scale
	push:start()



	print_table_in_order(character_sheet, item_utils.STAT_CATEGORIES, 700, 50)
	draw_item_box(item, slot, x, y)
	

	push:finish()
end