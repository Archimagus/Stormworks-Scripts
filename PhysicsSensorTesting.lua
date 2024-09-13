--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F6 to simulate this file
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA


--[====[ EDITABLE SIMULATOR CONFIG - *automatically removed from the F7 build output ]====]
---@section __LB_SIMULATOR_ONLY__
do
    ---@type Simulator -- Set properties and screen sizes here - will run once when the script is loaded
    simulator = simulator
    simulator:setScreen(1, "3x3")
    simulator:setProperty("ExampleNumberProperty", 123)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
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

        -- NEW! button/slider options from the UI
        simulator:setInputBool(31, simulator:getIsClicked(1))     -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1))      -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2))     -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end;
end
---@endsection



--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.ArchIo")

require("LifeBoatAPI")

-- edit this
-- Output 1 to 3 (Number): X, Y and Z position of the block
-- Output 4 to 6 (Number): Euler rotation X, Y and Z of the block
-- Output 7 to 9 (Number): Linear velocity X, Y and Z of the block
-- Output 10 to 12 (Number): Angular velocity X, Y and Z of the block
-- Output 13 (Number): Absolute linear velocity of the block
-- Output 14 (Number): Absolute angular velocity of the block
-- Output 15 (Number): Local Z tilt (pitch)
-- Output 16 (Number): Local X tilt (roll)
-- Output 17 (Number): Compass heading (-0.5 to 0.5)
graphs = {
    { label = "X",       input = 1,  min = -10000, max = 10000, r = 255, g = 0,   b = 0 },
    { label = "Y",       input = 2,  min = -10000, max = 10000, r = 0,   g = 255, b = 0 },
    { label = "Z",       input = 3,  min = -10000, max = 10000, r = 0,   g = 0,   b = 255 },
    { label = "RX",      input = 4,  min = -1,     max = 1,     r = 64,  g = 0,   b = 0 },
    { label = "RY",      input = 5,  min = -1,     max = 1,     r = 0,   g = 64,  b = 0 },
    { label = "RZ",      input = 6,  min = -1,     max = 1,     r = 0,   g = 0,   b = 64 },
    { label = "VX",      input = 7,  min = -1,     max = 1,     r = 120, g = 120, b = 0 },
    { label = "VY",      input = 8,  min = -1,     max = 1,     r = 120, g = 0,   b = 120 },
    { label = "VZ",      input = 9,  min = -1,     max = 1,     r = 0,   g = 120, b = 120 },
    { label = "RVX",     input = 10, min = -1,     max = 1,     r = 120, g = 120, b = 0 },
    { label = "RVY",     input = 11, min = -1,     max = 1,     r = 120, g = 0,   b = 120 },
    { label = "RVZ",     input = 12, min = -1,     max = 1,     r = 0,   g = 120, b = 120 },
    { label = "ALV",     input = 13, min = -1,     max = 1,     r = 120, g = 120, b = 120 },
    { label = "PITCH",   input = 15, min = -1,     max = 1,     r = 255, g = 64,  b = 64 },
    { label = "ROLL",    input = 16, min = -1,     max = 1,     r = 64,  g = 64,  b = 255 },
    { label = "HEADING", input = 17, min = -1,     max = 1,     r = 64,  g = 255, b = 64 },
}

function onTick()
    for i = 1, #graphs do
        graphs[i].value = input.getNumber(graphs[i].input)
        local i2 = graphs[i].input
        if i2 == 15 then
            graphs[i].value = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(input.getNumber(i2))
        end
        if i2 == 16 then
            graphs[i].value = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(input.getNumber(i2))
        end
        if i2 == 17 then
            graphs[i].value = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth(input.getNumber(i2))
        end
    end
end

local lineHeight = 10

function onDraw()
    for i = 1, #graphs do
        screen.setColor(graphs[i].r, graphs[i].g, graphs[i].b)
        screen.drawText(10, (i - 1) * lineHeight, graphs[i].label .. ": " .. string.format("%.2f", graphs[i].value))
    end
end
