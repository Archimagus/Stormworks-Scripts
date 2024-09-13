-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
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

require("LifeBoatAPI")
require("Utils")
require("Autopilot.PlaneController")
require("Autopilot.HelicopterController")
--- Flight controls for an airplane

--- Physics sensor inputs
-- Input 1 to 3 (Number): X, Y and Z position of the block
-- Input 4 to 6 (Number): Euler rotation X, Y and Z of the block
-- Input 7 to 9 (Number): Linear velocity X, Y and Z of the block
-- Input 10 to 12 (Number): Angular velocity X, Y and Z of the block
-- Input 13 (Number): Absolute linear velocity of the block
-- Input 14 (Number): Absolute angular velocity of the block
-- Input 15 (Number): Local Z tilt (pitch)
-- Input 16 (Number): Local X tilt (roll)
-- Input 17 (Number): Compass heading (-0.5 to 0.5)

--- Control inputs
-- Input 18 (Number) A/D
-- Input 19 (Number) W/S
-- Input 20 (Number) L/R
-- Input 21 (Number) Up/Down

--- Autopilot Inputs
-- Input 21 (Number) Target Altitude
-- Input 22 (Number) Destination X
-- Input 23 (Number) Destination Y

-- Input 1 (Boolean) Reset Altitude
-- Input 2 (Boolean) Go to Destination
-- Input 3 (Boolean) Direct Mode
-- Input 4 (Boolean) Plane Mode


local maxPitch, maxRoll = 45, 45

local physicsSensor = ArchUtils.PhysicsSensor:new()
local autopilot = ArchUtils.Autopilot:new(physicsSensor)
local planeController = ArchUtils.PlaneController:new(autopilot, maxPitch, maxRoll)
local heloController = ArchUtils.HelicopterController:new(autopilot, maxPitch, maxRoll)

function onTick()
    local rollCommand, pitchCommand, yawCommand, collectiveCommand, tgtAlt, destX, destY = getN(18, 19, 20, 21, 22, 23,
        24)

    resetAltitude, goToDestination, directMode, planeMode = getB(1, 2, 3, 4)


    if resetAltitude or tgtAlt ~= targetAltitude then
        targetAltitude = tgtAlt
        planeController:setTargetAltitude(targetAltitude)
        heloController:setTargetAltitude(targetAltitude)
    end
    if directMode then
        outN(1, rollCommand, pitchCommand, yawCommand, collectiveCommand)
    else
        if planeMode then
            local planeControlSignals = planeController:update(rollCommand, pitchCommand, yawCommand, goToDestination,
                destX,
                destY)
            outN(1, planeControlSignals.pitch, planeControlSignals.roll, planeControlSignals.yaw, 1)
        else
            local heloControlSignals = heloController:update(rollCommand, pitchCommand, yawCommand, collectiveCommand,
                goToDestination, destX, destY)
            outN(1, heloControlSignals.pitch, heloControlSignals.roll, heloControlSignals.yaw,
                heloControlSignals.collective)
        end
    end
end

function onDraw()
    screen.drawText(0, 0, "resetAltitude: " .. tostring(resetAltitude))
    screen.drawText(0, 10, "goToDestination: " .. tostring(goToDestination))
    screen.drawText(0, 20, "directMode: " .. tostring(directMode))
    screen.drawText(0, 30, "planeMode: " .. tostring(planeMode))
end
