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


require("Utils")
require("LifeBoatAPI")

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
indexBit = 0

drillButton = addElement({ x = 0, y = 2, w = 4, t = "Drill", tg = false })
grabPipeButton = addElement({ x = 0, y = 0, w = 4, t = "Grab", p = false })
adjustJoinerLeftButton = addElement({ x = 4, y = 6, w = 1, t = "<", p = false })
adjustJoinerRightButton = addElement({ x = 5, y = 6, w = 1, t = ">", p = false })
mergeButton = addElement({ x = 6, y = 6, w = 5, t = "Join", p = false, st = { drawBG = 1 } })
adjustGripperLeftButton = addElement({ x = 11, y = 6, w = 1, t = "<", p = false })
adjustGripperRightButton = addElement({ x = 12, y = 6, w = 1, t = ">", p = false })

bitDepthLabel = addElement({ x = 0, y = 7, w = 5, st = { drawBG = 0, drawBorder = 0, ha = 1, fg = ArchMaroon }, })
winchLabel = addElement({ x = 0, y = 8, w = 5, st = { drawBG = 0, drawBorder = 0, ha = 1, fg = ArchMaroon }, })


barrelRightButton = addElement({ x = 1, y = 1, w = 1, t = ">", p = false })
barrelLeftButton = addElement({ x = 0, y = 1, w = 1, t = "<", p = false })

grabberWatchState = function()
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
        indexBit = 1
        return grabPipeState
    end
end
grabberStuckState = function()
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
        return grabPipeState
    end
end
grabPipeState = function(self)
    indexBit = 0
    gripperAngle = 1
    gripperClamp = true
    if self.ticks > 90 then
        gripperRailUp = true
    end
    if (gripperClamped) then
        return positionPipeState
    end
    if (gripperRailPosition > 0.49 or self.ticks > 200) then
        return grabberStuckState
    end
end
positionPipeState = function(self)
    gripperRailUp = false
    gripperRailDown = true
    gripperAngle = -1

    if self.ticks < 60 then
        adjustGripperRightButton.p = true
    end

    mergeButton.t = connectorAligned and "Join" or ""
    mergeButton.st.fg = connectorAligned and ArchGreen or ArchGray
    mergeButton.visible = true
    adjustGripperLeftButton.visible = true
    adjustGripperRightButton.visible = true
    adjustJoinerLeftButton.visible = true
    adjustJoinerRightButton.visible = true
    if drillButton.p then
        return grabberWatchState
    end
end

drillState = function()
    if not drillButton.tg or spindleRailPosition <= -0.304 then
        drillButton.t = "Drill"
        drillButton.tg = false
        return drillRetractState
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

drillRetractState = function()
    spindleLock = false
    spindleUp = true
    spindleDown = false
    slurryPump = false
    drillSpeed = 0

    if drillButton.tg then
        drillButton.t = "Retract"
        return drillState
    end
end

grabberMachine = ArchStateMachine:new(grabberWatchState)
drillMachine = ArchStateMachine:new(drillRetractState)



function onTick()
    gripperClamped, connectorClamped, connectorAligned, spindleClamped, wellHeadLocked = getB(3, 4, 5, 6, 32)
    barrelAngle, gripperRailPosition, spindleRailPosition, headWinchPosition, bitDistance, drillDepth, wellDepth =
        getN(7, 8, 9, 10, 11, 31, 32)


    mergeButton.visible = grabberMachine.currentState == positionPipeState
    adjustGripperLeftButton.visible = grabberMachine.currentState == positionPipeState
    adjustGripperRightButton.visible = grabberMachine.currentState == positionPipeState
    adjustJoinerLeftButton.visible = grabberMachine.currentState == positionPipeState
    adjustJoinerRightButton.visible = grabberMachine.currentState == positionPipeState

    tickUI()

    grabberMachine:onTick()
    drillMachine:onTick()

    gripperPipeVelocity = ArchRampNumber(gripperPipeVelocity, adjustGripperRightButton.p, adjustGripperLeftButton.p)
    joinerPipeVelocity = ArchRampNumber(joinerPipeVelocity, adjustJoinerRightButton.p, adjustJoinerLeftButton.p)

    bitWinchDown = drillMachine.currentState == drillState and bitDistance > headWinchPosition - 0.1

    winchLabel.t = "Winch:" .. string.format("%.2f", headWinchPosition) .. "m"
    bitDepthLabel.t = "Bit:" .. string.format("%.2f", bitDistance) .. "m"

    outB(1, gripperRailUp, gripperRailDown, gripperClamp, mergeButton.p, spindleUp, spindleDown, spindleLock,
        slurryPump, bitWinchDown)
    outN(1, gripperAngle, gripperPipeVelocity, joinerPipeVelocity, drillSpeed, joinerPipeVelocity)

    -- Outputs for other scripts or for across the composite
    outB(21, barrelLeftButton.p, barrelRightButton.p)
    outN(20, barrelAngle, indexBit)
    outB(31, lockWellHead)
end

function onDraw()
    drawUI()
end
