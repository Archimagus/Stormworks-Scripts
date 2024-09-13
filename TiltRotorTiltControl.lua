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
        simulator:setInputNumber(1, simulator:getSlider(1) * -1)
    end;
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

-- Constants and configuration
HELO_ANGLE, PLANE_ANGLE = property.getNumber("HeloAngle"), property.getNumber("PlaneAngle")
ANGLE_MULTIPLIER = 4
MODE_THRESHOLD = 0.5

-- Initialize variables
currentTargetAngle = 9999 -- Large initial value to ensure first-run initialization
previousTargetAngle = nil
lastToggleState = false

-- Utility function to normalize a value between a min and max
function normalize(value, min, max)
    return (value - min) / (max - min)
end

function onTick()
    -- Read current prop angle and scale it
    local currentPropAngle = input.getNumber(1) * ANGLE_MULTIPLIER

    -- Initialize target angle on first run
    if currentTargetAngle == 9999 then
        currentTargetAngle = currentPropAngle
        previousTargetAngle = currentPropAngle
    end

    -- Normalize current angle between helo and plane angles
    local normalizedAngle = normalize(currentPropAngle, HELO_ANGLE, PLANE_ANGLE)

    -- Determine current mode (true for plane, false for helo)
    local isPlaneMode = normalizedAngle > MODE_THRESHOLD

    -- Read toggle input
    local toggleInput = input.getBool(1)

    -- Detect rising edge of toggle input
    local togglePressed = toggleInput and not lastToggleState
    lastToggleState = toggleInput

    -- Update target angle if toggle was pressed
    if togglePressed then
        if isPlaneMode then
            currentTargetAngle = HELO_ANGLE
        else
            currentTargetAngle = PLANE_ANGLE
        end
    end

    -- Output results
    output.setBool(1, isPlaneMode)          -- Current mode
    output.setNumber(1, normalizedAngle)    -- Normalized current angle
    output.setNumber(2, currentTargetAngle) -- Target angle
end
