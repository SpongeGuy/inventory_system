local start_m = love.timer.getTime()

local shaders = {}

shaders.reflective = love.graphics.newShader[[
    extern vec2 displacement = vec2(0.001, 0.001);

    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {
        // Apply displacement to UVs
        vec2 displacedUVs = uvs + displacement;
        
        // Sample the texture using the displaced UVs
        vec4 texColor = Texel(texture, displacedUVs);
        
        // Return the final color
        return texColor * color;
    }
]]

shaders.yellow = love.graphics.newShader[[
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {
        return vec4(1.0, 1.0, 0, 1.0);
    }
]]

shaders.pulse = love.graphics.newShader[[

	uniform float time;

    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {

    	// calculate alpha value based on time, creating fadein and fadeout effect
    	float alpha = smoothstep(0.0, 1.0, mod(time, 0.5));
    	// interpolate between the original color and transparent black based on the calculated alpha
        return mix(color, vec4(0.0), alpha);
    }
]]

shaders.bounce = love.graphics.newShader[[
    extern float time;

    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {

    	float normalized_time = mod(time, 1.0);
        vec4 pixel = Texel(texture, uvs);
        vec3 c = vec3(normalized_time, 1.0, 1.0);
        if (pixel.a < 0.01) {
        	return vec4(0.0);
        } else {
        	return vec4(c, 1);
        }
        
    }
]]

shaders.ripple = love.graphics.newShader[[
    extern float time;
    
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords) {
        // Calculate wave displacement
        float waveDisplacement = sin(uvs.x * 5.0 + time) * 0.015;
        
        // Apply wave displacement to y-coordinate
        vec2 displacedUVs = vec2(uvs.x, uvs.y + waveDisplacement);
        
        // Sample the texture with displaced UVs
        vec4 texColor = Texel(texture, displacedUVs);
        
        // Return the final color
        vec4 pixel = Texel(texture, uvs);
        if (pixel.a < 0.01) {
            return vec4(0.0);
        } else {
            return vec4(color.rgb, texColor.a);
        }
        
    }
]]

shaders.shimmer = love.graphics.newShader[[
    extern float time;

    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords) {
        // Sample the texture normally
        vec4 texColor = Texel(texture, uvs);

        // Calculate brightness modulation based on time and screen position
        float brightnessModulation1 = 5 * sin(screen_coords.x / 100.0 + screen_coords.y / 100.0 + time) + 5.35;

        // Apply brightness modulation to the color
        vec3 modulatedColor = texColor.rgb * clamp(brightnessModulation1, 0.0, 1.0);

        vec3 finalColor = 1 / modulatedColor * color.rgb;

        // Ensure the color stays within valid range
        vec3 clampedColor = clamp(finalColor, 0.0, 1.0);

        // Return the final color
        return vec4(clampedColor, texColor.a);
    }
]]

shaders.corrupt = love.graphics.newShader[[
    extern float time;
    
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords) {
        // Calculate wave displacement
        float waveDisplacement = sin(uvs.x * 100.0 + time) * 0.05;
        
        // Apply wave displacement to y-coordinate
        vec2 displacedUVs = vec2(uvs.x, uvs.y + waveDisplacement);
        
        // Sample the texture with displaced UVs
        vec4 texColor = Texel(texture, displacedUVs);
        
        // Brighten the color
        float brightness = 1.5; // Adjust this value to control the brightness level
        vec3 brightenedColor = clamp(texColor.rgb * brightness, 0.0, 1.0);
        
        // Return the final color
        vec4 pixel = Texel(texture, uvs);
        return vec4(brightenedColor, texColor.a);
        
    }
]]

shaders.demo_shader = love.graphics.newShader[[
    extern vec2 screen;
        
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {
        vec4 pixel = Texel(texture, uvs);
        vec2 sc = vec2(screen_coords.x / screen.x, screen_coords.y / screen.y);
        return vec4(sc.xy, 1.0, 1.0) * pixel;
    }
]]

shaders.rainbow = love.graphics.newShader[[
    extern float time;

    vec3 hsv_to_rgb(float h, float s, float v) {
        int i;
        float f, p, q, t;
        if(s == 0.0) {
            // achromatic (grey)
            return vec3(v, v, v);
        }
        h /= 60.0;            // sector 0 to 5
        i = int(floor(h));
        f = (h - float(i));    // factorial part of h
        p = v * (1.0 - s);
        q = v * (1.0 - s * f);
        t = v * (1.0 - s * (1.0 - f));

        if(i == 0) {
            return vec3(v, t, p);
        } else if(i == 1) {
            return vec3(q, v, p);
        } else if(i == 2) {
            return vec3(p, v, t);
        } else if(i == 3) {
            return vec3(p, q, v);
        } else if(i == 4) {
            return vec3(t, p, v);
        } else { // case 5
            return vec3(v, p, q);
        }

    }
        
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {   
        float normalized_time = mod(time, 359.0);
        vec3 rgb_color = hsv_to_rgb(normalized_time, 1.0, 1.0);
        vec4 pixel = Texel(texture, uvs);
        if (pixel.a < 0.01) {
        	return vec4(0.0);
        } else {
        	return vec4(rgb_color, 1.0);
        }
    }
]]

shaders.scrolling_rainbow = love.graphics.newShader[[
    extern float time;
    uniform float color_spread = 1;
    uniform float scroll_speed = 1;

    vec3 hsv_to_rgb(float h, float s, float v) {
        int i;
        float f, p, q, t;
        if(s == 0.0) {
            // achromatic (grey)
            return vec3(v, v, v);
        }
        h /= 60.0;            // sector 0 to 5
        i = int(floor(h));
        f = (h - float(i));    // factorial part of h
        p = v * (1.0 - s);
        q = v * (1.0 - s * f);
        t = v * (1.0 - s * (1.0 - f));

        if(i == 0) {
            return vec3(v, t, p);
        } else if(i == 1) {
            return vec3(q, v, p);
        } else if(i == 2) {
            return vec3(p, v, t);
        } else if(i == 3) {
            return vec3(p, q, v);
        } else if(i == 4) {
            return vec3(t, p, v);
        } else { // case 5
            return vec3(v, p, q);
        }

    }
        
    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {   
        float normalized_time = mod((time * scroll_speed) + screen_coords.x * color_spread, 359.0);
        vec3 rgb_color = hsv_to_rgb(normalized_time, 1.0, 1.0);
        vec4 pixel = Texel(texture, uvs);
        if (pixel.a < 0.01) {
        	return vec4(0.0);
        } else {
        	return vec4(rgb_color, 1.0);
        }
    }
]]

shaders.fade = love.graphics.newShader[[

	uniform float time;
	uniform float fadeout_duration = 1;
	uniform float pause_duration = -0.5;
	uniform float fadein_duration = 2;

    vec4 effect(vec4 color, Image texture, vec2 uvs, vec2 screen_coords)
    {
    	// define cycle length, including pause
    	float cycle_length = fadeout_duration + pause_duration + fadein_duration; // 2 seconds to fadeout, 2 seconds pause, 2 seconds fadein

    	// normalize time to the range [0, 1] for one cycle
    	float normalized_time = mod(time / cycle_length, 1.0);

    	// determine if in fadeout phase, pause, or fade-in phase
    	if (normalized_time < fadeout_duration / cycle_length) { // fadeout
    		float alpha = smoothstep(0.0, 1.0, normalized_time * 3.0);
    		return mix(color, vec4(0.0), alpha);
    	} else if (normalized_time < (fadeout_duration + pause_duration) / cycle_length) { // pause
    		return vec4(0.0);
    	} else { // fadein
    		float alpha = smoothstep(0.0, 1.0, (normalized_time - 2.0 / 3.0) * 3.0);
    		return mix(vec4(0.0), color, alpha);
    	}
    }
]]


local result_m = love.timer.getTime() - start_m
print(string.format("Shaders loaded in %.3f milliseconds!", result_m * 1000))
return shaders