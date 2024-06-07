local start_m = love.timer.getTime()
text_engine = {}


function text_engine.create_text_box(window_w, window_h, x, y)
    
end








local result_m = love.timer.getTime() - start_m
print(string.format("Text Engine loaded in %.3f milliseconds!", result_m * 1000))
return text_engine