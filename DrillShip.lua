-- DrillShip.lua
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
require("Utils.MyUITools")
require("LifeBoatAPI")

GrabberStates = {
    grabberWatchState = 'gw',
    grabPipeState = 'gp',
    grabberStuckState = 'gs',
    positionPipeState = 'pp',
}

DrillStates = {
    drillRetractState = 'dr',
    drillState = 'd',
}

gripperRailUp = false
gripperRailDown = false
gripperAngle = 1
gripperPipeVelocity = 0
joinerPipeVelocity = 0
gripperClamp = false

lockWellHead = false
spindleLock = false
spindleUp = false
spindleDown = false
slurryPump = false
drillSpeed = 0
barrelIndex = 0

drillButton = addElement({ x = 0, y = 0, w = 4, t = "Drill", tg = false })
grabPipeButton = addElement({ x = 5, y = 3, w = 4, t = "Grab", p = false })
adjustGripperLeftButton = addElement({ x = 9, y = 6, w = 1, t = "<", p = false })
adjustGripperRightButton = addElement({ x = 10, y = 6, w = 1, t = ">", p = false })
mergeButton = addElement({ x = 5, y = 6, w = 4, t = "Join", p = false, st = { drawBG = 1 } })
adjustJoinerLeftButton = addElement({ x = 3, y = 6, w = 1, t = "<", p = false })
adjustJoinerRightButton = addElement({ x = 4, y = 6, w = 1, t = ">", p = false })

bitIndexLabel = addElement({ x = 3, y = 1, w = 4, t = "Bit:0", st = { drawBorder = 0, drawBG = 0 } })

addElement({
    x = 1,
    y = 1,
    w = 1,
    t = ">",
    p = false,
    cf = function()
        barrelIndex = (barrelIndex + 1) % 36
        bitIndexLabel.t = "Bit:" .. tostring(barrelIndex)
    end
})
addElement({
    x = 0,
    y = 1,
    w = 1,
    t = "<",
    p = false,
    cf = function()
        barrelIndex = barrelIndex - 1
        if barrelIndex < 0 then
            barrelIndex = 35
        end
        bitIndexLabel.t = "Bit:" .. tostring(barrelIndex)
    end
})

grabberWatch = function(s)
    gripperAngle = -1
    gripperClamp = false
    gripperRailDown = false
    gripperRailUp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailUp = true
    end
    if (grabPipeButton.p) then
        return GrabberStates.grabPipeState
    end
end
grabberStuck = function(s)
    gripperAngle = 1
    gripperClamp = false
    gripperRailDown = false
    gripperRailUp = false
    if gripperRailPosition > 0.1 then
        gripperRailDown = true
    elseif gripperRailPosition < -0.1 then
        gripperRailUp = false
    end
    if grabPipeButton.p then
        return GrabberStates.grabPipeState
    end
end
grabPipe = function(self)
    gripperAngle = 1
    gripperClamp = true
    if self.ticks > 90 then
        gripperRailUp = true
    end
    if (gripperClamped) then
        return GrabberStates.positionPipeState
    end
    if (gripperRailPosition > 0.49 or self.ticks > 200) then
        return GrabberStates.grabberStuckState
    end
end
positionPipe = function(s)
    gripperRailUp = false
    gripperRailDown = true
    gripperAngle = -1
    mergeButton.t = connectorAligned and "Join" or ""
    mergeButton.st.drawBG = connectorAligned and 2 or 0
    if drillButton.p then
        return GrabberStates.grabberWatchState
    end
end

drill = function(s)
    if not drillButton.tg or spindleRailPosition <= -0.183 then
        drillButton.t = "Drill"
        drillButton.tg = false
        return DrillStates.drillRetractState
    end

    spindleLock = true
    spindleDown = true
    spindleUp = false
    if spindleClamped and wellHeadLocked then
        slurryPump = true
        drillSpeed = 1
    else
        slurryPump = false
        drillSpeed = 0
    end
end

drillRetract = function(s)
    spindleLock = false
    spindleUp = true
    spindleDown = false
    slurryPump = false
    drillSpeed = 0

    if drillButton.tg then
        drillButton.t = "Retract"
        return DrillStates.drillState
    end
end

grabberMachine = MyUtils.StateMachine:new(GrabberStates.grabberWatchState, grabberWatch)
grabberMachine:addState(GrabberStates.grabPipeState, grabPipe)
grabberMachine:addState(GrabberStates.positionPipeState, positionPipe)
grabberMachine:addState(GrabberStates.grabberStuckState, grabberStuck)

drillMachine = MyUtils.StateMachine:new(DrillStates.drillRetractState, drillRetract)
drillMachine:addState(DrillStates.drillState, drill)

function onTick()
    isPressed1, isPressed2, gripperClamped, connectorClamped, connectorAligned, spindleClamped, wellHeadLocked = getB(1,
        2, 3, 4, 5, 6, 32)
    screenWidth, screenHeight, input1X, input1Y, input2X, input2Y, barrelAngle, gripperRailPosition, spindleRailPosition, headWinchPosition, drillDepth, wellDepth =
        getN(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 31, 32)

    tickUI()

    grabberMachine:onTick()
    drillMachine:onTick()

    gripperPipeVelocity = rampNumber(gripperPipeVelocity, adjustGripperRightButton.p, adjustGripperLeftButton.p)
    joinerPipeVelocity = rampNumber(joinerPipeVelocity, adjustJoinerRightButton.p, adjustJoinerLeftButton.b)

    barrelTarget = barrelIndex / 36;
    barrelVelocity = (barrelTarget - barrelAngle) * 10;

    outB(1, gripperRailUp, gripperRailDown, gripperClamp, mergeButton.p, spindleUp, spindleDown, spindleLock,
        slurryPump)
    outB(31, lockWellHead)
    outN(1, gripperAngle, gripperPipeVelocity, joinerPipeVelocity, drillSpeed, barrelVelocity, joinerPipeVelocity)
end

function onDraw()
    drawUI()
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
