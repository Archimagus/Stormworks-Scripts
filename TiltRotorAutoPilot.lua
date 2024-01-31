-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: https://steamcommunity.com/profiles/76561197993236437/myworkshopfiles/?appid=573090
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
        simulator:setInputBool(31, simulator:getIsClicked(1)) -- if button 1 is clicked, provide an ON pulse for input.getBool(31)
        simulator:setInputNumber(31, simulator:getSlider(1)) -- set input 31 to the value of slider 1

        simulator:setInputBool(32, simulator:getIsToggled(2)) -- make button 2 a toggle, for input.getBool(32)
        simulator:setInputNumber(32, simulator:getSlider(2) * 50) -- set input 32 to the value from slider 2 * 50
    end
end
---@endsection


--[====[ IN-GAME CODE ]====]

-- try require("Folder.Filename") to include code from another file in this, so you can store code in libraries
-- the "LifeBoatAPI" is included by default in /_build/libs/ - you can use require("LifeBoatAPI") to get this, and use all the LifeBoatAPI.<functions>!

require("Utils.MyIoUtils")
require("Utils.MyBasicUtils")
require("Utils.MyPid")
require("Utils.MyVector2")
require("LifeBoatAPI")

local INPUT_THRESHOLD = 0.1

local Target, TargetAlt, TargetHeading, PrevAlt

local tgtPulse = Pulse:new()
local altPulse = Pulse:new()
local headingHoldPulse = Pulse:new()

local pidAlt = PID:new(property.getNumber("AltP") or 70
    , property.getNumber("AltI") or 0.001
    , property.getNumber("AltD") or 30
    , 0, -1000, 1000)

-- Initialize the PID objects
local pidPitch = PID:new(0.1, 0.01, 0.01, 0, -1000, 1000)
local pidRoll = PID:new(0.1, 0.01, 0.01, 0, -1000, 1000)
local pidYaw = PID:new(0.1, 0.01, 0.01, 0, -1000, 1000)

-- Constants for airplane performance limitations
local MAX_BANK_ANGLE = LifeBoatAPI.LBMaths.lbmaths_degsToRads * 45 -- degrees
local MAX_PITCH_ANGLE = LifeBoatAPI.LBMaths.lbmaths_degsToRads * 30 --degrees
local MAX_TURN_RATE = LifeBoatAPI.LBMaths.lbmaths_degsToRads * 10 -- degrees per second
local TURN_RATE_RAMP_UP_DEGREES = LifeBoatAPI.LBMaths.lbmaths_degsToRads * 30 -- degrees
local MAX_DESCENT_RATE = 1000 -- feet per minute
local FPS = 60 -- frames per second

function onTick()

    local pitch, roll, yaw, collective, curX, curY, curHdg, curAlt, curPitch, curRoll, airspeed, tgtX, tgtY, tgtAlt = getN(1
        , 2, 3
        , 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14)
    local altHold, headingHold, positionHold, goToTgtAlt, goToTgtPos, planeMode = getB(1, 2, 3, 4, 5, 6)

    curHdg = LifeBoatAPI.LBMaths.lbmaths_compassToAzimuth(curHdg)
    curRoll = LifeBoatAPI.LBMaths.lbmaths_tiltSensorToElevation(curRoll)

    local curPos = Vector2:new(curX, curY)

    local outPitch, outRoll, outYaw, outCollective

    local verticalVelocity = curAlt - PrevAlt
    PrevAlt = curAlt

    if tgtPulse(goToTgtPos) then
        Target = Vector2:new(tgtX, tgtY)
    end
    if headingHoldPulse(headingHold) then
        TargetHeading = curHdg
    end
    if altPulse(altHold) or goToTgtAlt then
        TargetAlt = tgtAlt
    end

    if planeMode then
        if math.abs(yaw) > INPUT_THRESHOLD or math.abs(roll) > INPUT_THRESHOLD then
            Target = nil
            TargetHeading = nil
            goToTgtPos = false
            headingHold = false
        elseif Target == nil then
            Target = curPos
        end
        if math.abs(pitch) > INPUT_THRESHOLD then
            TargetAlt = nil
            altHold = false
        elseif TargetAlt == nil then
            TargetAlt = curAlt + verticalVelocity
        end
    else
        if math.abs(pitch) > INPUT_THRESHOLD or math.abs(roll) > INPUT_THRESHOLD then
            Target = nil
            goToTgtPos = false
        elseif Target == nil then
            Target = curPos
        end
        if math.abs(yaw) > INPUT_THRESHOLD then
            TargetHeading = nil
            headingHold = false
        elseif TargetAlt == nil then
            TargetHeading = curHdg
        end
        if math.abs(collective) > INPUT_THRESHOLD then
            TargetAlt = nil
            altHold = false
        elseif TargetAlt == nil then
            TargetAlt = curAlt + verticalVelocity
        end
    end



    local upDown = 0
    if altHold and 'number' == type(TargetAlt) then
        upDown = pidAlt:update(TargetAlt, curAlt)
        outCollective = upDown
    end

    if positionHold or goToTgtPos then
        ---TODO
        TargetHeading = curPos.angle(Target)
    end

    if headingHold then
        local remainingDegrees = TargetHeading ~= nil and TargetHeading - curHdg or 0
        local desiredTurnRate
        if remainingDegrees <= TURN_RATE_RAMP_UP_DEGREES then
            desiredTurnRate = MAX_TURN_RATE * remainingDegrees / TURN_RATE_RAMP_UP_DEGREES
        else
            desiredTurnRate = MAX_TURN_RATE
        end
        outYaw = desiredTurnRate
    end




    if planeMode then
        outPitch, outRoll, outYaw = doPlaneControls(curHdg, TargetHeading, curAlt, upDown, airspeed, curRoll)
        outCollective = 1
    end

    outN(1, outPitch, outRoll, outYaw, outCollective)
end

local previousHeading, previousAltitude = 0, 0
-- Function to control an airplane through an ideal turn
function doPlaneControls(heading, targetHeading, altitude, desiredClimbRate, airspeed, currentBankAngle)
    -- Calculate current turn rate from heading and elapsed time
    local currentTurnRate = (heading - previousHeading) / (1 / FPS)
    previousHeading = heading

    -- Calculate desired turn rate
    local remainingDegrees = targetHeading ~= nil and targetHeading - heading or 0
    local desiredTurnRate
    if remainingDegrees <= TURN_RATE_RAMP_UP_DEGREES then
        desiredTurnRate = MAX_TURN_RATE * remainingDegrees / TURN_RATE_RAMP_UP_DEGREES
    else
        desiredTurnRate = MAX_TURN_RATE
    end

    -- Calculate desired bank angle from desired turn rate and airspeed
    local airspeedFactor = 1 + (airspeed - 100) / 1000 -- adjust airspeedFactor based on airspeed
    local desiredBankAngle = airspeedFactor * desiredTurnRate * MAX_BANK_ANGLE / MAX_TURN_RATE

    local currentClimbRate = (altitude - previousAltitude) / (1 / FPS)

    -- Update PID control objects
    local aileronDeflection = pidRoll:update(desiredBankAngle * 1000, currentBankAngle * 1000) / 1000
    local rudderDeflection = pidYaw:update(desiredTurnRate * 1000, currentTurnRate * 1000) / 1000
    local elevatorDeflection = pidPitch:update(desiredClimbRate * 1000, currentClimbRate * 1000) / 1000

    return elevatorDeflection, aileronDeflection, rudderDeflection
end
