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
    simulator:setProperty("HeloAngle", 0)
    simulator:setProperty("PlaneAngle", 1)

    -- Runs every tick just before onTick; allows you to simulate the inputs changing
    ---@param simulator Simulator Use simulator:<function>() to set inputs etc.
    ---@param ticks     number Number of ticks since simulator started
    function onLBSimulatorTick(simulator, ticks)
        -- touchscreen defaults

        -- NEW! button/slider options from the UI
        simulator:setInputBool(1, simulator:getIsClicked(1)) -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(1, simulator:getSlider(1))  -- set input 1 to the value of slider 1
    end;
end
---@endsection


local HELO_ANGLE = property.getNumber("HeloAngle")
local PLANE_ANGLE = property.getNumber("PlaneAngle")
local ANGLE_MULTIPLIER = 4
local MODE_THRESHOLD = 0.5
local initialPropAngle = 9999
local targetPropAngle
local togglePressed = false

function normalize(value, min, max)
    return (value - min) / (max - min)
end

function onTick()
    local toggleProp = input.getBool(1)
    local currentPropAngle = input.getNumber(1)
    currentPropAngle = currentPropAngle * ANGLE_MULTIPLIER

    if initialPropAngle == 9999 then
        initialPropAngle = currentPropAngle
        targetPropAngle = currentPropAngle
    end

    local normalizedAngle = normalize(currentPropAngle, HELO_ANGLE, PLANE_ANGLE)
    local isPlaneMode = normalizedAngle > MODE_THRESHOLD


    local toggle = toggleProp and not togglePressed
    togglePressed = toggleProp

    if toggle then
        if isPlaneMode then
            targetPropAngle = HELO_ANGLE
        else
            targetPropAngle = PLANE_ANGLE
        end
    end


    output.setBool(1, isPlaneMode)
    output.setBool(2, toggleProp)
    output.setNumber(1, normalizedAngle)
    output.setNumber(2, currentPropAngle)
    output.setNumber(3, targetPropAngle)
end
