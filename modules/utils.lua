local start_m = love.timer.getTime()

local utils = {}

math.randomseed(os.time())


-- DB32 color palette
utils.colors = {
    {0, 0, 0}, 			--  1; black
    {34, 32, 52},		--  2; dark purple
    {69, 40, 60},		--  3; deep magenta
    {102, 57, 49},		--  4; brown
    {143, 86, 59},		--  5; clay brown
    {223, 113, 38},		--  6; orange
    {217, 160, 102},	--  7; sandy orange
    {238, 195, 154},	--  8; cream
    {251, 242, 54},		--  9; bright yellow
    {153, 229, 80},		-- 10; light green
    {106, 190, 48},		-- 11; green
    {55, 148, 110},		-- 12; greenish cyan
    {75, 105, 47},		-- 13; forest green
    {82, 75, 36},		-- 14; muddy green
    {50, 60, 57},		-- 15; charcoal
    {63, 63, 116},		-- 16; dark purplish blue
    {48, 96, 130},		-- 17; dark teal
    {91, 110, 225},		-- 18; purplish blue
    {99, 155, 255},		-- 19; sky blue
    {95, 205, 228},		-- 20; turquoise
    {203, 219, 252},	-- 21; light bluish grey
    {255, 255, 255},	-- 22; white
    {155, 173, 183},	-- 23; bluish grey
    {132, 126, 135},	-- 24; pinkish grey
    {105, 106, 106},	-- 25; medium grey
    {89, 86, 82},		-- 26; dark grey
    {118, 66, 138},		-- 27; purple
    {172, 50, 50},		-- 28; brick red
    {217, 87, 99},		-- 29; salmon
    {215, 123, 186},	-- 30; bright pink
    {143, 151, 74},		-- 31; greenish yellow
    {138, 111, 48},		-- 32; dark beige
}

utils.fonts = {
    love.graphics.newFont("font/nokiafc22.ttf", 8),
    love.graphics.newFont("font/bmmini.ttf", 8),
    love.graphics.newFont("font/PressStart2P.ttf", 8),
    love.graphics.newFont("font/Notalot60.ttf", 11),
    love.graphics.newFont("font/Mitochondria.ttf", 8),
    love.graphics.newFont("font/Ho8Bit.otf", 7),
    love.graphics.newFont("font/princess-saves-you.otf", 9),
    love.graphics.newFont("font/Wizard.ttf", 8),
    love.graphics.newFont("font/crafters-delight.ttf", 16),
}

-- returns randomly seeded uuid
function utils.uuid()
	local template = 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function(c)
        local v = (c == 'x') and math.random(0, 0xf) or math.random(8, 0xb)
        return string.format('%x', v)
    end)
end

-- grabs a random key from a table.
-- only accepts unordered tables
function utils.get_random_key_from(arr)
	local keys = {}
	for k in pairs(arr) do
		table.insert(keys, k)
	end
	return keys[math.random(#keys)]
end

-- returns true if a point '1' collides with a zone '2'
-- return false otherwise
function utils.get_point_collision(x, y, x2, y2, w2, h2)
	if x > x2 and x < x2 + w2 and y > y2 and y < y2 + h2 then
		return true
	end
	return false
end

-- i dont remember what this is
function utils.iter(t)
	local i = 0
	return function()
		i = i + 1
		return t[i]
	end
end

-- returns table of rgb 0-1 values from rgb 0-255 values
function utils.get_color_table_from_rgb(r, g, b)
	r, g, b = love.math.colorFromBytes(r, g, b)
	return {r, g, b}
end

-- takes a string, converts underscores to spaces and capitalizes the first letter in each word
function utils.parse_descriptive_key(key)
	local space_string = key:gsub("_", " ")

	local formatted = ""
	for word in space_string:gmatch("%S+") do

		formatted = formatted .. word:sub(1, 1):upper() .. word:sub(2) .. " "
	end

	formatted = formatted:sub(1, -2)

	return formatted
end

-- takes a string, splitting it into separate parts
-- separates numbers from letters in the string
-- keeps the string's content intact
-- returns a table containing the split up string
function utils.get_string_as_table(input)
	local result = {}
	local str = ""
	local mode = nil
	local is_num = input:sub(1, 1):match("%d")
	if is_num then mode = 1 else mode = 0 end
    for i = 1, #input do
    	-- while adding alpha characters to str, insert if number character
    	-- while adding number characters to str, insert if alpha character
    	local char = input:sub(i, i)
    	str = str .. char

    	if input:sub(i+1, i+1) then
    		is_num = input:sub(i+1, i+1):match("%d") ~= nil
    	end

    	if mode == 0 and is_num and input:sub(i+1, i+1)then
    		-- switch to numbers
    		table.insert(result, str)
    		mode = 1
    		str = ""
    	elseif mode == 1 and not is_num and input:sub(i+1, i+1) then
    		-- switch to alpha
    		table.insert(result, tonumber(str))
    		mode = 0
    		str = ""
    	end
    end
    if mode == 0 then
    	table.insert(result, str)
    else
    	table.insert(result, tonumber(str))
    end
    return result
end

-- takes a table and prints its contents
function utils.deep_print_table(tbl, indent)
    -- Default indentation level
    indent = indent or 0

    -- Iterate over each key-value pair in the table
    for k, v in pairs(tbl) do
        -- Calculate new indentation level based on depth
        local newIndent = indent + 2

        -- Check if the value is a table (nested structure)
        if type(v) == "table" then
        	-- If the key is a string, print it directly
            if type(k) == "string" then
                print(string.rep(" ", indent)..k..": ")
            end
            -- Print opening brace and current indentation level
            print(string.rep(" ", indent).. "{")
            -- Recursively call deep_print_table for the nested table
            utils.deep_print_table(v, newIndent)
            -- Print closing brace after the nested content
            print(string.rep(" ", indent).. "}")
        else
            -- Print key and value with current indentation level
            -- Ensure keys are treated as strings for printing
            print(string.rep(" ", indent).. tostring(k).. ": ".. tostring(v))
        end
    end
end

local result_m = love.timer.getTime() - start_m
print(string.format("Utils loaded in %.3f milliseconds!", result_m * 1000))
return utils