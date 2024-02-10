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


require("Utils.MyIoUtils")
require("Utils.StateMachine")
require("LifeBoatAPI")

local GrabberStates = {
    grabberWatchState = 0,
    grabPipeState = 1,
    grabberStuckState = 2,
    positionPipeState = 3,
}

local DrillStates = {
    drillRetractState = 0,
    drillState = 1,
}

local gripperRailUp = false
local gripperRailDown = false
local gripperAngle = 1
local gripperPipeVelocity = 0
local gripperClamp = false
local joinerJoin = false

local lockWellHead = false
local spindleLock = false
local spindleUp = false
local spindleDown = false
local slurryPump = false
local drillSpeed = 0


local grabPipeToggled = false
local startDrillingToggled = false
local abortDrillingToggled = false
local adjustLeftToggled = false
local adjustRightToggled = false
local mergeButtonToggled = false

local grabPipeButton = LifeBoatAPI.LBTouchScreen:lbtouchscreen_newButton_Minimalist(0, 0, 40, 20, "grab")
local grabberWatch = function(s)
    gripperAngle = -1
    gripperClamp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailUp = true
    else
        gripperRailDown = false
        gripperRailUp = false
    end
    if (grabPipeToggled) then
        return DrillStates.grabPipeState
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
local grabPipe = function(self)
    gripperAngle = 1
    gripperClamp = true
    if self.ticks > 90 then
        gripperRailUp = true
    end
    if (gripperClamped) then
        return GrabberStates.positionPipeState
    end
    if (gripperRailPosition > 2) then
        return GrabberStates.grabberStuckState
    end
end
local positionPipe = function(s)
    gripperRailUp = false
    gripperRailDown = true
    gripperAngle = -1

    if startDrillingToggled then
        return GrabberStates.grabberWatchState
    end
end

local drill = function(s)
    if abortDrillingToggled or spindleRailPosition <= -0.75 then
        return DrillStates.drillRetractState
    end

    spindleLock = true
    spindleDown = true
    if spindleClamped and wellHeadLocked then
        slurryPump = true
        drillSpeed = 1
    else
        slurryPump = false
        drillSpeed = 0
    end
end

local drillRetract = function(s)
    spindleLock = false
    spindleUp = true
    slurryPump = false
    drillSpeed = 0

    if startDrillingToggled then
        return DrillStates.drillState
    end
end

local grabberMachine = MyUtils.StateMachine:new(GrabberStates.grabberWatchState, grabberWatch)
grabberMachine:addState(GrabberStates.grabPipeState, grabPipe)
grabberMachine:addState(GrabberStates.positionPipeState, positionPipe)
grabberMachine:addState(GrabberStates.grabberStuckState, grabberStuck)

local drillMachine = MyUtils.StateMachine:new(DrillStates.drillRetractState, drillRetract)
drillMachine:addState(DrillStates.drillState, drill)

function onTick()
    LifeBoatAPI.LBTouchScreen:lbtouchscreen_onTick()
    isPressed1, isPressed2, gripperClamped, connectorClamped, connectorAligned, spindleClamped, wellHeadLocked = getB(1,
        2, 3, 4, 5, 6, 32)
    screenWidth, screenHeight, input1X, input1Y, input2X, input2Y, barrelAngle, gripperRailPosition, spindleRailPosition, headWinchPosition, drillDepth, wellDepth =
        getN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 31, 32)

    grabberMachine:onTick()

    updateButtons()

    gripperPipeVelocity = rampNumber(gripperPipeVelocity, adjustRightToggled, adjustLeftToggled)

    outB(1, gripperRailUp, gripperRailDown, gripperClamp, joinerJoin, spindleUp, spindleDown, spindleLock, slurryPump)
    outB(31, lockWellHead)
    outN(1, gripperAngle, gripperPipeVelocity, drillSpeed)
end

function onDraw()
    grabPipeButton:lbbutton_draw()
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
            screen.drawRect(95, 70, 45, 19)
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
    screen.drawRect(92, 30, 39, 19)
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
        value = math.min(value + 0.01, 1)
        return value
    end
    if down then
        value = math.max(value - 0.01, -1)
        return value
    end
    value = 0
    return value
end
