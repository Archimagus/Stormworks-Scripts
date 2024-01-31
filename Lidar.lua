tU = table.unpack
function propN(...)local a={}for b,c in ipairs({...})do a[b]=property.getNumber(c)end;return tU(a) end
function getN(...)local a={}for b,c in ipairs({...})do a[b]=input.getNumber(c)end;return tU(a)end
function outN(o, ...) for i,v in ipairs({...}) do output.setNumber(o+i-1,v) end end
function clamp(number, min, max)
	return math.min(math.max(number, min), max)
end


local x = -1
local y = -1
local pixelX = 0
local pixelY = 0
local pixels
local width, height


function onTick()
    local w, h, range = getN(1,2,5)
    if w == nil or h == nil or range == nil then return end
    
    local fovX, fovY, maxRange = propN("fovX", "fovY", "maxRange")
    fovX = fovX or 1
    fovY = fovY or 1
    maxRange = maxRange or 30

    initPixels(w, h)
    
    if pixels == nil or pixels[pixelY + 1] == nil then
        outN(3, pixelX,pixelY) 
        return 
    end

    local color = math.ceil(clamp((range / maxRange) * 255, 0, 255))
    pixels[pixelY + 1][pixelX + 1] = color

    -- Update the x and y coordinates
    pixelX = pixelX + 1
    if pixelX >= width then
        pixelX = 0
        pixelY = pixelY + 1
        if pixelY >= height then
            pixelY = 0
        end
    end
    
    -- Convert pixel position to range of -1 to 1
    x = ((pixelX / (width - 1)) * 2 - 1) * fovX
    y = (1 - (pixelY / (height - 1)) * 2) * fovY

    outN(1, x,y)
end

function onDraw()
    if width == 0 then return end
    -- Loop through all the pixels and draw each one
    for y = 1, height do
        for x = 1, width do
            local c = pixels[y][x]
            screen.setColor(c,c,c)
            screen.drawRectF(x-1,y-1, 1, 1)
        end
    end
    screen.setColor(255,0,0)
    screen.drawRectF(pixelX, pixelY, 1,1)
end


function initPixels(w,h)
    if pixels == nil or w ~= width or h ~= height then
        width = w
        height = h
        pixels = {}
        for i = 1, height do
            pixels[i] = {}
            for j = 1, width do
                pixels[i][j] = 0
            end
        end
    end
end


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "1x1")
    simulator:setProperty("f0vX", 1)
    simulator:setProperty("fovY", 1)
    simulator:setProperty("maxRange", 31)

    -- Runs every tick just before onTick allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)

        -- touchscreen defaults
        local screenConnection = simulator:getTouchScreen(1)
        simulator:setInputBool(1, screenConnection.isTouched)
        simulator:setInputNumber(1, screenConnection.width)
        simulator:setInputNumber(2, screenConnection.height)
        simulator:setInputNumber(3, screenConnection.touchX)
        simulator:setInputNumber(4, screenConnection.touchY)

        simulator:setInputNumber(5, simulator:getSlider(1)*30)        -- set input 31 to the value of slider 1
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]
-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

