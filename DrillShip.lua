-- Author: Archimagus
-- GitHub: <GithubLink>
-- Workshop: <WorkshopLink>
--
--- Developed using LifeBoatAPI - Stormworks Lua plugin for VSCode - https://code.visualstudio.com/download (search "Stormworks Lua with LifeboatAPI" extension)
--- If you have any issues, please report them here: https://github.com/nameouschangey/STORMWORKS_VSCodeExtension/issues - by Nameous Changey


--[====[ HOTKEYS ]====]
-- Press F7 to build the project, copy the output from /_build/out/ into the game to use
-- Remember to set your Author name etc. in the settings: CTRL+COMMA

-- require("LifeBoatAPI.Tickable.LBTouchScreen")
-- require("Utils.StateMachine")
require("LifeBoatAPI.Tickable.LBStateMachine")

local gripperRailUp = false
local gripperRailDown = false
local gripperAngle = 1
local gripperPipeVelocity = 0
local gripperClamp = false
local joinerJoin = false

local grabPipeToggled = false
local startDrillingToggled = false
local adjustLeftToggled = false
local adjustRightToggled = false
local mergeButtonToggled = false

-- local grabPipeButton = LifeBoatAPI.LBTouchScreen:lbtouchscreen_newButton_Minimalist(0, 0, 40, 20, "grabPipe")

local grabberWatch = function(s)
    gripperAngle = -1
    gripperClamp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailDown = false
    else
        gripperRailDown = false
        gripperRailUp = false
    end
    if (grabPipeToggled) then
        return "grabPipe"
    end
end
local grabberStuck = function(s)
    gripperAngle = 1
    gripperClamp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailDown = false
    else
        gripperRailDown = false
        gripperRailUp = false
    end
end
local grabPipe = function(s)
    gripperAngle = -1
    gripperClamp = true
    if ticks > 60 then
        gripperRailUp = true
    end
    if (gripperClamped) then
        return "positionPipe"
    end
    if (gripperRailPosition > 2) then
        return "grabberStuck"
    end
end
local positionPipe = function(s)
    gripperRailUp = false
    gripperRailDown = true
    gripperAngle = 1

    if startDrillingToggled then
        return "grabberWatch"
    end
end


local grabberMachine = LifeBoatAPI.LBStateMachine:new(grabberWatch)
grabberMachine:lbstatemachine_addState("grabberWatch", grabberWatch)
grabberMachine:lbstatemachine_addState("grabPipe", grabPipe)
grabberMachine:lbstatemachine_addState("positionPipe", positionPipe)
grabberMachine:lbstatemachine_addState("grabberStuck", grabberStuck)

-- local grabberMachine = MyUtils.StateMachine:new("grabberWatch", grabberWatch)

-- MyUtils.grabberMachine:addState("grabPipe", grabPipe)
-- MyUtils.grabberMachine:addState("positionPipe", positionPipe)
-- MyUtils.grabberMachine:addState("grabberStuck", grabberStuck)

local lockWellHead = false
function onTick()
    -- LifeBoatAPI.LBTouchScreen:lbtouchscreen_onTick()
    isPressed1 = input.getBool(1)
    isPressed2 = input.getBool(2)

    screenWidth = input.getNumber(1)
    screenHeight = input.getNumber(2)

    input1X = input.getNumber(3)
    input1Y = input.getNumber(4)
    input2X = input.getNumber(5)
    input2Y = input.getNumber(6)

    barrelAngle = input.getNumber(7)
    gripperRailPosition = input.getNumber(8)
    spindleRailPosition = input.getNumber(9)
    headWinchPosition = input.getNumber(10)

    gripperClamped = input.getBool(3)
    connectorClamped = input.getBool(4)
    connectorAligned = input.getBool(5)
    spindleClamped = input.getBool(6)


    drillDepth = input.getNumber(31)
    wellDepth = input.getNumber(32)
    wellHeadLocked = input.getBool(32)


    grabberMachine:lbstatemachine_onTick()

    updateButtons()

    rampNumber(gripperPipeVelocity, adjustRightToggled, adjustLeftToggled)

    output.setBool(1, gripperRailUp)
    output.setBool(2, gripperRailDown)
    output.setBool(3, gripperClamp)
    output.setBool(4, joinerJoin)
    output.setBool(5, adjustLeftToggled)

    output.setNumber(1, gripperAngle)
    output.setNumber(2, gripperPipeVelocity)

    output.setBool(31, lockWellHead)
end

function onDraw()
    -- Draw the screen
    -- screen.setColor(0, 0, 0)
    -- screen.drawClear()
    -- screen.setColor(255, 255, 255)
    screen.drawText(1, 10, "Current State: " .. tostring(grabberMachine.currentState))
    screen.drawText(1, 20, "grabPipeToggled: " .. tostring(grabPipeToggled))
    -- screen.drawText(1, 30, "grabPipeButton: " .. tostring(grabPipeButton:lbbutton_isHeld()))

    drawButtons();
end

function updateButtons()
    if (isPressed1 and isInRect(43, 56, 12, 18, input1X, input1Y)) then
        adjustLeftToggled = true
    else
        adjustLeftToggled = false
    end

    if (isPressed1 and isInRect(63, 55, 16, 19, input1X, input1Y)) then
        adjustRightToggled = true
    else
        adjustRightToggled = false
    end

    if (connectorAligned and isPressed1 and isInRect(92, 70, 39, 19, input1X, input1Y)) then
        mergeButtonToggled = true
    else
        mergeButtonToggled = false
    end

    if (isPressed1 and isInRect(92, 30, 39, 19, input1X, input1Y)) then
        grabPipeToggled = true
    else
        grabPipeToggled = false
    end

    if (isPressed1 and isInRect(92, 10, 39, 19, input1X, input1Y)) then
        startDrillingToggled = true
    else
        startDrillingToggled = false
    end
end

function drawButtons()
    if adjustLeftToggled then
        screen.setColor(13, 34, 39)
    else
        screen.setColor(73, 45, 0)
    end
    cx = 49
    cy = 65
    angle = -1.58
    p1 = rotatePoint(cx, cy, angle, 43, 74)
    p2 = rotatePoint(cx, cy, angle, 49, 56)
    p3 = rotatePoint(cx, cy, angle, 55, 74)
    screen.drawTriangleF(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)

    if adjustRightToggled then
        screen.setColor(13, 34, 39)
    else
        screen.setColor(73, 45, 0)
    end
    cx = 71
    cy = 64.5
    angle = 1.57
    p1 = rotatePoint(cx, cy, angle, 63, 74)
    p2 = rotatePoint(cx, cy, angle, 71, 55)
    p3 = rotatePoint(cx, cy, angle, 79, 74)
    screen.drawTriangleF(p1.x, p1.y, p2.x, p2.y, p3.x, p3.y)

    if mergeButtonToggled then
        screen.setColor(255, 255, 255)
    else
        if connectorAligned then
            screen.setColor(0, 255, 0)
            screen.drawTextBox(97, 70, 39, 19, 'join', 0, 0)
        else
            screen.setColor(96, 96, 96)
            screen.drawRect(95, 70, 45, 19)
        end
    end

    if grabPipeToggled then
        screen.setColor(255, 255, 255)
    else
        screen.setColor(96, 96, 96)
    end
    screen.drawTextBox(92, 30, 39, 19, 'grab', 0, 0)


    if startDrillingToggled then
        screen.setColor(255, 255, 255)
    else
        screen.setColor(96, 96, 96)
    end
    screen.drawTextBox(92, 10, 39, 19, 'drill', 0, 0)
end

function isInRect(x, y, w, h, px, py)
    return px >= x and px <= x + w and py >= y and py <= y + h
end

function rotatePoint(cx, cy, angle, px, py)
    s = math.sin(angle)
    c = math.cos(angle)
    px = px - cx
    py = py - cy
    xnew = px * c - py * s
    ynew = px * s + py * c
    px = xnew + cx
    py = ynew + cy
    return { x = px, y = py }
end

function rampNumber(value, up, down)
    if up then
        return math.min(value + 0.01, 1)
    elseif down then
        return math.max(value - 0.01, -1)
    else
        return math.abs(value) < 0.01 and 0 or value > 0 and value - 0.01 or value + 0.01
    end
end
